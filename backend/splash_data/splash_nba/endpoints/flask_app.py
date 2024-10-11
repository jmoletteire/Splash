import os
import time

from flask import Flask, jsonify, request, Response
from flask_compress import Compress
from pymongo import MongoClient
import logging

app = Flask(__name__)
Compress(app)
bytes_transferred = 0
k_prev_season = '2023-24'
k_current_season = '2024-25'

# MongoDB connection setup
try:
    # Configure logging
    logging.basicConfig(level=logging.INFO)
    client = MongoClient('mongodb+srv://jmoletteire:J%40ckpa%24%245225@splash.p0xumnu.mongodb.net/')
    db = client.splash

    # Define all collections at the top level, so they're accessible across routes
    games_collection = db.nba_games
    teams_collection = db.nba_teams
    players_collection = db.nba_players
    player_shots_collection = db.nba_player_shot_data
    lg_history_collection = db.nba_league_history
    playoff_collection = db.nba_playoff_history
    cup_collection = db.nba_cup_history
    draft_collection = db.nba_draft_history
    transactions_collection = db.nba_transactions

    logging.info("Connected to MongoDB")
except Exception as e:
    logging.error(f"Failed to connect to MongoDB: {e}")


@app.route('/team_schedule_query', methods=['POST'])
def query_schedules_database():
    data = request.json
    selected_season = data.get('selectedSeason')
    selected_season_type = data.get('selectedSeasonType')

    filters = data.get('filters')

    if filters:
        results = apply_team_schedule_filters(selected_season, selected_season_type, filters)
    else:
        query = {f"seasons.{selected_season}": {"$exists": True}}
        results = list(teams_collection.find(
            query,
            {'TEAM_ID': 1, f'seasons.{selected_season}.GAMES': 1, '_id': 0}
        ))

    return jsonify(results)


def apply_team_schedule_filters(season, season_type, filters):
    initial_match_stage = {"$match": {}}

    results = None
    for stat_filter in filters:
        operator = stat_filter['operation']
        value = stat_filter['value']
        location = stat_filter['location']

        path = f"STATS.{season}.{season_type}.{location}"

        try:
            value = float(value)  # Try to convert value to a float for numerical comparisons
        except ValueError:
            pass  # Keep value as a string for non-numerical comparisons

        pipeline = [initial_match_stage]

        if operator == 'greater than':
            pipeline.append({"$match": {path: {"$gt": value}}})
        elif operator == 'less than':
            pipeline.append({"$match": {path: {"$lt": value}}})
        elif operator == 'equals':
            pipeline.append({"$match": {path: value}})
        elif operator == 'contains':
            pipeline.append({"$match": {path: {"$regex": value, "$options": "i"}}})
        elif operator == 'top':
            pipeline.append({"$sort": {path: -1}})
            pipeline.append({"$limit": int(value)})
        elif operator == 'bottom':
            pipeline.append({"$sort": {path: 1}})
            pipeline.append({"$limit": int(value)})

        pipeline.append({"$project": {'GAME_ID': 1}})

        current_results = list(players_collection.aggregate(pipeline))

        if results is None:
            results = current_results
        else:
            # Intersect current results with previous results
            current_ids = {game['GAME_ID'] for game in current_results}
            results = [game for game in results if game['GAME_ID'] in current_ids]

    if results:
        game_ids = [game['GAME_ID'] for game in results]
        final_results = list(players_collection.find(
            {'GAME_ID': {'$in': game_ids}},
            {'GAME_ID': 1, 'DISPLAY_FI_LAST': 1, 'TEAM_ID': 1, 'POSITION': 1, f'STATS.{season}.{season_type}': 1, '_id': 0}
        ))
    else:
        final_results = []

    return final_results


@app.route('/get_awards/by_award', methods=['GET'])
def get_awards_by_award():
    try:
        # logging.info(f"(get_awards_by_award) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_awards_by_award) {query_params}")

        # Validate the award parameter
        award = query_params.get('award')
        if not award:
            return jsonify({"error": "Award parameter is required"}), 400

        # Query the database for both YEAR and the specific award
        years = list(lg_history_collection.find(
            {award: {"$exists": True}},  # Only return documents where the award exists
            {award: 1, "_id": 0}  # Return both YEAR and award field
        ))

        if years:
            # logging.info(f"(get_awards_by_award) Retrieved awards from MongoDB")
            return jsonify(years)
        else:
            logging.warning("(get_awards_by_award) No award data found in MongoDB")
            return jsonify({"error": "No award found"})

    except Exception as e:
        logging.error(f"(get_awards_by_award) Error retrieving award: {e}")
        return jsonify({"error": "Failed to retrieve award"}), 500


