import time
import logging
from datetime import datetime, timedelta
from nba_api.stats.endpoints import ScoreboardV2
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary


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
            "personId": str(player["PLAYER_ID"]) if "PLAYER_ID" in player else None,
            "name": player["NAME"] if "NAME" in player else None,
            "position": player["POSITION"] if "POSITION" in player else None,
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
            home_id = summary["GameSummary"][0]["HOME_TEAM_ID"]
            away_id = summary["GameSummary"][0]["VISITOR_TEAM_ID"]
            home_linescore = summary["LineScore"][0] if summary["LineScore"][0]["TEAM_ID"] == home_id else summary["LineScore"][1]
            away_linescore = summary["LineScore"][0] if summary["LineScore"][0]["TEAM_ID"] == away_id else summary["LineScore"][1]
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
            home_id = summary["GameSummary"][0]["HOME_TEAM_ID"]
            away_id = summary["GameSummary"][0]["VISITOR_TEAM_ID"]
        except Exception:
            home_id = 0
            away_id = 0

        inactive["home"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if player["TEAM_ID"] == home_id])
        inactive["away"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if player["TEAM_ID"] == away_id])

    if "LastMeeting" in summary:
        try:
            last_meeting["game_id"] = summary["LastMeeting"][0]["LAST_GAME_ID"]
            last_meeting["date"] = summary["LastMeeting"][0]["LAST_GAME_DATE_EST"]
            last_meeting["home_id"] = summary["LastMeeting"][0]["LAST_GAME_HOME_TEAM_ID"]
            last_meeting["home_score"] = summary["LastMeeting"][0]["LAST_GAME_HOME_TEAM_POINTS"]
            last_meeting["away_id"] = summary["LastMeeting"][0]["LAST_GAME_VISITOR_TEAM_ID"]
            last_meeting["away_score"] = summary["LastMeeting"][0]["LAST_GAME_VISITOR_TEAM_POINTS"]
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


def fetch_upcoming_games(game_date):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f"(Upcoming Games) Failed to connect to MongoDB: {e}")
        return

    # Map season type codes to names
    season_type_map = {
        '1': 'PRE_SEASON',
        '2': 'REGULAR_SEASON',
        '3': 'ALL_STAR',
        '4': 'PLAYOFFS',
        '5': 'PLAY_IN',
        '6': 'IST_FINAL'
    }
    try:
        scoreboard = ScoreboardV2(proxy=PROXY, headers=HEADERS, game_date=game_date, day_offset=0)
        games = scoreboard.get_normalized_dict()
    except Exception as e:
        logging.error(f"(Upcoming Games) Failed to fetch games for {game_date}: {e}", exc_info=True)
        return

    if len(games['GameHeader']) > 0:
        season = games['GameHeader'][0]['SEASON']
        season_type = games['GameHeader'][0]['GAME_ID'][2]

        # Collect all GAME_IDs into a list
        game_ids = []

        for details in games['GameHeader']:
            game_ids.append(details['GAME_ID'])
            games_collection.update_one(
                {'gameId': details['GAME_ID']},
                {'$set': {'date': game_date,
                          'season': season,
                          'seasonCode': f'{season_type}{season}',
                          'seasonType': season_type_map[season_type],
                          'homeTeamId': details['HOME_TEAM_ID'],
                          'awayTeamId': details['VISITOR_TEAM_ID'],
                          'broadcast': details['NATL_TV_BROADCASTER_ABBREVIATION'],
                          'gameClock': details['GAME_STATUS_TEXT'],
                          'status': 1,
                          "matchup": matchup_details(fetch_box_score_summary(details['GAME_ID']), {}),
                          "stats": {},
                          "pbp": []
                          }
                 },
                upsert=True
            )

        # After all updates, delete any documents where gameId is not in the list
        games_collection.delete_many({'gameId': {'$nin': game_ids}, 'date': game_date})


def fetch_games_for_date_range(start_date, end_date):
    current_date = start_date
    i = 0
    while current_date <= end_date:
        logging.info(f"Fetching games for {current_date.strftime('%Y-%m-%d')}")
        fetch_upcoming_games(current_date.strftime('%Y-%m-%d'))

        i += 1
        current_date += timedelta(days=1)

        # Pause 15 seconds every 25 days processed
        if i % 25 == 0:
            time.sleep(15)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    try:
        # Define date range
        start_date = datetime(2025, 4, 28)
        end_date = datetime(2025, 6, 30)

        # Fetch games for each date in the range
        fetch_games_for_date_range(start_date, end_date)

    except Exception as e:
        logging.error(f"Failed to fetch games for date range: {e}", exc_info=True)
