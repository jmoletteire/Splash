import logging
import re
import nba_api
from datetime import datetime, timedelta, timezone
from nba_api.live.nba.endpoints import boxscore, playbyplay
from nba_api.stats.endpoints import commonplayoffseries, scoreboardv2
from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.lib.games.fetch_new_games import fetch_games_for_date_range
from splash_nba.lib.games.fetch_play_by_play import update_play_by_play, fetch_play_by_play
from splash_nba.lib.games.nba_cup import update_current_cup, flag_cup_games
from splash_nba.lib.games.playoff_bracket import reformat_series_data, get_playoff_bracket_data
from splash_nba.lib.teams.update_team_games import update_team_games

try:
    # Try to import the local env.py file
    from splash_nba.util.env import PROXY, URI, CURR_SEASON
    from splash_nba.util.mongo_connect import get_mongo_collection
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI, CURR_SEASON
        from mongo_connect import get_mongo_collection
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


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

# Global flag to prevent further updates for the day
skip_updates = False


# Function to reset the skip_updates flag daily
def reset_flags():
    global skip_updates
    skip_updates = False
    logging.info("(Flag Reset) Daily reset complete, live updates will resume.")


def format_duration(input_str):
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

    return input_str  # Return original string if no match is found


def games_today():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    global skip_updates
    if skip_updates:
        logging.info(f"(Games Live) No games today, skipping further updates. [{datetime.now()}]")
        return  # Skip the update if there are no games today

    try:
        games_collection = get_mongo_collection('nba_games')
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    today = datetime.today().strftime('%Y-%m-%d')
    yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')

    # Else if games today + within 1 hour of first tip-off
    linescore = scoreboardv2.ScoreboardV2(game_date=today, day_offset=0).get_normalized_dict()
    line_scores = linescore['LineScore']
    games_yesterday = linescore['GameHeader']

    for game in games_yesterday:
        is_upcoming = game['GAME_STATUS_ID'] == 1
        in_progress = game['GAME_STATUS_ID'] == 2
        is_final = game['GAME_STATUS_ID'] == 3
        line_score = [line for line in line_scores if line['GAME_ID'] == game['GAME_ID']]

        # If game upcoming or in-progress, check for updates
        if is_upcoming:
            summary = fetch_box_score_summary(game['GAME_ID'])
            try:
                box_score = boxscore.BoxScore(game_id=game['GAME_ID']).get_dict()['game']
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0][
                            'GAME_DATE_EST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0][
                            'GAME_SEQUENCE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0]['GAME_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0][
                            'GAME_STATUS_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT': summary['GameSummary'][0][
                            'GAME_STATUS_TEXT'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0]['GAMECODE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0][
                            'HOME_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID': summary['GameSummary'][0][
                            'VISITOR_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0]['SEASON'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0][
                            'LIVE_PERIOD'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0][
                            'LIVE_PC_TIME'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION':
                            summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST':
                            summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0][
                            'WH_STATUS'],
                        f'GAMES.{game["gameId"]}.SUMMARY.Officials': summary['Officials'],
                        f'GAMES.{game["gameId"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameInfo': summary['GameInfo'],
                        f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["gameId"]}.SUMMARY.OtherStats': summary['OtherStats'],
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore': summary['LineScore'],
                        f'GAMES.{game["gameId"]}.BOXSCORE': box_score
                    }}
                )
                logging.info(f'(Games Live) Upcoming game {game["GAME_ID"]} is up to date + Box Score.')
            except Exception:
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0][
                        'GAME_DATE_EST'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0][
                                  'GAME_SEQUENCE'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0][
                                  'GAME_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID':
                                  summary['GameSummary'][0]['GAME_STATUS_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT':
                                  summary['GameSummary'][0]['GAME_STATUS_TEXT'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0][
                                  'GAMECODE'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0][
                                  'HOME_TEAM_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID':
                                  summary['GameSummary'][0]['VISITOR_TEAM_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0][
                                  'SEASON'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0][
                                  'LIVE_PERIOD'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0][
                                  'LIVE_PC_TIME'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION':
                                  summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST':
                                  summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0][
                                  'WH_STATUS'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.Officials': summary['Officials'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameInfo': summary['GameInfo'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.OtherStats': summary['OtherStats'],
                              }}
                )
                logging.info(f'(Games Live) Upcoming game {game["GAME_ID"]} is up to date.')

        # IN-PROGRESS
        elif in_progress:
            # Summary, Box Score, PBP
            summary = fetch_box_score_summary(game['GAME_ID'])
            box_score = boxscore.BoxScore(game_id=game['GAME_ID']).get_dict()['game']

            keys = [
                'actionNumber',
                'clock',
                'period',
                'teamId',
                'personId',
                'personIdsFilter',
                'playerNameI',
                'possession',
                'scoreHome',
                'scoreAway',
                'isFieldGoal',
                'description',
                'xLegacy',
                'yLegacy'
            ]

            try:
                actions = playbyplay.PlayByPlay(game_id=game['GAME_ID']).get_dict()['game']['actions']
                pbp = [{key: action.get(key, 0) for key in keys} for action in actions]
            except Exception:
                pbp = []

            home_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['homeTeam']['teamId'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['awayTeam']['teamId'] else 1

            # Update data
            games_collection.update_one(
                {'GAME_DATE': today},
                {'$set': {
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': box_score['gameStatus'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': box_score['period'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': format_duration(
                        box_score['gameClock']),
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.Officials': summary['Officials'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameInfo': summary['GameInfo'],
                    # HOME TEAM
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.GAME_ID': line_score[home_line_index][
                        'GAME_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ID': line_score[home_line_index][
                        'TEAM_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ABBREVIATION':
                        line_score[home_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_CITY_NAME':
                        line_score[home_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_NICKNAME':
                        line_score[home_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR1':
                        box_score['homeTeam']['periods'][0]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR2':
                        box_score['homeTeam']['periods'][1]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR3':
                        box_score['homeTeam']['periods'][2]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR4':
                        box_score['homeTeam']['periods'][3]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT1':
                        box_score['homeTeam']['periods'][4]['score'] if len(
                            box_score['homeTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT2':
                        box_score['homeTeam']['periods'][5]['score'] if len(
                            box_score['homeTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT3':
                        box_score['homeTeam']['periods'][6]['score'] if len(
                            box_score['homeTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT4':
                        box_score['homeTeam']['periods'][7]['score'] if len(
                            box_score['homeTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT5':
                        box_score['homeTeam']['periods'][8]['score'] if len(
                            box_score['homeTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT6':
                        box_score['homeTeam']['periods'][9]['score'] if len(
                            box_score['homeTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT7':
                        box_score['homeTeam']['periods'][10]['score'] if len(
                            box_score['homeTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT8':
                        box_score['homeTeam']['periods'][11]['score'] if len(
                            box_score['homeTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT9':
                        box_score['homeTeam']['periods'][12]['score'] if len(
                            box_score['homeTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT10':
                        box_score['homeTeam']['periods'][13]['score'] if len(
                            box_score['homeTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS': box_score['homeTeam']['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                        line_score[home_line_index]['TEAM_WINS_LOSSES'],
                    # AWAY TEAM
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.GAME_ID': line_score[away_line_index][
                        'GAME_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ID': line_score[away_line_index][
                        'TEAM_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ABBREVIATION':
                        line_score[away_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_CITY_NAME':
                        line_score[away_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_NICKNAME':
                        line_score[away_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR1':
                        box_score['awayTeam']['periods'][0]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR2':
                        box_score['awayTeam']['periods'][1]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR3':
                        box_score['awayTeam']['periods'][2]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR4':
                        box_score['awayTeam']['periods'][3]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT1':
                        box_score['awayTeam']['periods'][4]['score'] if len(
                            box_score['awayTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT2':
                        box_score['awayTeam']['periods'][5]['score'] if len(
                            box_score['awayTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT3':
                        box_score['awayTeam']['periods'][6]['score'] if len(
                            box_score['awayTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT4':
                        box_score['awayTeam']['periods'][7]['score'] if len(
                            box_score['awayTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT5':
                        box_score['awayTeam']['periods'][8]['score'] if len(
                            box_score['awayTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT6':
                        box_score['awayTeam']['periods'][9]['score'] if len(
                            box_score['awayTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT7':
                        box_score['awayTeam']['periods'][10]['score'] if len(
                            box_score['awayTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT8':
                        box_score['awayTeam']['periods'][11]['score'] if len(
                            box_score['awayTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT9':
                        box_score['awayTeam']['periods'][12]['score'] if len(
                            box_score['awayTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT10':
                        box_score['awayTeam']['periods'][13]['score'] if len(
                            box_score['awayTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS': box_score['awayTeam']['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                        line_score[away_line_index]['TEAM_WINS_LOSSES'],
                    # Summary, Box Score, PBP
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.OtherStats': summary['OtherStats'],
                    f'GAMES.{game["GAME_ID"]}.BOXSCORE': box_score,
                    f'GAMES.{game["GAME_ID"]}.PBP': pbp,
                }
                }
            )
            logging.info(f'(Games Live) Updated live game {game["GAME_ID"]} [{datetime.now()}]')

        # If game is final, update final box score
        elif is_final:
            update_team_games(games_collection.find_one({'GAME_DATE': today}, {'GAMES': 1}))
            summary = fetch_box_score_summary(game['GAME_ID'])
            adv = fetch_box_score_adv(game['GAME_ID'])
            highlights = 'No highlights found'  # search_youtube_highlights(YOUTUBE_API_KEY, teams[game['homeTeam']['teamId']], teams[game['awayTeam']['teamId']], today)

            home_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['HOME_TEAM_ID'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['VISITOR_TEAM_ID'] else 1

            if highlights == 'No highlights found':
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                            line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                            line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["GAME_ID"]}.ADV': adv,
                        f'GAMES.{game["GAME_ID"]}.FINAL': True if adv['PlayerStats'][0][
                                                                      'E_OFF_RATING'] is not None else False
                    }
                    }
                )
            else:
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                            line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                            line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.Highlights': highlights,
                        f'GAMES.{game["GAME_ID"]}.ADV': adv,
                        f'GAMES.{game["GAME_ID"]}.FINAL': True
                    }
                    }
                )
            logging.info(f'(Games Live) Finalizing game {game["GAME_ID"]}.')


def games_prev_day():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    global skip_updates
    if skip_updates:
        logging.info(f"(Games Live) No games today, skipping further updates. [{datetime.now()}]")
        return  # Skip the update if there are no games today

    try:
        games_collection = get_mongo_collection('nba_games')
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')

    # Else if games today + within 1 hour of first tip-off
    linescore = scoreboardv2.ScoreboardV2(game_date=yesterday, day_offset=0, proxy=PROXY).get_normalized_dict()
    line_scores = linescore['LineScore']
    games_yesterday = linescore['GameHeader']

    for game in games_yesterday:
        is_upcoming = game['GAME_STATUS_ID'] == 1
        in_progress = game['GAME_STATUS_ID'] == 2
        is_final = game['GAME_STATUS_ID'] == 3
        line_score = [line for line in line_scores if line['GAME_ID'] == game['GAME_ID']]

        # If game upcoming or in-progress, check for updates
        if is_upcoming:
            summary = fetch_box_score_summary(game['GAME_ID'])
            try:
                box_score = boxscore.BoxScore(game_id=game['GAME_ID'], proxy=PROXY).get_dict()['game']
                games_collection.update_one(
                    {'GAME_DATE': yesterday},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0][
                            'GAME_DATE_EST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0][
                            'GAME_SEQUENCE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0]['GAME_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0][
                            'GAME_STATUS_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT': summary['GameSummary'][0][
                            'GAME_STATUS_TEXT'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0]['GAMECODE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0][
                            'HOME_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID': summary['GameSummary'][0][
                            'VISITOR_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0]['SEASON'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0][
                            'LIVE_PERIOD'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0][
                            'LIVE_PC_TIME'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION':
                            summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST':
                            summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0][
                            'WH_STATUS'],
                        f'GAMES.{game["gameId"]}.SUMMARY.Officials': summary['Officials'],
                        f'GAMES.{game["gameId"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameInfo': summary['GameInfo'],
                        f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["gameId"]}.SUMMARY.OtherStats': summary['OtherStats'],
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore': summary['LineScore'],
                        f'GAMES.{game["gameId"]}.BOXSCORE': box_score
                    }}
                )
                logging.info(f'(Games Live) Upcoming game {game["GAME_ID"]} is up to date + Box Score.')
            except Exception:
                games_collection.update_one(
                    {'GAME_DATE': yesterday},
                    {'$set': {f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0][
                        'GAME_DATE_EST'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0][
                                  'GAME_SEQUENCE'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0][
                                  'GAME_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID':
                                  summary['GameSummary'][0]['GAME_STATUS_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT':
                                  summary['GameSummary'][0]['GAME_STATUS_TEXT'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0][
                                  'GAMECODE'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0][
                                  'HOME_TEAM_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID':
                                  summary['GameSummary'][0]['VISITOR_TEAM_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0][
                                  'SEASON'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0][
                                  'LIVE_PERIOD'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0][
                                  'LIVE_PC_TIME'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION':
                                  summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST':
                                  summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0][
                                  'WH_STATUS'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.Officials': summary['Officials'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameInfo': summary['GameInfo'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.OtherStats': summary['OtherStats'],
                              }}
                )
                logging.info(f'(Games Live) Upcoming game {game["GAME_ID"]} is up to date.')

        # IN-PROGRESS
        elif is_final:
            # Summary, Box Score, PBP
            summary = fetch_box_score_summary(game['GAME_ID'])
            box_score = boxscore.BoxScore(game_id=game['GAME_ID'], proxy=PROXY).get_dict()['game']

            # PBP fields to keep
            pbp_keys = [
                'actionNumber',
                'clock',
                'period',
                'teamId',
                'personId',
                'personIdsFilter',
                'playerNameI',
                'possession',
                'scoreHome',
                'scoreAway',
                'isFieldGoal',
                'description',
                'xLegacy',
                'yLegacy'
            ]

            try:
                actions = playbyplay.PlayByPlay(game_id=game['GAME_ID'], proxy=PROXY).get_dict()['game']['actions']
                pbp = [{key: action.get(key, 0) for key in pbp_keys} for action in actions]
            except Exception:
                pbp = []

            home_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['homeTeam']['teamId'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['awayTeam']['teamId'] else 1

            # Update data
            games_collection.update_one(
                {'GAME_DATE': yesterday},
                {'$set': {
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': box_score['gameStatus'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': box_score['period'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': format_duration(
                        box_score['gameClock']),
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.Officials': summary['Officials'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameInfo': summary['GameInfo'],
                    # HOME TEAM
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.GAME_ID': line_score[home_line_index][
                        'GAME_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ID': line_score[home_line_index][
                        'TEAM_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ABBREVIATION':
                        line_score[home_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_CITY_NAME':
                        line_score[home_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_NICKNAME':
                        line_score[home_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_NAME':
                        line_score[home_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR1':
                        box_score['homeTeam']['periods'][0]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR2':
                        box_score['homeTeam']['periods'][1]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR3':
                        box_score['homeTeam']['periods'][2]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR4':
                        box_score['homeTeam']['periods'][3]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT1':
                        box_score['homeTeam']['periods'][4]['score'] if len(
                            box_score['homeTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT2':
                        box_score['homeTeam']['periods'][5]['score'] if len(
                            box_score['homeTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT3':
                        box_score['homeTeam']['periods'][6]['score'] if len(
                            box_score['homeTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT4':
                        box_score['homeTeam']['periods'][7]['score'] if len(
                            box_score['homeTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT5':
                        box_score['homeTeam']['periods'][8]['score'] if len(
                            box_score['homeTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT6':
                        box_score['homeTeam']['periods'][9]['score'] if len(
                            box_score['homeTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT7':
                        box_score['homeTeam']['periods'][10]['score'] if len(
                            box_score['homeTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT8':
                        box_score['homeTeam']['periods'][11]['score'] if len(
                            box_score['homeTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT9':
                        box_score['homeTeam']['periods'][12]['score'] if len(
                            box_score['homeTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT10':
                        box_score['homeTeam']['periods'][13]['score'] if len(
                            box_score['homeTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS': box_score['homeTeam']['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                        line_score[home_line_index]['TEAM_WINS_LOSSES'],
                    # AWAY TEAM
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.GAME_ID': line_score[away_line_index][
                        'GAME_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ID': line_score[away_line_index][
                        'TEAM_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ABBREVIATION':
                        line_score[away_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_CITY_NAME':
                        line_score[away_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_NICKNAME':
                        line_score[away_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_NAME':
                        line_score[away_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR1':
                        box_score['awayTeam']['periods'][0]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR2':
                        box_score['awayTeam']['periods'][1]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR3':
                        box_score['awayTeam']['periods'][2]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR4':
                        box_score['awayTeam']['periods'][3]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT1':
                        box_score['awayTeam']['periods'][4]['score'] if len(
                            box_score['awayTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT2':
                        box_score['awayTeam']['periods'][5]['score'] if len(
                            box_score['awayTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT3':
                        box_score['awayTeam']['periods'][6]['score'] if len(
                            box_score['awayTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT4':
                        box_score['awayTeam']['periods'][7]['score'] if len(
                            box_score['awayTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT5':
                        box_score['awayTeam']['periods'][8]['score'] if len(
                            box_score['awayTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT6':
                        box_score['awayTeam']['periods'][9]['score'] if len(
                            box_score['awayTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT7':
                        box_score['awayTeam']['periods'][10]['score'] if len(
                            box_score['awayTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT8':
                        box_score['awayTeam']['periods'][11]['score'] if len(
                            box_score['awayTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT9':
                        box_score['awayTeam']['periods'][12]['score'] if len(
                            box_score['awayTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT10':
                        box_score['awayTeam']['periods'][13]['score'] if len(
                            box_score['awayTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS': box_score['awayTeam']['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                        line_score[away_line_index]['TEAM_WINS_LOSSES'],
                    # Summary, Box Score, PBP
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.OtherStats': summary['OtherStats'],
                    f'GAMES.{game["GAME_ID"]}.BOXSCORE': box_score,
                    f'GAMES.{game["GAME_ID"]}.PBP': pbp,
                }
                }
            )
            logging.info(f'(Games Live) Updated live game {game["GAME_ID"]} [{datetime.now()}]')

        # If game is final, update final box score
        elif is_final:
            update_team_games(games_collection.find_one({'GAME_DATE': yesterday}, {'GAMES': 1}))
            summary = fetch_box_score_summary(game['GAME_ID'])
            adv = fetch_box_score_adv(game['GAME_ID'])
            highlights = 'No highlights found'  # search_youtube_highlights(YOUTUBE_API_KEY, teams[game['homeTeam']['teamId']], teams[game['awayTeam']['teamId']], today)

            home_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['HOME_TEAM_ID'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['VISITOR_TEAM_ID'] else 1

            if highlights == 'No highlights found':
                games_collection.update_one(
                    {'GAME_DATE': yesterday},
                    {'$set': {
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                            line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                            line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["GAME_ID"]}.ADV': adv,
                        f'GAMES.{game["GAME_ID"]}.FINAL': True if adv['PlayerStats'][0][
                                                                      'E_OFF_RATING'] is not None else False
                    }
                    }
                )
            else:
                games_collection.update_one(
                    {'GAME_DATE': yesterday},
                    {'$set': {
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                            line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                            line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.Highlights': highlights,
                        f'GAMES.{game["GAME_ID"]}.ADV': adv,
                        f'GAMES.{game["GAME_ID"]}.FINAL': True
                    }
                    }
                )
            logging.info(f'(Games Live) Finalizing game {game["GAME_ID"]}.')


async def games_live_update():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    global skip_updates
    if skip_updates:
        logging.info(f"(Games Live) No games today, skipping further updates. [{datetime.now()}]")
        return  # Skip the update if there are no games today

    try:
        games_collection = get_mongo_collection('nba_games')
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    def parse_game_time(game_time_str):
        try:
            # Try parsing with microseconds
            return datetime.strptime(game_time_str, "%Y-%m-%dT%H:%M:%S.%fZ")
        except ValueError:
            # If microseconds are not present, try parsing without them
            return datetime.strptime(game_time_str, "%Y-%m-%dT%H:%M:%S%z")

    today = datetime.today().strftime('%Y-%m-%d')
    yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')

    try:
        scoreboard = nba_api.live.nba.endpoints.scoreboard.ScoreBoard(proxy=PROXY).get_dict()
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
        skip_updates = True
        return

    # Check if all games are final
    all_final = False
    for game in games_today:
        game_doc = games_collection.find_one({'GAME_DATE': today}, {f'GAMES.{game["gameId"]}.FINAL': 1})
        if game_doc and game_doc.get('GAMES', {}).get(game['gameId'], {}).get('FINAL', False):
            all_final = True
            continue
        else:
            all_final = False
            break

    # all_final = all(game['gameStatus'] == 3 for game in games_today)
    if all_final:
        logging.info(
            f"(Games Live) All games are final for today: {today}. Skipping updates for the rest of the day. [{datetime.now()}]")
        skip_updates = True
        return

    # Check if the first game is more than 1 hour away from start time
    first_game = games_today[0]
    first_game_time_str = first_game['gameTimeUTC']
    first_game_time = parse_game_time(first_game_time_str)
    first_game_date = first_game['gameEt'][:10]

    # Make current_time offset-aware in UTC
    current_time = datetime.now(timezone.utc)
    time_difference = first_game_time - current_time

    if time_difference > timedelta(hours=1):
        logging.info(f"(Games Live) First game is more than 1 hour away. Skipping updates. [{datetime.now()}]")
        return

    # Else if games today + within 1 hour of first tip-off
    try:
        linescore = scoreboardv2.ScoreboardV2(game_date=first_game_date, day_offset=0, proxy=PROXY).get_normalized_dict()
    except Exception:
        return

    line_scores = linescore['LineScore']

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
        line_score = [line for line in line_scores if line['GAME_ID'] == game['gameId']]

        # Check if the gameEt (game Eastern Time) is from yesterday
        game_et_str = game['gameEt']  # Assuming 'gameEt' contains the game time in Eastern Time
        game_et_str = game_et_str.replace('Z', '+00:00')  # Replace 'Z' with '+00:00' for UTC
        game_et = datetime.strptime(game_et_str, '%Y-%m-%dT%H:%M:%S%z')  # Parse with timezone information
        game_et_date = game_et.strftime('%Y-%m-%d')  # Extract only the date part

        if game_et_date == yesterday and not in_progress:
            logging.info(f"(Games Live) Game {game['gameId']} occurred yesterday. Skipping game. [{datetime.now()}]")
            continue

        # If game upcoming or in-progress, check for updates
        if is_upcoming:
            summary = fetch_box_score_summary(game['gameId'])
            try:
                box_score = boxscore.BoxScore(game_id=game['gameId'], proxy=PROXY).get_dict()['game']
                games_collection.update_one(
                    {'GAME_DATE': game_et_date},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0][
                            'GAME_DATE_EST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0][
                            'GAME_SEQUENCE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0]['GAME_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0][
                            'GAME_STATUS_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT': summary['GameSummary'][0][
                            'GAME_STATUS_TEXT'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0]['GAMECODE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0][
                            'HOME_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID': summary['GameSummary'][0][
                            'VISITOR_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0]['SEASON'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0][
                            'LIVE_PERIOD'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0][
                            'LIVE_PC_TIME'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION':
                            summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST':
                            summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0][
                            'WH_STATUS'],
                        f'GAMES.{game["gameId"]}.SUMMARY.Officials': summary['Officials'],
                        f'GAMES.{game["gameId"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameInfo': summary['GameInfo'],
                        f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["gameId"]}.SUMMARY.OtherStats': summary['OtherStats'],
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore': summary['LineScore'],
                        f'GAMES.{game["gameId"]}.BOXSCORE': box_score
                    }}
                )
                logging.info(f'(Games Live) Upcoming game {game["gameId"]} is up to date + Box Score.')
            except Exception:
                games_collection.update_one(
                    {'GAME_DATE': game_et_date},
                    {'$set': {f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0][
                        'GAME_DATE_EST'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0][
                                  'GAME_SEQUENCE'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0][
                                  'GAME_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0][
                                  'GAME_STATUS_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT':
                                  summary['GameSummary'][0]['GAME_STATUS_TEXT'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0][
                                  'GAMECODE'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0][
                                  'HOME_TEAM_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID':
                                  summary['GameSummary'][0]['VISITOR_TEAM_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0][
                                  'SEASON'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0][
                                  'LIVE_PERIOD'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0][
                                  'LIVE_PC_TIME'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION':
                                  summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST':
                                  summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0][
                                  'WH_STATUS'],
                              f'GAMES.{game["gameId"]}.SUMMARY.Officials': summary['Officials'],
                              f'GAMES.{game["gameId"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameInfo': summary['GameInfo'],
                              f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                              f'GAMES.{game["gameId"]}.SUMMARY.OtherStats': summary['OtherStats'],
                              }}
                )
                logging.info(f'(Games Live) Upcoming game {game["gameId"]} is up to date.')

        # IN-PROGRESS
        elif in_progress:
            # Summary, Box Score, PBP
            summary = fetch_box_score_summary(game['gameId'])
            box_score = boxscore.BoxScore(game_id=game['gameId'], proxy=PROXY).get_dict()['game']

            keys = [
                'actionNumber',
                'clock',
                'period',
                'teamId',
                'personId',
                'personIdsFilter',
                'playerNameI',
                'possession',
                'scoreHome',
                'scoreAway',
                'isFieldGoal',
                'description',
                'xLegacy',
                'yLegacy'
            ]

            try:
                actions = playbyplay.PlayByPlay(game_id=game['gameId'], proxy=PROXY).get_dict()['game']['actions']
                pbp = [{key: action.get(key, 0) for key in keys} for action in actions]
            except Exception:
                pbp = []

            home_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['homeTeam']['teamId'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['awayTeam']['teamId'] else 1

            # Update data
            games_collection.update_one(
                {'GAME_DATE': game_et_date},
                {'$set': {
                    f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': box_score['gameStatus'],
                    f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': box_score['period'],
                    f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': format_duration(
                        box_score['gameClock']),
                    f'GAMES.{game["gameId"]}.SUMMARY.Officials': summary['Officials'],
                    f'GAMES.{game["gameId"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                    f'GAMES.{game["gameId"]}.SUMMARY.GameInfo': summary['GameInfo'],
                    # HOME TEAM
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.GAME_ID': line_score[home_line_index][
                        'GAME_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ID': line_score[home_line_index][
                        'TEAM_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ABBREVIATION':
                        line_score[home_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_CITY_NAME':
                        line_score[home_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_NICKNAME':
                        line_score[home_line_index]['TEAM_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_NAME':
                        line_score[home_line_index]['TEAM_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR1':
                        box_score['homeTeam']['periods'][0]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR2':
                        box_score['homeTeam']['periods'][1]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR3':
                        box_score['homeTeam']['periods'][2]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR4':
                        box_score['homeTeam']['periods'][3]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT1':
                        box_score['homeTeam']['periods'][4]['score'] if len(
                            box_score['homeTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT2':
                        box_score['homeTeam']['periods'][5]['score'] if len(
                            box_score['homeTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT3':
                        box_score['homeTeam']['periods'][6]['score'] if len(
                            box_score['homeTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT4':
                        box_score['homeTeam']['periods'][7]['score'] if len(
                            box_score['homeTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT5':
                        box_score['homeTeam']['periods'][8]['score'] if len(
                            box_score['homeTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT6':
                        box_score['homeTeam']['periods'][9]['score'] if len(
                            box_score['homeTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT7':
                        box_score['homeTeam']['periods'][10]['score'] if len(
                            box_score['homeTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT8':
                        box_score['homeTeam']['periods'][11]['score'] if len(
                            box_score['homeTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT9':
                        box_score['homeTeam']['periods'][12]['score'] if len(
                            box_score['homeTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT10':
                        box_score['homeTeam']['periods'][13]['score'] if len(
                            box_score['homeTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS': box_score['homeTeam']['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                        line_score[home_line_index]['TEAM_WINS_LOSSES'],
                    # AWAY TEAM
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.GAME_ID': line_score[away_line_index][
                        'GAME_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ID': line_score[away_line_index][
                        'TEAM_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ABBREVIATION':
                        line_score[away_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_CITY_NAME':
                        line_score[away_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_NICKNAME':
                        line_score[away_line_index]['TEAM_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_NAME':
                        line_score[away_line_index]['TEAM_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR1':
                        box_score['awayTeam']['periods'][0]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR2':
                        box_score['awayTeam']['periods'][1]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR3':
                        box_score['awayTeam']['periods'][2]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR4':
                        box_score['awayTeam']['periods'][3]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT1':
                        box_score['awayTeam']['periods'][4]['score'] if len(
                            box_score['awayTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT2':
                        box_score['awayTeam']['periods'][5]['score'] if len(
                            box_score['awayTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT3':
                        box_score['awayTeam']['periods'][6]['score'] if len(
                            box_score['awayTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT4':
                        box_score['awayTeam']['periods'][7]['score'] if len(
                            box_score['awayTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT5':
                        box_score['awayTeam']['periods'][8]['score'] if len(
                            box_score['awayTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT6':
                        box_score['awayTeam']['periods'][9]['score'] if len(
                            box_score['awayTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT7':
                        box_score['awayTeam']['periods'][10]['score'] if len(
                            box_score['awayTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT8':
                        box_score['awayTeam']['periods'][11]['score'] if len(
                            box_score['awayTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT9':
                        box_score['awayTeam']['periods'][12]['score'] if len(
                            box_score['awayTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT10':
                        box_score['awayTeam']['periods'][13]['score'] if len(
                            box_score['awayTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS': box_score['awayTeam']['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                        line_score[away_line_index]['TEAM_WINS_LOSSES'],
                    # Summary, Box Score, PBP
                    f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                    f'GAMES.{game["gameId"]}.SUMMARY.OtherStats': summary['OtherStats'],
                    f'GAMES.{game["gameId"]}.BOXSCORE': box_score,
                    f'GAMES.{game["gameId"]}.PBP': pbp,
                }
                }
            )
            logging.info(f'(Games Live) Updated live game {game["gameId"]} [{datetime.now()}]')

        # If game is final, update final box score
        elif is_final:
            # Check if the final update has already been applied
            game_doc = games_collection.find_one({'GAME_DATE': game_et_date}, {f'GAMES.{game["gameId"]}.FINAL': 1})
            if game_doc and game_doc.get('GAMES', {}).get(game['gameId'], {}).get('FINAL', False):
                logging.info(
                    f'(Games Live) Game {game["gameId"]} already finalized, skipping update. [{datetime.now()}]')
                continue  # Skip this game as it's already been finalized

            # Update team schedules with game results
            update_team_games(games_collection.find_one({'GAME_DATE': game_et_date}, {'GAMES': 1}))

            # Finalize Box Score, Adv Stats, and Summary
            summary = fetch_box_score_summary(game['gameId'])
            adv = fetch_box_score_adv(game['gameId'])
            highlights = 'No highlights found'  # search_youtube_highlights(YOUTUBE_API_KEY, teams[game['homeTeam']['teamId']], teams[game['awayTeam']['teamId']], today)

            home_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['HOME_TEAM_ID'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['VISITOR_TEAM_ID'] else 1

            if highlights == 'No highlights found':
                games_collection.update_one(
                    {'GAME_DATE': game_et_date},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                            line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                            line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["gameId"]}.ADV': adv,
                        f'GAMES.{game["gameId"]}.FINAL': True if adv['PlayerStats'][0][
                                                                     'E_OFF_RATING'] is not None else False,
                        f'GAMES.{game["gameId"]}.UPDATED': False
                    }
                    }
                )
            else:
                games_collection.update_one(
                    {'GAME_DATE': game_et_date},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES':
                            line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES':
                            line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["gameId"]}.SUMMARY.Highlights': highlights,
                        f'GAMES.{game["gameId"]}.ADV': adv,
                        f'GAMES.{game["gameId"]}.FINAL': True,
                        f'GAMES.{game["gameId"]}.UPDATED': False
                    }
                    }
                )
            logging.info(f'(Games Live) Finalizing game {game["gameId"]}.')


def games_daily_update():
    """
    Runs every day at 2:00AM.\n
    Updates games, NBA Cup, and playoff data for each team.
    """
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    logging.info("Video PBP..")
    update_play_by_play()

    # Upcoming Games
    logging.info("Upcoming Games..")
    try:
        # Define date range
        start_date = datetime.today()
        end_date = datetime(2025, 4, 13)

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
        playoff_games = commonplayoffseries.CommonPlayoffSeries(season=CURR_SEASON).get_normalized_dict()[
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
    games_prev_day()
    # games_live_update()