@app.route('/get_awards', methods=['GET'])
def get_awards():
    try:
        # logging.info(f"(get_awards) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_awards) {query_params}")

        season = query_params['season']

        # Query the database
        year = lg_history_collection.find_one(
            {"YEAR": season},
            {"YEAR": 0, "_id": 0}
        )

        if year:
            # logging.info(f"(get_awards) Retrieved {season} from MongoDB")
            return jsonify(year)
        else:
            logging.warning("(get_awards) No award data found in MongoDB")
            return jsonify({"error": "No award found"})

    except Exception as e:
        logging.error(f"(get_awards) Error retrieving season: {e}")
        return jsonify({"error": "Failed to retrieve season"}), 500


@app.route('/get_draft/by_pick', methods=['GET'])
def get_draft_by_pick():
    try:
        query_params = request.args.to_dict()
        ovr_pick = int(query_params['overallPick'])  # Ensure overallPick is treated as an integer
        results = []

        # Query the database for all draft documents
        drafts = draft_collection.find({}, {"_id": 0, "SELECTIONS": 1})  # Exclude _id and only return SELECTIONS

        # Loop through each draft document and find the selection with the matching OVERALL_PICK
        for draft in drafts:
            selections = draft.get('SELECTIONS', [])
            for selection in selections:
                if selection.get('OVERALL_PICK') == ovr_pick:
                    results.append(selection)
                    break

        if results:
            return jsonify(results), 200
        else:
            return jsonify({"error": "No matching picks found"}), 404

    except Exception as e:
        logging.error(f"Error retrieving draft picks: {e}")
        return jsonify({"error": "Failed to retrieve draft picks"}), 500


@app.route('/get_draft', methods=['GET'])
def get_draft():
    try:
        # logging.info(f"(get_draft) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_draft) {query_params}")

        draft_year = query_params['draftYear']

        # Query the database
        draft = draft_collection.find_one(
            {"YEAR": draft_year},
            {"_id": 0}
        )

        if draft:
            # logging.info(f"(get_draft) Retrieved {draft_year} NBA Draft from MongoDB")
            return jsonify(draft)
        else:
            logging.warning("(get_draft) No draft data found in MongoDB")
            return jsonify({"error": "No draft found"})

    except Exception as e:
        logging.error(f"(get_draft) Error retrieving draft: {e}")
        return jsonify({"error": "Failed to retrieve draft"}), 500


@app.route('/get_transactions', methods=['GET'])
def get_transactions():
    try:
        # Query the database
        transactions = transactions_collection.find(
            {},
            {"_id": 0}
        )

        transactions = list(transactions)

        if transactions:
            # logging.info(f"(get_transactions) Retrieved transactions from MongoDB")
            return transactions
        else:
            logging.warning("(get_transactions) No transactions data found in MongoDB")
            return jsonify({"error": "No transactions found"})

    except Exception as e:
        logging.error(f"(get_transactions) Error retrieving transactions: {e}")
        return jsonify({"error": "Failed to retrieve transactions"}), 500


@app.route('/stats_query', methods=['POST'])
def query_database():
    data = request.json
    selected_season = data.get('selectedSeason')
    selected_season_type = data.get('selectedSeasonType')

    position_map = {
        'ALL': '',
        'G': 'Guard',
        'F': 'Forward',
        'C': 'Center',
        'G-F': 'Guard-Forward',
        'F-G': 'Forward-Guard',
        'C-F': 'Center-Forward',
        'F-C': 'Forward-Center',
    }

    position = position_map[data.get('selectedPosition')]

    filters = data.get('filters')

    if filters:
        results = apply_player_filters(selected_season, selected_season_type, filters, position)
    else:
        query = {f"STATS.{selected_season}.{selected_season_type}": {"$exists": True}}
        if position:
            query['POSITION'] = position
        results = list(players_collection.find(
            query,
            {
                'PERSON_ID': 1,
                'DISPLAY_FI_LAST': 1,
                'TEAM_ID': 1,
                'POSITION': 1,
                f'STATS.{selected_season}.{selected_season_type}': 1,
                '_id': 0
            }
        ))

    return jsonify(results)


