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


def get_games_from_db(game_date, game_id=None):
    try:
        games_collection = get_mongo_collection("nba_games_unwrapped")

        if game_id is None:
            games = list(games_collection.find({"date": game_date}))
        else:
            games = games_collection.find_one({"gameId": game_id})  # Don't wrap find_one in list()

        return jsonify(games) if games else jsonify({}), 200  # Always return a valid response
    except Exception as e:
        logging.error(f"(get_games_from_db) MongoDB Query Error: {e}")
        return jsonify({"error": "Database query failed"}), 500  # Return an error response


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
