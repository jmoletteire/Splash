import logging
import datetime
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import PROXY, URI
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def get_last_game(seasons):
    # Get today's date for comparison
    today = datetime.date.today()

    # Extract the keys from the MongoDB object
    keys = seasons.keys()

    # Convert the keys to a sortable format (tuples of integers)
    converted_keys = [(int(year.split("-")[0]), int(year.split("-")[1])) for year in keys]

    # Sort the keys to iterate through them from latest to earliest
    converted_keys.sort(reverse=True)

    # Iterate through the sorted keys and check the games in each season
    for key_tuple in converted_keys:
        # Convert the tuple back to the original format
        key = f"{key_tuple[0]}-{key_tuple[1]}"

        # Convert the GAMES dictionary to a list of tuples (key, value)
        if 'GAMES' in seasons[key].keys():
            entries = list(seasons[key]["GAMES"].items())

            # Sort the entries by the GAME_DATE value
            entries.sort(key=lambda x: x[1]["GAME_DATE"])

            # Find the latest game date that is less than today
            for game_key, game_data in reversed(entries):
                game_date = datetime.date(int(game_data["GAME_DATE"][0:4]), int(game_data["GAME_DATE"][5:7]), int(game_data["GAME_DATE"][8:]))  # Adjust the format as necessary
                if game_date < today and game_data['RESULT'] != 'Cancelled':
                    return game_key, game_data["GAME_DATE"]
        else:
            continue

    # If no game date is found that's less than today, return None or handle it as appropriate
    return None, None


def get_last_lineup(team_id, last_game_id, last_game_date):
    # Connect to MongoDB
    try:
        client = MongoClient(URI)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f"\tFailed to connect to MongoDB: {e}")
        exit(1)

    try:
        games = games_collection.find({"GAME_DATE": last_game_date}, {"GAMES": 1, "_id": 0})

        # Extract the "GAMES" key from the cursor
        games_data = []
        for document in games:
            games_data.append(document.get("GAMES"))

        last_game = games_data[0][last_game_id]
        team = last_game["BOXSCORE"]["homeTeam"]["players"] if last_game["BOXSCORE"]["homeTeam"]["teamId"] == team_id else last_game["BOXSCORE"]["awayTeam"]["players"]

        starters = []
        for player in team:
            if player["starter"] == "1":
                starters.append({
                    "PLAYER_ID": player["personId"],
                    "NAME": player["name"],
                    "POSITION": player["position"],
                })

            if len(starters) == 5:
                break
            else:
                continue

        return starters

    except Exception as e:
        logging.error(f"\tError while getting last lineup: {e}")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    try:
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
        games_collection = db.nba_games
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Unable to connect to MongoDB: {e}")
        exit(1)

    # All Teams
    for team in teams_collection.find({}, {"TEAM_ID": 1, "seasons": 1, "_id": 0}):
        if team['TEAM_ID'] == 0:
            continue

        logging.info(f"Processing team {team['TEAM_ID']}...")

        # Get most recent game by date
        game_id, game_date = get_last_game(team['seasons'])

        # Get starting lineup for most recent game
        last_starting_lineup = get_last_lineup(team['TEAM_ID'], game_id, game_date)

        # Update document
        teams_collection.update_one(
            {"TEAM_ID": team['TEAM_ID']},
            {"$set": {"LAST_STARTING_LINEUP": last_starting_lineup}},
        )

        logging.info(f"Fetched lineup for team {team['TEAM_ID']}")
