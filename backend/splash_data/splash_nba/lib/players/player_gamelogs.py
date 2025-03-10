import random
import time
import logging
from nba_api.stats.endpoints import playergamelogs
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS


def gamelogs(player_id, season, season_type):
    try:
        players_collection = get_mongo_collection('nba_players')
    except Exception as e:
        logging.error(e)
        return

    if season_type == 'PLAYOFFS':
        gamelog = playergamelogs.PlayerGameLogs(proxy=PROXY, headers=HEADERS, player_id_nullable=player_id, season_nullable=season, season_type_nullable='Playoffs').get_normalized_dict()['PlayerGameLogs']
        if season >= '1996-97':
            adv_gamelog = playergamelogs.PlayerGameLogs(proxy=PROXY, headers=HEADERS, player_id_nullable=player_id, season_nullable=season, season_type_nullable='Playoffs', measure_type_player_game_logs_nullable='Advanced').get_normalized_dict()['PlayerGameLogs']
    else:
        gamelog = playergamelogs.PlayerGameLogs(proxy=PROXY, headers=HEADERS, player_id_nullable=player_id, season_nullable=season).get_normalized_dict()['PlayerGameLogs']
        if season >= '1996-97':
            adv_gamelog = playergamelogs.PlayerGameLogs(proxy=PROXY, headers=HEADERS, player_id_nullable=player_id, season_nullable=season, measure_type_player_game_logs_nullable='Advanced').get_normalized_dict()['PlayerGameLogs']

    base_keys = [list(gamelog[0].keys())[1]] + [list(gamelog[0].keys())[4]] + list(gamelog[0].keys())[7:34]
    if season >= '1996-97':
        adv_keys = ['OFF_RATING', 'DEF_RATING', 'NET_RATING', 'EFG_PCT', 'TS_PCT', 'USG_PCT', 'PACE', 'POSS', 'MIN_SEC']

    gamelog_data = {}

    # Fill in the player data from each list
    for game in gamelog:
        gamelog_data[game['GAME_ID']] = {}
        for key in base_keys:
            gamelog_data[game['GAME_ID']][key] = game[key]

    if season >= '1996-97':
        for game in adv_gamelog:
            for key in adv_keys:
                gamelog_data[game['GAME_ID']][key] = game[key]

    players_collection.update_one(
        {'PERSON_ID': player_id},
        {'$set': {f'STATS.{season}.GAMELOGS.{season_type}': gamelog_data}}
    )


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
    teams_collection = get_mongo_collection('nba_teams')
    logging.info("Connected to MongoDB")

    season_types = ['REGULAR SEASON', 'PLAYOFFS']

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 2251
    i = 2251

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season, season_stats in stats.items():
                    for season_type in season_types:
                        if season_type not in season_stats.keys():
                            continue
                        else:
                            try:
                                gamelogs(player['PERSON_ID'], season, season_type)
                            except Exception as e:
                                logging.error(f'Could not add gamelogs for player {player["PERSON_ID"]}: {e}')
                                continue
                            # Pause for a random time between 0.5 and 1 second
                            time.sleep(random.uniform(0.5, 1.0))

            time.sleep(10)