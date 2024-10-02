import random
import time
from datetime import datetime

import nba_api
from nba_api.live.nba.endpoints import scoreboard, boxscore
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


# Function to fetch box score stats for a game
def fetch_live_scores():
    scores = scoreboard.ScoreBoard().get_dict()['scoreboard']['games']
    return scores


def fetch_boxscore(today, game_id):
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f'(Live Box Score) Failed to connect to MongoDB: {e}')
        return

    boxscore = nba_api.live.nba.endpoints.boxscore.BoxScore(game_id=game_id).get_dict()['boxscore']

    games_collection.update_one(
        {'GAME_DATE': today},
        {'$set': {f'GAMES.{game_id}.BOXSCORE': boxscore}}
    )


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games

        print("Box score stats update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")