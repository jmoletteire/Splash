from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def get_last_game(seasons):
    # Extract the keys from the MongoDB object
    keys = seasons.keys()

    # Convert the keys to a sortable format (tuples of integers)
    converted_keys = [(int(year.split("-")[0]), int(year.split("-")[1])) for year in keys]

    # Find the maximum key
    max_key_tuple = max(converted_keys)

    # Convert the maximum key back to the original format
    max_key = f"{max_key_tuple[0]}-{max_key_tuple[1]}"

    # Convert the GAMES dictionary to a list of tuples (key, value)
    entries = list(seasons[max_key]["GAMES"].items())

    # Sort the entries by the GAME_DATE value
    entries.sort(key=lambda x: x[1]["GAME_DATE"])

    # Extract the sorted keys
    game_index = [e[0] for e in entries]

    # Save the maximum key
    max_game_key = game_index[-1]

    return max_game_key, seasons[max_key]["GAMES"][max_game_key]["GAME_DATE"]


def get_last_lineup(team_id, last_game_id, last_game_date):
    try:
        games = games_collection.find({"GAME_DATE": last_game_date}, {"GAMES": 1, "_id": 0})

        # Extract the "GAMES" key from the cursor
        games_data = []
        for document in games:
            games_data.append(document.get("GAMES"))

        last_game = games_data[0][last_game_id]

        starters = []
        for player in last_game["BOXSCORE"]["PlayerStats"]:
            if player["TEAM_ID"] == team_id and player["START_POSITION"] != "":
                starters.append({
                    "PLAYER_ID": player["PLAYER_ID"],
                    "NAME": player["PLAYER_NAME"],
                    "POSITION": player["START_POSITION"],
                })

            if len(starters) == 5:
                break
            else:
                continue

        return starters

    except Exception as e:
        logging.error(f"Error while getting last lineup: {e}")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    try:
        client = MongoClient(uri)
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
