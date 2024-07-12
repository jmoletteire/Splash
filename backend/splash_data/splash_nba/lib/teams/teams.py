from nba_api.stats.static import teams
from nba_api.stats.endpoints import franchisehistory, teamdetails
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def update_team_history(team_id):
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
        logging.error(f"Error fetching team history for {team_id}: {e}")
        exit(1)

    try:
        # Insert or update the team history in MongoDB
        for team_history in organized_data_list:
            teams_collection.update_one(
                {"TEAM_ID": team_history['team_id']},
                {"$set": {"team_history": team_history['team_history']}},
                upsert=True
            )
        logging.info("Updated team histories.")
    except Exception as e:
        logging.error(f"Error updating team history for {team_id}: {e}")


def update_teams():
    try:
        # Get a list of 30 NBA team ids
        team_ids = [team['id'] for team in teams.get_teams()]

        # Insert teams into the collection
        for team_id in team_ids:
            team_details = teamdetails.TeamDetails(team_id)
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


def fetch_teams():
    try:
        # Get a list of 30 NBA team ids
        team_ids = [team['id'] for team in teams.get_teams()]

        # Insert teams into the collection
        for team_id in team_ids:
            team_details = teamdetails.TeamDetails(team_id)
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
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    # fetch_teams()
    update_teams()
    logging.info("Updated teams.")
