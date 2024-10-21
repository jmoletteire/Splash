import random
import time
from datetime import datetime

from nba_api.stats.endpoints import boxscoretraditionalv2, videoeventsasset
from nba_api.live.nba.endpoints import playbyplay
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def update_play_by_play():
    # Video PBP
    today = datetime.today().strftime('%Y-%m-%d')
    with games_collection.find({'GAME_DATE': today}, {"_id": 1, "GAMES": 1, "GAME_DATE": 1}) as cursor:
        docs = list(cursor)
        if not docs:
            return

        for doc in docs:
            logging.info(f'\nAdding Video PBP for {doc["GAME_DATE"]}')

            for game_id, game_data in doc['GAMES'].items():
                # Fetch PBP for the game
                try:
                    pbp = fetch_play_by_play(game_id)
                except Exception as e:
                    logging.error(f"Error fetching play-by-play for game_id {game_id}: {e}")
                    continue

                # Update the game data with the fetched stats
                try:
                    # Update the MongoDB document with the fetched stats under the "PBP" key
                    games_collection.update_one(
                        {'_id': doc['_id'], f"GAMES.{game_id}": {"$exists": True}},
                        {"$set": {f"GAMES.{game_id}.PBP": pbp}}
                    )

                    print(f"Processed {doc['GAME_DATE']} {game_id}")
                except Exception as e:
                    logging.error(f"Error updating box score for game_id {game_id}: {e}")
                    continue

                # Pause 30 seconds between games
                time.sleep(30)


# Function to fetch box score stats for a game
def fetch_play_by_play(game_id):
    keys = [
        'actionNumber',
        'clock',
        'period',
        'teamId',
        'personId',
        'personIdsFilter',
        'playerNameI',
        'possession',
        'scoreHome',
        'scoreAway',
        'isFieldGoal',
        'description',
        'xLegacy',
        'yLegacy'
    ]

    actions = playbyplay.PlayByPlay(game_id=game_id).get_dict()['game']['actions']
    pbp = []

    for i, action in enumerate(actions):
        logging.info(f'{i + 1} of {len(actions)}')
        play_info = {key: action.get(key, 0) for key in keys}

        try:
            play_info['videoId'] = videoeventsasset.VideoEventsAsset(game_id=game_id, game_event_id=action.get('actionNumber', 0)).get_dict()['resultSets']['Meta']['videoUrls'][0]['uuid']
            time.sleep(random.uniform(0.5, 1.0))
        except Exception:
            play_info['videoId'] = None

        pbp.append(play_info)

    return pbp


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
        # documents = games_collection.find({}, {"_id": 1, "GAMES": 1, "GAME_DATE": 1})

        # Set batch size to process documents
        batch_size = 100
        total_documents = games_collection.count_documents({'SEASON_CODE': '42023'})
        game_counter = 0
        processed_count = 0
        i = 0

        while processed_count < total_documents:
            with games_collection.find({'SEASON_CODE': '42023'}, {"_id": 1, "GAMES": 1, "GAME_DATE": 1}).skip(processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for document in documents:
                    i += 1
                    logging.info(f'\nProcessing {i} of {total_documents} ({document["GAME_DATE"]})')

                    for game_id, game_data in document['GAMES'].items():
                        # Fetch PBP for the game
                        try:
                            pbp = fetch_play_by_play(game_id)
                            game_counter += 1
                        except Exception as e:
                            pbp = None
                            logging.error(f"Error fetching play-by-play for game_id {game_id}: {e}")
                            continue

                        # Update the game data with the fetched stats
                        try:
                            # Update the MongoDB document with the fetched stats under the "PBP" key
                            games_collection.update_one(
                                {'_id': document['_id'], f"GAMES.{game_id}": {"$exists": True}},
                                {"$set": {f"GAMES.{game_id}.PBP": pbp}}
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

        print("Play-By-Play update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
