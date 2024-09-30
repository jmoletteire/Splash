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
    # ("3PAr", "REGULAR SEASON.BASIC", -1),
    # ("FTAr", "REGULAR SEASON.BASIC", -1),
    # ("FT_PER_FGA", "REGULAR SEASON.BASIC", -1),

    # ("FGM_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("FGA_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("FTM_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("FTA_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("FG3M_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("FG3A_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("STL_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("BLK_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("REB_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("OREB_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("DREB_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("PF_PER_75", "BASIC", 1),
    # ("PFD_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("PTS_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("PLUS_MINUS_PER_75", "REGULAR SEASON.BASIC", -1),
    # ("PLUS_MINUS_PER_75", "PLAYOFFS.BASIC", -1),
    # ("TOV", "REGULAR SEASON.BASIC", 1),
    # ("TOV", "PLAYOFFS.BASIC", 1),
    # ("TOV_PER_75", "REGULAR SEASON.BASIC", 1),
    # ("TOV_PER_75", "PLAYOFFS.BASIC", 1),

    # ADV
    # ("OFF_RATING_ON_OFF", "REGULAR SEASON.ADV", -1),
    # ("DEF_RATING_ON_OFF", "REGULAR SEASON.ADV", 1),
    # ("NET_RATING_ON_OFF", "REGULAR SEASON.ADV", -1),
    # ("POSS", "PLAYOFFS.ADV", -1),
    # ("POSS_PER_GM", "REGULAR SEASON.ADV", -1),
    # ("DEF_PTS_SAVED", "REGULAR SEASON.ADV", -1),
    # ("PARTIAL_POSS", "REGULAR SEASON.ADV", -1),
    # ("DPS_PER_75", "REGULAR SEASON.ADV", -1),
    # ("BOX_CREATION", "PLAYOFFS.ADV", -1),
    # ("OFFENSIVE_LOAD", "REGULAR SEASON.ADV", -1),
    # ("OFFENSIVE_LOAD", "PLAYOFFS.ADV", -1),
    # ("ADJ_TOV_PCT", "REGULAR SEASON.ADV", 1),
    # ("ADJ_TOV_PCT", "PLAYOFFS.ADV", 1),
    # ("VERSATILITY_SCORE", "REGULAR SEASON.ADV", -1),
    # ("VERSATILITY_SCORE", "PLAYOFFS.ADV", -1),
    # ("MATCHUP_DIFFICULTY", "REGULAR SEASON.ADV", -1),
    # ("MATCHUP_DIFFICULTY", "PLAYOFFS.ADV", -1),
    # ("DEF_IMPACT_EST", "REGULAR SEASON.ADV", -1),
    # ("DEF_IMPACT_EST", "PLAYOFFS.ADV", -1),

    # ADV -> PASSING
    # ("PASSES_MADE", "REGULAR SEASON.ADV.PASSING", -1),
    # ("PASSES_RECEIVED", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST", "REGULAR SEASON.ADV.PASSING", -1),
    # ("FT_AST", "REGULAR SEASON.ADV.PASSING", -1),
    # ("SECONDARY_AST", "REGULAR SEASON.ADV.PASSING", -1),
    # ("POTENTIAL_AST", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST_PTS_CREATED", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST_ADJ", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST_TO_PASS_PCT", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST_TO_PASS_PCT_ADJ", "REGULAR SEASON.ADV.PASSING", -1),

    # ("PASSES_MADE_PER_75", "REGULAR SEASON.ADV.PASSING", -1),
    # ("PASSES_RECEIVED_PER_75", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST_PER_75", "REGULAR SEASON.ADV.PASSING", -1),
    # ("FT_AST_PER_75", "REGULAR SEASON.ADV.PASSING", -1),
    # ("SECONDARY_AST_PER_75", "REGULAR SEASON.ADV.PASSING", -1),
    # ("POTENTIAL_AST_PER_75", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST_PTS_CREATED_PER_75", "REGULAR SEASON.ADV.PASSING", -1),
    # ("AST_ADJ_PER_75", "REGULAR SEASON.ADV.PASSING", -1),

    # ("TOUCHES", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("FRONT_CT_TOUCHES", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("TIME_OF_POSS", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("AVG_SEC_PER_TOUCH", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("AVG_DRIB_PER_TOUCH", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("PTS_PER_TOUCH", "REGULAR SEASON.ADV.TOUCHES", -1),

    # ("FGA_PER_TOUCH", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("PASSES_PER_TOUCH", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("TOV_PER_TOUCH", "REGULAR SEASON.ADV.TOUCHES", 1),
    # ("PFD_PER_TOUCH", "REGULAR SEASON.ADV.TOUCHES", -1),

    # ("TOUCHES_PER_75", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("FRONT_CT_TOUCHES_PER_75", "REGULAR SEASON.ADV.TOUCHES", -1),
    # ("TIME_OF_POSS_PER_75", "REGULAR SEASON.ADV.TOUCHES", -1),

    # HUSTLE
    # ("CONTESTED_SHOTS_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("SCREEN_ASSISTS_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("SCREEN_AST_PTS_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("BOX_OUTS_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("OFF_BOXOUTS_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("DEF_BOXOUTS_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("DEFLECTIONS_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("LOOSE_BALLS_RECOVERED_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("CHARGES_DRAWN_PER_75", "REGULAR SEASON.HUSTLE", -1),
    # ("DIST_MILES", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("DIST_MILES_OFF", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("DIST_MILES_DEF", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("DIST_MILES_PER_75", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("DIST_MILES_OFF_PER_75", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("DIST_MILES_DEF_PER_75", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("AVG_SPEED", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("AVG_SPEED_OFF", "REGULAR SEASON.HUSTLE.SPEED", -1),
    # ("AVG_SPEED_DEF", "REGULAR SEASON.HUSTLE.SPEED", -1),

    # ("DIST_MILES", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("DIST_MILES_OFF", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("DIST_MILES_DEF", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("DIST_MILES_PER_75", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("DIST_MILES_OFF_PER_75", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("DIST_MILES_DEF_PER_75", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("AVG_SPEED", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("AVG_SPEED_OFF", "PLAYOFFS.HUSTLE.SPEED", -1),
    # ("AVG_SPEED_DEF", "PLAYOFFS.HUSTLE.SPEED", -1),

    # ADV -> DRIVES
    # ("DRIVES", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FGM", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FGA", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FG_PCT", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FTM", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FTA", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FT_PCT", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_PTS", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_PTS_PCT", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_PASSES", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_PASSES_PCT", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_AST", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_AST_PCT", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_TOV", "PLAYOFFS.ADV.DRIVES", 1),
    # ("DRIVE_TOV_PCT", "PLAYOFFS.ADV.DRIVES", 1),
    # ("DRIVE_TS_PCT", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FT_PER_FGA", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVES_PER_TOUCH", "PLAYOFFS.ADV.DRIVES", -1),

    # ("DRIVES_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FGM_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FGA_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FTM_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_FTA_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_PTS_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_PASSES_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_AST_PER_75", "PLAYOFFS.ADV.DRIVES", -1),
    # ("DRIVE_TOV_PER_75", "PLAYOFFS.ADV.DRIVES", 1),

    # ADV -> REBOUNDING
    # ("OREB_CONTEST", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_UNCONTEST", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_CONTEST_PCT", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_CHANCES", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_CHANCE_DEFER", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_CHANCE_PCT", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_CHANCE_PCT_ADJ", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CONTEST", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_UNCONTEST", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CONTEST_PCT", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CHANCES", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CHANCE_DEFER", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CHANCE_PCT", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CHANCE_PCT_ADJ", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CONTEST", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_UNCONTEST", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CONTEST_PCT", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CHANCES", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CHANCE_DEFER", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CHANCE_PCT", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CHANCE_PCT_ADJ", "PLAYOFFS.ADV.REBOUNDING", -1),

    # ("OREB_CONTEST_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_UNCONTEST_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_CHANCES_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("OREB_CHANCE_DEFER_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CONTEST_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_UNCONTEST_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CHANCES_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("DREB_CHANCE_DEFER_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CONTEST_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_UNCONTEST_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CHANCES_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1),
    # ("REB_CHANCE_DEFER_PER_75", "PLAYOFFS.ADV.REBOUNDING", -1)
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

for season in seasons:
    logging.info(f"Season: {season}")
    for stat in custom_stats:

        loc = stat[1].split('.')

        if (loc[-1] == 'PASSING' or loc[-1] == 'TOUCHES' or loc[-1] == 'DRIVES' or loc[-1] == 'REBOUNDING') and season < '2013-14':
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
                "$project": {
                    f"STATS.{season}.{stat[1]}.{stat[0]}": 1
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
