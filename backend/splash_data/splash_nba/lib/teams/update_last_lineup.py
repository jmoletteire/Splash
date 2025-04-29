import logging
import datetime
from splash_nba.imports import get_mongo_collection


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


def get_last_lineup(team_id, last_game_id):
    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f"\tFailed to connect to MongoDB: {e}", exc_info=True)
        return None

    try:
        games = games_collection.find({"gameId": last_game_id}, {"homeTeamId": 1, "awayTeamId": 1, "matchup": 1, "_id": 0})
        try:
            last_game = games[0]
            home_id = last_game["homeTeamId"]
        except IndexError:
            return None

        return last_game["matchup"]["lineups"]["home"] if team_id == home_id else last_game["matchup"]["lineups"]["away"]

    except Exception as e:
        logging.error(f"\tError while getting last lineup: {e}", exc_info=True)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    try:
        teams_collection_ = get_mongo_collection('nba_teams')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Unable to connect to MongoDB: {e}", exc_info=True)
        exit(1)

    # All Teams
    for team in teams_collection_.find({}, {"TEAM_ID": 1, "SEASONS": 1, "_id": 0}):
        if team['TEAM_ID'] == 0:
            continue

        logging.info(f"Processing team {team['TEAM_ID']}...")

        seasons = team.get('SEASONS', None)
        if seasons is None:
            continue

        # Get most recent game by date
        game_id, game_date = get_last_game(team['SEASONS'])

        # Get starting lineup for most recent game
        last_starting_lineup = get_last_lineup(str(team['TEAM_ID']), game_id)

        # Update document
        teams_collection_.update_one(
            {"TEAM_ID": team['TEAM_ID']},
            {"$set": {"LAST_STARTING_LINEUP": last_starting_lineup}},
        )

        logging.info(f"Fetched lineup for team {team['TEAM_ID']}")
