import logging
from collections import defaultdict
from nba_api.stats.endpoints import leaguedashplayerstats
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON


def update_player_stats(season_type, team_id):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
    basic_stats = []
    adv_stats = []
    num_players = players_collection.count_documents({'ROSTERSTATUS': 'Active'})

    # Fetch basic and advanced stats for the given season
    if season_type == 'REGULAR SEASON':
        basic_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, season=CURR_SEASON, team_id_nullable=team_id).get_normalized_dict()['LeagueDashPlayerStats']
        adv_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, measure_type_detailed_defense='Advanced', season=CURR_SEASON, team_id_nullable=team_id).get_normalized_dict()['LeagueDashPlayerStats']
    elif season_type == 'PLAYOFFS':
        basic_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, season=CURR_SEASON, season_type_all_star='Playoffs', team_id_nullable=team_id).get_normalized_dict()['LeagueDashPlayerStats']
        adv_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, measure_type_detailed_defense='Advanced', season=CURR_SEASON, season_type_all_star='Playoffs', team_id_nullable=team_id).get_normalized_dict()['LeagueDashPlayerStats']

    if len(basic_stats) > 0 and len(adv_stats) > 0:
        basic_keys = list(basic_stats[0].keys())[:35] if len(basic_stats) > 0 else []
        adv_keys = list(adv_stats[0].keys())[:38] if len(adv_stats) > 0 else []

        player_stats = defaultdict(lambda: {'BASIC': {}, 'ADV': {}})

        # Fill in the player data from each list
        if basic_stats:
            for player in basic_stats:
                if 'PLAYER_ID' in player.keys():
                    player_id = player['PLAYER_ID']
                    player_stats[player_id]['BASIC'] = {key: player[key] for key in basic_keys}
                else:
                    continue
        else:
            for player_id in player_stats.keys():
                player_stats[player_id]['BASIC'] = {}

        if adv_stats:
            for player in adv_stats:
                if 'PLAYER_ID' in player.keys():
                    player_id = player['PLAYER_ID']
                    player_stats[player_id]['ADV'] = {key: player[key] for key in adv_keys}
                else:
                    continue
        else:
            for player_id in player_stats.keys():
                player_stats[player_id]['ADV'] = {}

        logging.info(f'Processing BASIC & ADV stats for {CURR_SEASON}...')

        logging.info(f'Adding data for {len(player_stats)} players.')
        for player_id, player_data in player_stats.items():
            try:
                player_data['BASIC']['NUM_PLAYERS'] = num_players
                player_data['ADV']['NUM_PLAYERS'] = num_players

                # Update BASIC & ADV stats for player
                players_collection.update_one(
                    {'PERSON_ID': player_id},
                    {
                        '$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.BASIC': player_data['BASIC'],
                            f'STATS.{CURR_SEASON}.{season_type}.ADV': player_data['ADV']
                        }
                    }
                )
            except Exception as e:
                logging.error(f"Unable to add stats for player {player_id}: {e}")
                continue
    else:
        logging.info('No stats to add.')
        return


def fetch_playoff_stats(seasons):
    for season in seasons:
        basic_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, season=season, season_type_all_star='Playoffs').get_normalized_dict()['LeagueDashPlayerStats']
        adv_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, measure_type_detailed_defense='Advanced', season=season, season_type_all_star='Playoffs').get_normalized_dict()['LeagueDashPlayerStats']

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
        # Fetch basic and advanced stats for the given season
        basic_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, season=season).get_normalized_dict()['LeagueDashPlayerStats']
        adv_stats = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, measure_type_detailed_defense='Advanced', season=season).get_normalized_dict()['LeagueDashPlayerStats']

        # Combine basic and advanced stats based on PLAYER_ID
        combined_list = [(d1, d2) for d1 in basic_stats for d2 in adv_stats if d1['PLAYER_ID'] == d2['PLAYER_ID']]

        logging.info(f'Processing stats for {season}...')
        player_stats = combined_list
        num_players = len(player_stats)

        logging.info(f'Adding data for {len(player_stats)} players.')
        for i, player in enumerate(player_stats):
            try:
                player[0]['NUM_PLAYERS'] = num_players

                # Only update if BASIC does not exist, or exists but is empty
                players_collection.update_one(
                    {
                        'PERSON_ID': player[0]['PLAYER_ID'],
                        '$or': [
                            {f'STATS.{season}.REGULAR SEASON.BASIC': {'$exists': False}},
                            {f'STATS.{season}.REGULAR SEASON.BASIC': {'$eq': {}}}
                        ]
                    },
                    {
                        '$set': {
                            f'STATS.{season}.REGULAR SEASON.BASIC': player[0],
                            f'STATS.{season}.REGULAR SEASON.ADV': player[1]
                        }
                    }
                )
            except Exception as e:
                logging.error(f"Unable to add stats for {player[0]['PLAYER_NAME']}: {e}")
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

    fetch_player_stats(seasons)
    # fetch_playoff_stats(seasons)
