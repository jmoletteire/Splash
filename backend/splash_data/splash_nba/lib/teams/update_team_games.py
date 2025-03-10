import logging
from splash_nba.imports import get_mongo_collection, CURR_SEASON


def convert_year_to_season(year):
    try:
        start_year = int(year)
        end_year = start_year + 1
        return f"{start_year}-{str(end_year)[-2:]}"
    except ValueError:
        return "Invalid year format"


# Function to get the game result
def get_game_result(team_pts, opp_pts):
    return "W" if team_pts > opp_pts else "L"


def update_team_games(game):
    """
    Iterates over games from games collection and uses the data
    to write game results to teams collection.
    """
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Team Games) Failed to connect to MongoDB: {e}", exc_info=True)
        return

    # Iterate through each game on that date
    try:
        try:
            season = convert_year_to_season(game["season"])
        except Exception:
            season = CURR_SEASON

        is_nba_cup = False
        if "title" in game.keys():
            if 'NBA Cup' in game["title"]:
                is_nba_cup = True

        if game["status"] == 3 and game["homeScore"] is not None and game["awayScore"] is not None:
            home_result = get_game_result(game["homeScore"], game["awayScore"])
            visitor_result = get_game_result(game["awayScore"], game["homeScore"])
        else:
            home_result = game["gameClock"]
            visitor_result = game["gameClock"]

        # Create the game object for both teams
        game_data_home = {
            "SEASON_ID": game["season"],
            "GAME_DATE": game["date"],
            "NBA_CUP": is_nba_cup,
            "HOME_AWAY": "vs",
            "OPP": game["awayTeamId"],
            "TEAM_PTS": game["homeScore"],
            "OPP_PTS": game["awayScore"],
            "RESULT": home_result,
            "BROADCAST": game["broadcast"]
        }

        game_data_visitor = {
            "SEASON_ID": game["season"],
            "GAME_DATE": game["date"],
            "NBA_CUP": is_nba_cup,
            "HOME_AWAY": "@",
            "OPP": game["homeTeamId"],
            "TEAM_PTS": game["awayScore"],
            "OPP_PTS": game["homeScore"],
            "RESULT": visitor_result,
            "BROADCAST": game["broadcast"]
        }

        # Update the home team season data
        teams_collection.update_one(
            {"TEAM_ID": game["homeTeamId"]},
            {"$set": {f"SEASONS.{season}.GAMES.{game['gameId']}": game_data_home}},
        )

        # Update the visitor team season data
        teams_collection.update_one(
            {"TEAM_ID": game["awayTeamId"]},
            {"$set": {f"SEASONS.{season}.GAMES.{game['gameId']}": game_data_visitor}},
        )
    except Exception as e:
        logging.error(f"(Team Games) Could not process games for {game['gameId']}: {e}", exc_info=True)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Access your database and collections
    games_collection = get_mongo_collection('nba_games')
    logging.info("Connected to MongoDB.")

    # Set the batch size
    batch_size = 25

    # Get the total number of documents
    total_documents = games_collection.count_documents({})
    logging.info(f"Total game dates to process: {total_documents}")

    for batch_start in range(0, total_documents, batch_size):
        logging.info(f"Processing batch starting at {batch_start}")

        # Sort the documents in nba_games collection by GAME_DATE in descending order and set batch size
        sorted_games_cursor = games_collection.find({}, {"GAME_DATE": 1, "GAMES": 1, "_id": 0}).sort("GAME_DATE", -1).skip(batch_start).limit(batch_size)

        # Process the games in batches
        for i, day in enumerate(sorted_games_cursor):
            logging.info(f"Processing {i + 1} of {batch_size} ({day['GAME_DATE']})")
            update_team_games(day)
