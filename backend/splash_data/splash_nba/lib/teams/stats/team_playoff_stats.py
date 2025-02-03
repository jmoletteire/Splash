import logging
from nba_api.stats.endpoints import leaguedashteamstats, leaguehustlestatsteam
from splash_nba.imports import get_mongo_collection, PROXY


# List of seasons
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
    '1996-97'
]


def fetch_team_playoff_stats(season):
    try:
        # Get basic stats
        basic_stats = leaguedashteamstats.LeagueDashTeamStats(
            season=season, season_type_all_star='Playoffs', timeout=30, proxy=PROXY
        ).get_normalized_dict()['LeagueDashTeamStats']

        for team in basic_stats:
            team_basic_stats = team
            team_basic_stats['LEAGUE_TEAMS'] = len(basic_stats)

            teams_collection.update_one(
                {"TEAM_ID": team['TEAM_ID']},
                {"$set": {f"seasons.{season}.STATS.PLAYOFFS.BASIC": team_basic_stats}},
                upsert=True
            )
    except Exception as e:
        logging.error(f'Error retrieving basic stats: {e}')

    # Advanced Stats only available since 1996-97.
    if season >= '1996-97':
        try:
            adv_stats = leaguedashteamstats.LeagueDashTeamStats(
                season=season, season_type_all_star='Playoffs', measure_type_detailed_defense='Advanced', timeout=30, proxy=PROXY
            ).get_normalized_dict()['LeagueDashTeamStats']

            for team in adv_stats:
                team_adv_stats = team
                team_adv_stats['LEAGUE_TEAMS'] = len(adv_stats)

                teams_collection.update_one(
                    {"TEAM_ID": team['TEAM_ID']},
                    {"$set": {f"seasons.{season}.STATS.PLAYOFFS.ADV": team_adv_stats}},
                    upsert=True
                )
        except Exception as e:
            logging.error(f'Error retrieving advanced stats: {e}')

    # Hustle Stats only available since 2015-16.
    if season >= '2015-16':
        try:
            hustle_stats = leaguehustlestatsteam.LeagueHustleStatsTeam(
                season=season, season_type_all_star='Playoffs', timeout=30, proxy=PROXY
            ).get_normalized_dict()['HustleStatsTeam']

            for team in hustle_stats:
                team_hustle_stats = team
                team_hustle_stats['LEAGUE_TEAMS'] = len(hustle_stats)

                teams_collection.update_one(
                    {"TEAM_ID": team['TEAM_ID']},
                    {"$set": {f"seasons.{season}.STATS.PLAYOFFS.HUSTLE": team_hustle_stats}},
                    upsert=True
                )
        except Exception as e:
            logging.error(f'Error retrieving hustle stats: {e}')


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    for season in seasons:
        logging.info(f'Season: {season}')
        fetch_team_playoff_stats(season)

