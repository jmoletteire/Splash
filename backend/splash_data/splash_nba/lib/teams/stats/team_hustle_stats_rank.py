from pymongo import MongoClient
from splash_nba.util.env import uri, k_current_season
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

# Replace with your MongoDB connection string
client = MongoClient(uri)
db = client.splash
teams_collection = db.nba_teams
logging.info("Connected to MongoDB")


def rank_hustle_stats_current_season():
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
        logging.info(f"\nCalculating {stat} rank...")

        logging.info(f"Season: {k_current_season}")
        pipeline = [
            {
                "$setWindowFields": {
                    "sortBy": {
                        f"seasons.{k_current_season}.STATS.HUSTLE.{stat}": -1
                    },
                    "output": {
                        f"seasons.{k_current_season}.STATS.HUSTLE.{stat}_RANK": {
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
                {"$set": {f"seasons.{k_current_season}.STATS.HUSTLE.{stat}_RANK": result['seasons'][k_current_season]['STATS']['HUSTLE'][f'{stat}_RANK']}}
            )


def rank_hustle_stats_all_seasons():
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
