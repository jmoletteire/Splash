import time
from datetime import datetime, timedelta

import requests
from nba_api.stats.endpoints import leaguegamefinder, ScoreboardV2
from pymongo import MongoClient

from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_basic import fetch_box_score_stats
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.util.env import uri, k_current_season
import logging


def fetch_odds(nba_today_odds, game_id):
    for game_data in nba_today_odds:
        if game_data['gameId'] == game_id:
            games_collection.update_one(
                {'GAME_DATE': datetime.today().strftime('%Y-%m-%d')},
                {'$set': {f'GAMES.{game_id}.ODDS.srMatchId': game_data['srMatchId']}},
            )


def update_game_data():
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        # Fetch the data from the URL
        url = "https://cdn.nba.com/static/json/liveData/odds/odds_todaysGames.json"
        response = requests.get(url)

        # Check if the request was successful
        if response.status_code == 200:
            odds_data = response.json()

        # Fetch only games that are from the current season and have occurred before today
        today = datetime.today().strftime('%Y-%m-%d')
        query = {
            'SEASON_YEAR': k_current_season[:4],
            'GAME_DATE': {'$lt': today}
        }

        # Add Summary and Box Score data for games on past dates
        for game_date in games_collection.find(query, {'_id': 0}):
            for game_id, game_data in game_date['GAMES'].items():
                game_data['SUMMARY'] = fetch_box_score_summary(game_id)
                game_data['ADV'] = fetch_box_score_adv(game_id)
                # game_data['ODDS'] = fetch_odds(odds_data, game_id)

    except Exception as e:
        logging.error(f"Error fetching scores: {e}")


def fetch_upcoming_games(game_date):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games

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

    scoreboard = ScoreboardV2(game_date=game_date, day_offset=0)
    games = scoreboard.get_normalized_dict()

    if len(games['GameHeader']) > 0:
        season = games['GameHeader'][0]['SEASON']
        season_type = games['GameHeader'][0]['GAME_ID'][2]

        games_map = {}
        for i in range(0, len(games['GameHeader'])):
            game_id = games['GameHeader'][i]['GAME_ID']
            games_map[game_id] = {
                'SUMMARY': {
                    'GameSummary': [header for header in games['GameHeader'] if header['GAME_ID'] == game_id],
                    'LineScore': [linescore for linescore in games['LineScore'] if linescore['GAME_ID'] == game_id],
                    'LastMeeting': [last_meeting for last_meeting in games['LastMeeting'] if last_meeting['GAME_ID'] == game_id]
                }
            }

        games_collection.update_one(
            {'GAME_DATE': game_date},
            {'$set': {'SEASON_YEAR': season,
                      'SEASON_CODE': f'{season_type}{season}',
                      'SEASON_TYPE': season_type_map[season_type],
                      'GAME_DATE': game_date,
                      'GAMES': games_map
                      }
             },
            upsert=True
        )


def fetch_games_for_date_range(start_date, end_date):
    current_date = start_date
    i = 0
    while current_date <= end_date:
        logging.info(f"Fetching games for {current_date.strftime('%Y-%m-%d')}")
        fetch_upcoming_games(current_date.strftime('%Y-%m-%d'))

        i += 1
        current_date += timedelta(days=i)

        # Pause 15 seconds every 25 days processed
        if i % 25 == 0:
            time.sleep(15)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
        logging.info("Connected to MongoDB")

    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")

    try:
        # Define date range
        start_date = datetime(2024, 10, 4)
        end_date = datetime(2025, 4, 13)

        # Fetch games for each date in the range
        fetch_games_for_date_range(start_date, end_date)
    except Exception as e:
        logging.error(f"Failed to fetch games for date range: {e.with_traceback()}")
