import logging
from pymongo import MongoClient
from nba_api.stats.endpoints import franchisehistory

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


def update_team_history(team_id):
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"(Team History) Failed to connect to MongoDB: {e}")
        return

    try:
        # Fetch the franchise history data
        history_list = franchisehistory.FranchiseHistory().get_normalized_dict()['FranchiseHistory']

        # Organize the data into the desired format
        organized_data = {}
        for entry in history_list:
            team_id = entry['TEAM_ID']
            if team_id not in organized_data:
                organized_data[team_id] = {
                    "team_id": team_id,
                    "team_history": []
                }
            organized_data[team_id]['team_history'].append(entry)

        # Convert the organized data to a list of dictionaries
        organized_data_list = list(organized_data.values())
    except Exception as e:
        logging.error(f"(Team History) Error fetching team history for {team_id}: {e}")
        return

    try:
        # Insert or update the team history in MongoDB
        for team_history in organized_data_list:
            teams_collection.update_one(
                {"TEAM_ID": team_history['team_id']},
                {"$set": {"team_history": team_history['team_history']}},
                upsert=True
            )
    except Exception as e:
        logging.error(f"(Team History) Error updating team history for {team_id}: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB, then fetch teams
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    for i, team in enumerate(teams_collection.find()):
        update_team_history(team['TEAM_ID'])
        logging.info(f"Updated {i + 1} of 30.")
    logging.info("Updated teams.")
