import logging
import random
import re
import time

import nba_api
from datetime import datetime, timedelta, timezone
from nba_api.live.nba.endpoints import boxscore, playbyplay
from nba_api.stats.endpoints import commonplayoffseries, scoreboardv2

from splash_nba.endpoints.routes.games.scoreboard.services.utils.stats import game_stats
from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.lib.games.fetch_new_games import fetch_games_for_date_range
from splash_nba.lib.games.fetch_play_by_play import update_play_by_play
from splash_nba.lib.games.nba_cup import update_current_cup, flag_cup_games
from splash_nba.lib.games.playoff_bracket import reformat_series_data, get_playoff_bracket_data
from splash_nba.lib.teams.update_team_games import update_team_games
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS, CURR_SEASON

teams = {
    1610612737: 'Atlanta Hawks',
    1610612738: 'Boston Celtics',
    1610612739: 'Cleveland Cavaliers',
    1610612740: 'New Orleans Pelicans',
    1610612741: 'Chicago Bulls',
    1610612742: 'Dallas Mavericks',
    1610612743: 'Denver Nuggets',
    1610612744: 'Golden State Warriors',
    1610612745: 'Houston Rockets',
    1610612746: 'Los Angeles Clippers',
    1610612747: 'Los Angeles Lakers',
    1610612748: 'Miami Heat',
    1610612749: 'Milwaukee Bucks',
    1610612750: 'Minnesota Timberwolves',
    1610612751: 'Brooklyn Nets',
    1610612752: 'New York Knicks',
    1610612753: 'Orlando Magic',
    1610612754: 'Indiana Pacers',
    1610612755: 'Philadelphia 76ers',
    1610612756: 'Phoenix Suns',
    1610612757: 'Portland Trail Blazers',
    1610612758: 'Sacramento Kings',
    1610612759: 'San Antonio Spurs',
    1610612760: 'Oklahoma City Thunder',
    1610612761: 'Toronto Raptors',
    1610612762: 'Utah Jazz',
    1610612763: 'Memphis Grizzlies',
    1610612764: 'Washington Wizards',
    1610612765: 'Detroit Pistons',
    1610612766: 'Charlotte Hornets',
}


def format_duration(input_str):
    if input_str is None:
        return ""

    try:
        # Regular expression to match 'PT' followed by minutes and seconds
        match = re.match(r'PT(\d+)M(\d+)\.(\d+)S', input_str)

        if match:
            minutes = int(match.group(1))  # Convert minutes to int
            seconds = int(match.group(2))  # Convert seconds to int
            tenths = match.group(3)[0]  # Take only the first digit of the fraction for tenths

            if minutes == 0:  # Less than a minute left, show seconds and tenths
                return f":{seconds}.{tenths}"
            else:  # Regular minutes and seconds format
                return f"{minutes}:{seconds:02d}"  # Format seconds with leading zero if necessary
    except Exception:
        return ""

    return input_str  # Return original string if no match is found


def format_adv_stats(summary, adv_stats=None):
    # Check for advanced stats
    team_adv = {"home": {}, "away": {}}
    player_adv = {"home": [], "away": []}
    if adv_stats is not None:
        if "TeamStats" in adv_stats:
            for team in adv_stats["TeamStats"]:
                if team["TEAM_ID"] == summary["GameSummary"][0]["HOME_TEAM_ID"]:
                    team_adv["home"] = team
                else:
                    team_adv["away"] = team
        if "PlayerStats" in adv_stats:
            for player in adv_stats["PlayerStats"]:
                if player["TEAM_ID"] == summary["GameSummary"][0]["HOME_TEAM_ID"]:
                    player_adv["home"].append(player)
                else:
                    player_adv["away"].append(player)

    adv = {
        "home": {"team": team_adv["home"], "players": player_adv["home"]},
        "away": {"team": team_adv["away"], "players": player_adv["away"]}
    }

    return adv


def get_game_status(summary):
    if 'GameSummary' not in summary:
        return ''

    try:
        game_summary = summary['GameSummary'][0]
    except Exception:
        return ''

    status = game_summary.get('GAME_STATUS_ID', 0)

    if status == 3:
        return 3
    if status == 2:
        return 1
    if status == 1:
        return 2

    return 1


