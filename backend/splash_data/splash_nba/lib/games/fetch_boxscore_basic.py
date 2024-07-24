import random
import time
from nba_api.stats.endpoints import boxscoretraditionalv2
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


# Function to fetch box score stats for a game
def fetch_box_score_stats(game_id):
    boxscore = boxscoretraditionalv2.BoxScoreTraditionalV2(game_id=game_id).get_normalized_dict()
    return boxscore


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
        logging.info("Connected to MongoDB")

        # Retrieve all documents from the collection
        documents = games_collection.find({}, {"_id": 1, "GAMES": 1, "GAME_DATE": 1})

        game_counter = 0

        for document in documents:
            for game_id, game_data in document['GAMES'].items():
                # Check if BOXSCORE already exists for the game
                if "BOXSCORE" not in game_data:
                    # Fetch box score stats for the game
                    try:
                        stats = fetch_box_score_stats(game_id)
                        game_counter += 1
                    except Exception as e:
                        stats = None
                        logging.error(f"Error fetching box score for game_id {game_id}: {e}")

                    # Update the game data with the fetched stats
                    try:
                        # Update the MongoDB document with the fetched stats under the "BOXSCORE" key
                        games_collection.update_one(
                            {'_id': document['_id'], f"GAMES.{game_id}": {"$exists": True}},
                            {"$set": {f"GAMES.{game_id}.BOXSCORE": stats}}
                        )

                        print(f"Processed {document['GAME_DATE']} {game_id}")
                    except Exception as e:
                        logging.error(f"Error updating box score for game_id {game_id}: {e}")

                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(random.uniform(0.5, 1.0))

                    # Pause for 10 seconds every 100 games processed
                    if game_counter % 100 == 0:
                        logging.info(f"Processed {game_counter} games. Pausing for 10 seconds...")
                        time.sleep(10)

        print("Box score stats update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
