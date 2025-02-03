import logging
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON, CURR_SEASON_TYPE

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB Atlas
collection = get_mongo_collection('nba_games')

# Prepare the new collection
new_collection = get_mongo_collection('nba_games_v2')

# Process and insert transformed documents
try:
    documents = collection.find()

    for doc in documents:
        season_year = doc["SEASON_YEAR"]
        season_code = doc["SEASON_CODE"]
        season_type = doc["SEASON_TYPE"]

        for game_date, games_on_date in doc['GAME_DATES'].items():
            new_document = {
                "SEASON_YEAR": season_year,
                "SEASON_CODE": season_code,
                "SEASON_TYPE": season_type,
                "GAME_DATE": game_date,
                "GAMES": games_on_date  # Simplified to use games_on_date directly
            }
            new_collection.insert_one(new_document)

    logging.info("Documents have been restructured and inserted successfully.")

except Exception as e:
    logging.error(f"Error processing documents: {e}")