def get_game_clock(summary, boxscore):
    if boxscore.get('gameStatusText', '') == 'pregame':
        return 'Pregame'

    if 'GameSummary' not in summary:
        return ''

    try:
        game_summary = summary['GameSummary'][0]
    except Exception:
        return ''

    status = boxscore.get('gameStatus', game_summary.get('GAME_STATUS_ID', 0))
    period = boxscore.get('period', game_summary.get('LIVE_PERIOD', 0))

    try:
        clock = format_duration(boxscore.get('gameClock', ''))
    except Exception:
        clock = game_summary.get('LIVE_PC_TIME', '')

    if clock == "":
        clock = game_summary.get('LIVE_PC_TIME', '')

    if status == 1:
        # Upcoming
        if clock == "     ":
            return "Pregame"
        else:
            return boxscore.get('gameStatusText', game_summary.get('GAME_STATUS_TEXT', '')).replace(" ET", "").replace(" ", "")
    elif status == 2:
        # End Quarter
        if clock == ":0.0" or clock == "     ":
            if period == 1:
                return 'End 1st'
            elif period == 2:
                return 'HALF'
            elif period == 3:
                return 'End 3rd'
            elif period == 4:
                return 'Final'
            elif period == 5:
                return 'Final/OT'
            else:
                return f'Final/{period - 4}OT'
        else:
            # Game in-progress
            if period <= 4:
                if period == 1:
                    return f'{period}st {clock}'
                elif period == 2:
                    return f'{period}nd {clock}'
                elif period == 3:
                    return f'{period}rd {clock}'
                elif period == 4:
                    return f'{period}th {clock}'
                else:
                    return ''
            elif period == 5:
                return f'OT {clock}'
            else:
                return f'{period - 4}OT {clock}'

    elif status == 3:
        # Game Final
        if period == 4:
            return 'Final'
        elif period == 5:
            return 'Final/OT'
        else:
            return f'Final/{period - 4}OT'
    else:
        return ''


def expected_lineup_data(team_id):
    try:
        team = get_mongo_collection('nba_teams').find_one({'TEAM_ID': team_id}, {'LAST_STARTING_LINEUP': 1})
        last_lineup = team.get('LAST_STARTING_LINEUP', [])
    except Exception as e:
        last_lineup = []
        logging.error(e)

    lineup_final = []

    for player in last_lineup:
        lineup_final.append({
            "personId": str(player["personId"]) if "personId" in player else None,
            "name": player["name"] if "name" in player else None,
            "position": player["position"] if "position" in player else None,
        })

    return lineup_final


def lineup_data(player):
    return {
        "personId": str(player["personId"]) if "personId" in player else None,
        "name": player["nameI"] if "nameI" in player else None,
        "number": player["jerseyNum"] if "jerseyNum" in player else None,
        "position": player["position"] if "position" in player else None
    }


