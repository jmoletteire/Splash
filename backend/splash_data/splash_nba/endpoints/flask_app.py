import os

from flask import Flask, jsonify, request
from pymongo import MongoClient
import logging

from splash_nba.util.env import uri

app = Flask(__name__)


@app.route('/stats_query', methods=['POST'])
def query_database():
    data = request.json
    selected_season = data.get('selectedSeason')
    selected_season_type = data.get('seasonType')
    filters = data.get('filters')

    query = build_query(selected_season, selected_season_type, filters)
    results = players_collection.find(query, {'PERSON_ID': 1, 'DISPLAY_FI_LAST': 1, 'TEAM_ID': 1, f'STATS.{selected_season}': 1, '_id': 0})

    return jsonify([result for result in results])


def build_query(season, season_type, filters):
    query = {"$and": []}
    for stat_filter in filters:
        logging.info(stat_filter)

        operator = stat_filter['operation']
        value = stat_filter['value']
        location = stat_filter['location']

        stats = 'STATS'
        if season_type == 'Playoffs':
            stats = 'STATS.PLAYOFFS'

        path = f"{stats}.{season}.{location}"

        try:
            value = float(value)  # Try to convert value to a float for numerical comparisons
        except ValueError:
            pass  # Keep value as a string for non-numerical comparisons

        if operator == 'greater than':
            query["$and"].append({path: {"$gt": value}})
        elif operator == 'less than':
            query["$and"].append({path: {"$lt": value}})
        elif operator == 'equals':
            query["$and"].append({path: value})
        elif operator == 'contains':
            query["$and"].append({path: {"$regex": value, "$options": "i"}})
    return query


@app.route('/search', methods=['GET'])
def search():
    try:
        query = request.args.get('query', '')

        if not query:
            return jsonify({"players": [], "teams": []})

        # Use Atlas Search for players, limit results to 5
        player_matches = players_collection.aggregate([
            {
                "$search": {
                    "index": "person_id",
                    "text": {
                        "query": query,
                        "path": "DISPLAY_FIRST_LAST",
                        "fuzzy": {
                            "maxEdits": 2
                        }
                    }
                },
            },
            {
                "$limit": 5
            },
            {
                "$project": {
                    "_id": 0,
                    "DISPLAY_FIRST_LAST": 1,
                    "PERSON_ID": 1,
                    "TEAM_ID": 1
                }
            }
        ])

        # Use Atlas Search for teams, limit results to 5
        team_matches = teams_collection.aggregate([
            {
                "$search": {
                    "index": "team_name",  # Use the name of your search index for teams
                    "compound": {
                        "should": [
                            {
                                "text": {
                                    "query": query,
                                    "path": "CITY"
                                }
                            },
                            {
                                "text": {
                                    "query": query,
                                    "path": "NICKNAME"
                                }
                            }
                        ]
                    }
                }
            },
            {
                "$limit": 5
            },
            {
                "$project": {
                    "_id": 0,
                    "CITY": 1,
                    "NICKNAME": 1,
                    "TEAM_ID": 1
                }
            }
        ])

        players = [player for player in player_matches]
        teams = [team for team in team_matches]

        return jsonify({"players": players, "teams": teams})

    except Exception as e:
        logging.error(f" Error searching: {e}")
        return jsonify({"error": "Search failed"}), 500


@app.route('/get_games', methods=['GET'])
def get_games():
    try:
        # logging.info(f"(get_games) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_games) {query_params}")

        game_date = query_params['date']

        # Query the database
        games = games_collection.aggregate([
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
        ])

        games = list(games)

        if len(games) > 0:
            # logging.info(f"(get_games) Retrieved games for {game_date} from MongoDB")
            return jsonify(games[0]['GAMES'])
        else:
            logging.warning("(get_games) No games found in MongoDB")
            return jsonify({"error": "No games found"})

    except Exception as e:
        logging.error(f"(get_games) Error retrieving games: {e}")
        return jsonify({"error": "Failed to retrieve games"}), 500


@app.route('/get_player', methods=['GET'])
def get_player():
    try:
        # logging.info(f"(get_player) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_player) {query_params}")

        # Retrieve the required parameter
        person_id = query_params.get('person_id')
        if not person_id:
            return jsonify({"error": "person_id is required"}), 400

        # Convert the person_id to an integer
        try:
            query = int(person_id)
        except ValueError:
            return jsonify({"error": "person_id must be an integer"}), 400

        # Query the database
        player = players_collection.aggregate([
            {
                "$search": {
                    "index": "person_id",
                    "equals": {
                        "value": query,
                        "path": "PERSON_ID"
                    }
                }
            },
            {
                "$project": {
                    "_id": 0,
                }
            }
        ])

        player = list(player)

        if len(player) > 0:
            # logging.info(f"(get_player) Retrieved player {person_id} from MongoDB")
            return jsonify(player[0])
        else:
            logging.warning("(get_player) No player found in MongoDB")
            return jsonify({"error": "No player found"}), 404

    except Exception as e:
        logging.error(f"(get_player) Error retrieving player: {e}")
        return jsonify({"error": "Failed to retrieve player"}), 500


@app.route('/get_team', methods=['GET'])
def get_team():
    try:
        # logging.info(f"(get_team) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_team) {query_params}")

        # Retrieve the required parameter
        team_id = query_params.get('team_id')
        if not team_id:
            return jsonify({"error": "team_id is required"}), 400

        # Convert the team_id to an integer
        try:
            query = int(team_id)
        except ValueError:
            return jsonify({"error": "team_id must be an integer"}), 400

        # Perform the search query using the $search stage with the equals operator for numbers
        team_cursor = teams_collection.aggregate([
            {
                "$search": {
                    "index": "team_name",
                    "equals": {
                        "value": query,
                        "path": "TEAM_ID"
                    }
                }
            },
            {
                "$project": {
                    "_id": 0
                }
            }
        ])

        # Convert the cursor to a list and get the first result
        team = list(team_cursor)

        if len(team) > 0:
            # logging.info(f"(get_team) Retrieved team {team_id} from MongoDB")
            return jsonify(team[0])
        else:
            logging.warning("(get_team) No team found in MongoDB")
            return jsonify({"error": "No team found"}), 404

    except Exception as e:
        logging.error(f"(get_team) Error retrieving team: {e}")
        return jsonify({"error": "Failed to retrieve team"}), 500


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
        teams_collection = db.nba_teams
        players_collection = db.nba_players
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")

    app.run(host='0.0.0.0', port=8000)
