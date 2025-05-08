import sys
import logging
from datetime import datetime
from flask import Blueprint, jsonify, request

env_path = "/home/ubuntu"
if env_path not in sys.path:
    sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

try:
    from mongo_connect import get_mongo_collection
except ImportError:
    raise ImportError("mongo_connect.py could not be found locally or at /home/ubuntu.")

games_bp = Blueprint('games', __name__)


@games_bp.route('/games/scoreboard', methods=['GET'])
def get_scoreboard():
    query_params = request.args.to_dict()
    game_date = query_params.get('date', datetime.utcnow().strftime('%Y-%m-%d'))
    game_id = query_params.get('gameId', None)

    # Fetch games from the database
    try:
        games_collection = get_mongo_collection("nba_games_unwrapped")
        proj = {'_id': 0, 'FINAL': 0}

        if game_id is None:
            games = list(games_collection.find({"date": game_date}, proj))
        else:
            games = list(games_collection.find({"gameId": game_id}, proj))

        # Sort by custom status order: 2, 1, 3
        custom_order = {2: 0, 1: 1, 3: 2}
        games.sort(key=lambda x: custom_order.get(x.get('status', 3), 99))

        return jsonify(games) if games else jsonify({}), 200  # Always return a valid response

    except Exception as e:
        logging.error(f"(get_games_from_db) MongoDB Query Error: {e}")
        return jsonify({"error": "Database query failed"}), 500  # Return an error response
