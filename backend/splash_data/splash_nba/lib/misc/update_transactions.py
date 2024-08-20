import requests
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

# Replace with your MongoDB connection string
client = MongoClient(uri)
db = client.splash
transactions_collection = db.nba_transactions
logging.info("Connected to MongoDB")

# Fetch the data from the URL
url = "https://stats.nba.com/js/data/playermovement/NBA_Player_Movement.json"
response = requests.get(url)

# Check if the request was successful
if response.status_code == 200:
    data = response.json()

    transactions_collection.insert_many(data['NBA_Player_Movement']['rows'])
else:
    print(f"Failed to fetch data. Status code: {response.status_code}")