from pymongo import MongoClient
from splash_nba.util.env import uri
from nba_api.stats.endpoints import playerawards
import logging

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
    'MONTH',
    'WEEK',
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
