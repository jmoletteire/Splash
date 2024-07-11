from nba_api.stats.endpoints import leaguedashplayerstats
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def fetch_playoff_stats(seasons):
    for season in seasons:
        basic_stats = leaguedashplayerstats.LeagueDashPlayerStats(season=season, season_type_all_star='Playoffs').get_normalized_dict()['LeagueDashPlayerStats']
        adv_stats = leaguedashplayerstats.LeagueDashPlayerStats(measure_type_detailed_defense='Advanced', season=season, season_type_all_star='Playoffs').get_normalized_dict()['LeagueDashPlayerStats']

        player_stats = [(d1, d2) for d1 in basic_stats for d2 in adv_stats if d1['PLAYER_ID'] == d2['PLAYER_ID']]

        logging.info(f'Processing stats for {season}...')
        num_players = len(player_stats)

        logging.info(f'Adding data for {len(player_stats)} players.')
        for player in player_stats:
            try:
                players_collection.update_one(
                    {'PERSON_ID': player[0]['PLAYER_ID']},
                    {'$set': {f'STATS.{season}.PLAYOFFS.BASIC': player[0]}}
                )
                players_collection.update_one(
                    {'PERSON_ID': player[0]['PLAYER_ID']},
                    {'$set': {f'STATS.{season}.PLAYOFFS.BASIC.NUM_PLAYERS': num_players, f'STATS.{season}.PLAYOFFS.ADV': player[1]}}
                )
            except Exception as e:
                logging.error(f'Unable to add stats for {player[0]["PLAYER_NAME"]}: {e}')
                continue


def fetch_player_stats(seasons):
    for season in seasons:
        basic_stats = leaguedashplayerstats.LeagueDashPlayerStats(season=season).get_normalized_dict()['LeagueDashPlayerStats']
        adv_stats = leaguedashplayerstats.LeagueDashPlayerStats(measure_type_detailed_defense='Advanced', season=season).get_normalized_dict()['LeagueDashPlayerStats']

        combined_list = [(d1, d2) for d1 in basic_stats for d2 in adv_stats if d1['PLAYER_ID'] == d2['PLAYER_ID']]

        for season in seasons:
            logging.info(f'Processing stats for {season}...')
            player_stats = combined_list
            num_players = len(player_stats)

            logging.info(f'Adding data for {len(player_stats)} players.')
            for player in player_stats:
                try:
                    players_collection.update_one(
                        {'PERSON_ID': player[0]['PLAYER_ID']},
                        {'$set': {f'STATS.{season}.BASIC': player[0], f'STATS.{season}.BASIC.NUM_PLAYERS': num_players, f'STATS.{season}.ADV': player[1]}}
                    )
                except Exception as e:
                    logging.error(f'Unable to add stats for {player[0]}: {e}')
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

    # fetch_player_stats(seasons)
    fetch_playoff_stats(seasons)
