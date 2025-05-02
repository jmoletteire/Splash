import re
import time
import random
import logging
from datetime import datetime, timedelta
from nba_api.live.nba.endpoints import playbyplay
from nba_api.stats.endpoints import videoeventsasset
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS


def convert_playtime(duration_str):
    if duration_str is None:
        return ""
    try:
        match = re.match(r"PT(\d+)M([\d.]+)S", duration_str)
        if match:
            minutes = int(match.group(1))
            seconds = round(float(match.group(2)))  # Handle potential float values
            return f"{minutes}:{seconds:02d}"
        else:
            return ""
    except Exception:
        return ""


def update_play_by_play():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    games_collection = get_mongo_collection('nba_games_unwrapped')

    # Video PBP
    yesterday = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')
    with games_collection.find({'date': yesterday}, {"_id": 0}) as cursor:
        docs = list(cursor)
        if not docs:
            return

        for doc in docs:
            logging.info(f'\nAdding Video PBP for {doc["date"]}')

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
                    {'gameId': doc['gameId']},
                    {"$set": {"pbp": pbp}}
                )

                print(f"Processed {doc['date']} {game_id}")
            except Exception as e:
                logging.error(f"Error updating box score for game_id {game_id}: {e}")
                continue

            # Pause 30 seconds between games
            time.sleep(30)


# Function to fetch box score stats for a game
def fetch_play_by_play(game_id):
    actions = playbyplay.PlayByPlay(proxy=PROXY, headers=HEADERS, game_id=game_id).get_dict()['game']['actions']
    pbp = []

    for i, action in enumerate(actions):
        # logging.info(f'{i + 1} of {len(actions)}')

        play_info = {
            'action': str(action.get('actionNumber', '0')),
            'clock': convert_playtime(action.get('clock', '')),
            'period': str(action.get('period', '0')),
            'teamId': str(action.get('teamId', '0')),
            'personId': str(action.get('personId', '0')),
            'playerNameI': str(action.get('playerNameI', '')),
            'possession': str(action.get('possession', '0')),
            'scoreHome': str(action.get('scoreHome', '')),
            'scoreAway': str(action.get('scoreAway', '')),
            'isFieldGoal': str(action.get('isFieldGoal', '0')),
            'description': str(action.get('description', '')),
            'xLegacy': str(action.get('xLegacy', '0')),
            'yLegacy': str(action.get('yLegacy', '0')),
        }

        # try:
        #     play_info['videoId'] = videoeventsasset.VideoEventsAsset(proxy=None, game_id=game_id, game_event_id=action.get('actionNumber', 0)).get_dict()['resultSets']['Meta']['videoUrls'][0]['uuid']
        #     time.sleep(random.uniform(0.5, 1.0))
        # except Exception:
        #     play_info['videoId'] = None

        pbp.append(play_info)

    return pbp


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
        logging.info("Connected to MongoDB")

        # Retrieve all documents from the collection
        query = {"season": "2024"}
        proj = {"_id": 0}

        # Set batch size to process documents

        batch_size = 100
        total_documents = games_collection.count_documents(query)
        game_counter = 0
        processed_count = 0
        i = 0

        while processed_count < total_documents:
            with games_collection.find(query, proj).skip(processed_count).limit(batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for document in documents:
                    i += 1
                    logging.info(f'\nProcessing {i} of {total_documents} ({document["date"]})')

                    # Fetch PBP for the game
                    try:
                        game_id = document['gameId']
                        pbp = fetch_play_by_play(game_id)
                        # pbp = reformat_data(game_data)
                        game_counter += 1
                    except Exception as e:
                        pbp = None
                        logging.error(f"Error fetching play-by-play for game_id {game_id}: {e}", exc_info=True)
                        continue

                    # Update the game data with the fetched stats
                    try:
                        # Update the MongoDB document with the fetched stats under the "PBP" key
                        games_collection.update_one(
                            {'gameId': game_id},
                            {"$set": {"pbp": pbp}}
                        )

                        print(f"Processed {document['date']} {game_id}")
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

        logging.info("Play-By-Play update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
