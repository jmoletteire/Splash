import inspect

from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


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


def update_team_games(game_day):
    """
    Iterates over games from games collection and uses the data
    to write game results to teams collection.
    """
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"(Team Games) Failed to connect to MongoDB: {e}")
        exit(1)

    # Iterate through each game on that date
    for game_id, game in game_day["GAMES"].items():
        try:
            season = convert_year_to_season(game["SUMMARY"]["GameSummary"][0]["SEASON"])
            game_date = game["SUMMARY"]["GameSummary"][0]["GAME_DATE_EST"][:10]
            season_id = game["SUMMARY"]["GameSummary"][0]["GAME_ID"][2] + game["SUMMARY"]["GameSummary"][0]["SEASON"]

            line_scores = game["SUMMARY"]["LineScore"]
            home_team_id = game["SUMMARY"]["GameSummary"][0]['HOME_TEAM_ID']
            visitor_team_id = game["SUMMARY"]["GameSummary"][0]['VISITOR_TEAM_ID']
            home_team_pts = None
            visitor_team_pts = None

            # Determine home and away team by checking team IDs
            if len(line_scores) > 0:
                if line_scores[0]["TEAM_ID"] == home_team_id:
                    home_team_pts = line_scores[0]["PTS"]
                    visitor_team_pts = line_scores[1]["PTS"]
                else:
                    home_team_pts = line_scores[1]["PTS"]
                    visitor_team_pts = line_scores[0]["PTS"]

            if home_team_pts is not None and visitor_team_pts is not None:
                home_result = get_game_result(home_team_pts, visitor_team_pts)
                visitor_result = get_game_result(visitor_team_pts, home_team_pts)
            else:
                home_result = game["SUMMARY"]["GameSummary"][0]['GAME_STATUS_TEXT']
                visitor_result = game["SUMMARY"]["GameSummary"][0]['GAME_STATUS_TEXT']

            natl_tv = game["SUMMARY"]["GameSummary"][0]['NATL_TV_BROADCASTER_ABBREVIATION']

            # Create the game object for both teams
            game_data_home = {
                "SEASON_ID": season_id,
                "GAME_DATE": game_date,
                "HOME_AWAY": "vs",
                "OPP": visitor_team_id,
                "TEAM_PTS": home_team_pts,
                "OPP_PTS": visitor_team_pts,
                "RESULT": home_result,
                "BROADCAST": natl_tv
            }

            game_data_visitor = {
                "SEASON_ID": season_id,
                "GAME_DATE": game_date,
                "HOME_AWAY": "@",
                "OPP": home_team_id,
                "TEAM_PTS": visitor_team_pts,
                "OPP_PTS": home_team_pts,
                "RESULT": visitor_result,
                "BROADCAST": natl_tv
            }

            # Update the home team season data
            teams_collection.update_one(
                {"TEAM_ID": home_team_id},
                {"$set": {f"seasons.{season}.GAMES.{game_id}": game_data_home}},
            )

            # Update the visitor team season data
            teams_collection.update_one(
                {"TEAM_ID": visitor_team_id},
                {"$set": {f"seasons.{season}.GAMES.{game_id}": game_data_visitor}},
            )
        except Exception as e:
            logging.error(f"(Team Games) Could not process games for {game_day['GAME_DATE']}: {e}")
            continue


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to your MongoDB cluster
    client = MongoClient(uri)

    # Access your database and collections
    db = client.splash
    games_collection = db.nba_games
    teams_collection = db.nba_teams
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
        for i, game_day in enumerate(sorted_games_cursor):
            logging.info(f"Processing {i + 1} of {batch_size} ({game_day['GAME_DATE']})")
            update_team_games(game_day)
