from nba_api.stats.endpoints import drafthistory
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def draft_history():
    draft_hist = drafthistory.DraftHistory().get_normalized_dict()['DraftHistory']

    # Organize the data into the desired format
    organized_data = {}
    for entry in draft_hist:
        year = entry['SEASON']
        if year not in organized_data:
            organized_data[year] = {
                "DRAFT_YEAR": year,
                "SELECTIONS": []
            }
        organized_data[year]['SELECTIONS'].append(entry)

    try:
        # Insert or update the draft history in MongoDB
        for draft in organized_data.values():
            draft_collection.update_one(
                {"YEAR": draft["DRAFT_YEAR"]},
                {"$set": draft},
                upsert=True
            )
        logging.info("Updated draft histories.")
    except Exception as e:
        logging.error(f"Error updating draft history: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    draft_collection = db.nba_draft_history
    logging.info("Connected to MongoDB")

    draft_history()
