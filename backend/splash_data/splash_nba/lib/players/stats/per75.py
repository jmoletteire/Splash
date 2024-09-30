from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


# Function to calculate per-75 possession values and update the document
def calculate_and_update_per_75_possessions(player_doc, playoffs):
    stats = player_doc.get("STATS", None)

    if stats is None:
        return

    for season_key, season_stats in stats.items():
        if playoffs:
            playoff_stats = season_stats.get("PLAYOFFS", None)

            if playoff_stats is None:
                continue

            adv_stats = playoff_stats.get("ADV", {})
        else:
            reg_season_stats = season_stats.get("REGULAR SEASON", {})
            adv_stats = reg_season_stats.get("ADV", {})

        possessions = adv_stats.get("POSS", None)

        if possessions:
            for stat_key, location in stats_to_calculate:
                if playoffs:
                    location = 'PLAYOFFS.' + location
                else:
                    location = 'REGULAR SEASON.' + location

                loc = location.split('.')

                if loc[1] == 'HUSTLE' and season_key < '2013-14':
                    continue

                if len(loc) == 2:
                    stat_value = season_stats[loc[0]].get(loc[1], {}).get(stat_key, None)
                elif len(loc) == 3:
                    stat_value = season_stats[loc[0]][loc[1]].get(loc[2], {}).get(stat_key, None)
                else:
                    stat_value = season_stats.get(location, {}).get(stat_key, None)

                if stat_value is not None:
                    try:
                        per_75_value = (stat_value / possessions) * 75
                        per_75_key = f"{stat_key}_PER_75"

                        # Update the player document with the new per-75 possession value
                        players_collection.update_one(
                            {"_id": player_doc["_id"]},
                            {"$set": {f"STATS.{season_key}.{location}.{per_75_key}": per_75_value}}
                        )
                    except Exception as e:
                        logging.error(f'Unable to add {stat_key} for {player_doc["PLAYER_ID"]} for {season_key}: {e}')
        else:
            continue


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    logging.info("Connected to MongoDB")

    # List of tuples specifying the stats to calculate per-75 possession values for
    # Each tuple should be in the format ("stat_key", "location")
    # Example: [("PTS", "BASIC"), ("AST", "BASIC")]
    stats_to_calculate = [
        # BASIC
        # ("FGM", "BASIC"),
        # ("FGA", "BASIC"),
        # ("FTM", "BASIC"),
        # ("FTA", "BASIC"),
        # ("FG3M", "BASIC"),
        # ("FG3A", "BASIC"),
        # ("AST", "BASIC"),
        # ("STL", "BASIC"),
        # ("BLK", "BASIC"),
        # ("BLKA", "BASIC"),
        # ("REB", "BASIC"),
        # ("OREB", "BASIC"),
        # ("DREB", "BASIC"),
        # ("TOV", "BASIC"),
        # ("PF", "BASIC"),
        # ("PFD", "BASIC"),
        # ("PTS", "BASIC"),
        # ("PLUS_MINUS", "BASIC"),

        # HUSTLE
        # ("CONTESTED_SHOTS", "HUSTLE"),
        # ("SCREEN_ASSISTS", "HUSTLE"),
        # ("SCREEN_AST_PTS", "HUSTLE"),
        # ("BOX_OUTS", "HUSTLE"),
        # ("OFF_BOXOUTS", "HUSTLE"),
        # ("DEF_BOXOUTS", "HUSTLE"),
        # ("DEFLECTIONS", "HUSTLE"),
        # ("LOOSE_BALLS_RECOVERED", "HUSTLE"),
        # ("CHARGES_DRAWN", "HUSTLE"),
        ("DIST_MILES", "HUSTLE.SPEED"),
        ("DIST_MILES_OFF", "HUSTLE.SPEED"),
        ("DIST_MILES_DEF", "HUSTLE.SPEED"),

        # ADV -> PASSING
        # ("PASSES_MADE", "ADV.PASSING"),
        # ("PASSES_RECEIVED", "ADV.PASSING"),
        # ("AST", "ADV.PASSING"),
        # ("FT_AST", "ADV.PASSING"),
        # ("SECONDARY_AST", "ADV.PASSING"),
        # ("POTENTIAL_AST", "ADV.PASSING"),
        # ("AST_PTS_CREATED", "ADV.PASSING"),
        # ("AST_ADJ", "ADV.PASSING"),

        # ADV -> TOUCHES
        # ("TOUCHES", "ADV.TOUCHES"),
        # ("FRONT_CT_TOUCHES", "ADV.TOUCHES"),
        # ("TIME_OF_POSS", "ADV.TOUCHES"),

        # ADV -> DRIVES
        # ("DRIVES", "ADV.DRIVES"),
        # ("DRIVE_FGM", "ADV.DRIVES"),
        # ("DRIVE_FGA", "ADV.DRIVES"),
        # ("DRIVE_FTM", "ADV.DRIVES"),
        # ("DRIVE_FTA", "ADV.DRIVES"),
        # ("DRIVE_PTS", "ADV.DRIVES"),
        # ("DRIVE_PASSES", "ADV.DRIVES"),
        # ("DRIVE_AST", "ADV.DRIVES"),
        # ("DRIVE_TOV", "ADV.DRIVES"),

        # ADV -> REBOUNDING
        # ("OREB_CONTEST", "ADV.REBOUNDING"),
        # ("OREB_UNCONTEST", "ADV.REBOUNDING"),
        # ("OREB_CHANCES", "ADV.REBOUNDING"),
        # ("OREB_CHANCE_DEFER", "ADV.REBOUNDING"),
        # ("DREB_CONTEST", "ADV.REBOUNDING"),
        # ("DREB_UNCONTEST", "ADV.REBOUNDING"),
        # ("DREB_CHANCES", "ADV.REBOUNDING"),
        # ("DREB_CHANCE_DEFER", "ADV.REBOUNDING"),
        # ("REB_CONTEST", "ADV.REBOUNDING"),
        # ("REB_UNCONTEST", "ADV.REBOUNDING"),
        # ("REB_CHANCES", "ADV.REBOUNDING"),
        # ("REB_CHANCE_DEFER", "ADV.REBOUNDING")
    ]

    playoffs = True

    # Set the batch size
    batch_size = 25  # Adjust this value based on your needs and system performance

    # Get the total number of documents
    total_documents = players_collection.count_documents({})
    logging.info(f"Total player documents to process: {total_documents}")

    # Process documents in batches
    for batch_start in range(0, total_documents, batch_size):
        logging.info(f"Processing batch starting at {batch_start}")
        batch_cursor = players_collection.find().skip(batch_start).limit(batch_size)

        for i, player_doc in enumerate(batch_cursor):
            logging.info(f"Processing {i + 1} of {batch_size}")
            calculate_and_update_per_75_possessions(player_doc, playoffs)

    print("Per-75 possession values have been calculated and updated.")
