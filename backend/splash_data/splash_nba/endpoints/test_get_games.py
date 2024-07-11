from pymongo import MongoClient
from splash_nba.util.env import uri
import logging

def find_game_by_date(game_date):
    try:
        # Connect to MongoDB
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games_v2

        # Query to find documents containing the specified game date
        query = {
            f'GAME_DATES.{game_date}': {"$exists": True}
        }

        # Execute the query
        results = games_collection.find(query)
        print(list(results))

        # Print the results
        for result in list(results):
            print(result)

    except Exception as e:
        logging.error(f"Error finding games by date: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Specify the game date to search for
    game_date_to_find = "2024-06-09"  # Replace with the actual game date you're looking for
    find_game_by_date(game_date_to_find)