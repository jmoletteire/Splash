import logging
import random
from datetime import datetime, timedelta, timezone

import nba_api
import schedule
import time

from nba_api.live.nba.endpoints import scoreboard, boxscore, playbyplay
from nba_api.stats.endpoints import commonplayoffseries, playerawards, scoreboardv2
from pymongo import MongoClient

from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_basic import fetch_box_score_stats
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.lib.games.fetch_new_games import update_game_data, fetch_games_for_date_range
from splash_nba.lib.games.game_odds import fetch_odds
from splash_nba.lib.games.live_scores import fetch_boxscore, fetch_live_scores
from splash_nba.lib.games.nba_cup import update_current_cup
from splash_nba.lib.games.playoff_bracket import reformat_series_data, get_playoff_bracket_data
from splash_nba.lib.games.youtube_highlights import search_youtube_highlights
from splash_nba.lib.players.player_gamelogs import gamelogs
from splash_nba.lib.players.stats.custom_player_stats_rank import current_season_custom_stats_rank
from splash_nba.lib.players.stats.per75 import current_season_per_75
from splash_nba.lib.players.stats.player_career_stats import update_player_career_stats
from splash_nba.lib.players.stats.player_hustle_stats import update_player_hustle_stats, \
    update_player_playoff_hustle_stats
from splash_nba.lib.players.stats.player_stats import update_player_stats, update_player_playoff_stats
from splash_nba.lib.players.stats.shooting_stat_rank import current_season_shooting_stat_ranks
from splash_nba.lib.players.stats.shot_chart_data import get_shot_chart_data
from splash_nba.lib.players.stats.update_custom_player_stats import update_player_on_off, update_poss_per_game, \
    update_three_and_ft_rate, update_player_tracking_stats, update_shot_distribution, update_touches_breakdown, \
    update_drive_stats, update_scoring_breakdown_and_pct_unassisted, update_box_creation, update_offensive_load, \
    update_adj_turnover_pct, update_versatility_score, update_matchup_difficulty_and_dps
from splash_nba.lib.players.update_all_players import add_players, restructure_new_docs, update_player_info
from splash_nba.lib.players.update_player_contracts import fetch_player_contract_data, keep_most_informative
from splash_nba.lib.teams.stats.custom_team_stats import three_and_ft_rate
from splash_nba.lib.teams.stats.custom_team_stats_rank import custom_team_stats_rank, \
    current_season_custom_team_stats_rank
from splash_nba.lib.teams.stats.per100 import calculate_and_update_per_100_possessions, \
    current_season_per_100_possessions
from splash_nba.lib.teams.team_cap_sheet import update_team_contract_data
from splash_nba.lib.teams.team_history import update_team_history
from splash_nba.lib.teams.update_team_games import update_team_games
from splash_nba.lib.teams.standings import update_current_standings
from splash_nba.lib.teams.update_news_and_transactions import fetch_team_transactions, fetch_team_news
from splash_nba.lib.teams.team_seasons import update_current_season
from splash_nba.lib.teams.stats.team_hustle_stats_rank import rank_hustle_stats_current_season
from splash_nba.lib.teams.team_rosters import update_current_roster
from splash_nba.lib.teams.update_last_lineup import get_last_game, get_last_lineup
from splash_nba.util.env import uri, k_current_season, k_current_season_type, youtube_api_key

import re


# Global flag to prevent further updates for the day
skip_updates = False


# Function to reset the skip_updates flag daily
def reset_flags():
    global skip_updates
    skip_updates = False
    logging.info("(Flag Reset) Daily reset complete, live updates will resume.")


