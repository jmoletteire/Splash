from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri, maxPoolSize=100)
    db = client.splash
    games_collection = db.nba_games
    logging.info("Connected to MongoDB")
