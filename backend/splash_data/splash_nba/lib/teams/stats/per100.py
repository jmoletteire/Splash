import logging
from splash_nba.imports import get_mongo_collection


# Function to calculate per-100 possession values and update the document
def calculate_per_100_poss(team, seasons: list = None, season_types: list = None):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection("nba_teams")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}", exc_info=True)
        return

    if seasons is None:
        # List of all available seasons
        seasons = [
            '2024-25',
            # '2023-24',
            # '2022-23',
            # '2021-22',
            # '2020-21',
            # '2019-20',
            # '2018-19',
            # '2017-18',
            # '2016-17',
            # '2015-16',
            # '2014-15',
            # '2013-14',
            # '2012-13',
            # '2011-12',
            # '2010-11',
            # '2009-10',
            # '2008-09',
            # '2007-08',
            # '2006-07',
            # '2005-06',
            # '2004-05',
            # '2003-04',
            # '2002-03',
            # '2001-02',
            # '2000-01',
            # '1999-00',
            # '1998-99',
            # '1997-98',
            # '1996-97'
        ]
    if season_types is None:
        # List of all season types
        season_types = ["REGULAR SEASON", "PLAYOFFS"]

    stats_to_calculate = [
        # HUSTLE
        "CONTESTED_SHOTS",
        "DEFLECTIONS",
        "CHARGES",
        "SCREEN_AST",
        "SCREEN_AST_PTS",
        "LOOSE_BALLS",
        "OFF_BOXOUTS",
        "DEF_BOXOUTS",
        "BOX_OUTS"
    ]

    for season in seasons:
        for season_type in season_types:
            stats = team.get("SEASONS", {}).get(season, {}).get("STATS", {}).get(season_type, None)
            if stats is None:
                continue

            possessions = stats.get("POSS", {}).get("Totals", {}).get("Value", None)
            if possessions is None:
                continue

            for stat_key in stats_to_calculate:
                stat_value = stats.get(stat_key, {}).get("Totals", {}).get("Value", None)
                if stat_value is None:
                    continue

                try:
                    try:
                        per_100_value = (int(stat_value) / int(possessions)) * 100
                    except ZeroDivisionError:
                        per_100_value = 0

                    stat_dict = {"Value": f"{per_100_value:.1f}", "Rank": "0", "Pct": "0.000"}

                    # Update the team document with the new per-100 possession value
                    teams_collection.update_one(
                        {"TEAM_ID": team["TEAM_ID"]},
                        {"$set": {f"SEASONS.{season}.STATS.{season_type}.{stat_key}.Per100Possessions": stat_dict}}
                    )

                except Exception as e:
                    logging.error(f'(Stats) Unable to add {stat_key} for {team["TEAM_ID"]} for {season}: {e}', exc_info=True)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    _teams_collection = get_mongo_collection("nba_teams")
    logging.info("Connected to MongoDB")

    # Get the total number of documents
    total_documents = _teams_collection.count_documents({})
    logging.info(f"Total team documents to process: {total_documents}")

    # Process documents in batches
    query = {"TEAM_ID": {"$ne": 0}}
    proj = {"TEAM_ID": 1, "SEASONS": 1, "_id": 0}
    for i, team_doc in enumerate(_teams_collection.find(query, proj)):
        logging.info(f"Processing {i + 1} of {total_documents}")
        calculate_per_100_poss(team_doc)

    logging.info("Per-100 possession values have been calculated and updated.")
