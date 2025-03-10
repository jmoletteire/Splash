import time
import random
import logging
from datetime import datetime
from nba_api.stats.endpoints import boxscoreadvancedv2
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON, CURR_SEASON_TYPE


# Function to fetch box score stats for a game
def fetch_box_score_adv(game_id):
    boxscore = boxscoreadvancedv2.BoxScoreAdvancedV2(proxy=PROXY, game_id=game_id).get_normalized_dict()
    return boxscore


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    players_collection = get_mongo_collection('nba_players')
    teams_collection = get_mongo_collection('nba_teams')
    games_collection = get_mongo_collection('nba_games')
    logging.info("Connected to MongoDB")

    # Get today's date in "yyyy-mm-dd" format
    today_date = datetime.today().strftime("%Y-%m-%d")

    # Set batch size to process documents
    filter = {"SEASON_CODE": '22024', "GAME_DATE": {"$lt": today_date}}  # {"GAME_DATE": '2024-11-21'}  #
    batch_size = 100
    total_documents = games_collection.count_documents(filter)
    processed_count = 0

    while processed_count < total_documents:
        with games_collection.find(filter).skip(processed_count).limit(batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break

            game_counter = 0

            for document in documents:
                processed_count += 1
                logging.info(f'Processing {processed_count} of {total_documents} ({document["GAME_DATE"]})...')

                year = document['SEASON_YEAR']
                next_year = str(int(year) + 1)
                season = f"{year}-{next_year[-2:]}"
                season_type = document['SEASON_TYPE'] if document['SEASON_TYPE'] != 'REGULAR_SEASON' else 'REGULAR SEASON'

                for game_id, game_data in document['GAMES'].items():
                    # Check if ADV already exists for the game
                    if "ADV" in game_data:
                        # Fetch box score summary for the game
                        try:
                            stats = fetch_box_score_adv(game_id)

                            if 'homeTeam' in game_data['BOXSCORE'].keys():
                                team_ft = {
                                    game_data['BOXSCORE']['homeTeam']['teamId']: game_data['BOXSCORE']['homeTeam']['statistics']['freeThrowsMade'],
                                    game_data['BOXSCORE']['awayTeam']['teamId']: game_data['BOXSCORE']['awayTeam']['statistics']['freeThrowsMade']
                                }
                            elif 'TeamStats' in game_data['BOXSCORE'].keys():
                                team_ft = {
                                    game_data['BOXSCORE']['TeamStats'][0]['TEAM_ID']: game_data['BOXSCORE']['TeamStats'][0]['FTM'],
                                    game_data['BOXSCORE']['TeamStats'][1]['TEAM_ID']: game_data['BOXSCORE']['TeamStats'][1]['FTM']
                                }
                            else:
                                continue

                        except Exception as e:
                            stats = None
                            logging.error(f"Error fetching box score for game_id {game_id}: {e.with_traceback()}")

                        # Update the game data with the fetched summary
                        try:
                            # Update the MongoDB document with the fetched stats under the "SUMMARY" key
                            games_collection.update_one(
                                {'_id': document['_id'], f"GAMES.{game_id}": {"$exists": True}},
                                {"$set": {f"GAMES.{game_id}.ADV": stats}}
                            )

                            # print(f"Processed {document['GAME_DATE']} {game_id}")
                        except Exception as e:
                            logging.error(f"Error updating advanced stats for game_id {game_id}: {e}")

                        game_counter += 1

                        # Pause for a random time between 0.5 and 1 second
                        time.sleep(random.uniform(0.5, 1.0))

                        # Pause for 10 seconds every 100 games processed
                        if game_counter % 100 == 0:
                            logging.info(f"Processed {game_counter} games. Pausing for 10 seconds...")
                            time.sleep(10)

    logging.info("Box score stats update complete.")
