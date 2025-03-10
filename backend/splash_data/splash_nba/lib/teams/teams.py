import logging
from nba_api.stats.static import teams
from nba_api.stats.endpoints import teamdetails
from splash_nba.lib.teams.team_history import update_team_history
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS


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
            team_details = teamdetails.TeamDetails(team_id, proxy=PROXY, headers=HEADERS)
            team_info = team_details.get_normalized_dict()['TeamBackground'][0]
            teams_collection.insert_one(team_info)

        logging.info(f"Number of teams fetched: {len(team_ids)}")
    except Exception as e:
        logging.error(f"Error fetching teams: {e}", exc_info=True)

    try:
        # Loop through all documents in the collection
        for i, team in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            team_id = team['TEAM_ID']
            update_team_history(team_id)
            logging.info(f"Processed {i + 1} of 30")
    except Exception as e:
        logging.error(f"Error updating team history: {e}", exc_info=True)


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

    # fetch_teams()
    update_teams()
    logging.info("Updated teams.")
