import json
import os
import time
from datetime import datetime
from pymongo.errors import PyMongoError
from flask import Flask, jsonify, request, Response, stream_with_context
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
    sports_collection = db.sports
    games_collection = db.nba_games
    teams_collection = db.nba_teams
    players_collection = db.nba_players
    player_shots_collection = db.nba_player_shot_data
    lg_history_collection = db.nba_league_history
    playoff_collection = db.nba_playoff_history
    cup_collection = db.nba_cup_history
    draft_collection = db.nba_draft_history
    transactions_collection = db.nba_transactions
    latest_news_collection = db.latest_news_articles

    logging.info("Connected to MongoDB")
except Exception as e:
    logging.error(f"Failed to connect to MongoDB: {e}")


@app.route("/latest-news", methods=['GET'])
def latest_news():
    try:
        # Query the database
        news_articles = latest_news_collection.find(
            {},
            {"_id": 0}
        )

        articles = list(news_articles)

        if articles:
            return articles
        else:
            logging.warning("(latest_news) No news articles found in MongoDB")
            return jsonify({"error": "No articles found"})

    except Exception as e:
        logging.error(f"(latest_news) Error retrieving transactions: {e}")
        return jsonify({"error": "Failed to retrieve articles"}), 500


@app.route('/awards/by-award', methods=['GET'])
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


@app.route('/awards/by-year', methods=['GET'])
def get_awards_by_year():
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
            # logging.info(f"(Awards) Retrieved {season} from MongoDB")
            return jsonify(year)
        else:
            logging.warning("(Awards) No award data found in MongoDB")
            return jsonify({"error": "No award found"})

    except Exception as e:
        logging.error(f"(Awards) Error retrieving season: {e}")
        return jsonify({"error": "Failed to retrieve season"}), 500


@app.route('/draft/by-pick', methods=['GET'])
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


@app.route('/draft/by-year', methods=['GET'])
def get_draft_by_year():
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


@app.route('/trans', methods=['GET'])
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


@app.route('/stats-query', methods=['POST'])
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


@app.route('/nba-cup', methods=['GET'])
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


@app.route('/playoff-bracket', methods=['GET'])
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


@app.route('/games/all-game-dates', methods=['GET'])
def get_game_dates():
    dates = games_collection.distinct('GAME_DATE')
    return jsonify(dates)


@app.route('/games', methods=['GET'])
def get_games():
    try:
        query_params = request.args.to_dict()
        game_date = query_params.get('date', datetime.utcnow().strftime('%Y-%m-%d'))  # Default to today's date
        game_id = query_params.get('gameId')  # `gameId` is optional

        # Base query to search games by date
        pipeline = [
            {
                "$search": {
                    "index": "game_index",
                    "phrase": {
                        "query": game_date,
                        "path": "GAME_DATE"
                    }
                }
            }
        ]

        # Add a projection step depending on whether a specific game is requested
        if game_id:
            pipeline.append({
                "$project": {
                    "_id": 0,
                    f"GAMES.{game_id}": 1
                }
            })
        else:
            pipeline.append({
                "$project": {
                    "_id": 0,
                    "GAMES": 1
                }
            })

        # Execute the query
        results = list(games_collection.aggregate(pipeline))

        if not results:
            logging.warning(f"(get_games) No games found in MongoDB for date {game_date}")
            return jsonify({"error": f"No games found for date {game_date}"}), 404

        if game_id:
            # If `gameId` is provided, return the specific game
            game = results[0].get("GAMES", {}).get(game_id)
            if not game:
                return jsonify({"error": f"No game found with id {game_id} on {game_date}"}), 404
            return jsonify(game)
        else:
            # Otherwise, return all games for the date
            return jsonify(results[0].get('GAMES', {}))

    except Exception as e:
        logging.error(f"(get_games) Error retrieving games: {e}")
        return jsonify({"error": "Failed to retrieve games"}), 500


@app.route('/players/stats/shot-chart', methods=['GET'])
def get_player_shot_chart():
    try:
        # logging.info(f"(get_player_shot_chart) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_player_shot_chart) {query_params}")

        # Retrieve the required parameters
        person_id = query_params.get('personId')
        if not person_id:
            return jsonify({"error": "personId is required"}), 400

        season = query_params.get('season')
        if not season:
            return jsonify({"error": "season is required"}), 400

        season_type = query_params.get('seasonType')
        if not season:
            return jsonify({"error": "seasonType is required"}), 400

        # Convert the person_id to an integer
        try:
            player_id = int(person_id)
        except ValueError:
            return jsonify({"error": "could not convert personId to integer"}), 400

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


@app.route('/players', methods=['GET'])
def get_player():
    try:
        # logging.info(f"(get_player) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_player) {query_params}")

        # Retrieve the required parameter
        person_id = query_params.get('personId')
        if not person_id:
            return jsonify({"error": "personId is required"}), 400

        # Convert the person_id to an integer
        try:
            query = int(person_id)
        except ValueError:
            return jsonify({"error": "could not convert personId to integer"}), 400

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


