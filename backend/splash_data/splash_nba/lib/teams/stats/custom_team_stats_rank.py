import logging
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI, CURR_SEASON, CURR_SEASON_TYPE
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import URI, CURR_SEASON, CURR_SEASON_TYPE
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def current_season_custom_team_stats_rank():
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"(Custom Team Stats Rank) Failed to connect to MongoDB: {e}")
        exit(1)

    # Stats to rank
    custom_stats = [
        # BASIC
        ("FGM_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FGA_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FTM_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FTA_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FG3M_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FG3A_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("STL_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("BLK_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("REB_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("OREB_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("DREB_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("TOV_PER_100", f"{CURR_SEASON_TYPE}.BASIC", 1),
        ("PF_PER_100", f"{CURR_SEASON_TYPE}.BASIC", 1),
        ("PFD_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("PTS_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FT_PER_FGA", f"{CURR_SEASON_TYPE}.BASIC", -1),

        ("3PAr", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FTAr", f"{CURR_SEASON_TYPE}.BASIC", -1),

        # ADV
        ("XPTS_DIFF", f"{CURR_SEASON_TYPE}.ADV", -1),
        ("XPTS_FOR", f"{CURR_SEASON_TYPE}.ADV", -1),
        ("XPTS_AGAINST", f"{CURR_SEASON_TYPE}.ADV", 1),

        ("XPTS_DIFF_PER_100", f"{CURR_SEASON_TYPE}.ADV", -1),
        ("XPTS_FOR_PER_100", f"{CURR_SEASON_TYPE}.ADV", -1),
        ("XPTS_AGAINST_PER_100", f"{CURR_SEASON_TYPE}.ADV", 1),

        # HUSTLE
        ("CONTESTED_SHOTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_ASSISTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_AST_PTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("BOX_OUTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("OFF_BOXOUTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEF_BOXOUTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEFLECTIONS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("LOOSE_BALLS_RECOVERED_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("CHARGES_DRAWN_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),

        ("CONTESTED_SHOTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_ASSISTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_AST_PTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("BOX_OUTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("OFF_BOXOUTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEF_BOXOUTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEFLECTIONS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("LOOSE_BALLS_RECOVERED", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("CHARGES_DRAWN", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
    ]

    # Initialize the pipeline list
    pipeline = []

    # Loop over each season to build the pipeline
    for stat in custom_stats:
        logging.info(f"\n(Team Custom Stats Rank) Calculating {stat[0]} rank...")

        loc = stat[1].split('.')

        pipeline = [
            {
                "$setWindowFields": {
                    "sortBy": {
                        f"seasons.{CURR_SEASON}.STATS.{stat[1]}.{stat[0]}": stat[2]
                    },
                    "output": {
                        f"seasons.{CURR_SEASON}.STATS.{stat[1]}.{stat[0]}_RANK": {
                            "$documentNumber": {}
                        }
                    }
                }
            }
        ]

        # Execute the pipeline and get the results
        results = list(teams_collection.aggregate(pipeline))

        logging.info(f"(Team Custom Stats Rank) Adding {stat[0]}_RANK to database.")

        # Update each document with the new rank field
        for result in results:
            if len(loc) == 2:
                res = result['seasons'][CURR_SEASON]['STATS'][loc[0]][loc[1]][f'{stat[0]}_RANK']
            elif len(loc) == 3:
                res = result['seasons'][CURR_SEASON]['STATS'][loc[0]][loc[1]][loc[2]][f'{stat[0]}_RANK']
            else:
                res = result['seasons'][CURR_SEASON]['STATS'][stat[1]][f'{stat[0]}_RANK']

            try:
                teams_collection.update_one(
                    {"_id": result["_id"]},
                    {"$set": {f"seasons.{CURR_SEASON}.STATS.{stat[1]}.{stat[0]}_RANK": res}}
                )
            except Exception as e:
                logging.error(f"(Team Custom Stats Rank) Failed to add {stat[0]}_RANK to database: {e}")
                continue


def custom_team_stats_rank():
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"(Custom Team Stats Rank) Failed to connect to MongoDB: {e}")
        exit(1)

    # Stats to rank
    custom_stats = [
        # BASIC
        ("FGM_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FGA_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FTM_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FTA_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FG3M_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FG3A_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("STL_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("BLK_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("REB_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("OREB_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("DREB_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("TOV_PER_100", f"{CURR_SEASON_TYPE}.BASIC", 1),
        ("PF_PER_100", f"{CURR_SEASON_TYPE}.BASIC", 1),
        ("PFD_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("PTS_PER_100", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FT_PER_FGA", f"{CURR_SEASON_TYPE}.BASIC", -1),

        ("3PAr", f"{CURR_SEASON_TYPE}.BASIC", -1),
        ("FTAr", f"{CURR_SEASON_TYPE}.BASIC", -1),

        # HUSTLE
        ("CONTESTED_SHOTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_ASSISTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_AST_PTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("BOX_OUTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("OFF_BOXOUTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEF_BOXOUTS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEFLECTIONS_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("LOOSE_BALLS_RECOVERED_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("CHARGES_DRAWN_PER_100", f"{CURR_SEASON_TYPE}.HUSTLE", -1),

        ("CONTESTED_SHOTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_ASSISTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("SCREEN_AST_PTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("BOX_OUTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("OFF_BOXOUTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEF_BOXOUTS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("DEFLECTIONS", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("LOOSE_BALLS_RECOVERED", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
        ("CHARGES_DRAWN", f"{CURR_SEASON_TYPE}.HUSTLE", -1),
    ]

    # List of seasons
    seasons = [
        '2024-25'
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
        '2012-13',
        '2011-12',
        '2010-11',
        '2009-10',
        '2008-09',
        '2007-08',
        '2006-07',
        '2005-06',
        '2004-05',
        '2003-04',
        '2002-03',
        '2001-02',
        '2000-01',
        '1999-00',
        '1998-99',
        '1997-98',
        '1996-97'
    ]

    # Initialize the pipeline list
    pipeline = []

    # Loop over each season to build the pipeline
    for season in seasons:
        logging.info(f"Season: {season}")
        for stat in custom_stats:
            logging.info(f"\nCalculating {stat[0]} rank...")

            loc = stat[1].split('.')

            if loc[-1] == 'HUSTLE' and season < '2016-17':
                continue

            pipeline = [
                {
                    "$setWindowFields": {
                        "sortBy": {
                            f"seasons.{season}.STATS.{stat[1]}.{stat[0]}": stat[2]
                        },
                        "output": {
                            f"seasons.{season}.STATS.{stat[1]}.{stat[0]}_RANK": {
                                "$documentNumber": {}
                            }
                        }
                    }
                }
            ]

            # Execute the pipeline and get the results
            results = list(teams_collection.aggregate(pipeline))

            logging.info(f"Adding {stat[0]}_RANK to database.")

            # Update each document with the new rank field
            for result in results:
                if len(loc) == 2:
                    res = result['seasons'][season]['STATS'][loc[0]][loc[1]][f'{stat[0]}_RANK']
                elif len(loc) == 3:
                    res = result['seasons'][season]['STATS'][loc[0]][loc[1]][loc[2]][f'{stat[0]}_RANK']
                else:
                    res = result['seasons'][season]['STATS'][stat[1]][f'{stat[0]}_RANK']

                try:
                    teams_collection.update_one(
                        {"_id": result["_id"]},
                        {"$set": {f"seasons.{season}.STATS.{stat[1]}.{stat[0]}_RANK": res}}
                    )
                except Exception as e:
                    logging.error(e)
                    continue


if __name__ == "__main__":
    current_season_custom_team_stats_rank()