def matchup_details(summary, boxscore):
    matchup = f'{boxscore.get("awayTeam", {}).get("teamName", "Away")} @ {boxscore.get("homeTeam", {}).get("teamName", "Home")}'
    officials = ""
    location = ""
    team_records = {"home": "0-0", "away": "0-0"}
    lineups = {"home": [], "away": []}
    inactive = {"home": "", "away": ""}
    last_meeting = {}
    series = {"home": 0, "away": 0}

    if 'LineScore' in summary:
        try:
            home_id = str(summary["GameSummary"][0]["HOME_TEAM_ID"])
            away_id = str(summary["GameSummary"][0]["VISITOR_TEAM_ID"])
            home_linescore = summary["LineScore"][0] if str(summary["LineScore"][0]["TEAM_ID"]) == home_id else summary["LineScore"][1]
            away_linescore = summary["LineScore"][0] if str(summary["LineScore"][0]["TEAM_ID"]) == away_id else summary["LineScore"][1]
            matchup = f'{away_linescore["TEAM_NICKNAME"]} @ {home_linescore["TEAM_NICKNAME"]}'
            team_records["home"] = home_linescore["TEAM_WINS_LOSSES"]
            team_records["away"] = away_linescore["TEAM_WINS_LOSSES"]
        except Exception:
            matchup = 'Away @ Home'

    # Officials
    if "officials" in boxscore:
        officials = ", ".join([ref["name"] for ref in boxscore["officials"]])

    # Arena
    if "arena" in boxscore:
        name = boxscore["arena"]["arenaName"] if "arenaName" in boxscore["arena"] else ""
        city = boxscore["arena"]["arenaCity"] if "arenaCity" in boxscore["arena"] else ""
        state = boxscore["arena"]["arenaState"] if "arenaState" in boxscore["arena"] else ""
        location = f'{name}, {city}, {state}'

    # Lineups
    if "homeTeam" in boxscore:
        if "players" in boxscore["homeTeam"]:
            lineups["home"] = [lineup_data(player) for player in boxscore["homeTeam"]["players"] if player["starter"] == "1"]
            order = [4, 3, 0, 2, 1]  # PG, SG, SF, C, PF
            lineups["home"] = [lineups["home"][i] for i in order]
    else:
        try:
            lineups["home"] = expected_lineup_data(summary["GameSummary"][0]["HOME_TEAM_ID"])
            order = [4, 3, 0, 2, 1]  # PG, SG, SF, C, PF
            lineups["home"] = [lineups["home"][i] for i in order]
        except Exception:
            lineups["home"] = []
            # logging.error(traceback.format_exc())

    if "awayTeam" in boxscore:
        if "players" in boxscore["awayTeam"]:
            lineups["away"] = [lineup_data(player) for player in boxscore["awayTeam"]["players"] if player["starter"] == "1"]
            order = [0, 2, 1, 4, 3]  # SF, C, PF, PG, SG
            lineups["away"] = [lineups["away"][i] for i in order]
    else:
        try:
            lineups["away"] = expected_lineup_data(summary["GameSummary"][0]["VISITOR_TEAM_ID"])
            order = [0, 2, 1, 4, 3]  # SF, C, PF, PG, SG
            lineups["away"] = [lineups["away"][i] for i in order]
        except Exception:
            lineups["away"] = []
            # logging.error(traceback.format_exc())

    # Inactive
    if "InactivePlayers" in summary:
        try:
            home_id = str(summary["GameSummary"][0]["HOME_TEAM_ID"])
            away_id = str(summary["GameSummary"][0]["VISITOR_TEAM_ID"])
        except Exception:
            home_id = 0
            away_id = 0

        inactive["home"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if str(player["TEAM_ID"]) == home_id])
        inactive["away"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if str(player["TEAM_ID"]) == away_id])

    if "LastMeeting" in summary:
        try:
            last_meeting["game_id"] = str(summary["LastMeeting"][0]["LAST_GAME_ID"])
            last_meeting["date"] = summary["LastMeeting"][0]["LAST_GAME_DATE_EST"]
            last_meeting["home_id"] = str(summary["LastMeeting"][0]["LAST_GAME_HOME_TEAM_ID"])
            last_meeting["home_score"] = str(summary["LastMeeting"][0]["LAST_GAME_HOME_TEAM_POINTS"])
            last_meeting["away_id"] = str(summary["LastMeeting"][0]["LAST_GAME_VISITOR_TEAM_ID"])
            last_meeting["away_score"] = str(summary["LastMeeting"][0]["LAST_GAME_VISITOR_TEAM_POINTS"])
        except Exception:
            last_meeting["game_id"] = ""
            last_meeting["date"] = ""
            last_meeting["home_id"] = ""
            last_meeting["home_score"] = ""
            last_meeting["away_id"] = ""
            last_meeting["away_score"] = ""

    if "SeasonSeries" in summary:
        try:
            series["home"] = summary["SeasonSeries"][0]["HOME_TEAM_WINS"]
            series["away"] = summary["SeasonSeries"][0]["HOME_TEAM_LOSSES"]
        except Exception:
            series["home"] = 0
            series["away"] = 0

    return {
        "matchup": matchup,
        "officials": officials,
        "location": location,
        "teamRecords": team_records,
        "lineups": lineups,
        "inactive": inactive,
        "lastMeeting": last_meeting,
        "series": series
    }


