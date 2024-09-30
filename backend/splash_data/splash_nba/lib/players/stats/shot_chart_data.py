import random
import time

from nba_api.stats.endpoints import shotchartdetail
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def get_shot_chart_data(player, team, season, season_type, keep_lg_avg):
    shot_data = shotchartdetail.ShotChartDetail(player_id=player, team_id=team, season_nullable=season,
                                                season_type_all_star=season_type,
                                                context_measure_simple='FGA').get_normalized_dict()

    filtered_data = [
        {
            "LOC_X": shot['LOC_X'],
            "LOC_Y": shot['LOC_Y'],
            "SHOT_ATTEMPTED_FLAG": shot['SHOT_ATTEMPTED_FLAG'],
            "SHOT_MADE_FLAG": shot['SHOT_MADE_FLAG'],
            "SHOT_TYPE": shot['ACTION_TYPE'],
            "DISTANCE": shot['SHOT_DISTANCE']
        }
        for shot in shot_data['Shot_Chart_Detail']
    ]

    player_shots_collection.update_one(
        {'PLAYER_ID': player},
        {'$set': {
            'PLAYER_ID': player,
            f'SEASON.{season}.{season_type}': filtered_data
        }},
        upsert=True
    )

    if keep_lg_avg:
        lg_avg = {}

        for item in shot_data['LeagueAverages']:
            zone = item['SHOT_ZONE_AREA']
            range_ = item['SHOT_ZONE_RANGE']
            if zone not in lg_avg:
                lg_avg[zone] = {}
            lg_avg[zone][range_] = item['FG_PCT']

        player_shots_collection.update_one(
            {'PLAYER_ID': 0},
            {'$set': {
                'PLAYER_ID': 0,
                f'SEASON.{season}.{season_type}': lg_avg
            }},
            upsert=True
        )


if __name__ == "__main__":
    season_types = ['Regular Season', 'Playoffs']

    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    player_shots_collection = db.nba_player_shot_data
    logging.info("Connected to MongoDB")

    league_averages = player_shots_collection.find_one(
        {'PLAYER_ID': 0},
        {'_id': 0, 'SEASON': 1},
    )

    # Set batch size to process documents
    batch_size = 10
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

                for season in stats.keys():
                    try:
                        keep_league_avg = season not in league_averages['SEASON']
                        get_shot_chart_data(player['PERSON_ID'], stats[season]['REGULAR SEASON']['BASIC']['TEAM_ID'],
                                            season, 'Regular Season', keep_league_avg)
                        if 'PLAYOFFS' in stats[season]:
                            keep_league_avg = 'Playoffs' not in league_averages['SEASON'][season]
                            get_shot_chart_data(player['PERSON_ID'], stats[season]['PLAYOFFS']['BASIC']['TEAM_ID'],
                                                season, 'Playoffs', keep_league_avg)
                    except Exception as e:
                        logging.error(f'Could not process shot chart for Player {player["PERSON_ID"]}: {e}')
                        continue
                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(random.uniform(0.5, 1.0))

            time.sleep(30)
