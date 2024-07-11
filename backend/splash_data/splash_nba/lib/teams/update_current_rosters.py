from nba_api.stats.endpoints import commonteamroster
from pymongo import MongoClient
from splash_nba.util.env import uri, k_current_season
import logging


def fetch_roster(team_id):
    try:
        team_roster = commonteamroster.CommonTeamRoster(team_id, season=k_current_season).get_normalized_dict()['CommonTeamRoster']

        # Player dictionary {"player_id": {data}}
        team_roster_dict = {
            str(roster_dict['PLAYER_ID']): roster_dict
            for roster_dict in team_roster
        }

        # Coaches
        team_coaches = commonteamroster.CommonTeamRoster(team_id).get_normalized_dict()['Coaches']

        # Update document
        teams_collection.update_one(
            {"TEAM_ID": team_id},
            {"$set": {"roster": team_roster_dict, "coaches": team_coaches}},
            upsert=True
        )
        logging.info(f"Updated roster for team {team_id}")
    except Exception as e:
        logging.error(f"Updated to fetch roster for team {team_id}: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        # All Teams
        for i, doc in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            team = doc['TEAM_ID']
            fetch_roster(team)
            logging.info(f"Processed {i + 1} of 30")
        logging.info("Done")
    except Exception as e:
        logging.error(f"Error updating team rosters: {e}")
