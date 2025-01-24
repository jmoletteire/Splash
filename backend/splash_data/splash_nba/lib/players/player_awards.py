import random
import time
import logging
from pymongo import MongoClient
from nba_api.stats.endpoints import playerawards

try:
    # Try to import the local env.py file
    from splash_nba.util.env import uri
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import uri
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB
client = MongoClient(uri)
db = client.splash
players_collection = db.nba_players
logging.info("Connected to MongoDB")

keys = [
    'DESCRIPTION',
    'ALL_NBA_TEAM_NUMBER',
    'SEASON',
    'CONFERENCE',
    'TYPE'
]
players = players_collection.count_documents({})

for i, player in enumerate(players_collection.find({}, {"PERSON_ID": 1, "_id": 0})):
    try:
        player_awards = playerawards.PlayerAwards(player["PERSON_ID"]).get_normalized_dict()['PlayerAwards']

        awards = {}

        for award in player_awards:
            if award['DESCRIPTION'] not in awards.keys():
                awards[award['DESCRIPTION']] = [{key: award[key] for key in keys}]
            else:
                awards[award['DESCRIPTION']].append({key: award[key] for key in keys})

        players_collection.update_one(
            {"PERSON_ID": player["PERSON_ID"]},
            {"$set": {"AWARDS": awards}},
        )

        logging.info(f"Updated {i + 1} of {players}")

    except Exception as e:
        logging.error(f"Unable to process player {player['PERSON_ID']}: {e}")

    # Pause for a random time between 0.5 and 2 seconds
    time.sleep(random.uniform(0.5, 2.0))

    # Pause 15 seconds for every 50 players
    if i % 50 == 0:
        time.sleep(15)
