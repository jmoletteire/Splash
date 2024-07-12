from nba_api.stats.endpoints import teamdetails
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def fetch_team_awards(team_id):
    team_details = teamdetails.TeamDetails(team_id).get_normalized_dict()
    league_title_years = [team_dict['YEARAWARDED'] for team_dict in team_details['TeamAwardsChampionships']]
    conf_title_years = [team_dict['YEARAWARDED'] for team_dict in team_details['TeamAwardsConf']]
    div_title_years = [team_dict['YEARAWARDED'] for team_dict in team_details['TeamAwardsDiv']]

    teams_collection.update_one(
        {"id": team_id},
        {"$set": {"team_history": team_details}}
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

        for team in teams_collection.find():
            fetch_team_awards(team['id'])

    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
