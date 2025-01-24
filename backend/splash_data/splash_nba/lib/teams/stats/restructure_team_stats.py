import logging
from pymongo import MongoClient
from splash_nba.util.env import URI

try:
    # Try to import the local env.py file
    from splash_nba.util.env import PROXY, URI
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB
client = MongoClient(URI)
db = client.splash
collection = db.nba_teams
logging.info("Connected to MongoDB")

num_teams = collection.count_documents({})

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

# Update documents
for i, doc in enumerate(collection.find({}, {'seasons': 1, '_id': 1})):
    logging.info(f'Processing {i + 1} of {num_teams}')
    team_seasons = doc.get('seasons', None)

    for season in seasons:
        if season in team_seasons:
            season_stats = team_seasons.get(season)['STATS']

            if season_stats:
                basic = season_stats.pop('BASIC', None)
                adv = season_stats.pop('ADV', None)
                hustle = season_stats.pop('HUSTLE', None)

                regular_season = {
                    'BASIC': basic,
                    'ADV': adv,
                    'HUSTLE': hustle
                }

                collection.update_one(
                    {'_id': doc['_id']},
                    {'$set': {f'seasons.{season}.STATS.REGULAR SEASON': regular_season}}
                )

print("Update completed.")