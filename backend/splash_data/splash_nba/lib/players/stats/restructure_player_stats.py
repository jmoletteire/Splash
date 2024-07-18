import logging
from pymongo import MongoClient
from splash_nba.util.env import uri

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