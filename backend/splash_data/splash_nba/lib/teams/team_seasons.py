import time
import logging
from pymongo import MongoClient
from nba_api.stats.endpoints import teamyearbyyearstats
from splash_nba.lib.teams.stats.team_stats import fetch_team_stats

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI, CURR_SEASON, CURR_SEASON_TYPE
    PROXY = None
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI, CURR_SEASON, CURR_SEASON_TYPE
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def update_current_season(team_id):
    # Connect to MongoDB
    try:
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"\t(Team Seasons) Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        team_seasons_list = teamyearbyyearstats.TeamYearByYearStats(team_id, proxy=PROXY).get_normalized_dict()['TeamStats']

        # Only for current season
        # EXAMPLE: season_stats_dict = {"2024-25": { data }}
        season_stats_dict = {
            season_dict['YEAR']: dict(list(season_dict.items())[:15])
            for season_dict in team_seasons_list
            if season_dict['YEAR'] == CURR_SEASON
        }

        try:
            # Fetch team stats for this team in given season
            season_stats_dict[CURR_SEASON]['STATS'] = {CURR_SEASON_TYPE: fetch_team_stats(team_id=team_id, season=CURR_SEASON, season_type='Regular Season' if CURR_SEASON_TYPE == 'REGULAR SEASON' else 'PLAYOFFS')}

            # Update SEASONS for this team
            teams_collection.update_one(
                {"TEAM_ID": team_id},
                {"$set": {
                    f"seasons.{CURR_SEASON}.TEAM_ID": season_stats_dict[CURR_SEASON]['TEAM_ID'],
                    f"seasons.{CURR_SEASON}.TEAM_CITY": season_stats_dict[CURR_SEASON]['TEAM_CITY'],
                    f"seasons.{CURR_SEASON}.TEAM_NAME": season_stats_dict[CURR_SEASON]['TEAM_NAME'],
                    f"seasons.{CURR_SEASON}.YEAR": season_stats_dict[CURR_SEASON]['YEAR'],
                    f"seasons.{CURR_SEASON}.GP": season_stats_dict[CURR_SEASON]['GP'],
                    f"seasons.{CURR_SEASON}.WINS": season_stats_dict[CURR_SEASON]['WINS'],
                    f"seasons.{CURR_SEASON}.LOSSES": season_stats_dict[CURR_SEASON]['LOSSES'],
                    f"seasons.{CURR_SEASON}.WIN_PCT": season_stats_dict[CURR_SEASON]['WIN_PCT'],
                    f"seasons.{CURR_SEASON}.CONF_RANK": season_stats_dict[CURR_SEASON]['CONF_RANK'],
                    f"seasons.{CURR_SEASON}.DIV_RANK": season_stats_dict[CURR_SEASON]['DIV_RANK'],
                    f"seasons.{CURR_SEASON}.PO_WINS": season_stats_dict[CURR_SEASON]['PO_WINS'],
                    f"seasons.{CURR_SEASON}.PO_LOSSES": season_stats_dict[CURR_SEASON]['PO_LOSSES'],
                    f"seasons.{CURR_SEASON}.STATS.{CURR_SEASON_TYPE}": season_stats_dict[CURR_SEASON]['STATS'][CURR_SEASON_TYPE]
                }},
                upsert=True
            )
        except Exception as e:
            logging.error(f"\t(Team Seasons) {CURR_SEASON} season stats unavailable for {team_id}: {e}")
            teams_collection.update_one(
                {"TEAM_ID": team_id},
                {"$set": {
                    f"seasons.{CURR_SEASON}.TEAM_ID": team_id,
                    f"seasons.{CURR_SEASON}.YEAR": CURR_SEASON,
                    f"seasons.{CURR_SEASON}.GP": 0,
                    f"seasons.{CURR_SEASON}.WINS": 0,
                    f"seasons.{CURR_SEASON}.LOSSES": 0,
                    f"seasons.{CURR_SEASON}.WIN_PCT": 0.000,
                    f"seasons.{CURR_SEASON}.CONF_RANK": 0,
                    f"seasons.{CURR_SEASON}.DIV_RANK": 0,
                    f"seasons.{CURR_SEASON}.PO_WINS": 0,
                    f"seasons.{CURR_SEASON}.PO_LOSSES": 0,
                    f"seasons.{CURR_SEASON}.STATS.{CURR_SEASON_TYPE}": {'BASIC': {}, 'ADV': {}, 'HUSTLE': {}}
                }},
                upsert=True
            )

            logging.info(f"\t(Team Seasons) Updated {CURR_SEASON} stats for {team_id}.")
    except Exception as e:
        logging.error(f"\t(Team Seasons) Failed to update current season for team {team_id}: {e}")


def fetch_all_seasons(team_id):
    team_seasons_list = teamyearbyyearstats.TeamYearByYearStats(team_id, proxy=PROXY).get_normalized_dict()['TeamStats']

    # All seasons since 1980-81
    season_stats_dict = {
        season_dict['YEAR']: dict(list(season_dict.items())[:15])
        for season_dict in team_seasons_list
        if int(season_dict['YEAR'][:4]) < 1980
    }

    for season in season_stats_dict.keys():
        # Stats only available since 1996-97
        if season >= '1996-97':
            # Fetch team stats for this team in given season
            season_stats_dict[season]['STATS'] = fetch_team_stats(team_id=team_id, season=season, season_type='Regular Season')
            time.sleep(5)

        logging.info(f"Processed {season} for {team_id}")

        # Update SEASONS for this team
        teams_collection.update_one(
            {"TEAM_ID": team_id},
            {"$set": {f"seasons.{season}": season_stats_dict[season]}},
            upsert=True
        )
    logging.info(f"Fetched seasons for team {team_id}\n")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(URI)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        # Loop through all documents in the collection
        #for i, doc in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            #team = doc['TEAM_ID']
            update_current_season(1610612750)
            #fetch_all_seasons(team)
            # time.sleep(30)
       # rank_hustle_stats_current_season()
    except Exception as e:
        logging.error(f"Error updating team seasons: {e}")
