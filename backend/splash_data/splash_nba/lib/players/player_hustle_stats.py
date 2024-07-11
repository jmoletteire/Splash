from nba_api.stats.endpoints import leaguehustlestatsplayer
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def fetch_player_playoff_hustle_stats(seasons):

    for season in seasons:
        logging.info(f'Processing stats for {season}...')
        player_hustle_stats = leaguehustlestatsplayer.LeagueHustleStatsPlayer(season=season, season_type_all_star='Playoffs').get_normalized_dict()['HustleStatsPlayer']

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
        player_hustle_stats = leaguehustlestatsplayer.LeagueHustleStatsPlayer(season=season).get_normalized_dict()['HustleStatsPlayer']

        logging.info(f'Adding data for {len(player_hustle_stats)} players.')
        for player in player_hustle_stats:
            try:
                players_collection.update_one(
                    {'PERSON_ID': player['PLAYER_ID']},
                    {'$set': {f'STATS.{season}.HUSTLE': player}}
                )
            except Exception as e:
                logging.error(f'Unable to add stats for {player}: {e}')
                continue


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
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

    # fetch_player_hustle_stats(seasons)
    fetch_player_playoff_hustle_stats(seasons)