def upcoming_game(game_id):
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f'(Games Live - upcoming_game) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    summary = fetch_box_score_summary(game_id)

    try:
        game_summary = summary["GameSummary"][0]
    except Exception:
        return

    try:
        broadcast = game_summary["NATL_TV_BROADCASTER_ABBREVIATION"]
    except Exception:
        broadcast = None

    try:
        box_score = boxscore.BoxScore(proxy=PROXY, headers=HEADERS, game_id=game_id).get_dict()['game']
        games_collection.update_one(
            {'gameId': game_id},
            {'$set': {
                'gameId': str(game_summary['GAME_ID']),
                'date': game_summary['GAME_DATE_EST'][:10],
                'homeTeamId': str(game_summary['HOME_TEAM_ID']),
                'awayTeamId': str(game_summary['VISITOR_TEAM_ID']),
                'season': game_summary['SEASON'],
                'broadcast': broadcast,
                'status': 1,
                'gameClock': get_game_clock(summary, box_score),
                'matchup': matchup_details(summary, box_score),
                'pbp': [],
                'stats': {
                    "home": {"team": {}, "players": []},
                    "away": {"team": {}, "players": []},
                    "linescore": {}
                }
            }}
        )
        logging.info(f'(Games Live) Upcoming game {game_id} is up to date + Box Score.')
    except Exception:
        games_collection.update_one(
            {'gameId': game_id},
            {'$set': {
                'gameId': str(game_summary['GAME_ID']),
                'date': game_summary['GAME_DATE_EST'][:10],
                'homeTeamId': str(game_summary['HOME_TEAM_ID']),
                'awayTeamId': str(game_summary['VISITOR_TEAM_ID']),
                'season': game_summary['SEASON'],
                'broadcast': broadcast,
                'status': 1,
                'gameClock': get_game_clock(summary, {}),
                'matchup': matchup_details(summary, {}),
                'pbp': [],
                'stats': {
                    "home": {"team": {}, "players": []},
                    "away": {"team": {}, "players": []},
                    "linescore": {}
                }
            }}
        )
        logging.info(f'(Games Live) Upcoming game {game_id} is up to date.')


def in_progress_game(game_id):
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f'(Games Live - in_progress_game) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    # Summary, Box Score, PBP
    summary = fetch_box_score_summary(game_id)
    box_score = boxscore.BoxScore(proxy=PROXY, headers=HEADERS, game_id=game_id).get_dict()['game']

    try:
        actions = playbyplay.PlayByPlay(proxy=PROXY, headers=HEADERS, game_id=game_id).get_dict()['game']['actions']
        pbp = []

        for i, action in enumerate(actions):
            play_info = {
                'action': str(action.get('actionNumber', '0')),
                'clock': format_duration(action.get('clock', '')),
                'period': str(action.get('period', '0')),
                'teamId': str(action.get('teamId', '0')),
                'personId': str(action.get('personId', '0')),
                'playerNameI': str(action.get('playerNameI', '')),
                'possession': str(action.get('possession', '0')),
                'scoreHome': str(action.get('scoreHome', '')),
                'scoreAway': str(action.get('scoreAway', '')),
                'isFieldGoal': str(action.get('isFieldGoal', '0')),
                'description': str(action.get('description', '')),
                'xLegacy': str(action.get('xLegacy', '0')),
                'yLegacy': str(action.get('yLegacy', '0')),
            }

            pbp.append(play_info)
    except Exception:
        pbp = []

    # home_line_score = game_line_score[0] if game_line_score[0]['TEAM_ID'] == box_score['homeTeam']['teamId'] else game_line_score[1]
    # away_line_score = game_line_score[0] if game_line_score[0]['TEAM_ID'] == box_score['awayTeam']['teamId'] else game_line_score[1]

    try:
        broadcast = summary["GameSummary"][0]["NATL_TV_BROADCASTER_ABBREVIATION"]
    except Exception:
        broadcast = None

    # Update data
    games_collection.update_one(
        {'gameId': game_id},
        {'$set': {
            "homeTeamId": str(box_score.get('homeTeam', {}).get('teamId', 0)),
            "awayTeamId": str(box_score.get('awayTeam', {}).get('teamId', 0)),
            "homeScore": box_score.get('homeTeam', {}).get('score', None),
            "awayScore": box_score.get('awayTeam', {}).get('score', None),
            "broadcast": broadcast,
            "status": 2,
            "gameClock": get_game_clock(summary, box_score),
            "matchup": matchup_details(summary, box_score),
            "pbp": pbp,
            "stats": game_stats(2, summary, box_score, {})
            }
        }
    )
    logging.info(f'(Games Live) Updated live game {game_id} [{datetime.now()}]')


