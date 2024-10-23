import inspect

from pymongo import MongoClient
from splash_nba.util.env import uri, k_current_season
import logging


def current_season_per_100_possessions(team_doc, playoffs):
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"\t(Team Per-100) Failed to connect to MongoDB: {e}")
        exit(1)

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

    seasons = team_doc.get("seasons", None)

    for season_key, season in seasons.items():
        if season_key != k_current_season:
            continue

        season_stats = season.get("STATS", None)
        if season_stats is None:
            continue

        if playoffs:
            playoff_stats = season_stats.get("PLAYOFFS", None)

            if playoff_stats is None:
                continue

            adv_stats = playoff_stats.get("ADV", {})
        else:
            reg_season_stats = season_stats.get("REGULAR SEASON", None)

            if reg_season_stats is None:
                continue

            adv_stats = reg_season_stats.get("ADV", {})

        possessions = adv_stats.get("POSS", None)

        if possessions:
            for stat_key, location in stats_to_calculate:
                if playoffs:
                    location = 'PLAYOFFS.' + location
                else:
                    location = 'REGULAR SEASON.' + location

                loc = location.split('.')

                try:
                    if len(loc) == 2:
                        stat_value = season_stats[loc[0]].get(loc[1], {}).get(stat_key, None)
                    elif len(loc) == 3:
                        stat_value = season_stats[loc[0]][loc[1]].get(loc[2], {}).get(stat_key, None)
                    else:
                        stat_value = season_stats.get(location, {}).get(stat_key, None)
                except KeyError:
                    logging.error(f"\t(Team Per-100) Could not find stat for {stat_key} in {location}")
                    stat_value = None

                if stat_value is not None:
                    try:
                        try:
                            per_100_value = (stat_value / possessions) * 100
                        except ZeroDivisionError:
                            per_100_value = 0

                        per_100_key = f"{stat_key}_PER_100"

                        # Update the team document with the new per-100 possession value
                        teams_collection.update_one(
                            {"TEAM_ID": team_doc["TEAM_ID"]},
                            {"$set": {f"seasons.{season_key}.STATS.{location}.{per_100_key}": per_100_value}}
                        )
                    except Exception as e:
                        logging.error(f"\t(Team Per-100) Unable to add {stat_key} for {team_doc['TEAM_ID']} for {season_key}: {e}")
        else:
            continue


# Function to calculate per-100 possession values and update the document
def calculate_and_update_per_100_possessions(team_doc, playoffs):
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

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
                        logging.error(f'(Stats) Unable to add {stat_key} for {team_doc["TEAM_ID"]} for {season_key}: {e}')
        else:
            continue


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

    playoffs = False

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
            #current_season_per_100_possessions(team_doc, playoffs)

    print("Per-100 possession values have been calculated and updated.")
