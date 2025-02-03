import logging
from splash_nba.imports import get_mongo_collection

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB
collection = get_mongo_collection('nba_players')
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