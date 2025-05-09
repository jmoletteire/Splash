import time
import random
import logging
from nba_api.stats.endpoints import boxscoresummaryv2
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS


# Function to fetch box score stats for a game
def fetch_box_score_summary(game_id):
    boxscore = boxscoresummaryv2.BoxScoreSummaryV2(proxy=PROXY, headers=HEADERS, game_id=game_id).get_normalized_dict()
    return boxscore


def process_documents(documents):
    game_counter = 0

    for document in documents:
        if document['GAME_DATE'] < '2024-07-01':
            for game_id, game_data in document['GAMES'].items():
                # Check if SUMMARY already exists for the game
                if "AvailableVideo" not in game_data['SUMMARY'].keys():
                    # Fetch box score summary for the game
                    try:
                        stats = fetch_box_score_summary(game_id)
                    except Exception as e:
                        stats = None
                        logging.error(f"Error fetching box score for game_id {game_id}: {e}")

                    # Update the game data with the fetched summary
                    try:
                        # Update the MongoDB document with the fetched stats under the "SUMMARY" key
                        games_collection.update_one(
                            {'_id': document['_id'], f"GAMES.{game_id}": {"$exists": True}},
                            {"$set": {f"GAMES.{game_id}.SUMMARY": stats}}
                        )

                        print(f"Processed {document['GAME_DATE']} {game_id}")
                    except Exception as e:
                        logging.error(f"Error updating summary for game_id {game_id}: {e}")

                    game_counter += 1

                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(random.uniform(0.5, 1.0))

                    # Pause for 10 seconds every 100 games processed
                    if game_counter % 100 == 0:
                        logging.info(f"Processed {game_counter} games. Pausing for 10 seconds...")
                        time.sleep(10)

    print("Batch processing complete.")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games')
        logging.info("Connected to MongoDB")

        # Set batch size to process documents
        batch_size = 100
        total_documents = games_collection.count_documents({})
        processed_count = 0

        while processed_count < total_documents:
            with games_collection.find().skip(processed_count).limit(batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                process_documents(documents)
                processed_count += len(documents)

        print("Box score stats update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")