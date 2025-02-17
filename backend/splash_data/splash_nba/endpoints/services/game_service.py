from datetime import datetime
from flask import jsonify
from splash_nba.endpoints.utils.game_helpers import summarize_game, specific_game
from pymongo import MongoClient
import logging

client = MongoClient("your-mongo-db-connection-string")
db = client.splash
games_collection = db.nba_games


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
                return jsonify({"error": f"No game found with id {game_id}"}), 404

            summarized_games[0].update(specific_game(game))

        return summarized_games

    except Exception as e:
        logging.error(f"(process_scoreboard) Error processing scoreboard: {e}")
        return []
