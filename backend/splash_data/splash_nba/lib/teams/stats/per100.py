import inspect

from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


# Function to calculate per-100 possession values and update the document
def calculate_and_update_per_100_possessions(team_doc, playoffs):
    # Get the current call stack
    stack = inspect.stack()

    # Check the second item in the stack (the caller)
    # The first item in the stack is the current function itself
    caller_frame = stack[1]

    # Extract the function name of the caller
    caller_function = caller_frame.function

    # Check if the caller is the main script
    if caller_function == '<module>':  # '<module>' indicates top-level execution (like __main__)
        print("Called from main script.")
    else:
        # Connect to MongoDB
        try:
            client = MongoClient(uri)
            db = client.splash
            teams_collection = db.nba_teams
        except Exception as e:
            logging.error(f"Failed to connect to MongoDB: {e}")
            exit(1)

    seasons = team_doc.get("seasons", None)

    for season_key, season in seasons.items():
        season_stats = season['STATS']
        if playoffs:
            playoff_stats = season_stats.get("PLAYOFFS", None)

            if playoff_stats is None:
                continue

            adv_stats = playoff_stats.get("ADV", {})
        else:
            adv_stats = season_stats.get("ADV", {})

        possessions = adv_stats.get("POSS", None)

        if possessions:
            for stat_key, location in stats_to_calculate:
                if playoffs:
                    location = 'PLAYOFFS.' + location

                loc = location.split('.')

                if len(loc) == 2:
                    stat_value = season_stats[loc[0]].get(loc[1], {}).get(stat_key, None)
                elif len(loc) == 3:
                    stat_value = season_stats[loc[0]][loc[1]].get(loc[2], {}).get(stat_key, None)
                else:
                    stat_value = season_stats.get(location, {}).get(stat_key, None)

                if stat_value is not None:
                    try:
                        per_100_value = (stat_value / possessions) * 100
                        per_100_key = f"{stat_key}_PER_100"

                        # Update the player document with the new per-75 possession value
                        teams_collection.update_one(
                            {"_id": team_doc["_id"]},
                            {"$set": {f"seasons.{season_key}.STATS.{location}.{per_100_key}": per_100_value}}
                        )
                    except Exception as e:
                        logging.error(f'Unable to add {stat_key} for {team_doc["TEAM_ID"]} for {season_key}: {e}')
        else:
            continue


# List of tuples specifying the stats to calculate per-75 possession values for
# Each tuple should be in the format ("stat_key", "location")
# Example: [("PTS", "BASIC"), ("AST", "BASIC")]
stats_to_calculate = [
    # BASIC
    ("FGM", "BASIC"),
    ("FGA", "BASIC"),
    ("FTM", "BASIC"),
    ("FTA", "BASIC"),
    ("FG3M", "BASIC"),
    ("FG3A", "BASIC"),
    ("STL", "BASIC"),
    ("BLK", "BASIC"),
    ("REB", "BASIC"),
    ("OREB", "BASIC"),
    ("DREB", "BASIC"),
    ("TOV", "BASIC"),
    ("PF", "BASIC"),
    ("PFD", "BASIC"),
    ("PTS", "BASIC"),

    # HUSTLE
    ("CONTESTED_SHOTS", "HUSTLE"),
    ("SCREEN_ASSISTS", "HUSTLE"),
    ("SCREEN_AST_PTS", "HUSTLE"),
    ("BOX_OUTS", "HUSTLE"),
    ("OFF_BOXOUTS", "HUSTLE"),
    ("DEF_BOXOUTS", "HUSTLE"),
    ("DEFLECTIONS", "HUSTLE"),
    ("LOOSE_BALLS_RECOVERED", "HUSTLE"),
]

if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

    playoffs = True

    # Set the batch size
    batch_size = 10  # Adjust this value based on your needs and system performance

    # Get the total number of documents
    total_documents = teams_collection.count_documents({})
    logging.info(f'Total team documents to process: {total_documents}')

    # Process documents in batches
    for batch_start in range(0, total_documents, batch_size):
        logging.info(f'Processing batch starting at {batch_start}')
        batch_cursor = teams_collection.find().skip(batch_start).limit(batch_size)

        for i, team_doc in enumerate(batch_cursor):
            logging.info(f'Processing {i + 1} of {batch_size}')
            calculate_and_update_per_100_possessions(team_doc, playoffs)

    print("Per-100 possession values have been calculated and updated.")
