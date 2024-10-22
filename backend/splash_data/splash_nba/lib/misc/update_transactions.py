import requests
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


# Function to compare old data with new data and find new entries
def find_new_data(old_data, new_data):
    if not old_data:
        return new_data  # If old data is empty, all new data is considered new

    # Use a set of unique identifiers from the old data
    old_ids = {transaction['GroupSort'] for transaction in old_data}

    # Find new entries that aren't in the old data
    new_entries = [transaction for transaction in new_data if transaction['GroupSort'] not in old_ids]

    return new_entries


def update_transactions():
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

        # Fetch sorted existing data from the collection
        existing_data = transactions_collection.find({}, {'GroupSort': 1, '_id': 0}).sort('TRANSACTION_DATE', -1)

        new_data = find_new_data(existing_data, data['NBA_Player_Movement']['rows'])

        transactions_collection.insert_many(new_data)
    else:
        print(f"Failed to fetch data. Status code: {response.status_code}")


if __name__ == "__main__":
    update_transactions()