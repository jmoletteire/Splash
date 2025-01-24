import logging
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import URI
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB Atlas
client = MongoClient(URI)
db = client.splash
collection = db.nba_games

# Prepare the new collection
new_collection = db.nba_games_v2

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