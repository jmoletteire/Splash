from nba_api.stats.endpoints import leaguestandings
from pymongo import MongoClient
from splash_nba.util.env import uri, k_current_season
import logging


def update_current_standings():
    try:
        logging.info(f"Updating standings for Season: {k_current_season}")
        standings = leaguestandings.LeagueStandings(season=k_current_season).get_normalized_dict()['Standings']

        for i, team in enumerate(standings):
            # Update STANDINGS data for each team
            teams_collection.update_one(
                {"TEAM_ID": team['TeamID']},
                {"$set": {f"seasons.{k_current_season}.STANDINGS": team}},
                upsert=True
            )
            logging.info(f"Updated {i + 1} of {len(standings)}\n")
    except Exception as e:
        logging.error(f"Unable to update standings: {e}")


def fetch_all_standings():
    seasons = [
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
        '1996-97',
        '1995-96',
        '1994-95',
        '1993-94',
        '1992-93',
        '1991-92',
        '1990-91',
        '1989-90',
        '1988-89',
        '1987-88',
        '1986-87',
        '1985-86',
        '1984-85',
        '1983-84',
        '1982-83',
        '1981-82',
        '1980-81',
    ]

    for season in seasons:
        logging.info(f"Fetching standings for Season: {season}")

        try:
            standings = leaguestandings.LeagueStandings(season=season).get_normalized_dict()['Standings']

            for i, team in enumerate(standings):
                # Add STANDINGS data for each team
                teams_collection.update_one(
                    {"TEAM_ID": team["TeamID"]},
                    {"$set": {f"seasons.{season}.STANDINGS": team}},
                    upsert=True
                )
                logging.info(f"Fetched {i + 1} of {len(standings)}\n")
        except Exception as e:
            logging.error(f"Unable to fetch standings: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    # fetch_all_standings()
    update_current_standings()
