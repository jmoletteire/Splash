import time

from nba_api.stats.endpoints import commonallplayers, commonplayerinfo
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def add_players():
    all_players = commonallplayers.CommonAllPlayers(season='2024-25').get_normalized_dict()['CommonAllPlayers']

    # Filter players to only add those that don't exist in the collection
    new_players = [player for player in all_players if not players_collection.find_one({"PERSON_ID": player["PERSON_ID"]}) and player["ROSTERSTATUS"] == 1]

    if new_players:
        players_collection.insert_many(new_players)

        for player in new_players:
            new_player_info(player["PERSON_ID"])

        logging.info(f"Added {len(new_players)} new players.")
    else:
        logging.info("No new players to add.")


def new_player_info(player):
    try:
        player_data = commonplayerinfo.CommonPlayerInfo(player).get_normalized_dict()['CommonPlayerInfo']

        players_collection.update_one(
            {"PERSON_ID": player},
            {"$set": {"player_info": player_data, "STATS": {}, "AWARDS": {}}},
            upsert=True
        )
        logging.info(f" Added info for player {player}")
    except Exception as e:
        logging.error(f" Failed to add info for {player}: {e}")


def restructure_new_docs():
    # Loop through each document in the collection
    for i, player in enumerate(players_collection.find({"player_info": {"$exists": True}})):
        player_info = player.get('player_info', [])

        if player_info:
            # Create a new document retaining _id, STATS, and AWARDS
            new_doc = {
                '_id': player['_id'],
                'STATS': player['STATS'],
                'AWARDS': player['AWARDS']
            }

            for field in player_info[0].keys():
                new_doc[field] = player_info[0][field]

            # Replace the document in the collection with the new document
            players_collection.replace_one({'_id': player['_id']}, new_doc)
            logging.info(f"Unpacked player_info for {i + 1} players.")

    logging.info("Unpacking process complete.")


# Function to get the latest player info
def get_player_info(person_id):
    try:
        latest_info = commonplayerinfo.CommonPlayerInfo(player_id=person_id).get_normalized_dict()['CommonPlayerInfo']
        return latest_info
    except Exception as e:
        print(f"Error fetching data for player ID {person_id}: {e}")
        return None


def update_player_info():
    # Loop through each document in the collection
    for i, player in enumerate(players_collection.find({"ROSTERSTATUS": "Active"})):
        person_id = player['PERSON_ID']
        latest_info = get_player_info(person_id)

        if latest_info:
            # Update the document in the collection
            players_collection.update_one(
                {"_id": player['_id']},
                {"$set": {
                    'WEIGHT': latest_info[0]['WEIGHT'],
                    'SEASON_EXP': latest_info[0]['SEASON_EXP'],
                    'JERSEY': latest_info[0]['JERSEY'],
                    'POSITION': latest_info[0]['POSITION'],
                    'ROSTERSTATUS': latest_info[0]['ROSTERSTATUS'],
                    'TEAM_ID': latest_info[0]['TEAM_ID'],
                    'GAMES_PLAYED_CURRENT_SEASON_FLAG': latest_info[0]['GAMES_PLAYED_CURRENT_SEASON_FLAG'],
                    'TEAM_NAME': latest_info[0]['TEAM_NAME'],
                    'TEAM_ABBREVIATION': latest_info[0]['TEAM_ABBREVIATION'],
                    'TEAM_CODE': latest_info[0]['TEAM_CODE'],
                    'TEAM_CITY': latest_info[0]['TEAM_CITY'],
                    'TO_YEAR': latest_info[0]['TO_YEAR'],
                    'DLEAGUE_FLAG': latest_info[0]['DLEAGUE_FLAG'],
                    'NBA_FLAG': latest_info[0]['NBA_FLAG']
                }}
            )
            print(
                f"Updated player {i + 1} of {players_collection.count_documents({'ROSTERSTATUS': 'Active'})} with new info.")

            # Rest 10 seconds every 25 players
            if i % 25 == 0:
                time.sleep(10)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        players_collection = db.nba_players
        logging.info("Connected to MongoDB")

        try:
            add_players()
            restructure_new_docs()
            update_player_info()
        except Exception as e:
            logging.error(f"Error adding players: {e}")

    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)
