import inspect
import logging
from pymongo import MongoClient
from nba_api.stats.endpoints import commonteamroster

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI, CURR_SEASON, CURR_SEASON_TYPE
    PROXY = None
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI, CURR_SEASON, CURR_SEASON_TYPE
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def fetch_roster(team_id):
    # Get the current call stack
    stack = inspect.stack()

    # Check the second item in the stack (the caller)
    # The first item in the stack is the current function itself
    caller_frame = stack[1]

    # Extract the function name of the caller
    caller_function = caller_frame.function

    # Check if the caller is the main script
    if caller_function == '<module>':  # '<module>' indicates top-level execution (like __main__)
        print("Called from main script.")
    else:
        # Connect to MongoDB
        try:
            client = MongoClient(URI)
            db = client.splash
            teams_collection = db.nba_teams
        except Exception as e:
            logging.error(f"Failed to connect to MongoDB: {e}")
            exit(1)

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
        if caller_function == '<module>':
            main_teams_collection.update_one(
                {"TEAM_ID": team_id},
                {"$set": {f"seasons.{CURR_SEASON}.ROSTER": team_roster_dict, f"seasons.{CURR_SEASON}.COACHES": coaches}},
                upsert=True
            )
        else:
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
        client = MongoClient(URI)
        db = client.splash
        main_teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        # All Teams
        for i, doc in enumerate(main_teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            team = doc['TEAM_ID']
            fetch_roster(team)
            logging.info(f"Processed {i + 1} of 30")
        logging.info("Done")
    except Exception as e:
        logging.error(f"Error updating team rosters: {e}")
