from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def get_avg_ranks(season, category, stats):
    pipeline = [
        {
            "$addFields": {
                f"seasons.{season}.STATS.ADV": {
                    "$mergeObjects": [
                        f"$seasons.{season}.STATS.ADV",
                        {f"{category}_AVG_RANK": {"$avg": [f"$seasons.{season}.STATS.{location}.{stat}" for stat, location in stats]}}
                    ]
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
            ('STL_PER_100', 'BASIC'),
            ('BLK_PER_100', 'BASIC'),
            ('DEFLECTIONS_PER_100', 'HUSTLE'),
            ('CONTESTED_SHOTS_PER_100', 'HUSTLE'),
        ],
        'REBOUNDING': [
            ('OREB_PCT', 'ADV'),
            ('DREB_PCT', 'ADV'),
            ('BOX_OUTS_PER_100', 'HUSTLE')
        ],
        'HUSTLE': [
            ('PACE', 'ADV'),
            ('SCREEN_ASSISTS_PER_100', 'HUSTLE'),
            ('SCREEN_AST_PTS_PER_100', 'HUSTLE'),
            ('LOOSE_BALLS_RECOVERED_PER_100', 'HUSTLE'),
        ]
    }

    # Update each document in the collection
    for season in seasons:
        for stat_group in stats.keys():
            try:
                logging.info(f"Season: {season}")
                results = get_avg_ranks(season, stat_group, stats[stat_group])

                logging.info(f"Adding {stat_group}_AVG_RANK to database.")

                # Update each document with the new rank field
                for result in results:
                    teams_collection.update_one(
                        {"_id": result["_id"]},
                        {"$set": {f"seasons.{season}.STATS.ADV.{stat_group}_AVG_RANK":
                                      result['seasons'][season]['STATS']['ADV'][f'{stat_group}_AVG_RANK']}}
                    )

            except Exception as e:
                logging.error(f"Error processing documents for season {season}: {e}")


def three_and_ft_rate(season, season_type):
    # Update each document in the collection
    for document in teams_collection.find({}, {"TEAM_ID": 1, "seasons": 1, "_id": 0}):
        team_id = document['TEAM_ID']
        logging.info(f'Processing team {team_id}...')
        for season in document['seasons']:
            if season in seasons:
                try:
                    # Extract the values needed for calculation
                    fg3a = document['seasons'][season]['STATS'][season_type]['BASIC'].get('FG3A', 0)
                    fta = document['seasons'][season]['STATS'][season_type]['BASIC'].get('FTA', 0)
                    ftm = document['seasons'][season]['STATS'][season_type]['BASIC'].get('FTM', 1)
                    fga = document['seasons'][season]['STATS'][season_type]['BASIC'].get('FGA', 1)  # Avoid division by zero
                    # Calculate 3PAr
                    three_pt_rate = fg3a / fga
                    fta_rate = fta / fga
                    ft_per_fga = ftm / fga
                    logging.info(f'Calculated for {season}')

                    # Update the document with the new field
                    teams_collection.update_one(
                        {'TEAM_ID': document['TEAM_ID']},
                        {'$set': {f'seasons.{season}.STATS.BASIC.3PAr': three_pt_rate,
                                  f'seasons.{season}.STATS.BASIC.FTAr': fta_rate,
                                  f'seasons.{season}.STATS.{season_type}.BASIC.FT_PER_FGA': ft_per_fga}
                         }
                    )

                    logging.info(f'Added stats for {season} for team {team_id}')

                except KeyError as e:
                    print(f"Key error for document {document['TEAM_ID']}: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

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
        three_and_ft_rate(season, 'PLAYOFFS')
        # avg_category_rankings()

    logging.info("Update complete.")
