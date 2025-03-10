import time
import random
import logging
from nba_api.live.nba.endpoints import boxscore
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS


# Function to fetch box score stats for a game
def fetch_box_score_stats(game_id):
    box_score = boxscore.BoxScore(proxy=PROXY, headers=HEADERS, game_id=game_id).get_dict()['game']
    return box_score


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games')
        logging.info("Connected to MongoDB")

        # Retrieve all documents from the collection
        # documents = games_collection.find({}, {"_id": 1, "GAMES": 1, "GAME_DATE": 1})

        # Set batch size to process documents
        batch_size = 100
        total_documents = games_collection.count_documents({})
        game_counter = 0
        processed_count = 0
        i = 0

        while processed_count < total_documents:
            with games_collection.find({}, {"_id": 1, "GAMES": 1, "GAME_DATE": 1}).skip(processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for document in documents:
                    i += 1
                    logging.info(f'\nProcessing {i} of {total_documents} ({document["GAME_DATE"]})')

                    for game_id, game_data in document['GAMES'].items():
                        # Check if BOXSCORE already exists for the game
                        #if "BOXSCORE" not in game_data:
                        # Fetch box score stats for the game
                        try:
                            stats = fetch_box_score_stats(game_id)
                            game_counter += 1
                        except Exception as e:
                            stats = None
                            logging.error(f"Error fetching box score for game_id {game_id}: {e}")
                            continue

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
                            continue

                        # Pause for 10 seconds every 100 games processed
                        if game_counter % 100 == 0:
                            logging.info(f"Processed {game_counter} games. Pausing for 10 seconds...")
                            time.sleep(10)
                        else:
                            # Pause for a random time between 0.5 and 1 second
                            time.sleep(random.uniform(0.5, 1.0))

        print("Box score stats update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
