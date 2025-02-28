import sys
import logging
from datetime import datetime
from flask import Blueprint, jsonify, request

env_path = "/home/ubuntu"
if env_path not in sys.path:
    sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

try:
    from env import URI, PREV_SEASON, CURR_SEASON, CURR_SEASON_TYPE, PROXY
    from mongo_connect import get_mongo_collection
except ImportError:
    raise ImportError("env.py could not be found locally or at /home/ubuntu.")

teams_bp = Blueprint('teams', __name__)


@teams_bp.route('/teams/metadata', methods=['GET'])
def get_teams_metadata():
    try:
        # Query the database
        teams_collection = get_mongo_collection('nba_teams')
        teams = teams_collection.find(
            {"TEAM_ID": {"$exists": True, "$ne": 0}},
            {
                "_id": 0,
                "SPORT_ID": 1,
                "TEAM_ID": 1,
                "ABBREVIATION": 1,
                "NICKNAME": 1,
                "CITY": 1,
                "seasons": 1
            },
        )

        if teams:
            teams_final = process_team_data(teams)
            return teams_final
        else:
            logging.warning("(get_teams_metadata) No teams data found in MongoDB")
            return jsonify({"error": "No teams found"})

    except Exception as e:
        logging.error(f"(get_teams_metadata) Error retrieving teams: {e}")
        return jsonify({"error": "Failed to retrieve teams"}), 500
