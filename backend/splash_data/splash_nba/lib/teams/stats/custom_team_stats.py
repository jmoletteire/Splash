from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def get_rank(season, stats):
    pipeline = [
        {
            "$project": {
                "average": {
                    "$avg": [f"seasons.{season}.STATS.{location}.{stat}_RANK" for stat, location in stats]
                }
            }
        }
    ]

    # Execute the pipeline and get the results
    results = list(teams_collection.aggregate(pipeline))
    return results


def avg_category_rankings():
    seasons = [
        '2023-24',
        '2022-23',
        '2021-22',
        '2020-21',
        '2019-20',
        '2018-19',
        '2017-18',
        '2016-17'
    ]

    # Stats to rank
    stats = {
        'EFFICIENCY': [
            ('OFF_RATING', 'ADV'),
            ('DEF_RATING', 'ADV'),
            ('NET_RATING', 'ADV'),
            ('TM_TOV_PCT', 'ADV')
        ],
        'SHOOTING': [
            ('TS_PCT', 'ADV')
        ],
        'DEFENSE': [
            ('DEF_RATING', 'ADV'),
            ('STL', 'BASIC'),
            ('BLK', 'BASIC'),
            ('DEFLECTIONS', 'HUSTLE'),
            ('CONTESTED_SHOTS', 'HUSTLE'),
        ],
        'REBOUNDING': [
            ('OREB_PCT', 'ADV'),
            ('DREB_PCT', 'ADV'),
            ('BOX_OUTS', 'HUSTLE'),
            ('OFF_BOXOUTS', 'HUSTLE'),
            ('DEF_BOXOUTS', 'HUSTLE')
        ],
        'HUSTLE': [
            ('SCREEN_ASSISTS', 'HUSTLE'),
            ('SCREEN_AST_PTS', 'HUSTLE'),
            ('LOOSE_BALLS_RECOVERED', 'HUSTLE'),
        ]
    }

    # Update each document in the collection
    for team in teams_collection.find({}, {"TEAM_ID": 1, "seasons": 1, "_id": 0}):
        team_id = team['TEAM_ID']
        logging.info(f'Processing team {team_id}...')
        for season in seasons:
            for stat_group in stats.keys():
                try:
                    logging.info(f"Season: {season}")
                    results = get_rank(season, stats[stat_group])

                    logging.info(f"Adding {stat_group}_AVG_RANK to database.")

                    # Update each document with the new rank field
                    for result in results:
                        teams_collection.update_one(
                            {"_id": result["_id"]},
                            {"$set": {f"seasons.{season}.STATS.{stat_group}.{stat_group}_AVG_RANK":
                                          result['seasons'][season]['STATS'][stat_group][f'{stat_group}_AVG_RANK']}}
                        )

                except KeyError as e:
                    logging.error(f"Key error for document with _id {team['_id']}: {e}")


def three_and_ft_rate():
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

    # Update each document in the collection
    for document in teams_collection.find({}, {"TEAM_ID": 1, "seasons": 1, "_id": 0}):
        team_id = document['TEAM_ID']
        logging.info(f'Processing team {team_id}...')
        for season in document['seasons']:
            if season in seasons:
                try:
                    # Extract the values needed for calculation
                    fg3a = document['seasons'][season]['STATS']['BASIC'].get('FG3A', 0)
                    fta = document['seasons'][season]['STATS']['BASIC'].get('FTA', 0)
                    ftm = document['seasons'][season]['STATS']['BASIC'].get('FTM', 1)
                    fga = document['seasons'][season]['STATS']['BASIC'].get('FGA', 1)  # Avoid division by zero
                    fgm = document['seasons'][season]['STATS']['BASIC'].get('FGM', 1)
                    # Calculate 3PAr
                    three_pt_rate = fg3a / fga
                    fta_rate = fta / fga
                    ft_per_fgm = ftm / fgm
                    logging.info(f'Calculated for {season}')

                    # Update the document with the new field
                    teams_collection.update_one(
                        {'TEAM_ID': document['TEAM_ID']},
                        {'$set': {f'seasons.{season}.STATS.BASIC.3PAr': three_pt_rate,
                                  f'seasons.{season}.STATS.BASIC.FTAr': fta_rate,
                                  f'seasons.{season}.STATS.BASIC.FT_PER_FGM': ft_per_fgm}
                         }
                    )

                    logging.info(f'Added stats for {season} for team {team_id}')

                except KeyError as e:
                    print(f"Key error for document with _id {document['_id']}: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

    three_and_ft_rate()

    logging.info("Update complete.")
