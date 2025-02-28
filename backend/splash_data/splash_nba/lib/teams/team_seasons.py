import time
import logging
from datetime import datetime
from nba_api.stats.endpoints import teamyearbyyearstats
from splash_nba.lib.teams.stats.team_stats import fetch_team_stats
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON, CURR_SEASON_TYPE


def update_current_season(team_id):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"\t(Team Seasons) Failed to connect to MongoDB: {e}", exc_info=True)
        return

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
            # Update SEASONS for this team
            teams_collection.update_one(
                {"TEAM_ID": team_id},
                {"$set": {
                    f"SEASONS.{CURR_SEASON}.TEAM_ID": season_stats_dict[CURR_SEASON]['TEAM_ID'],
                    f"SEASONS.{CURR_SEASON}.TEAM_CITY": season_stats_dict[CURR_SEASON]['TEAM_CITY'],
                    f"SEASONS.{CURR_SEASON}.TEAM_NAME": season_stats_dict[CURR_SEASON]['TEAM_NAME'],
                    f"SEASONS.{CURR_SEASON}.YEAR": season_stats_dict[CURR_SEASON]['YEAR'],
                    f"SEASONS.{CURR_SEASON}.GP": season_stats_dict[CURR_SEASON]['GP'],
                    f"SEASONS.{CURR_SEASON}.WINS": season_stats_dict[CURR_SEASON]['WINS'],
                    f"SEASONS.{CURR_SEASON}.LOSSES": season_stats_dict[CURR_SEASON]['LOSSES'],
                    f"SEASONS.{CURR_SEASON}.WIN_PCT": season_stats_dict[CURR_SEASON]['WIN_PCT'],
                    f"SEASONS.{CURR_SEASON}.CONF_RANK": season_stats_dict[CURR_SEASON]['CONF_RANK'],
                    f"SEASONS.{CURR_SEASON}.DIV_RANK": season_stats_dict[CURR_SEASON]['DIV_RANK'],
                    f"SEASONS.{CURR_SEASON}.PO_WINS": season_stats_dict[CURR_SEASON]['PO_WINS'],
                    f"SEASONS.{CURR_SEASON}.PO_LOSSES": season_stats_dict[CURR_SEASON]['PO_LOSSES']
                }},
                upsert=True
            )
        except Exception as e:
            logging.error(f"\t(Team Seasons) {CURR_SEASON} season stats unavailable for {team_id}: {e}", exc_info=True)
            teams_collection.update_one(
                {"TEAM_ID": team_id},
                {"$set": {
                    f"SEASONS.{CURR_SEASON}.TEAM_ID": team_id,
                    f"SEASONS.{CURR_SEASON}.YEAR": CURR_SEASON,
                    f"SEASONS.{CURR_SEASON}.GP": 0,
                    f"SEASONS.{CURR_SEASON}.WINS": 0,
                    f"SEASONS.{CURR_SEASON}.LOSSES": 0,
                    f"SEASONS.{CURR_SEASON}.WIN_PCT": 0.000,
                    f"SEASONS.{CURR_SEASON}.CONF_RANK": 0,
                    f"SEASONS.{CURR_SEASON}.DIV_RANK": 0,
                    f"SEASONS.{CURR_SEASON}.PO_WINS": 0,
                    f"SEASONS.{CURR_SEASON}.PO_LOSSES": 0
                }},
                upsert=True
            )

            logging.info(f"\t(Team Seasons) Updated {CURR_SEASON} stats for {team_id}.")
    except Exception as e:
        logging.error(f"\t(Team Seasons) Failed to update current season for team {team_id}: {e}", exc_info=True)


def fetch_all_seasons(team_id):
    team_seasons_list = teamyearbyyearstats.TeamYearByYearStats(team_id, proxy=None).get_normalized_dict()['TeamStats']

    # All seasons since 1996-97
    season_stats_dict = {
        season_dict['YEAR']: dict(list(season_dict.items())[:15])
        for season_dict in team_seasons_list
    }

    season_types = ['Regular Season', 'Playoffs']

    for season in season_stats_dict.keys():
        logging.info(f"Processing {season} for {team_id}... [{datetime.now()}]")
        # Stats only available since 1996-97
        if season >= '1996-97':
            # Regular Season & Playoffs
            for season_type in season_types:
                # Ensure STATS exists in season
                season_stats_dict[season].setdefault('STATS', {})

                # Ensure season_type exists in season_stats_dict[season]
                season_stats_dict[season]['STATS'].setdefault(season_type.upper(), {})

                # Fetch team stats for this team in given season/season-type
                season_stats_dict[season]['STATS'][season_type.upper()] = fetch_team_stats(team_id=team_id, season=season, season_type=season_type)
                time.sleep(10)
        else:
            season_stats_dict[season]['STATS'] = {}

        # Update SEASONS for this team
        _teams_collection.update_one(
            {"TEAM_ID": team_id},
            {"$set": {f"SEASONS.{season}.STATS": season_stats_dict[season]['STATS']}},
            upsert=True
        )
    logging.info(f"Fetched seasons for team {team_id} [{datetime.now()}]\n")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        _teams_collection = get_mongo_collection('nba_teams')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}", exc_info=True)
        exit(1)

    try:
        # Loop through all documents in the collection
        for i, doc in enumerate(_teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
            team = doc['TEAM_ID']
            fetch_all_seasons(team)
            time.sleep(60)
    except Exception as e:
        logging.error(f"Error updating team seasons: {e}", exc_info=True)