def final_game(game_id):
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f'(Games Live - in_progress_game) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    # Update team schedules with game results
    update_team_games(games_collection.find_one({'gameId': game_id}))

    # Finalize Box Score, Adv Stats, and Summary
    summary = fetch_box_score_summary(game_id)
    box_score = boxscore.BoxScore(proxy=PROXY, headers=HEADERS, game_id=game_id).get_dict()['game']
    adv = format_adv_stats(summary=summary, adv_stats=fetch_box_score_adv(game_id))

    series = {"home": 0, "away": 0}

    if "SeasonSeries" in summary:
        try:
            series["home"] = summary["SeasonSeries"][0]["HOME_TEAM_WINS"]
            series["away"] = summary["SeasonSeries"][0]["HOME_TEAM_LOSSES"]
        except Exception:
            series["home"] = 0
            series["away"] = 0

    try:
        adv_null_check = adv['home']['players'][0]['MIN'] is not None
    except Exception as e:
        logging.error(f"Error retrieving adv stats: {e}", exc_info=True)
        adv_null_check = False

    games_collection.update_one(
        {'gameId': game_id},
        {'$set': {
            'status': 3,
            'matchup.series': series,
            'stats': game_stats(3, summary, box_score, adv),
            'FINAL': adv_null_check
            }
        }
    )
    logging.info(f'(Games Live) Finalizing game {game_id}.')


def games_prev_day(offset: int = 1):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    yesterday = (datetime.today() - timedelta(days=offset)).strftime('%Y-%m-%d')

    # Else if games today + within 1 hour of first tip-off
    games_yesterday = scoreboardv2.ScoreboardV2(proxy=PROXY, headers=HEADERS, game_date=yesterday, day_offset=0).get_normalized_dict()['GameHeader']

    for game in games_yesterday:
        is_upcoming = game['GAME_STATUS_ID'] == 1
        in_progress = game['GAME_STATUS_ID'] == 2
        is_final = game['GAME_STATUS_ID'] == 3

        # If game upcoming or in-progress, check for updates
        if is_upcoming:
            upcoming_game(game["GAME_ID"])

        # IN-PROGRESS
        elif in_progress:
            in_progress_game(game["GAME_ID"])

        # If game is final, update final box score
        elif is_final:
            in_progress_game(game["GAME_ID"])
            final_game(game["GAME_ID"])


