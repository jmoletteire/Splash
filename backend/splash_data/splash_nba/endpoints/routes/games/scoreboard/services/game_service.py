import sys
import logging
from flask import jsonify
from .utils.game_helpers import summarize_game, specific_game

env_path = "/home/ubuntu"
if env_path not in sys.path:
    sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

try:
    from env import URI, PREV_SEASON, CURR_SEASON, CURR_SEASON_TYPE, PROXY
    from mongo_connect import get_mongo_collection
except ImportError:
    raise ImportError("env.py could not be found locally or at /home/ubuntu.")

games_collection = get_mongo_collection("nba_games")


def get_games_from_db(game_date):
    """Fetches games from the database by date."""
    pipeline = [
        {
            "$search": {
                "index": "game_index",
                "phrase": {
                    "query": game_date,
                    "path": "GAME_DATE"
                }
            }
        },
        {
            "$project": {
                "_id": 0,
                "GAMES": 1
            }
        }
    ]

    try:
        games = list(games_collection.aggregate(pipeline))
        return games[0]['GAMES'] if games else {}
    except Exception as e:
        logging.error(f"(get_games_from_db) MongoDB Query Error: {e}")
        return {}


def process_scoreboard(games, game_id=None):
    """Processes games and returns summarized data."""
    try:
        if game_id:
            summarized_games = [summarize_game(id, game) for id, game in games.items() if id == game_id]
        else:
            summarized_games = [summarize_game(id, game) for id, game in games.items()]

        if game_id:
            game = games.get(game_id, {})
            if not game:
                return {"error": f"No game found with id {game_id}"}

            summarized_games[0].update(specific_game(game))

        return summarized_games

    except Exception as e:
        logging.error(f"(process_scoreboard) Error processing scoreboard: {e}")
        return []
