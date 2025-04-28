import logging
from nba_api.stats.endpoints import franchisehistory
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS


def update_team_history(team_id):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Team History) Failed to connect to MongoDB: {e}", exc_info=True)
        return

    try:
        # Fetch the franchise history data
        history_list = franchisehistory.FranchiseHistory(proxy=PROXY, headers=HEADERS).get_normalized_dict()['FranchiseHistory']

        # Insert or update the team history in MongoDB
        for entry in history_list:
            if entry['TEAM_ID'] == team_id:
                teams_collection.update_one(
                    {"TEAM_ID": entry['TEAM_ID']},
                    {"$set": {"TEAM_HISTORY": entry}},
                    upsert=True
                )
    except Exception as e:
        logging.error(f"(Team History) Error fetching team history for {team_id}: {e}", exc_info=True)
        return




if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB, then fetch teams
    try:
        teams_collection = get_mongo_collection('nba_teams')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}", exc_info=True)
        exit(1)

    for i, team in enumerate(teams_collection.find()):
        update_team_history(team['TEAM_ID'])
        logging.info(f"Updated {i + 1} of 30.")
    logging.info("Updated teams.")
