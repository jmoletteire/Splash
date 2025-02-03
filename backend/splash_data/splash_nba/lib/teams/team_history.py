import logging
from nba_api.stats.endpoints import franchisehistory
from splash_nba.imports import get_mongo_collection, PROXY


def update_team_history(team_id):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Team History) Failed to connect to MongoDB: {e}")
        return

    try:
        # Fetch the franchise history data
        history_list = franchisehistory.FranchiseHistory(proxy=PROXY).get_normalized_dict()['FranchiseHistory']

        # Organize the data into the desired format
        organized_data = {}
        for entry in history_list:
            if entry['TEAM_ID'] == team_id and team_id not in organized_data:
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
        teams_collection = get_mongo_collection('nba_teams')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    for i, team in enumerate(teams_collection.find()):
        update_team_history(team['TEAM_ID'])
        logging.info(f"Updated {i + 1} of 30.")
    logging.info("Updated teams.")
