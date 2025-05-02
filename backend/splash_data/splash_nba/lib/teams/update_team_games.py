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


def update_team_games(game, to_remove: bool = False):
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

    try:
        try:
            season = convert_year_to_season(game["season"])
        except Exception:
            season = CURR_SEASON

        if to_remove:
            # Update the home team season data
            teams_collection.update_one(
                {"TEAM_ID": int(game["homeTeamId"])},
                {"$unset": {f"SEASONS.{season}.GAMES.{game['gameId']}": ""}},
            )

            # Update the visitor team season data
            teams_collection.update_one(
                {"TEAM_ID": int(game["awayTeamId"])},
                {"$unset": {f"SEASONS.{season}.GAMES.{game['gameId']}": ""}},
            )

            return

        is_nba_cup = False
        if "title" in game.keys():
            if 'NBA Cup' in game["title"]:
                is_nba_cup = True

        home_score = None
        away_score = None
        broadcast = None
        if "homeScore" in game.keys():
            home_score = game["homeScore"]
        if "awayScore" in game.keys():
            away_score = game["awayScore"]
        if "broadcast" in game.keys():
            broadcast = game["broadcast"]

        if game["status"] == 3 and home_score is not None and away_score is not None:
            home_result = get_game_result(home_score, away_score)
            visitor_result = get_game_result(away_score, home_score)
        else:
            home_result = game["gameClock"]
            visitor_result = game["gameClock"]

        # Create the game object for both teams
        game_data_home = {
            "SEASON_ID": game["seasonCode"],
            "GAME_DATE": game["date"],
            "NBA_CUP": is_nba_cup,
            "HOME_AWAY": "vs",
            "OPP": str(game["awayTeamId"]),
            "TEAM_PTS": home_score,
            "OPP_PTS": away_score,
            "RESULT": home_result,
            "BROADCAST": broadcast
        }

        game_data_visitor = {
            "SEASON_ID": game["seasonCode"],
            "GAME_DATE": game["date"],
            "NBA_CUP": is_nba_cup,
            "HOME_AWAY": "@",
            "OPP": str(game["homeTeamId"]),
            "TEAM_PTS": away_score,
            "OPP_PTS": home_score,
            "RESULT": visitor_result,
            "BROADCAST": broadcast
        }

        # Update the home team season data
        teams_collection.update_one(
            {"TEAM_ID": int(game["homeTeamId"])},
            {"$set": {f"SEASONS.{season}.GAMES.{game['gameId']}": game_data_home}},
        )

        # Update the visitor team season data
        teams_collection.update_one(
            {"TEAM_ID": int(game["awayTeamId"])},
            {"$set": {f"SEASONS.{season}.GAMES.{game['gameId']}": game_data_visitor}},
        )
    except Exception as e:
        logging.error(f"(Team Games) Could not process games for {game['gameId']}: {e}", exc_info=True)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Access your database and collections
    games_collection = get_mongo_collection('nba_games_unwrapped')
    logging.info("Connected to MongoDB")

    # Set the batch size
    batch_size = 25

    # Get the total number of documents
    query = {"seasonCode": "42024"}
    proj = {
        "_id": 0,
        "gameId": 1,
        "awayTeamId": 1,
        "homeTeamId": 1,
        "broadcast": 1,
        "date": 1,
        "gameClock": 1,
        "homeScore": 1,
        "awayScore": 1,
        "season": 1,
        "seasonCode": 1,
        "status": 1,
        "title": 1
    }
    total_documents = games_collection.count_documents(query)
    logging.info(f"Total game dates to process: {total_documents}")

    for batch_start in range(0, total_documents, batch_size):
        logging.info(f"Processing batch starting at {batch_start}")

        # Sort the documents in nba_games collection by GAME_DATE in descending order and set batch size
        sorted_games_cursor = games_collection.find(query, proj).sort("date", -1).skip(batch_start).limit(batch_size)

        # Process the games in batches
        for i, game in enumerate(sorted_games_cursor):
            logging.info(f"Processing {i + 1} of {batch_size} ({game['date']})")
            update_team_games(game)
