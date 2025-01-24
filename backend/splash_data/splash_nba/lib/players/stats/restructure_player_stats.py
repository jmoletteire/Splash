import logging
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import uri
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import uri
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB
client = MongoClient(uri)
db = client.splash
collection = db.nba_players
logging.info("Connected to MongoDB")

num_players = collection.count_documents({})

# Update documents
for i, doc in enumerate(collection.find({}, {'STATS': 1, '_id': 1})):
    logging.info(f'Processing {i + 1} of {num_players}')
    stats = doc.get('STATS', {})

    for season in stats.keys():
        season_stats = stats.get(season, {})

        basic = season_stats.pop('BASIC', {})
        adv = season_stats.pop('ADV', {})
        hustle = season_stats.pop('HUSTLE', {})

        regular_season = {
            'BASIC': basic,
            'ADV': adv,
            'HUSTLE': hustle
        }

        season_stats['REGULAR SEASON'] = regular_season

        collection.update_one(
            {'_id': doc['_id']},
            {'$set': {f'STATS.{season}': season_stats}}
        )

print("Update completed.")