def apply_player_filters(season, season_type, filters, position):
    initial_match_stage = {"$match": {}}
    if position:
        initial_match_stage["$match"]['POSITION'] = position

    results = None
    for stat_filter in filters:
        operator = stat_filter['operation']
        value = stat_filter['value']
        location = stat_filter['location']

        path = f"STATS.{season}.{season_type}.{location}"

        try:
            value = float(value)  # Try to convert value to a float for numerical comparisons
        except ValueError:
            pass  # Keep value as a string for non-numerical comparisons

        pipeline = [initial_match_stage]

        if operator == 'greater than':
            pipeline.append({"$match": {path: {"$gt": value}}})
        elif operator == 'less than':
            pipeline.append({"$match": {path: {"$lt": value}}})
        elif operator == 'equals':
            pipeline.append({"$match": {path: value}})
        elif operator == 'contains':
            pipeline.append({"$match": {path: {"$regex": value, "$options": "i"}}})
        elif operator == 'top':
            pipeline.append({"$sort": {path: -1}})
            pipeline.append({"$limit": int(value)})
        elif operator == 'bottom':
            pipeline.append({"$sort": {path: 1}})
            pipeline.append({"$limit": int(value)})

        pipeline.append({"$project": {'PERSON_ID': 1}})

        current_results = list(players_collection.aggregate(pipeline, allowDiskUse=True))

        if results is None:
            results = current_results
        else:
            # Intersect current results with previous results
            current_ids = {player['PERSON_ID'] for player in current_results}
            results = [player for player in results if player['PERSON_ID'] in current_ids]

    if results:
        person_ids = [player['PERSON_ID'] for player in results]
        final_results = list(players_collection.find(
            {'PERSON_ID': {'$in': person_ids}},
            {'PERSON_ID': 1, 'DISPLAY_FI_LAST': 1, 'TEAM_ID': 1, 'POSITION': 1,
             f'STATS.{season}.{season_type}.BASIC.AGE': 1,
             f'STATS.{season}.{season_type}.BASIC.GP': 1,
             f'STATS.{season}.{season_type}.BASIC.MIN': 1,
             f'STATS.{season}.{season_type}.ADV.MIN': 1,
             f'STATS.{season}.{season_type}.ADV.POSS': 1,
             f'STATS.{season}.{season_type}.ADV.POSS_PER_GM': 1,
             f'STATS.{season}.{season_type}.BASIC.PTS': 1,
             f'STATS.{season}.{season_type}.BASIC.REB': 1,
             f'STATS.{season}.{season_type}.BASIC.AST': 1,
             f'STATS.{season}.{season_type}.BASIC.STL': 1,
             f'STATS.{season}.{season_type}.BASIC.BLK': 1,
             f'STATS.{season}.{season_type}.BASIC.TOV': 1,
             f'STATS.{season}.{season_type}.BASIC.FGM': 1,
             f'STATS.{season}.{season_type}.BASIC.FGA': 1,
             f'STATS.{season}.{season_type}.BASIC.FG_PCT': 1,
             f'STATS.{season}.{season_type}.BASIC.FG3M': 1,
             f'STATS.{season}.{season_type}.BASIC.FG3A': 1,
             f'STATS.{season}.{season_type}.BASIC.FG3_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.6+ Feet - Wide Open.FG3_PCT': 1,
             f'STATS.{season}.{season_type}.BASIC.3PAr': 1,
             f'STATS.{season}.{season_type}.BASIC.FTM': 1,
             f'STATS.{season}.{season_type}.BASIC.FTA': 1,
             f'STATS.{season}.{season_type}.BASIC.FT_PCT': 1,
             f'STATS.{season}.{season_type}.BASIC.FT_PER_FGA': 1,
             f'STATS.{season}.{season_type}.ADV.EFG_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.TS_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.SCORING_BREAKDOWN.PCT_UAST_FGM': 1,
             f'STATS.{season}.{season_type}.ADV.SCORING_BREAKDOWN.PCT_UAST_3PM': 1,
             f'STATS.{season}.{season_type}.ADV.USG_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.OFFENSIVE_LOAD': 1,
             f'STATS.{season}.{season_type}.ADV.ADJ_TOV_PCT': 1,
             f'STATS.{season}.{season_type}.BASIC.PLUS_MINUS': 1,
             f'STATS.{season}.{season_type}.ADV.NET_RATING_ON_OFF': 1,
             f'STATS.{season}.{season_type}.ADV.OFF_RATING_ON_OFF': 1,
             f'STATS.{season}.{season_type}.ADV.DEF_RATING_ON_OFF': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.TOUCHES': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.TIME_OF_POSS': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.AVG_SEC_PER_TOUCH': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.AVG_DRIB_PER_TOUCH': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.FGA_PER_TOUCH': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.PASSES_PER_TOUCH': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.TOV_PER_TOUCH': 1,
             f'STATS.{season}.{season_type}.ADV.TOUCHES.PFD_PER_TOUCH': 1,
             f'STATS.{season}.{season_type}.ADV.REBOUNDING.REB': 1,
             f'STATS.{season}.{season_type}.ADV.REBOUNDING.OREB': 1,
             f'STATS.{season}.{season_type}.ADV.OREB_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.REBOUNDING.OREB_CHANCE_PCT_ADJ': 1,
             f'STATS.{season}.{season_type}.ADV.REBOUNDING.DREB': 1,
             f'STATS.{season}.{season_type}.ADV.DREB_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.REBOUNDING.DREB_CHANCE_PCT_ADJ': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.PASSES_MADE': 1,
             f'STATS.{season}.{season_type}.ADV.AST_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.SECONDARY_AST': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.FT_AST': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.AST_ADJ': 1,
             f'STATS.{season}.{season_type}.ADV.BOX_CREATION': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.POTENTIAL_AST': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.AST_PTS_CREATED': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.AST_TO_PASS_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.PASSING.AST_TO_PASS_PCT_ADJ': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVES': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVES_PER_TOUCH': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_PTS_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_FT_PER_FGA': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_FG_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_TS_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_PASSES_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_AST_PCT': 1,
             f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_TOV_PCT': 1,
             f'STATS.{season}.{season_type}.HUSTLE.SCREEN_ASSISTS': 1,
             f'STATS.{season}.{season_type}.HUSTLE.SCREEN_AST_PTS': 1,
             f'STATS.{season}.{season_type}.BASIC.PF': 1,
             f'STATS.{season}.{season_type}.BASIC.PFD': 1,
             f'STATS.{season}.{season_type}.HUSTLE.LOOSE_BALLS_RECOVERED': 1,
             f'STATS.{season}.{season_type}.HUSTLE.CHARGES_DRAWN': 1,
             f'STATS.{season}.{season_type}.ADV.DEF_RATING': 1,
             f'STATS.{season}.{season_type}.ADV.VERSATILITY_SCORE': 1,
             f'STATS.{season}.{season_type}.ADV.MATCHUP_DIFFICULTY': 1,
             f'STATS.{season}.{season_type}.ADV.DEF_IMPACT_EST': 1,
             f'STATS.{season}.{season_type}.HUSTLE.DEFLECTIONS': 1,
             f'STATS.{season}.{season_type}.HUSTLE.CONTESTED_SHOTS': 1,
             '_id': 0}
        ))
    else:
        final_results = []

    return final_results


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
                    "compound": {
                        "should": [
                            {
                                "autocomplete": {
                                    "query": query,
                                    "path": "DISPLAY_FIRST_LAST",
                                    "fuzzy": {
                                        "maxEdits": 2,
                                        "prefixLength": 1
                                    }
                                }
                            },
                            {
                                "text": {
                                    "query": query,
                                    "path": "DISPLAY_FIRST_LAST",
                                    "fuzzy": {
                                        "maxEdits": 2
                                    }
                                }
                            }
                        ]
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
                    "TEAM_ID": 1,
                    'FROM_YEAR': 1,
                    'TO_YEAR': 1
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


@app.route('/get_nba_cup', methods=['GET'])
def get_nba_cup():
    try:
        query_params = request.args.to_dict()
        season = query_params.get('season')

        # Query the database
        nba_cup = cup_collection.find_one(
            {f"SEASON": season},
            {"_id": 0}
        )

        if nba_cup:
            # logging.info(f"(get_nba_cup) Retrieved {season} NBA Cup from MongoDB")
            return jsonify(nba_cup)
        else:
            logging.warning("(get_nba_cup) No games found in MongoDB")
            return jsonify({"error": "No games found"})

    except Exception as e:
        logging.error(f"(get_nba_cup) Error retrieving cup data: {e}")
        return jsonify({"error": "Failed to retrieve cup data"}), 500


@app.route('/get_playoffs', methods=['GET'])
def get_playoff_bracket():
    try:
        # logging.info(f"(get_playoffs) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_playoffs) {query_params}")
        season = query_params.get('season')

        # Query the database
        playoffs = playoff_collection.find_one(
            {f"SEASON": season},
            {"_id": 0}
        )

        if playoffs:
            # logging.info(f"(get_playoffs) Retrieved {season} playoffs from MongoDB")
            return jsonify(playoffs)
        else:
            logging.warning("(get_playoffs) No games found in MongoDB")
            return jsonify({"error": "No games found"})

    except Exception as e:
        logging.error(f"(get_playoffs) Error retrieving playoff data: {e}")
        return jsonify({"error": "Failed to retrieve playoff data"}), 500


@app.route('/game_dates', methods=['GET'])
def get_dates():
    dates = games_collection.distinct('GAME_DATE')
    return jsonify(dates)


@app.route('/live_scores')
def stream_scores():
    def generate():
        while True:
            # Replace this with your NBA score-fetching logic
            updated_scores = fetch_latest_nba_scores()  # Custom function to fetch scores
            yield f"data: {jsonify(updated_scores)}\n\n"
            time.sleep(5)  # Interval for sending updates (e.g., every 5 seconds)

    return Response(generate(), content_type='text/event-stream')


def fetch_latest_nba_scores():
    # This is your logic to retrieve updated NBA scores from the backend.
    return {
        'game_1': {'home_team': 'Lakers', 'away_team': 'Warriors', 'score': '102-98'},
        'game_2': {'home_team': 'Celtics', 'away_team': 'Heat', 'score': '110-105'}
    }


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


@app.route('/get_game', methods=['GET'])
def get_game():
    try:
        # logging.info(f"(get_game) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_game) {query_params}")

        game_id = query_params['gameId']

        # Query the database
        game = games_collection.find_one(
            {f"GAMES.{game_id}": {"$exists": True}},
            {"_id": 0, f"GAMES.{game_id}": 1}
        )

        if game:
            # logging.info(f"(get_game) Retrieved game {game_id} from MongoDB")
            return jsonify(game["GAMES"][game_id])
        else:
            logging.warning("(get_game) No games found in MongoDB")
            return jsonify({"error": "No games found"})

    except Exception as e:
        logging.error(f"(get_game) Error retrieving games: {e}")
        return jsonify({"error": "Failed to retrieve games"}), 500


@app.route('/get_team_player_stats', methods=['GET'])
def get_team_player_stats():
    try:
        # logging.info(f"(get_team_player_stats) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_team_player_stats) {query_params}")

        # Retrieve the required parameter
        team_id_str = query_params.get('team_id')
        if not team_id_str:
            return jsonify({"error": "team_id is required"}), 400

        # Convert the person_id to an integer
        try:
            team_id = int(team_id_str)
        except ValueError:
            return jsonify({"error": "team_id must be an integer"}), 400

        # Query the database
        players = players_collection.aggregate([
            {
                "$search": {
                    "index": "active_by_team",
                    "compound": {
                        "must": [
                            {
                                "equals": {
                                    "value": team_id,
                                    "path": "TEAM_ID"
                                }
                            },
                            {
                                "text": {
                                    "query": "Active",
                                    "path": "ROSTERSTATUS"
                                }
                            }
                        ]
                    }
                }
            },
            {
                "$project": {
                    "_id": 0,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.POSS": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.MIN": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.PTS": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.REB": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.AST": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.STL": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.BLK": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.TOV": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.FGM": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.FGA": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.FG3M": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.FG3A": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.FTM": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.FTA": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.OREB": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.DREB": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.PF": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.PLUS_MINUS": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.EFG_PCT": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.TS_PCT": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.USG_PCT": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.OFF_RATING": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.DEF_RATING": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.NET_RATING": 1,

                    f"STATS.{k_current_season}.REGULAR SEASON.ADV.POSS": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.MIN": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.PTS": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.REB": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.AST": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.STL": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.BLK": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.TOV": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.FGM": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.FGA": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.FG3M": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.FG3A": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.FTM": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.FTA": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.OREB": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.DREB": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.PF": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.PLUS_MINUS": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.ADV.EFG_PCT": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.ADV.TS_PCT": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.ADV.USG_PCT": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.ADV.OFF_RATING": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.ADV.DEF_RATING": 1,
                    f"STATS.{k_current_season}.REGULAR SEASON.ADV.NET_RATING": 1,

                    f"STATS.{k_current_season}.PLAYOFFS.ADV.POSS": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.MIN": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.PTS": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.REB": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.AST": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.STL": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.BLK": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.TOV": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.FGM": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.FGA": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.FG3M": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.FG3A": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.FTM": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.FTA": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.OREB": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.DREB": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.PF": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.PLUS_MINUS": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.ADV.EFG_PCT": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.ADV.TS_PCT": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.ADV.USG_PCT": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.ADV.OFF_RATING": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.ADV.DEF_RATING": 1,
                    f"STATS.{k_current_season}.PLAYOFFS.ADV.NET_RATING": 1,
                }
            }
        ])

        players = list(players)

        if len(players) > 0:
            # logging.info(f"(get_team_player_stats) Retrieved players from MongoDB")
            return jsonify(players)
        else:
            logging.warning("(get_team_player_stats) No players found in MongoDB")
            return jsonify({"error": "No players found"}), 404

    except Exception as e:
        logging.error(f"(get_team_player_stats) Error retrieving players: {e}")
        return jsonify({"error": "Failed to retrieve players"}), 500


@app.route('/get_player_shot_chart', methods=['GET'])
def get_player_shot_chart():
    try:
        # logging.info(f"(get_player_shot_chart) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_player_shot_chart) {query_params}")

        # Retrieve the required parameters
        person_id = query_params.get('person_id')
        if not person_id:
            return jsonify({"error": "person_id is required"}), 400

        season = query_params.get('season')
        if not season:
            return jsonify({"error": "season is required"}), 400

        season_type = query_params.get('season_type')
        if not season:
            return jsonify({"error": "season_type is required"}), 400

        # Convert the person_id to an integer
        try:
            player_id = int(person_id)
        except ValueError:
            return jsonify({"error": "person_id must be an integer"}), 400

        # Query the database to find the player by PERSON_ID
        player = player_shots_collection.aggregate([
            {
                "$search": {
                    "index": "player_id",
                    "equals": {
                        "value": player_id,
                        "path": "PLAYER_ID"
                    }
                }
            },
            {
                "$project": {
                    "_id": 0,
                    f"SEASON.{season}.{season_type}": 1
                }
            }
        ])

        player = list(player)

        if len(player) > 0:
            # logging.info(f"(get_player_shot_chart) Retrieved player {person_id} from MongoDB")
            return jsonify(player[0])
        else:
            logging.warning("(get_player_shot_chart) No player found in MongoDB")
            return jsonify({"error": "No player found"}), 404

    except Exception as e:
        logging.error(f"(get_player_shot_chart) Error retrieving player: {e}")
        return jsonify({"error": "Failed to retrieve player"}), 500


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


@app.after_request
def log_response_size(response):
    global bytes_transferred
    response_size = len(response.get_data())
    bytes_transferred += response_size
    logging.info(f"Endpoint: {request.path}, Response Size: {response_size} bytes, Session: {bytes_transferred} bytes, {round(bytes_transferred / 1000000000, 2)} GB")
    return response


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient('mongodb+srv://jmoletteire:J%40ckpa%24%245225@splash.p0xumnu.mongodb.net/')
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

    # app.run(host='0.0.0.0', port=8000)
