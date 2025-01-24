import logging
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI, CURR_SEASON, CURR_SEASON_TYPE
    PROXY = None
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI, CURR_SEASON, CURR_SEASON_TYPE
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def rank_hustle_stats_current_season():
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"(Team Hustle Rank) Failed to connect to MongoDB: {e}")
        exit(1)

    # Stats to rank
    hustle_stats = [
        'CONTESTED_SHOTS',
        'DEFLECTIONS',
        'CHARGES_DRAWN',
        'SCREEN_ASSISTS',
        'SCREEN_AST_PTS',
        'LOOSE_BALLS_RECOVERED',
        'BOX_OUTS',
        'OFF_BOXOUTS',
        'DEF_BOXOUTS'
    ]

    # Loop over each season to build the pipeline
    for stat in hustle_stats:
        logging.info(f"\n(Team Hustle Rank) Calculating {stat} rank...")
        try:
            pipeline = [
                {
                    "$setWindowFields": {
                        "sortBy": {
                            f"seasons.{CURR_SEASON}.STATS.{CURR_SEASON_TYPE}.HUSTLE.{stat}": -1
                        },
                        "output": {
                            f"seasons.{CURR_SEASON}.STATS.{CURR_SEASON_TYPE}.HUSTLE.{stat}_RANK": {
                                "$documentNumber": {}
                            }
                        }
                    }
                }
            ]

            # Execute the pipeline and get the results
            results = list(teams_collection.aggregate(pipeline))

            logging.info(f"(Team Hustle Rank) Adding {stat}_RANK to database.")

            # Update each document with the new rank field
            for result in results:
                teams_collection.update_one(
                    {"_id": result["_id"]},
                    {"$set": {f"seasons.{CURR_SEASON}.STATS.{CURR_SEASON_TYPE}.HUSTLE.{stat}_RANK": result['seasons'][CURR_SEASON]['STATS'][CURR_SEASON_TYPE]['HUSTLE'][f'{stat}_RANK']}}
                )
        except Exception as e:
            logging.error(f"(Team Hustle Rank) Failed to add {stat} to database: {e}")
            continue


def rank_hustle_stats_all_seasons():
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"(Team Hustle Rank) Failed to connect to MongoDB: {e}")
        exit(1)

    # Stats to rank
    hustle_stats = [
        'CONTESTED_SHOTS',
        'DEFLECTIONS',
        'CHARGES_DRAWN',
        'SCREEN_ASSISTS',
        'SCREEN_AST_PTS',
        'LOOSE_BALLS_RECOVERED',
        'BOX_OUTS',
        'OFF_BOXOUTS',
        'DEF_BOXOUTS'
    ]

    # List of seasons
    seasons = [
        "2015-16",
        "2016-17",
        "2017-18",
        "2018-19",
        "2019-20",
        "2020-21",
        "2021-22",
        "2022-23",
        "2023-24"
    ]

    # Loop over each season to build the pipeline
    for stat in hustle_stats:
        logging.info(f"\nCalculating {stat} rank...")
        for season in seasons:
            logging.info(f"Season: {season}")
            pipeline = [
                {
                    "$setWindowFields": {
                        "sortBy": {
                            f"seasons.{season}.STATS.HUSTLE.{stat}": -1
                        },
                        "output": {
                            f"seasons.{season}.STATS.HUSTLE.{stat}_RANK": {
                                "$documentNumber": {}
                            }
                        }
                    }
                }
            ]

            # Execute the pipeline and get the results
            results = list(teams_collection.aggregate(pipeline))

            logging.info(f"Adding {stat}_RANK to database.")

            # Update each document with the new rank field
            for result in results:
                teams_collection.update_one(
                    {"_id": result["_id"]},
                    {"$set": {f"seasons.{season}.STATS.HUSTLE.{stat}_RANK": result['seasons'][season]['STATS']['HUSTLE'][f'{stat}_RANK']}}
                )