def games_prev_day():
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
    global skip_updates
    if skip_updates:
        logging.info(f"(Games Live) No games today, skipping further updates. [{datetime.now()}]")
        return  # Skip the update if there are no games today

    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    def format_duration(input_str):
        # Regular expression to match 'PT' followed by minutes and seconds
        match = re.match(r'PT(\d+)M(\d+)\.(\d+)S', input_str)

        if match:
            minutes = int(match.group(1))  # Convert minutes to int
            seconds = int(match.group(2))  # Convert seconds to int
            tenths = match.group(3)[0]     # Take only the first digit of the fraction for tenths

            if minutes == 0:  # Less than a minute left, show seconds and tenths
                return f":{seconds}.{tenths}"
            else:  # Regular minutes and seconds format
                return f"{minutes}:{seconds:02d}"  # Format seconds with leading zero if necessary

        return input_str  # Return original string if no match is found

    yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')

    # Else if games today + within 1 hour of first tip-off
    linescore = scoreboardv2.ScoreboardV2(game_date=yesterday, day_offset=0).get_normalized_dict()
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
                    {'GAME_DATE': yesterday},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0]['GAME_DATE_EST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0]['GAME_SEQUENCE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0]['GAME_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0]['GAME_STATUS_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT': summary['GameSummary'][0]['GAME_STATUS_TEXT'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0]['GAMECODE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0]['HOME_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID': summary['GameSummary'][0]['VISITOR_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0]['SEASON'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0]['LIVE_PERIOD'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0]['LIVE_PC_TIME'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION': summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST': summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0]['WH_STATUS'],
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
                    {'$set': {f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0]['GAME_DATE_EST'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0]['GAME_SEQUENCE'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0]['GAME_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0]['GAME_STATUS_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT': summary['GameSummary'][0]['GAME_STATUS_TEXT'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0]['GAMECODE'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0]['HOME_TEAM_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID': summary['GameSummary'][0]['VISITOR_TEAM_ID'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0]['SEASON'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0]['LIVE_PERIOD'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0]['LIVE_PC_TIME'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION': summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST': summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                              f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0]['WH_STATUS'],
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
                {'GAME_DATE': yesterday},
                {'$set': {
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': box_score['gameStatus'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': box_score['period'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': format_duration(box_score['gameClock']),
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.Officials': summary['Officials'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.GameInfo': summary['GameInfo'],
                    # HOME TEAM
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.GAME_ID': line_score[home_line_index]['GAME_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ID': line_score[home_line_index]['TEAM_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ABBREVIATION': line_score[home_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_CITY_NAME': line_score[home_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_NICKNAME': line_score[home_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR1': box_score['homeTeam']['periods'][0]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR2': box_score['homeTeam']['periods'][1]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR3': box_score['homeTeam']['periods'][2]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR4': box_score['homeTeam']['periods'][3]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT1': box_score['homeTeam']['periods'][4]['score'] if len(box_score['homeTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT2': box_score['homeTeam']['periods'][5]['score'] if len(box_score['homeTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT3': box_score['homeTeam']['periods'][6]['score'] if len(box_score['homeTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT4': box_score['homeTeam']['periods'][7]['score'] if len(box_score['homeTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT5': box_score['homeTeam']['periods'][8]['score'] if len(box_score['homeTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT6': box_score['homeTeam']['periods'][9]['score'] if len(box_score['homeTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT7': box_score['homeTeam']['periods'][10]['score'] if len(box_score['homeTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT8': box_score['homeTeam']['periods'][11]['score'] if len(box_score['homeTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT9': box_score['homeTeam']['periods'][12]['score'] if len(box_score['homeTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT10': box_score['homeTeam']['periods'][13]['score'] if len(box_score['homeTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.PTS': box_score['homeTeam']['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES': line_score[home_line_index]['TEAM_WINS_LOSSES'],
                    # AWAY TEAM
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.GAME_ID': line_score[away_line_index]['GAME_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ID': line_score[away_line_index]['TEAM_ID'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ABBREVIATION': line_score[away_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_CITY_NAME': line_score[away_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_NICKNAME': line_score[away_line_index]['TEAM_NAME'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR1': box_score['awayTeam']['periods'][0]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR2': box_score['awayTeam']['periods'][1]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR3': box_score['awayTeam']['periods'][2]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR4': box_score['awayTeam']['periods'][3]['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT1': box_score['awayTeam']['periods'][4]['score'] if len(box_score['awayTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT2': box_score['awayTeam']['periods'][5]['score'] if len(box_score['awayTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT3': box_score['awayTeam']['periods'][6]['score'] if len(box_score['awayTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT4': box_score['awayTeam']['periods'][7]['score'] if len(box_score['awayTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT5': box_score['awayTeam']['periods'][8]['score'] if len(box_score['awayTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT6': box_score['awayTeam']['periods'][9]['score'] if len(box_score['awayTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT7': box_score['awayTeam']['periods'][10]['score'] if len(box_score['awayTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT8': box_score['awayTeam']['periods'][11]['score'] if len(box_score['awayTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT9': box_score['awayTeam']['periods'][12]['score'] if len(box_score['awayTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT10': box_score['awayTeam']['periods'][13]['score'] if len(box_score['awayTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.PTS': box_score['awayTeam']['score'],
                    f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES': line_score[away_line_index]['TEAM_WINS_LOSSES'],
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
            highlights = 'No highlights found'  # search_youtube_highlights(youtube_api_key, teams[game['homeTeam']['teamId']], teams[game['awayTeam']['teamId']], today)

            home_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['HOME_TEAM_ID'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['VISITOR_TEAM_ID'] else 1

            if highlights == 'No highlights found':
                games_collection.update_one(
                    {'GAME_DATE': yesterday},
                    {'$set': {
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES': line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES': line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["GAME_ID"]}.ADV': adv,
                        f'GAMES.{game["GAME_ID"]}.FINAL': True if adv['PlayerStats'][0]['E_OFF_RATING'] is not None else False
                    }
                    }
                )
            else:
                games_collection.update_one(
                    {'GAME_DATE': yesterday},
                    {'$set': {
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES': line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES': line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.Highlights': highlights,
                        f'GAMES.{game["GAME_ID"]}.ADV': adv,
                        f'GAMES.{game["GAME_ID"]}.FINAL': True
                    }
                    }
                )
            logging.info(f'(Games Live) Finalizing game {game["GAME_ID"]}.')


def games_live_update():
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
    global skip_updates
    if skip_updates:
        logging.info(f"(Games Live) No games today, skipping further updates. [{datetime.now()}]")
        return  # Skip the update if there are no games today

    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    import re

    def format_duration(input_str):
        # Regular expression to match 'PT' followed by minutes and seconds
        match = re.match(r'PT(\d+)M(\d+)\.(\d+)S', input_str)

        if match:
            minutes = int(match.group(1))  # Convert minutes to int
            seconds = int(match.group(2))  # Convert seconds to int
            tenths = match.group(3)[0]     # Take only the first digit of the fraction for tenths

            if minutes == 0:  # Less than a minute left, show seconds and tenths
                return f":{seconds}.{tenths}"
            else:  # Regular minutes and seconds format
                return f"{minutes}:{seconds:02d}"  # Format seconds with leading zero if necessary

        return input_str  # Return original string if no match is found

    def parse_game_time(game_time_str):
        try:
            # Try parsing with microseconds
            return datetime.strptime(game_time_str, "%Y-%m-%dT%H:%M:%S.%fZ")
        except ValueError:
            # If microseconds are not present, try parsing without them
            return datetime.strptime(game_time_str, "%Y-%m-%dT%H:%M:%S%z")

    today = datetime.today().strftime('%Y-%m-%d')
    yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')
    scoreboard = nba_api.live.nba.endpoints.scoreboard.ScoreBoard().get_dict()

    try:
        games_today = scoreboard['scoreboard']['games']
    except KeyError as e:
        logging.error(f'(Games Live) Failed to get scores for today (KeyError) [{datetime.now()}]: {e}')
        return

    # If there are no games today, set the flag to skip further updates for the rest of the day
    if not games_today:
        logging.info(f"(Games Live) No games found for today: {today}. Skipping updates for the rest of the day. [{datetime.now()}]")
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
        logging.info(f"(Games Live) All games are final for today: {today}. Skipping updates for the rest of the day. [{datetime.now()}]")
        skip_updates = True
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

    # Else if games today + within 1 hour of first tip-off
    linescore = scoreboardv2.ScoreboardV2(game_date=today, day_offset=0).get_normalized_dict()
    line_scores = linescore['LineScore']

    for game in games_today:
        game_time_str = game['gameTimeUTC']
        game_time = parse_game_time(game_time_str)
        game_time_difference = game_time - current_time
        if game_time_difference > timedelta(hours=1):
            logging.info(f"(Games Live) Game {game['gameId']} is more than 1 hour away. Skipping game. [{datetime.now()}]")
            continue

        # Check if the gameEt (game Eastern Time) is from yesterday
        game_et_str = game['gameEt']  # Assuming 'gameEt' contains the game time in Eastern Time
        game_et_str = game_et_str.replace('Z', '+00:00')  # Replace 'Z' with '+00:00' for UTC
        game_et = datetime.strptime(game_et_str, '%Y-%m-%dT%H:%M:%S%z')  # Parse with timezone information
        game_et_date = game_et.strftime('%Y-%m-%d')  # Extract only the date part

        if game_et_date == yesterday:
            logging.info(f"(Games Live) Game {game['gameId']} occurred yesterday. Skipping game. [{datetime.now()}]")
            continue

        is_upcoming = game['gameStatus'] == 1
        in_progress = game['gameStatus'] == 2
        is_final = game['gameStatus'] == 3
        line_score = [line for line in line_scores if line['GAME_ID'] == game['gameId']]

        # If game upcoming or in-progress, check for updates
        if is_upcoming:
            summary = fetch_box_score_summary(game['gameId'])
            try:
                box_score = boxscore.BoxScore(game_id=game['gameId']).get_dict()['game']
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0]['GAME_DATE_EST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0]['GAME_SEQUENCE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0]['GAME_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0]['GAME_STATUS_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT': summary['GameSummary'][0]['GAME_STATUS_TEXT'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0]['GAMECODE'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0]['HOME_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID': summary['GameSummary'][0]['VISITOR_TEAM_ID'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0]['SEASON'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0]['LIVE_PERIOD'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0]['LIVE_PC_TIME'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION': summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST': summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0]['WH_STATUS'],
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
                    {'GAME_DATE': today},
                    {'$set': {f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_DATE_EST': summary['GameSummary'][0]['GAME_DATE_EST'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_SEQUENCE': summary['GameSummary'][0]['GAME_SEQUENCE'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_ID': summary['GameSummary'][0]['GAME_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': summary['GameSummary'][0]['GAME_STATUS_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_TEXT': summary['GameSummary'][0]['GAME_STATUS_TEXT'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAMECODE': summary['GameSummary'][0]['GAMECODE'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.HOME_TEAM_ID': summary['GameSummary'][0]['HOME_TEAM_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.VISITOR_TEAM_ID': summary['GameSummary'][0]['VISITOR_TEAM_ID'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.SEASON': summary['GameSummary'][0]['SEASON'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': summary['GameSummary'][0]['LIVE_PERIOD'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': summary['GameSummary'][0]['LIVE_PC_TIME'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.NATL_TV_BROADCASTER_ABBREVIATION': summary['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD_TIME_BCAST': summary['GameSummary'][0]['LIVE_PERIOD_TIME_BCAST'],
                              f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.WH_STATUS': summary['GameSummary'][0]['WH_STATUS'],
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
            box_score = boxscore.BoxScore(game_id=game['gameId']).get_dict()['game']

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
                actions = playbyplay.PlayByPlay(game_id=game['gameId']).get_dict()['game']['actions']
                pbp = [{key: action.get(key, 0) for key in keys} for action in actions]
            except Exception:
                pbp = []

            home_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['homeTeam']['teamId'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == box_score['awayTeam']['teamId'] else 1

            # Update data
            games_collection.update_one(
                {'GAME_DATE': today},
                {'$set': {
                    f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': box_score['gameStatus'],
                    f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PERIOD': box_score['period'],
                    f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.LIVE_PC_TIME': format_duration(box_score['gameClock']),
                    f'GAMES.{game["gameId"]}.SUMMARY.Officials': summary['Officials'],
                    f'GAMES.{game["gameId"]}.SUMMARY.InactivePlayers': summary['InactivePlayers'],
                    f'GAMES.{game["gameId"]}.SUMMARY.GameInfo': summary['GameInfo'],
                    # HOME TEAM
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.GAME_ID': line_score[home_line_index]['GAME_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ID': line_score[home_line_index]['TEAM_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_ABBREVIATION': line_score[home_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_CITY_NAME': line_score[home_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_NICKNAME': line_score[home_line_index]['TEAM_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR1': box_score['homeTeam']['periods'][0]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR2': box_score['homeTeam']['periods'][1]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR3': box_score['homeTeam']['periods'][2]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_QTR4': box_score['homeTeam']['periods'][3]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT1': box_score['homeTeam']['periods'][4]['score'] if len(box_score['homeTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT2': box_score['homeTeam']['periods'][5]['score'] if len(box_score['homeTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT3': box_score['homeTeam']['periods'][6]['score'] if len(box_score['homeTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT4': box_score['homeTeam']['periods'][7]['score'] if len(box_score['homeTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT5': box_score['homeTeam']['periods'][8]['score'] if len(box_score['homeTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT6': box_score['homeTeam']['periods'][9]['score'] if len(box_score['homeTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT7': box_score['homeTeam']['periods'][10]['score'] if len(box_score['homeTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT8': box_score['homeTeam']['periods'][11]['score'] if len(box_score['homeTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT9': box_score['homeTeam']['periods'][12]['score'] if len(box_score['homeTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS_OT10': box_score['homeTeam']['periods'][13]['score'] if len(box_score['homeTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.PTS': box_score['homeTeam']['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES': line_score[home_line_index]['TEAM_WINS_LOSSES'],
                    # AWAY TEAM
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.GAME_ID': line_score[away_line_index]['GAME_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ID': line_score[away_line_index]['TEAM_ID'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_ABBREVIATION': line_score[away_line_index]['TEAM_ABBREVIATION'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_CITY_NAME': line_score[away_line_index]['TEAM_CITY_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_NICKNAME': line_score[away_line_index]['TEAM_NAME'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR1': box_score['awayTeam']['periods'][0]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR2': box_score['awayTeam']['periods'][1]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR3': box_score['awayTeam']['periods'][2]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_QTR4': box_score['awayTeam']['periods'][3]['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT1': box_score['awayTeam']['periods'][4]['score'] if len(box_score['awayTeam']['periods']) > 4 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT2': box_score['awayTeam']['periods'][5]['score'] if len(box_score['awayTeam']['periods']) > 5 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT3': box_score['awayTeam']['periods'][6]['score'] if len(box_score['awayTeam']['periods']) > 6 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT4': box_score['awayTeam']['periods'][7]['score'] if len(box_score['awayTeam']['periods']) > 7 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT5': box_score['awayTeam']['periods'][8]['score'] if len(box_score['awayTeam']['periods']) > 8 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT6': box_score['awayTeam']['periods'][9]['score'] if len(box_score['awayTeam']['periods']) > 9 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT7': box_score['awayTeam']['periods'][10]['score'] if len(box_score['awayTeam']['periods']) > 10 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT8': box_score['awayTeam']['periods'][11]['score'] if len(box_score['awayTeam']['periods']) > 11 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT9': box_score['awayTeam']['periods'][12]['score'] if len(box_score['awayTeam']['periods']) > 12 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS_OT10': box_score['awayTeam']['periods'][13]['score'] if len(box_score['awayTeam']['periods']) > 13 else 0,
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.PTS': box_score['awayTeam']['score'],
                    f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES': line_score[away_line_index]['TEAM_WINS_LOSSES'],
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
            game_doc = games_collection.find_one({'GAME_DATE': today}, {f'GAMES.{game["gameId"]}.FINAL': 1})
            if game_doc and game_doc.get('GAMES', {}).get(game['gameId'], {}).get('FINAL', False):
                logging.info(f'(Games Live) Game {game["gameId"]} already finalized, skipping update. [{datetime.now()}]')
                continue  # Skip this game as it's already been finalized

            update_team_games(games_collection.find_one({'GAME_DATE': today}, {'GAMES': 1}))
            summary = fetch_box_score_summary(game['gameId'])
            adv = fetch_box_score_adv(game['gameId'])
            highlights = 'No highlights found'  # search_youtube_highlights(youtube_api_key, teams[game['homeTeam']['teamId']], teams[game['awayTeam']['teamId']], today)

            home_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['HOME_TEAM_ID'] else 1
            away_line_index = 0 if line_score[0]['TEAM_ID'] == summary['GameSummary'][0]['VISITOR_TEAM_ID'] else 1

            if highlights == 'No highlights found':
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES': line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES': line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["gameId"]}.ADV': adv,
                        f'GAMES.{game["gameId"]}.FINAL': True if adv['PlayerStats'][0]['E_OFF_RATING'] is not None else False
                    }
                    }
                )
            else:
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {
                        f'GAMES.{game["gameId"]}.SUMMARY.GameSummary.0.GAME_STATUS_ID': 3,
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{home_line_index}.TEAM_WINS_LOSSES': line_score[home_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.LineScore.{away_line_index}.TEAM_WINS_LOSSES': line_score[away_line_index]['TEAM_WINS_LOSSES'],
                        f'GAMES.{game["gameId"]}.SUMMARY.SeasonSeries': summary['SeasonSeries'],
                        f'GAMES.{game["gameId"]}.SUMMARY.Highlights': highlights,
                        f'GAMES.{game["gameId"]}.ADV': adv,
                        f'GAMES.{game["gameId"]}.FINAL': True
                    }
                    }
                )
            logging.info(f'(Games Live) Finalizing game {game["gameId"]}.')


def games_daily_update():
    """
    Runs every day at 2:30AM.\n
    Updates games, NBA Cup, and playoff data for each team.
    """
    # Games
    # logging.info("Games/Scores..")
    # update_game_data()

    # Upcoming Games
    logging.info("Upcoming Games..")
    try:
        # Define date range
        start_date = datetime.today()
        end_date = datetime(2025, 4, 13)

        # Fetch games for each date in the range
        fetch_games_for_date_range(start_date, end_date)
    except Exception as e:
        logging.error(f"(Games Daily) Failed to fetch upcoming games: {e}")

    # NBA Cup
    logging.info("NBA Cup...")
    update_current_cup()

    # Playoffs
    logging.info("Playoffs...")
    playoff_games = commonplayoffseries.CommonPlayoffSeries(season=k_current_season).get_normalized_dict()[
        'PlayoffSeries']
    if not playoff_games:
        logging.info("(Games Daily) No playoff games found.")
        return
    else:
        series_data = reformat_series_data(playoff_games)
        get_playoff_bracket_data(k_current_season, series_data)


def teams_daily_update():
    """
    Runs every day at 3AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """

    logging.info("Updating teams (daily)...")
    try:
        # Games (0 API calls)
        logging.info("Games...")
        # Sort the documents in nba_games collection by GAME_DATE in descending order
        sorted_games_cursor = games_collection.find(
            {"SEASON_YEAR": k_current_season[0:4]},
            {"GAME_DATE": 1, "GAMES": 1, "_id": 0}
        ).sort("GAME_DATE", -1)
        # Process the games in batches
        for i, game_day in enumerate(sorted_games_cursor):
            logging.info(f"Processing {game_day['GAME_DATE']}...")
            update_team_games(game_day)

        # Standings (min. 30 API calls [more if tiebreakers])
        logging.info("Standings...")
        update_current_standings()

        # News & Transactions (NATSTAT - 60 API calls)
        logging.info("News & Transactions...")
        fetch_team_transactions()
        fetch_team_news()

        # Cap Sheet (0 API calls)
        logging.info("Cap Sheet...")
        update_team_contract_data()

        # Loop through all documents in the collection
        batch_size = 10
        total_documents = teams_collection.count_documents({})
        processed_count = 0
        while processed_count < total_documents:
            with teams_collection.find({}, {"TEAM_ID": 1, f"seasons": 1, "_id": 0}).skip(processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for doc in documents:
                    team = doc['TEAM_ID']

                    if team == 0:
                        continue

                    logging.info(f"Processing team {team} ({processed_count} of 30)...")

                    # Team History (30 API calls)
                    logging.info("History...")
                    update_team_history(team_id=team)
                    time.sleep(15)

                    # Season Stats (120 API calls)
                    logging.info("Stats...")
                    update_current_season(team_id=team)
                    # Filter seasons to only include the current season key
                    filtered_doc = doc.copy()
                    filtered_doc['seasons'] = {key: doc['seasons'][key] for key in doc['seasons'] if key == k_current_season}
                    current_season_per_100_possessions(team_doc=filtered_doc, playoffs=k_current_season_type == 'PLAYOFFS')
                    time.sleep(15)

                    # Current Roster & Coaches (~400-500 API calls)
                    logging.info("Roster & Coaches...")
                    season_not_started = True if doc['seasons'][k_current_season]['GP'] == 0 else False
                    update_current_roster(team_id=team, season_not_started=season_not_started)
                    time.sleep(15)

                    # Last Starting Lineup (0 API Calls)
                    # Get most recent game by date
                    game_id, game_date = get_last_game(doc['seasons'])
                    # Get starting lineup for most recent game
                    last_starting_lineup = get_last_lineup(team, game_id, game_date)
                    # Update document
                    teams_collection.update_one(
                        {"TEAM_ID": team},
                        {"$set": {"LAST_STARTING_LINEUP": last_starting_lineup}},
                    )

                    # Pause 15 seconds between teams
                    time.sleep(15)

        rank_hustle_stats_current_season()
        three_and_ft_rate(seasons=[k_current_season], season_type=k_current_season_type)
        current_season_custom_team_stats_rank()
    except Exception as e:
        logging.error(f"(Teams Daily) Error updating teams: {e}")


def players_daily_update():
    """
    Runs every day at 3:30AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """

    def player_info():
        # Player Info
        logging.info("Player Info...")
        try:
            add_players()
            restructure_new_docs()
            update_player_info()
        except Exception as e:
            logging.error(f"(Player Info) Error adding players: {e}")

    def player_stats():
        # Stats
        logging.info("Player Stats...")

        # BASIC, ADV, HUSTLE
        if k_current_season_type == 'REGULAR SEASON':
            update_player_stats()
            update_player_hustle_stats()
        else:
            update_player_playoff_stats()
            update_player_playoff_hustle_stats()

        # CUSTOM STATS (Calculated)
        update_player_on_off(k_current_season_type)  # ON/OFF
        update_poss_per_game(k_current_season_type)  # POSS PER G
        update_three_and_ft_rate(k_current_season_type)  # 3PAr, FTAr, FT/FGA
        update_player_tracking_stats(k_current_season_type)  # TOUCHES, PASSING, DRIVES, REBOUNDING, SPEED/DISTANCE
        update_touches_breakdown(k_current_season_type)  # % PASS, % SHOOT, % TOV, % FOULED
        update_shot_distribution(k_current_season_type)  # SHOT TYPE, CLOSEST DEFENDER
        update_drive_stats(k_current_season_type)  # DRIVE %, DRIVE TS%, DRIVE FT/FGA
        update_scoring_breakdown_and_pct_unassisted(k_current_season_type)  # % UAST
        update_box_creation(k_current_season_type)  # BOX CREATION
        update_offensive_load(k_current_season_type)  # OFF LOAD
        update_adj_turnover_pct(k_current_season_type)  # cTOV
        update_versatility_score(k_current_season_type)  # VERSATILITY
        update_matchup_difficulty_and_dps(k_current_season_type)  # MATCHUP DIFF & DIE

        # PER 75
        current_season_per_75(k_current_season_type == 'PLAYOFFS')

        # Rank
        current_season_custom_stats_rank()
        current_season_shooting_stat_ranks(k_current_season_type)

    def player_career_stats():
        # Stats
        logging.info("Player Career Stats...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active'})
        processed_count = 0
        i = 0

        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active'},
                                         {'PERSON_ID': 1, 'STATS': 1, 'CAREER': 1, '_id': 0}).skip(
                    processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for player in documents:
                    i += 1
                    logging.info(f'(Career Stats) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                    try:
                        update_player_career_stats(player['PERSON_ID'])
                    except Exception as e:
                        logging.error(
                            f'(Career Stats) Could not update career stats for player {player["PERSON_ID"]}: {e}')
                        continue

                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(random.uniform(0.5, 1.0))

                # Pause 15 seconds every 25 players
                time.sleep(15)

    def player_game_logs():
        # Game Logs
        logging.info("Player Game Logs...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active'})
        processed_count = 0
        i = 0

        # Loop through all ACTIVE players
        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active'}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(
                    processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for player in documents:
                    i += 1
                    logging.info(
                        f'\n(Player Game Logs) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                    try:
                        # Pass player, current season, and current season type
                        gamelogs(player['PERSON_ID'], k_current_season, k_current_season_type)
                    except Exception as e:
                        logging.error(
                            f'(Player Game Logs) Could not add game logs for player {player["PERSON_ID"]}: {e}')
                        continue
                    # Pause for a random time between 0.5 and 1 second between each player
                    time.sleep(random.uniform(0.5, 1.0))

                # Pause 10 seconds every 25 players
                time.sleep(10)

    def player_shot_charts():
        # Shot Charts
        logging.info("Player Shot Charts...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active'})
        processed_count = 0
        i = 0
        keep_league_avg = True

        # Loop through all ACTIVE players
        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active'}, {'PERSON_ID': 1, 'TEAM_ID': 1, '_id': 0}).skip(
                    processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for player in documents:
                    i += 1
                    logging.info(
                        f'\n(Player Shot Charts) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                    try:
                        get_shot_chart_data(
                            player['PERSON_ID'],
                            player['TEAM_ID'],
                            k_current_season,
                            'Regular Season' if k_current_season_type == 'REGULAR SEASON' else 'Playoffs',
                            keep_league_avg
                        )
                        keep_league_avg = False
                    except Exception as e:
                        logging.error(
                            f'(Player Shot Charts) Could not process shot chart for Player {player["PERSON_ID"]}: {e}')
                        continue

                    # Pause for a random time between 0.5 and 1 second between players
                    time.sleep(random.uniform(0.5, 1.0))

                # Pause 30 seconds every 25 players
                time.sleep(30)

    def player_contracts_and_trans():
        # Contracts & Transactions
        logging.info("Player Contracts & Transactions...")

        # Update all ACTIVE players
        for i, player in enumerate(players_collection.find({'ROSTERSTATUS': 'Active'}, {'PERSON_ID': 1, '_id': 0})):
            logging.info(f'Processing {i + 1} of {players_collection.count_documents({"ROSTERSTATUS": "Active"})}...')

            try:
                player_id = str(player['PERSON_ID'])

                # Define the GraphQL endpoint
                url = "https://fanspo.com/api/graphql"

                # Define the headers
                headers = {
                    "Content-Type": "application/json"
                }

                # Define the initial query variables
                variables = {
                    "playerId": player_id
                }

                # Fetch all paginated data
                contracts, transactions = fetch_player_contract_data(url, variables, headers)
                transactions = keep_most_informative(transactions)

                players_collection.update_one(
                    {"PERSON_ID": int(player_id)},
                    {"$set": {'CONTRACTS': contracts, 'TRANSACTIONS': transactions}},
                )
            except Exception as e:
                logging.error(
                    f'(Player Contracts) Could not process contract data for Player {player["PERSON_ID"]}: {e}')
                continue

    def player_awards():
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Connect to MongoDB
        client = MongoClient(uri)
        db = client.splash
        players_collection = db.nba_players

        logging.info("Player Awards...")

        keys = [
            'DESCRIPTION',
            'ALL_NBA_TEAM_NUMBER',
            'SEASON',
            'CONFERENCE',
            'TYPE'
        ]
        players = players_collection.count_documents({'ROSTERSTATUS': 'Active'})

        # Update awards for all ACTIVE players
        for i, player in enumerate(players_collection.find({'ROSTERSTATUS': 'Active'}, {"PERSON_ID": 1, "_id": 0})):
            try:
                player_awards = playerawards.PlayerAwards(player["PERSON_ID"]).get_normalized_dict()['PlayerAwards']

                awards = {}

                for award in player_awards:
                    if award['DESCRIPTION'] not in awards.keys():
                        awards[award['DESCRIPTION']] = [{key: award[key] for key in keys}]
                    else:
                        awards[award['DESCRIPTION']].append({key: award[key] for key in keys})

                players_collection.update_one(
                    {"PERSON_ID": player["PERSON_ID"]},
                    {"$set": {"AWARDS": awards}},
                )

                logging.info(f"(Player Awards) Updated {i + 1} of {players}")

            except Exception as e:
                logging.error(f"(Player Awards) Unable to process player {player['PERSON_ID']}: {e}")

            # Pause for a random time between 0.5 and 2 seconds
            time.sleep(random.uniform(0.5, 2.0))

            # Pause 15 seconds for every 50 players
            if i % 50 == 0:
                time.sleep(15)

    logging.info("Updating players (daily)...")

    # INFO
    try:
        player_info()
        #print('Skip')
    except Exception as e:
        logging.error(f"Error updating player info: {e}")

    # STATS
    try:
        #player_stats()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player stats: {e}")

    # CAREER
    try:
        #player_career_stats()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player career stats: {e}")

    # GAME LOGS
    try:
        #player_game_logs()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player game logs: {e}")

    # SHOT CHART
    try:
        #player_shot_charts()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player shot charts: {e}")

    # CONTRACT & TRANSACTIONS
    try:
        player_contracts_and_trans()
        #print('Skip')
    except Exception as e:
        logging.error(f"Error updating player contracts & transactions: {e}")

    # AWARDS
    try:
        #player_awards()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player awards: {e}")


# Schedule the tasks
schedule.every(10).seconds.do(games_live_update)  # Update games
schedule.every(10).seconds.do(fetch_odds)  # Update odds
schedule.every().day.at("00:00").do(reset_flags)  # Reset the flag at midnight
schedule.every().day.at("02:00").do(games_daily_update)  # Run every day at 2:30 AM
schedule.every().day.at("02:15").do(teams_daily_update)  # Run every day at 3:00 AM
schedule.every().day.at("04:00").do(players_daily_update)  # Run every day at 3:30 AM


# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB
try:
    client = MongoClient(uri)
    db = client.splash

    games_collection = db.nba_games

    teams_collection = db.nba_teams

    players_collection = db.nba_players
    player_shots_collection = db.nba_player_shot_data

    playoff_collection = db.nba_playoff_history
    cup_collection = db.nba_cup_history

    draft_collection = db.nba_draft_history

    transactions_collection = db.nba_transactions

    logging.info("Connected to MongoDB")
except Exception as e:
    logging.error(f"Failed to connect to MongoDB: {e}")
    exit(1)

#games_daily_update()
#teams_daily_update()
#players_daily_update()
#games_live_update()
# games_prev_day()

while True:
    schedule.run_pending()
    time.sleep(1)  # Wait for 1 second between checking the schedule
