import logging
from pymongo import MongoClient
from nba_api.stats.static import teams
from nba_api.stats.endpoints import teamdetails
from splash_nba.lib.teams.team_history import update_team_history

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI
    PROXY = None
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def update_teams():
    try:
        # Loop through all documents in the collection
        for i, team in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            team_id = team['TEAM_ID']
            update_team_history(team_id)
            logging.info(f"Processed {i + 1} of 30")
    except Exception as e:
        logging.error(f"Error updating team history: {e}")


def fetch_teams():
    try:
        # Get a list of 30 NBA team ids
        team_ids = [team['id'] for team in teams.get_teams()]

        # Insert teams into the collection
        for team_id in team_ids:
            team_details = teamdetails.TeamDetails(team_id, proxy=PROXY)
            team_info = team_details.get_normalized_dict()['TeamBackground'][0]
            teams_collection.insert_one(team_info)

        logging.info(f"Number of teams fetched: {len(team_ids)}")
    except Exception as e:
        logging.error(f"Error fetching teams: {e}")

    try:
        # Loop through all documents in the collection
        for i, team in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            team_id = team['TEAM_ID']
            update_team_history(team_id)
            logging.info(f"Processed {i + 1} of 30")
    except Exception as e:
        logging.error(f"Error updating team history: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB, then fetch teams
    try:
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    # fetch_teams()
    update_teams()
    logging.info("Updated teams.")