async def games_live_update():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    def parse_game_time(game_time_string):
        try:
            # Try parsing with microseconds
            return datetime.strptime(game_time_string, "%Y-%m-%dT%H:%M:%S.%fZ")
        except ValueError:
            # If microseconds are not present, try parsing without them
            return datetime.strptime(game_time_string, "%Y-%m-%dT%H:%M:%S%z")

    today = datetime.today().strftime('%Y-%m-%d')

    try:
        scoreboard = nba_api.live.nba.endpoints.scoreboard.ScoreBoard(proxy=PROXY, headers=HEADERS).get_dict()
    except Exception:
        return

    try:
        games_today = scoreboard['scoreboard']['games']
    except KeyError as e:
        logging.error(f'(Games Live) Failed to get scores for today (KeyError) [{datetime.now()}]: {e}')
        return

    # If there are no games today, set the flag to skip further updates for the rest of the day
    if not games_today:
        logging.info(
            f"(Games Live) No games found for today: {today}. Skipping updates for the rest of the day. [{datetime.now()}]")
        return

    # Check if the first game is more than 1 hour away from start time
    first_game = games_today[0]
    first_game_time_str = first_game['gameTimeUTC']
    first_game_time = parse_game_time(first_game_time_str)

    # Make current_time offset-aware in UTC
    current_time = datetime.now(timezone.utc)
    time_difference = first_game_time - current_time

    if time_difference > timedelta(hours=1):
        logging.info(f"(Games Live) First game is more than 1 hour away. Skipping updates. [{datetime.now()}]")
        return

    for game in games_today:
        game_time_str = game['gameTimeUTC']
        game_time = parse_game_time(game_time_str)
        game_time_difference = game_time - current_time
        if game_time_difference > timedelta(hours=1):
            logging.info(
                f"(Games Live) Game {game['gameId']} is more than 1 hour away. Skipping game. [{datetime.now()}]")
            continue

        is_upcoming = game['gameStatus'] == 1
        in_progress = game['gameStatus'] == 2
        is_final = game['gameStatus'] == 3

        # If game upcoming or in-progress, check for updates
        if is_upcoming:
            upcoming_game(game["gameId"])

        # IN-PROGRESS
        elif in_progress:
            in_progress_game(game["gameId"])

        # If game is final, update final box score
        elif is_final:
            # Check if the final update has already been applied
            game_doc = games_collection.find_one({"gameId": game["gameId"]}, {'FINAL': 1})
            if game_doc and game_doc.get("FINAL", False):
                logging.info(
                    f'(Games Live) Game {game["gameId"]} already finalized, skipping update. [{datetime.now()}]')
                continue  # Skip this game as it's already been finalized
            else:
                in_progress_game(game["gameId"])
                final_game(game["gameId"])


async def games_daily_update():
    """
    Runs every day at 2:00AM.\n
    Updates games, NBA Cup, and playoff data for each team.
    """
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    logging.info("Video PBP..")
    try:
        update_play_by_play()
    except Exception as e:
        logging.error(f"(Video PBP) Error fetching video PBP: {e}", exc_info=True)

    # Upcoming Games
    logging.info("Upcoming Games..")
    try:
        # Define date range
        start_date = datetime.today()
        end_date = datetime(2025, 6, 30)

        # Fetch games for each date in the range
        fetch_games_for_date_range(start_date, end_date)
    except Exception as e:
        logging.error(f"(Games Daily) Failed to fetch upcoming games: {e}", exc_info=True)

    # NBA Cup
    logging.info("NBA Cup...")
    try:
        update_current_cup()
        flag_cup_games(season=CURR_SEASON)
    except Exception as e:
        logging.error(f"(Games Daily) Failed to update NBA Cup: {e}", exc_info=True)

    # Playoffs
    logging.info("Playoffs...")
    try:
        playoff_games = commonplayoffseries.CommonPlayoffSeries(proxy=PROXY, headers=HEADERS, season=CURR_SEASON).get_normalized_dict()[
            'PlayoffSeries']
        if not playoff_games:
            logging.info("(Games Daily) No playoff games found.")
            return
        else:
            series_data = reformat_series_data(playoff_games)
            get_playoff_bracket_data(CURR_SEASON, series_data)
    except Exception as e:
        logging.error(f"(Games Daily) Failed to update playoff data: {e}", exc_info=True)


if __name__ == '__main__':
    # Define your target date as a string and convert it to a datetime object
    target_date_str = '2022-09-30'
    target_date = datetime.strptime(target_date_str, '%Y-%m-%d').date()

    # Get today's date
    today = datetime.today().date()

    # Calculate the number of days between today and the target date
    days_to_go_back = (today - target_date).days

    # Optional: Ensure the date isn't in the future
    if days_to_go_back < 1:
        print("Target date must be in the past.")
    else:
        for i in range(1, days_to_go_back + 1):
            games_prev_day(i)  # Optionally, pass an offset to change timedelta (e.g., 1 = yesterday)
            # Pause for a random time between 0.5 and 1 second
            time.sleep(random.uniform(0.5, 1.0))

    # games_live_update()
