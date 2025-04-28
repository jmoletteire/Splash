import random
import time
import logging
from json import JSONDecodeError

from nba_api.stats.endpoints import playerawards
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to MongoDB
players_collection = get_mongo_collection('nba_players')
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
        player_awards = playerawards.PlayerAwards(player["PERSON_ID"], proxy=PROXY, headers=HEADERS).get_normalized_dict()['PlayerAwards']

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

    except JSONDecodeError:
        logging.error(f"Unable to process player {player['PERSON_ID']}: No awards")

    # Pause for a random time between 0.5 and 2 seconds
    time.sleep(random.uniform(0.5, 2.0))

    # Pause 15 seconds for every 50 players
    if i % 50 == 0:
        time.sleep(15)
