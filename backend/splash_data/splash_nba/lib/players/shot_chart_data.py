from nba_api.stats.endpoints import shotchartdetail
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def get_shot_chart_data(player, team, season):
    shot_data = shotchartdetail.ShotChartDetail(player_id=player, team_id=team, season_nullable=season, context_measure_simple='FGA').get_normalized_dict()


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    player_shots_collection = db.nba_player_shot_data
    logging.info("Connected to MongoDB")

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

                for season in stats.keys():
                    get_shot_chart_data(player, stats[season]['TEAM_ID'], season)
