import inspect
import time
from nba_api.stats.endpoints import teamyearbyyearstats
from pymongo import MongoClient

from splash_nba.lib.teams.stats.team_hustle_stats_rank import rank_hustle_stats_current_season
from splash_nba.lib.teams.stats.team_stats import fetch_team_stats
from splash_nba.util.env import uri, k_current_season, k_current_season_type
import logging


def update_current_season(team_id):
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f"(Team Seasons) Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        team_seasons_list = teamyearbyyearstats.TeamYearByYearStats(team_id).get_normalized_dict()['TeamStats']

        # Only for current season
        # EXAMPLE: season_stats_dict = {"2024-25": { data }}
        season_stats_dict = {
            season_dict['YEAR']: dict(list(season_dict.items())[:15])
            for season_dict in team_seasons_list
            if season_dict['YEAR'] == k_current_season
        }

        try:
            # Fetch team stats for this team in given season
            season_stats_dict[k_current_season]['STATS'][k_current_season_type] = fetch_team_stats(team_id=team_id, season=k_current_season, season_type='Regular Season' if k_current_season_type == 'REGULAR SEASON' else 'PLAYOFFS')

            logging.info(f"(Team Seasons) Updated {k_current_season} stats for {team_id}")

            # Update SEASONS for this team
            teams_collection.update_one(
                {"TEAM_ID": team_id},
                {"$set": {
                    f"seasons.{k_current_season}.TEAM_ID": season_stats_dict[k_current_season]['TEAM_ID'],
                    f"seasons.{k_current_season}.TEAM_CITY": season_stats_dict[k_current_season]['TEAM_CITY'],
                    f"seasons.{k_current_season}.TEAM_NAME": season_stats_dict[k_current_season]['TEAM_NAME'],
                    f"seasons.{k_current_season}.YEAR": season_stats_dict[k_current_season]['YEAR'],
                    f"seasons.{k_current_season}.GP": season_stats_dict[k_current_season]['GP'],
                    f"seasons.{k_current_season}.WINS": season_stats_dict[k_current_season]['WINS'],
                    f"seasons.{k_current_season}.LOSSES": season_stats_dict[k_current_season]['LOSSES'],
                    f"seasons.{k_current_season}.WIN_PCT": season_stats_dict[k_current_season]['WIN_PCT'],
                    f"seasons.{k_current_season}.CONF_RANK": season_stats_dict[k_current_season]['CONF_RANK'],
                    f"seasons.{k_current_season}.DIV_RANK": season_stats_dict[k_current_season]['DIV_RANK'],
                    f"seasons.{k_current_season}.PO_WINS": season_stats_dict[k_current_season]['PO_WINS'],
                    f"seasons.{k_current_season}.PO_LOSSES": season_stats_dict[k_current_season]['PO_LOSSES'],
                    f"seasons.{k_current_season}.STATS.{k_current_season_type}": season_stats_dict[k_current_season]['STATS'][k_current_season_type]
                }},
                upsert=True
            )
        except Exception as e:
            logging.error(f"(Team Seasons) {k_current_season} season stats unavailable for {team_id}: {e}")
            teams_collection.update_one(
                {"TEAM_ID": team_id},
                {"$set": {
                    f"seasons.{k_current_season}.TEAM_ID": team_id,
                    f"seasons.{k_current_season}.YEAR": k_current_season,
                    f"seasons.{k_current_season}.GP": 0,
                    f"seasons.{k_current_season}.WINS": 0,
                    f"seasons.{k_current_season}.LOSSES": 0,
                    f"seasons.{k_current_season}.WIN_PCT": 0.000,
                    f"seasons.{k_current_season}.CONF_RANK": 0,
                    f"seasons.{k_current_season}.DIV_RANK": 0,
                    f"seasons.{k_current_season}.PO_WINS": 0,
                    f"seasons.{k_current_season}.PO_LOSSES": 0,
                    f"seasons.{k_current_season}.STATS.{k_current_season_type}": {'BASIC': {}, 'ADV': {}, 'HUSTLE': {}}
                }},
                upsert=True
            )

        logging.info(f"(Team Seasons) Updated current season for team {team_id}")
    except Exception as e:
        logging.error(f"(Team Seasons) Failed to update current season for team {team_id}: {e}")


def fetch_all_seasons(team_id):
    team_seasons_list = teamyearbyyearstats.TeamYearByYearStats(team_id).get_normalized_dict()['TeamStats']

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
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        # Loop through all documents in the collection
        for i, doc in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            team = doc['TEAM_ID']
            #update_current_season(team)
            fetch_all_seasons(team)
            # time.sleep(30)
        #rank_hustle_stats_current_season()
    except Exception as e:
        logging.error(f"Error updating team seasons: {e}")
