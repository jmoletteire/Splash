from flask import Blueprint, jsonify, request
from datetime import datetime
import logging
from splash_nba.endpoints.routes.games.scoreboard.services.game_service import get_games_from_db, process_scoreboard

games_bp = Blueprint('games', __name__)


@games_bp.route('/games/scoreboard', methods=['GET'])
def get_scoreboard():
    try:
        query_params = request.args.to_dict()
        game_date = query_params.get('date', datetime.utcnow().strftime('%Y-%m-%d'))
        game_id = query_params.get('gameId')

        # Fetch games from the database
        games = get_games_from_db(game_date)

        if not games:
            logging.warning(f"(get_scoreboard) No games found for date {game_date}")
            return jsonify({"error": f"No games found for date {game_date}"}), 404

        # Process the games
        summarized_games = process_scoreboard(games, game_id)

        return jsonify(summarized_games)

    except Exception as e:
        logging.error(f"(get_scoreboard) Error retrieving games: {e}")
        return jsonify({"error": "Failed to retrieve games"}), 500
