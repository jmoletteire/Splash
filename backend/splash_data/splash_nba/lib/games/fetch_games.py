from nba_api.stats.endpoints import leaguegamefinder
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def fetch_games():
    try:
        # Fetch all games using LeagueGameFinder without any parameters
        games = leaguegamefinder.LeagueGameFinder(league_id_nullable='00').get_normalized_dict()['LeagueGameFinderResults']

        # Keys to view
        keys_to_view = [
            'SEASON_ID',
            'GAME_ID',
            'GAME_DATE'
        ]

        # Map season type codes to names
        season_type_map = {
            '1': 'PRE_SEASON',
            '2': 'REGULAR_SEASON',
            '3': 'ALL_STAR',
            '4': 'PLAYOFFS',
            '5': 'PLAY_IN',
            '6': 'IST_FINAL'
        }

        # Dictionary to hold all structured data temporarily
        structured_data = {}

        for game in games:
            game = {key: game[key] for key in keys_to_view}

            season_id = game['SEASON_ID']
            season_type = season_type_map.get(season_id[0], 'UNKNOWN')
            season_year = season_id[1:]

            game_date = game['GAME_DATE']
            game_id = game['GAME_ID']

            # Initialize nested dictionaries if they don't exist
            if season_year not in structured_data:
                structured_data[season_year] = {}
            if season_type not in structured_data[season_year]:
                structured_data[season_year][season_type] = {}
            if game_date not in structured_data[season_year][season_type]:
                structured_data[season_year][season_type][game_date] = {}

            # Store the game data
            structured_data[season_year][season_type][game_date][game_id] = game

        # Insert each season type's data as a separate document into the MongoDB collection
        for season_year, season_data in structured_data.items():
            for season_type, games in season_data.items():
                document = {
                    'SEASON_YEAR': season_year,
                    'SEASON_CODE': f"{list(season_type_map.keys())[list(season_type_map.values()).index(season_type)]}{season_year}",
                    'SEASON_TYPE': season_type,
                    'GAME_DATES': games
                }
                games_collection.insert_one(document)

        logging.info(f'Complete! Added {len(games)} games.')

    except Exception as e:
        logging.error(f"Error fetching scores: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
        fetch_games()
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")