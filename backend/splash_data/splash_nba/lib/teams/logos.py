from bson import ObjectId
from nba_api.stats.endpoints import teamdetails
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def fetch_gleague_logos(team_id):
    team_abbr = teams_collection.find_one({'TEAM_ID': team_id}, {'ABBREVIATION': 1, '_id': 0})['ABBREVIATION']

    try:
        with open(f'../../images/GLeague_Logos/{team_abbr}.svg', 'r') as svg_file:
            svg_data = svg_file.read()
    except FileNotFoundError:
        with open(f'../../images/GLeague_Logos/NBA_G_League_logo.svg', 'r') as svg_file:
            svg_data = svg_file.read()

    logo = [svg_data]

    teams_collection.update_one(
        {'TEAM_ID': team_id},
        {'$set': {'DLEAGUEAFFILIATION.LOGO': logo}}
    )


def fetch_team_logos(team_id):
    team_abbr = teams_collection.find_one({'TEAM_ID': team_id}, {'ABBREVIATION': 1, '_id': 0})['ABBREVIATION']

    with open(f'../../images/NBA_Logos/{team_abbr}.svg', 'r') as svg_file:
        svg_data = svg_file.read()

    logo = [svg_data]

    teams_collection.update_one(
        {'TEAM_ID': team_id},
        {'$set': {'LOGO': logo}}
    )


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")

        for i, team in enumerate(teams_collection.find()):
            fetch_team_logos(team['TEAM_ID'])
            fetch_gleague_logos(team['TEAM_ID'])
            logging.info(f"Processed {i + 1} of {teams_collection.count_documents({})}")

    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
