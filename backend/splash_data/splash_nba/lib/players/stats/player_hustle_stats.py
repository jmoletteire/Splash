import logging
from nba_api.stats.endpoints import leaguehustlestatsplayer
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS, CURR_SEASON


def update_player_hustle_stats(season_type, team_id):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
    logging.info("Connected to MongoDB")
    player_hustle_stats = []

    logging.info(f'Processing HUSTLE stats for {CURR_SEASON}...')
    if season_type == 'REGULAR SEASON':
        player_hustle_stats = leaguehustlestatsplayer.LeagueHustleStatsPlayer(proxy=PROXY, headers=HEADERS, team_id_nullable=team_id, season=CURR_SEASON).get_normalized_dict()[
            'HustleStatsPlayer']
    elif season_type == 'PLAYOFFS':
        player_hustle_stats = leaguehustlestatsplayer.LeagueHustleStatsPlayer(proxy=PROXY, headers=HEADERS, team_id_nullable=team_id, season=CURR_SEASON, season_type_all_star='Playoffs').get_normalized_dict()[
            'HustleStatsPlayer']

    if len(player_hustle_stats) > 0:
        logging.info(f'Adding data for {len(player_hustle_stats)} players.')
        for player in player_hustle_stats:
            try:
                players_collection.update_one(
                    {'PERSON_ID': player['PLAYER_ID']},
                    {'$set': {f'STATS.{CURR_SEASON}.{season_type}.HUSTLE': player}}
                )
            except Exception as e:
                logging.error(f'Unable to add stats for player {player}: {e}')
                continue


def fetch_player_playoff_hustle_stats(seasons):
    for season in seasons:
        logging.info(f'Processing stats for {season}...')
        player_hustle_stats = leaguehustlestatsplayer.LeagueHustleStatsPlayer(proxy=PROXY, headers=HEADERS, season=season,
                                                                              season_type_all_star='Playoffs').get_normalized_dict()[
            'HustleStatsPlayer']

        logging.info(f'Adding data for {len(player_hustle_stats)} players.')
        for player in player_hustle_stats:
            try:
                players_collection.update_one(
                    {'PERSON_ID': player['PLAYER_ID']},
                    {'$set': {f'STATS.{season}.PLAYOFFS.HUSTLE': player}}
                )
            except Exception as e:
                logging.error(f'Unable to add stats for {player}: {e}')
                continue


def fetch_player_hustle_stats(seasons):
    for season in seasons:
        logging.info(f'Processing stats for {season}...')
        player_hustle_stats = leaguehustlestatsplayer.LeagueHustleStatsPlayer(proxy=PROXY, headers=HEADERS, season=season).get_normalized_dict()[
            'HustleStatsPlayer']

        logging.info(f'Adding data for {len(player_hustle_stats)} players.')
        for player in player_hustle_stats:
            try:
                players_collection.update_one(
                    {
                        'PERSON_ID': player['PLAYER_ID'],
                        '$or': [
                            {f'STATS.{season}.REGULAR SEASON.HUSTLE': {'$exists': False}},
                            {f'STATS.{season}.REGULAR SEASON.HUSTLE': {'$eq': {}}}
                        ]
                    },
                    {'$set': {f'STATS.{season}.REGULAR SEASON.HUSTLE': player}}
                )
            except Exception as e:
                logging.error(f'Unable to add stats for {player}: {e}')
                continue


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
    logging.info("Connected to MongoDB")

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
    ]

    fetch_player_hustle_stats(seasons)
    # fetch_player_playoff_hustle_stats(seasons)
