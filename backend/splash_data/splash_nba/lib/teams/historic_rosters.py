from nba_api.stats.endpoints import commonteamroster
from pymongo import MongoClient
from splash_nba.util.env import uri, k_current_season
import logging


def fetch_roster(team_id, season):
    try:
        team_data = commonteamroster.CommonTeamRoster(team_id, season=season).get_normalized_dict()
        team_roster = team_data['CommonTeamRoster']
        team_coaches = team_data['Coaches']

        # Player dictionary {"player_id": {data}}
        team_roster_dict = {
            str(roster_dict['PLAYER_ID']): roster_dict
            for roster_dict in team_roster
        }

        # Update document
        teams_collection.update_one(
            {"TEAM_ID": team_id},
            {"$set": {f"seasons.{season}.ROSTER": team_roster_dict, f"seasons.{season}.COACHES": team_coaches}},
            upsert=True
        )
        logging.info(f"Updated {season} roster for team {team_id}")
    except Exception as e:
        logging.error(f"Updated to fetch {season} roster for team {team_id}: {e}")


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
        for i, doc in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "seasons": 1, "_id": 0})):
            team = doc['TEAM_ID']
            seasons = doc['seasons']
            for season in seasons.keys():
                fetch_roster(team, season)
            logging.info(f"Processed {i + 1} of 30")
        logging.info("Done")
    except Exception as e:
        logging.error(f"Error updating team rosters: {e}")
