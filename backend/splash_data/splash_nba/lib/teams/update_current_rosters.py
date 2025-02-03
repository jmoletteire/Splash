import logging
from nba_api.stats.endpoints import commonteamroster
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON


def fetch_roster(team_id):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        return

    try:
        team_roster = commonteamroster.CommonTeamRoster(team_id, season=CURR_SEASON, proxy=PROXY).get_normalized_dict()
        players = team_roster['CommonTeamRoster']
        coaches = team_roster['Coaches']

        # Player dictionary {"player_id": {data}}
        team_roster_dict = {
            str(player['PLAYER_ID']): player
            for player in players
        }

        # Update document
        teams_collection.update_one(
            {"TEAM_ID": team_id},
            {"$set": {f"seasons.{CURR_SEASON}.ROSTER": team_roster_dict, f"seasons.{CURR_SEASON}.COACHES": coaches}},
            upsert=True
        )
        logging.info(f"Updated roster for team {team_id}")
    except Exception as e:
        logging.error(f"Failed to fetch roster for team {team_id}: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
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
