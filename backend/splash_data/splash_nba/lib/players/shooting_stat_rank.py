from pymongo import MongoClient
from splash_nba.util.env import uri
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

# Replace with your MongoDB connection string
client = MongoClient(uri)
db = client.splash
players_collection = db.nba_players
logging.info("Connected to MongoDB")

shot_types = [
    'Catch and Shoot',
    'Pull Ups',
    'Less than 10 ft',
    'Other'
]

closest_defender_types = [
    '0-2 Feet - Very Tight',
    '2-4 Feet - Tight',
    '4-6 Feet - Open',
    '6+ Feet - Wide Open'
]

shooting = [
    'FGA_FREQUENCY',
    'FGM',
    'FGA',
    'FG_PCT',
    'EFG_PCT',
    'FG2A_FREQUENCY',
    'FG2M',
    'FG2A',
    'FG2_PCT',
    'FG3A_FREQUENCY',
    'FG3M',
    'FG3A',
    'FG3_PCT',
]

# List of seasons
seasons = [
    '2023-24',
    '2022-23',
    '2021-22',
    '2020-21',
    '2019-20',
    '2018-19',
    '2017-18',
    '2016-17',
    '2015-16',
    '2014-15',
    '2013-14',
]

for season in seasons:
    logging.info(f"Season: {season}")
    for shot_type in shot_types:
    # for closest_defender in closest_defender_types:
        logging.info(f"Shot Type: {shot_type}")
        # logging.info(f"Closest Defender: {closest_defender}")
        for stat in shooting:

            logging.info(f"\nCalculating {stat} rank...")

            # Define the pipeline with filtering
            pipeline = [
                {
                    "$match": {
                        f"STATS.{season}.PLAYOFFS.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}": {"$exists": True}
                    }
                },
                {
                    "$project": {
                        f"STATS.{season}.PLAYOFFS.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}": 1
                    }
                },
                {
                    "$setWindowFields": {
                        "sortBy": {
                            f"STATS.{season}.PLAYOFFS.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}": -1
                        },
                        "output": {
                            f"STATS.{season}.PLAYOFFS.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}_RANK": {
                                "$documentNumber": {}
                            }
                        }
                    }
                }
            ]

            # Execute the pipeline and get the results
            results = list(players_collection.aggregate(pipeline, allowDiskUse=True))

            logging.info(f"Adding {stat}_RANK to database.")

            # Update each document with the new rank field
            for result in results:
                res = result['STATS'][season]['PLAYOFFS']['ADV']['SHOOTING']['SHOT_TYPE'][shot_type][f'{stat}_RANK']
                # res = result['STATS'][season]['PLAYOFFS']['ADV']['SHOOTING']['CLOSEST_DEFENDER'][closest_defender][f'{stat}_RANK']

                players_collection.update_one(
                    {"_id": result["_id"]},
                    {"$set": {
                        f"STATS.{season}.PLAYOFFS.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}_RANK": res
                        # f"STATS.{season}.PLAYOFFS.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}_RANK": res
                    }
                    }
                )

logging.info("Ranking calculation completed.")