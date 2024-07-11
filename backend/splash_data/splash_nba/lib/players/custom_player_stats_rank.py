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

# Stats to rank
custom_stats = [
    # BASIC
    # ("3PAr", "PLAYOFFS.BASIC", -1),
    # ("FTAr", "PLAYOFFS.BASIC", -1),
    # ("FT_PER_FGM", "PLAYOFFS.BASIC", -1),

    # ("FGM_PER_75", "PLAYOFFS.BASIC", -1),
    # ("FGA_PER_75", "PLAYOFFS.BASIC", -1),
    # ("FTM_PER_75", "PLAYOFFS.BASIC", -1),
    # ("FTA_PER_75", "PLAYOFFS.BASIC", -1),
    # ("FG3M_PER_75", "PLAYOFFS.BASIC", -1),
    # ("FG3A_PER_75", "PLAYOFFS.BASIC", -1),
    # ("STL_PER_75", "PLAYOFFS.BASIC", -1),
    # ("BLK_PER_75", "PLAYOFFS.BASIC", -1),
    # ("REB_PER_75", "PLAYOFFS.BASIC", -1),
    # ("OREB_PER_75", "PLAYOFFS.BASIC", -1),
    # ("DREB_PER_75", "PLAYOFFS.BASIC", -1),
    # ("PF_PER_75", "BASIC", 1),
    # ("PFD_PER_75", "PLAYOFFS.BASIC", -1),
    # ("PTS_PER_75", "PLAYOFFS.BASIC", -1),

    # ADV
    # ("OFF_RATING_ON_OFF", "PLAYOFFS.ADV", -1),
    # ("DEF_RATING_ON_OFF", "PLAYOFFS.ADV", 1),
    # ("NET_RATING_ON_OFF", "PLAYOFFS.ADV", -1),
    # ("POSS_PER_GM", "PLAYOFFS.ADV", -1),

    # ADV -> SHOOTING
    ()

    # ADV -> PASSING
    # ("PASSES_MADE", "PLAYOFFS.ADV.PASSING", -1),
    # ("PASSES_RECEIVED", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST", "PLAYOFFS.ADV.PASSING", -1),
    # ("FT_AST", "PLAYOFFS.ADV.PASSING", -1),
    # ("SECONDARY_AST", "PLAYOFFS.ADV.PASSING", -1),
    # ("POTENTIAL_AST", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST_PTS_CREATED", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST_ADJ", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST_TO_PASS_PCT", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST_TO_PASS_PCT_ADJ", "PLAYOFFS.ADV.PASSING", -1),

    # ("PASSES_MADE_PER_75", "PLAYOFFS.ADV.PASSING", -1),
    # ("PASSES_RECEIVED_PER_75", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST_PER_75", "PLAYOFFS.ADV.PASSING", -1),
    # ("FT_AST_PER_75", "PLAYOFFS.ADV.PASSING", -1),
    # ("SECONDARY_AST_PER_75", "PLAYOFFS.ADV.PASSING", -1),
    # ("POTENTIAL_AST_PER_75", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST_PTS_CREATED_PER_75", "PLAYOFFS.ADV.PASSING", -1),
    # ("AST_ADJ_PER_75", "PLAYOFFS.ADV.PASSING", -1),

    # ("TOUCHES", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("FRONT_CT_TOUCHES", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("TIME_OF_POSS", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("AVG_SEC_PER_TOUCH", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("AVG_DRIB_PER_TOUCH", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("PTS_PER_TOUCH", "PLAYOFFS.ADV.TOUCHES", -1),

    # ("TOUCHES_PER_75", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("FRONT_CT_TOUCHES_PER_75", "PLAYOFFS.ADV.TOUCHES", -1),

    # The following lines are commented out
    # ("FGA_PER_TOUCH", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("PASSES_PER_TOUCH", "PLAYOFFS.ADV.TOUCHES", -1),
    # ("TOV_PER_TOUCH", "PLAYOFFS.ADV.TOUCHES", 1),
    # ("PFD_PER_TOUCH", "PLAYOFFS.ADV.TOUCHES", -1),

    # HUSTLE
    # ("CONTESTED_SHOTS_PER_75", "PLAYOFFS.HUSTLE", -1),
    # ("SCREEN_ASSISTS_PER_75", "PLAYOFFS.HUSTLE", -1),
    # ("SCREEN_AST_PTS_PER_75", "PLAYOFFS.HUSTLE", -1),
    # ("BOX_OUTS_PER_75", "PLAYOFFS.HUSTLE", -1),
    # ("OFF_BOXOUTS_PER_75", "PLAYOFFS.HUSTLE", -1),
    # ("DEF_BOXOUTS_PER_75", "PLAYOFFS.HUSTLE", -1),
    # ("DEFLECTIONS_PER_75", "PLAYOFFS.HUSTLE", -1),
    # ("LOOSE_BALLS_RECOVERED_PER_75", "PLAYOFFS.HUSTLE", -1),
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
    '''
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
    '''
]

for season in seasons:
    logging.info(f"Season: {season}")
    for stat in custom_stats:

        loc = stat[1].split('.')

        if (loc[-1] == 'PASSING' or loc[-1] == 'TOUCHES') and season < '2013-14':
            continue
        elif loc[-1] == 'HUSTLE' and season < '2016-17':
            continue

        logging.info(f"\nCalculating {stat[0]} rank...")

        # Define the pipeline with filtering
        pipeline = [
            {
                "$match": {
                    f"STATS.{season}.{stat[1]}.{stat[0]}": {"$exists": True}
                }
            },
            {
                "$setWindowFields": {
                    "sortBy": {
                        f"STATS.{season}.{stat[1]}.{stat[0]}": stat[2]
                    },
                    "output": {
                        f"STATS.{season}.{stat[1]}.{stat[0]}_RANK": {
                            "$documentNumber": {}
                        }
                    }
                }
            }
        ]

        # Execute the pipeline and get the results
        results = list(players_collection.aggregate(pipeline, allowDiskUse=True))

        logging.info(f"Adding {stat[0]}_RANK to database.")

        # Update each document with the new rank field
        for result in results:
            if len(loc) == 2:
                res = result['STATS'][season][loc[0]][loc[1]][f'{stat[0]}_RANK']
            elif len(loc) == 3:
                res = result['STATS'][season][loc[0]][loc[1]][loc[2]][f'{stat[0]}_RANK']
            else:
                res = result['STATS'][season][stat[1]][f'{stat[0]}_RANK']

            players_collection.update_one(
                {"_id": result["_id"]},
                {"$set": {
                    f"STATS.{season}.{stat[1]}.{stat[0]}_RANK": res}}
            )

logging.info("Ranking calculation completed.")
