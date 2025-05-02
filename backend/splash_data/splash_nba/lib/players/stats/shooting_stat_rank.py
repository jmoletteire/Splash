import logging
from splash_nba.imports import get_mongo_collection, CURR_SEASON


def current_season_shooting_stat_ranks(season_type):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')

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

    for shot_type in shot_types:
        logging.info(f"(Shooting Stat Rank) Shot Type: {shot_type}")
        for stat in shooting:

            logging.info(f"(Shooting Stat Rank) Calculating {stat} rank...")

            # Define the pipeline with filtering
            pipeline = [
                {
                    "$match": {
                        f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}": {"$exists": True}
                    }
                },
                {
                    "$project": {
                        f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}": 1
                    }
                },
                {
                    "$setWindowFields": {
                        "sortBy": {
                            f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}": -1
                        },
                        "output": {
                            f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}_RANK": {
                                "$documentNumber": {}
                            }
                        }
                    }
                }
            ]

            # Execute the pipeline and get the results
            results = list(players_collection.aggregate(pipeline, allowDiskUse=True))

            logging.info(f"(Shooting Stat Rank) Adding {stat}_RANK to database.")

            # Update each document with the new rank field
            for result in results:
                try:
                    res = result['STATS'][CURR_SEASON][season_type]['ADV']['SHOOTING']['SHOT_TYPE'][shot_type][f'{stat}_RANK']
                except KeyError:
                    res = 0

                players_collection.update_one(
                    {"_id": result["_id"]},
                    {"$set": {
                        f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}_RANK": res
                        }
                    }
                )

    for closest_defender in closest_defender_types:
        logging.info(f"(Shooting Stat Rank) Closest Defender: {closest_defender}")
        for stat in shooting:

            logging.info(f"(Shooting Stat Rank) Calculating {stat} rank...")

            # Define the pipeline with filtering
            pipeline = [
                {
                    "$match": {
                        f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}": {"$exists": True}
                    }
                },
                {
                    "$project": {
                        f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}": 1
                    }
                },
                {
                    "$setWindowFields": {
                        "sortBy": {
                            f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}": -1
                        },
                        "output": {
                            f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}_RANK": {
                                "$documentNumber": {}
                            }
                        }
                    }
                }
            ]

            # Execute the pipeline and get the results
            results = list(players_collection.aggregate(pipeline, allowDiskUse=True))

            logging.info(f"(Shooting Stat Rank) Adding {stat}_RANK to database.")

            # Update each document with the new rank field
            for result in results:
                res = result['STATS'][CURR_SEASON][season_type]['ADV']['SHOOTING']['CLOSEST_DEFENDER'][closest_defender][f'{stat}_RANK']

                players_collection.update_one(
                    {"_id": result["_id"]},
                    {"$set": {
                        f"STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}_RANK": res
                    }
                    }
                )


def shooting_stat_rank():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
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

    season_type = 'REGULAR SEASON'

    for season in seasons:
        logging.info(f"Season: {season}")
        # for shot_type in shot_types:
        for closest_defender in closest_defender_types:
            # logging.info(f"Shot Type: {shot_type}")
            logging.info(f"Closest Defender: {closest_defender}")
            for stat in shooting:

                logging.info(f"\nCalculating {stat} rank...")

                # Define the pipeline with filtering
                pipeline = [
                    {
                        "$match": {
                            f"STATS.{season}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}": {"$exists": True}
                        }
                    },
                    {
                        "$project": {
                            f"STATS.{season}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}": 1
                        }
                    },
                    {
                        "$setWindowFields": {
                            "sortBy": {
                                f"STATS.{season}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}": -1
                            },
                            "output": {
                                f"STATS.{season}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}_RANK": {
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
                    # res = result['STATS'][season][season_type]['ADV']['SHOOTING']['SHOT_TYPE'][shot_type][f'{stat}_RANK']
                    res = result['STATS'][season][season_type]['ADV']['SHOOTING']['CLOSEST_DEFENDER'][closest_defender][f'{stat}_RANK']

                    players_collection.update_one(
                        {"_id": result["_id"]},
                        {"$set": {
                            # f"STATS.{season}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type}.{stat}_RANK": res
                            f"STATS.{season}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender}.{stat}_RANK": res
                        }
                        }
                    )

    logging.info("Ranking calculation completed.")