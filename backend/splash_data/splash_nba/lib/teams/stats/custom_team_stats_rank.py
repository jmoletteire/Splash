import logging
from splash_nba.imports import get_mongo_collection


def calculate_percentile(path, league_teams_path):
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Custom Team Stats Rank) Failed to connect to MongoDB: {e}", exc_info=True)
        return

    try:
        match = {
            "$and": [
                {f"{league_teams_path}": {"$exists": True}},
                {f"{path}.Value": {"$exists": True}}
            ]
        }
        print(teams_collection.count_documents(match))
        teams_collection.aggregate([
            # Match only documents where the given stat and League Teams fields exist
            {
                "$match": {
                    "$and": [
                        {f"{league_teams_path}": {"$exists": True}},
                        {f"{path}.Value": {"$exists": True}}
                    ]
                }
            },
            # Use $set to calculate Pct based on league_teams_path
            {
                "$set": {
                    f"{path}.Pct": {
                        "$let": {
                            "vars": {
                                "rank": {"$toInt": f"${path}.Rank"},
                                "total": {"$toInt": f"${league_teams_path}"}
                            },
                            "in": {
                                "$cond": {
                                    "if": {
                                        "$or": [
                                            {"$lt": [{"$subtract": ["$$total", 1]}, 1]},  # Pct < 0
                                            {"$lt": ["$$rank", 1]}  # Pct > 1
                                        ]
                                    },
                                    "then": "0.000",  # Avoid division by zero issues
                                    "else": {
                                        "$toString": {
                                            "$round": [
                                                {
                                                    "$subtract": [
                                                        1,
                                                        {
                                                            "$divide": [
                                                                {"$subtract": ["$$rank", 1]},
                                                                {"$subtract": ["$$total", 1]}
                                                            ]
                                                        }
                                                    ]
                                                },
                                                3  # Round to 3 decimal places
                                            ]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            # Merge the results back into the same collection
            {
                "$merge": {
                    "into": "nba_teams",  # Updates the same collection
                    "on": "_id",
                    "whenMatched": "merge",  # Updates existing documents
                    "whenNotMatched": "discard"  # Avoids inserting new documents
                }
            }
        ])
    except Exception as e:
        logging.error(f"(Custom Team Stats Rank) Failed to calculate percentile: {e}", exc_info=True)
        return


def calculate_rank(path, order):
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Custom Team Stats Rank) Failed to connect to MongoDB: {e}", exc_info=True)
        return

    try:
        match = {
                f"{path}.Value": {"$exists": True}
            }
        print(teams_collection.count_documents(match))
        teams_collection.aggregate([
            # Match only documents where the 'Value' field exists
            {
                "$match": {
                    f"{path}.Value": {"$exists": True}
                }
            },
            {
                "$setWindowFields": {
                    "sortBy": {
                        f"{path}.Value": order
                    },
                    "output": {
                        "rankTemp": {
                            "$documentNumber": {}
                        }
                    }
                }
            },
            # Convert rank to string
            {
                "$set": {
                    f"{path}.Rank": {
                        "$toString": "$rankTemp"
                    }
                }
            },
            # Remove temporary field
            {
                "$unset": "rankTemp"
            },
            # Merge the results back into the same collection
            {
                "$merge": {
                    "into": "nba_teams",  # Updates the same collection
                    "on": "_id",
                    "whenMatched": "merge",  # Updates existing documents
                    "whenNotMatched": "discard"  # Avoids inserting new documents
                }
            }
        ])
    except Exception as e:
        logging.error(f"(Custom Team Stats Rank) Failed to calculate rank: {e}", exc_info=True)
        return


def custom_team_stats_rank(seasons: list = None, season_types: list = None):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    if seasons is None:
        # List of seasons
        seasons = [
            '2024-25',
            '2023-24',
            '2022-23',
            '2021-22',
            '2020-21',
            '2019-20',
            '2018-19',
            '2017-18',
            '2016-17',
            '2015-16',
            '2014-15',
            '2013-14',
            '2012-13',
            '2011-12',
            '2010-11',
            '2009-10',
            '2008-09',
            '2007-08',
            '2006-07',
            '2005-06',
            '2004-05',
            '2003-04',
            '2002-03',
            '2001-02',
            '2000-01',
            '1999-00',
            '1998-99',
            '1997-98',
            '1996-97'
        ]
    if season_types is None:
        # List of season types
        season_types = ['REGULAR SEASON', 'PLAYOFFS']

    # Stat modes
    modes = ['Totals', 'PerGame', 'Per100Possessions']

    # Stats to rank
    custom_stats = [
        # BASIC
        ("3PAr", -1),
        ("FTAr", -1),
        ("FTr", -1),

        # ADV
        ("POSS", -1),

        # HUSTLE
        ("CONTESTED_SHOTS", -1),
        ("DEFLECTIONS", -1),
        ("CHARGES", -1),
        ("SCREEN_AST", -1),
        ("SCREEN_AST_PTS", -1),
        ("LOOSE_BALLS", -1),
        ("OFF_BOXOUTS", -1),
        ("DEF_BOXOUTS", -1),
        ("BOX_OUTS", -1)
    ]

    # Loop over each season to build the pipeline
    for stat in custom_stats:
        logging.info(f"\nCalculating {stat[0]} rank...")
        for season in seasons:
            for season_type in season_types:
                for mode in modes:
                    logging.info(f"\tSeason: {season} {season_type} {mode}")
                    path = f"SEASONS.{season}.STATS.{season_type}.{stat[0]}.{mode}"
                    league_teams_path = f"SEASONS.{season}.STATS.{season_type}.LEAGUE_TEAMS.Totals.Value"

                    calculate_rank(path, stat[1])
                    calculate_percentile(path, league_teams_path)


if __name__ == "__main__":
    custom_team_stats_rank(seasons=['2024-25'], season_types=['REGULAR SEASON'])
    # custom_team_stats_rank()
