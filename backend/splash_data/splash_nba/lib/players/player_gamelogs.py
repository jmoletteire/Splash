import random
import time

from nba_api.stats.endpoints import playergamelogs
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def gamelogs(player_id, season, season_type):
    gamelog = playergamelogs.PlayerGameLogs(player_id_nullable=player_id, season_nullable=season).get_normalized_dict()['PlayerGameLogs']

    keys = [list(gamelog[0].keys())[1]] + [list(gamelog[0].keys())[4]] + list(gamelog[0].keys())[7:32]

    # Initialize dictionaries for each data type
    gamelog_data = {}

    # Fill in the player data from each list
    for game in gamelog:
        game_id = game['GAME_ID']
        gamelog_data[game_id] = {key: game[key] for key in keys}

    players_collection.update_one(
        {'PERSON_ID': player_id},
        {'$set': {f'STATS.{season}.GAMELOGS.{season_type}': gamelog_data}}
    )


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

    season_types = ['REGULAR SEASON', 'PLAYOFFS']

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

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