@app.route('/team/roster/player-stats', methods=['GET'])
def get_team_player_stats():
    try:
        # logging.info(f"(get_team_player_stats) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_team_player_stats) {query_params}")

        # Retrieve the required parameter
        team_id_str = query_params.get('teamId')
        if not team_id_str:
            return jsonify({"error": "teamId is required"}), 400

        # Convert the person_id to an integer
        try:
            team_id = int(team_id_str)
        except ValueError:
            return jsonify({"error": "could not convert teamId to integer"}), 400

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
                    "PERSON_ID": 1,
                    "TEAM_ID": 1,
                    "DISPLAY_FI_LAST": 1,
                    "DISPLAY_FIRST_LAST": 1,
                    "POSITION": 1,
                    "JERSEY": 1,
                    "PlayerRotowires": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.ADV.POSS": 1,
                    f"STATS.{k_prev_season}.REGULAR SEASON.BASIC.GP": 1,
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
                    f"STATS.{k_current_season}.REGULAR SEASON.BASIC.GP": 1,
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
                    f"STATS.{k_current_season}.PLAYOFFS.BASIC.GP": 1,
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


@app.route('/team/seasons', methods=['GET'])
def get_team_seasons():
    try:
        # logging.info(f"(get_team) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_team) {query_params}")

        # Retrieve the required parameter
        team_id = query_params.get('teamId')
        if not team_id:
            return jsonify({"error": "teamId is required"}), 400

        # Convert the team_id to an integer
        try:
            query = int(team_id)
        except ValueError:
            return jsonify({"error": "could not convert teamId to integer"}), 400

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
                    "_id": 0,
                    "seasons": 1
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


@app.route('/team', methods=['GET'])
def get_team():
    try:
        # logging.info(f"(get_team) {request.args}")
        query_params = request.args.to_dict()
        # logging.info(f"(get_team) {query_params}")

        # Retrieve the required parameter
        team_id = query_params.get('teamId')
        if not team_id:
            return jsonify({"error": "teamId is required"}), 400

        # Convert the team_id to an integer
        try:
            query = int(team_id)
        except ValueError:
            return jsonify({"error": "could not convert teamId to integer"}), 400

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


@app.route('/teams/metadata', methods=['GET'])
def get_teams():
    try:
        # Query the database
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

        # Transform the keys
        teams = [
            {
                "sportId": team["SPORT_ID"],
                "teamId": team["TEAM_ID"],
                "abbv": team["ABBREVIATION"],
                "city": team["CITY"],
                "name": team["NICKNAME"],
                "seasons": sorted(
                    [
                        {
                            "year": season_key,
                            "rank": season_data["CONF_RANK"],
                            "wins": season_data["WINS"],
                            "losses": season_data["LOSSES"],
                            "pointsFor": season_data["STATS"]["REGULAR SEASON"]["BASIC"]["PTS"] if season_key >= '1996-97' else 0,
                            "pointsAgainst": int(season_data["STATS"]["REGULAR SEASON"]["BASIC"]["PTS"] - season_data["STATS"]["REGULAR SEASON"]["BASIC"]["PLUS_MINUS"]) if season_key >= '1996-97' else 0
                        }
                        for season_key, season_data in team["seasons"].items()
                    ],
                    key=lambda x: x["year"],  # Sorting key is the year
                    reverse=True
                )
            }
            for team in teams
        ]

        if teams:
            # logging.info(f"(get_teams) Retrieved teams from MongoDB")
            return teams
        else:
            logging.warning("(get_teams) No teams data found in MongoDB")
            return jsonify({"error": "No teams found"})

    except Exception as e:
        logging.error(f"(get_teams) Error retrieving teams: {e}")
        return jsonify({"error": "Failed to retrieve teams"}), 500


@app.route('/sports', methods=['GET'])
def get_sports():
    try:
        # Query the database
        sports = sports_collection.find(
            {},
            {"_id": 0}
        )

        sports = list(sports)

        if sports:
            # logging.info(f"(get_sports) Retrieved sports from MongoDB")
            return sports
        else:
            logging.warning("(get_sports) No sports found in MongoDB")
            return jsonify({"error": "No sports found"})

    except Exception as e:
        logging.error(f"(get_sports) Error retrieving sports: {e}")
        return jsonify({"error": "Failed to retrieve sports"}), 500


@app.route('/api/events', methods=['GET'])
def team_sse():
    def watch_team_changes():
        logging.info("watching changes")

        # Send an initial ping
        yield "event: ping\ndata: {\"message\": \"Connection Established\"}\n\n"

        try:
            with teams_collection.watch(full_document="updateLookup") as stream:
                logging.info("stream open")
                while stream.alive:
                    logging.info("stream alive")
                    try:
                        change = stream.try_next()
                        if change is not None:
                            # Process change
                            full_document = change.get("fullDocument", {})
                            updated_fields = change.get("updateDescription", {}).get("updatedFields", {})
                            event_data = {
                                "eventId": str(change["_id"]),
                                "teamId": full_document.get("TEAM_ID"),
                                "updatedFields": updated_fields
                            }
                            logging.info(f"Streaming SSE Event: {event_data}")
                            yield f"data: {json.dumps(event_data)}\n\n"
                    except StopIteration:
                        logging.info(f"(team_sse) StopIteration")
                        pass

                    # No changes, send a heartbeat
                    yield "event: ping\n\n"
                    time.sleep(1)  # Adjust delay to balance responsiveness
        except PyMongoError as e:
            logging.error(f"MongoDB watch error: {e}")
            yield f"data: Error: {str(e)}\n\n"

    return Response(stream_with_context(watch_team_changes()), content_type="text/event-stream")


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

        latest_news_collection = db.latest_news_articles

        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")

    # app.run(host='0.0.0.0', port=8000)
