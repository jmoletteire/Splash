import random
import re
import time

import requests
from nba_api.stats.endpoints import boxscoreadvancedv2
from pymongo import MongoClient

from splash_nba.lib.games.fetch_boxscore_basic import fetch_box_score_stats
from splash_nba.util.env import uri
import logging
from unidecode import unidecode


def update_players_and_teams(season, season_type):
    if season_type == 'REGULAR SEASON' or season_type == 'PLAYOFFS':
        players_collection.update_one(
            {'PERSON_ID': player_adv_stats['PLAYER_ID']},
            {
                '$set': {f'STATS.{season}.GAMELOGS.{season_type}.{game_id}.SQ_TOTAL': adv_boxscore['PlayerStats'][i]['SQ_TOTAL']},
                '$inc': {f'STATS.{season}.{season_type}.ADV.SQ_TOTAL': adv_boxscore['PlayerStats'][i]['SQ_TOTAL']}
            }
        )

        # Update Team's offensive SQ
        teams_collection.update_one(
            {'TEAM_ID': adv_boxscore['TeamStats'][team_adv_index]['TEAM_ID']},
            {
                '$inc': {f'seasons.{season}.STATS.{season_type}.ADV.SQ_TOTAL': adv_boxscore['PlayerStats'][i]['SQ_TOTAL']}
            }
        )

        # Update Opponent's defensive SQ
        teams_collection.update_one(
            {'TEAM_ID': adv_boxscore['TeamStats'][opp_adv_index]['TEAM_ID']},
            {
                '$inc': {
                    f'seasons.{season}.STATS.{season_type}.ADV.OPP_SQ_TOTAL': adv_boxscore['PlayerStats'][i]['SQ_TOTAL'],
                }
            }
        )

    if season_type == 'REGULAR SEASON' or season_type == 'PLAYOFFS':
        home_ftm = basic_boxscore['homeTeam']['statistics']['freeThrowsMade']
        away_ftm = basic_boxscore['awayTeam']['statistics']['freeThrowsMade']

        # Update Home Opp FTM
        teams_collection.update_one(
            {'TEAM_ID': basic_boxscore['homeTeam']['teamId']},
            {
                '$inc': {
                    f'seasons.{season}.STATS.{season_type}.ADV.OPP_FTM': away_ftm
                }
            }
        )
        # Update Away Opp FTM
        teams_collection.update_one(
            {'TEAM_ID': basic_boxscore['awayTeam']['teamId']},
            {
                '$inc': {
                    f'seasons.{season}.STATS.{season_type}.ADV.OPP_FTM': home_ftm
                }
            }
        )


def synergy_shot_quality(sr_id, adv_boxscore):
    # URL for the data you want to access
    url = f'https://basketball.synergysportstech.com/api/games/{sr_id}/playerboxscores/extended?take=1024'

    # Headers from your browser request
    headers = {
        'accept': 'application/json, text/plain, */*',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9',
        'authorization': 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjhDRjI4QTUzNTUzOURFMDU3ODFEOEFCRkQ5QUY4QUY1IiwidHlwIjoiYXQrand0In0.eyJpc3MiOiJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tIiwibmJmIjoxNzMxMTA3MDU5LCJpYXQiOjE3MzExMDcwNTksImV4cCI6MTczMTEwNzY1OSwiYXVkIjpbImFwaS5jb25maWciLCJhcGkuc2VjdXJpdHkiLCJhcGkuYmFza2V0YmFsbCIsImFwaS5zcG9ydCIsImFwaS5lZGl0b3IiLCJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tL3Jlc291cmNlcyJdLCJzY29wZSI6WyJvcGVuaWQiLCJhcGkuY29uZmlnIiwiYXBpLnNlY3VyaXR5IiwiYXBpLmJhc2tldGJhbGwiLCJhcGkuc3BvcnQiLCJhcGkuZWRpdG9yIiwib2ZmbGluZV9hY2Nlc3MiXSwiYW1yIjpbInB3ZCJdLCJjbGllbnRfaWQiOiJjbGllbnQuYmFza2V0YmFsbC50ZWFtc2l0ZSIsInN1YiI6IjY1OGIyMTNlYjE0YzE3OGRmYzgzOWExZiIsImF1dGhfdGltZSI6MTczMTAyMDQ5OSwiaWRwIjoibG9jYWwiLCJlbWFpbCI6ImphY2ttb2xlQG91dGxvb2suY29tIiwibmFtZSI6IkphY2sgTW9sZXR0ZWlyZSIsInNpZCI6IkVCQzgzNTA3NkEzQzdBQzdGQTM1N0Q5QTQwRUZENzFFIn0.XJLVZLSoXW2wZiEKTn5fj5JOe8xEO8RWxdYKvrhRU_koVK6knQ5ZVJXmrxpUhH-V4lT76Bf7OAfoBR6ECNV-qJ1n5z9zLQtQzHJQonQPu-2B64e1CdBGyzp_C1ekaD2PyCBtQ1T308W0mXbMh8n_APlVPiD3YiRKydBqlUoJA0iIpG_BuZucLoOOZAvomJOYJygYQDeoQtp3YxAjWNOYVDJhR-PL0WVUg4mV3roctz2xzY5OyCdb2oJICH7gFkkLSvu7MN6Lm9KV9AEPEKqdvRTnAmNm18b8pggUYs5nvsg2fhC76tbg9wgIr42y6jyjlx1W02laxtS0QLACCV88-g',
        'origin': 'https://apps.synergysports.com',
        'referer': 'https://apps.synergysports.com/',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        'sec-fetch-site': 'cross-site'
    }

    def normalize_name(name):
        # Remove diacritics, convert to lowercase, and remove non-alphabetic characters (e.g., periods)
        name = unidecode(name).lower()
        name = re.sub(r'[^a-z]', '', name)  # Keep only alphabetic characters
        return name

    # Make the GET request
    response = requests.get(url, headers=headers)
    adv_boxscore['TeamStats'][0]['SQ_TOTAL'] = 0
    adv_boxscore['TeamStats'][1]['SQ_TOTAL'] = 0

    if response.status_code == 200:
        sr_data = response.json()
        for player in sr_data['result']:
            if 'player' not in player or 'team' not in player:
                continue

            for i, player_adv_stats in enumerate(adv_boxscore['PlayerStats']):
                # Normalize both names by removing accents and converting to lowercase
                normalized_player_name = normalize_name(player_adv_stats['PLAYER_NAME'])
                normalized_comparator_name = normalize_name(player['player']['name'])

                if normalized_player_name == normalized_comparator_name and player_adv_stats['TEAM_ABBREVIATION'] == \
                        player['team']['abbr']:
                    team_index = 0 if adv_boxscore['TeamStats'][0]['TEAM_ABBREVIATION'] == player['team']['abbr'] else 1

                    if 'shotQualityTotal' not in player:
                        pts = player.get('points', 0)
                        ftm = player.get('freeThrowsMade', 0)
                        adv_boxscore['PlayerStats'][i]['SQ_TOTAL'] = (pts - ftm)
                        adv_boxscore['TeamStats'][team_index]['SQ_TOTAL'] += (pts - ftm)
                    else:
                        adv_boxscore['PlayerStats'][i]['SQ_TOTAL'] = player['shotQualityTotal']
                        adv_boxscore['TeamStats'][team_index]['SQ_TOTAL'] += player['shotQualityTotal']

        return adv_boxscore
    else:
        logging.error(f'Unexpected status code: {response.status_code}')
        return adv_boxscore


# Function to fetch box score stats for a game
def fetch_box_score_adv(game_id):
    boxscore = boxscoreadvancedv2.BoxScoreAdvancedV2(game_id=game_id).get_normalized_dict()
    return boxscore


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        players_collection = db.nba_player
        teams_collection = db.nba_teams
        games_collection = db.nba_games
        logging.info("Connected to MongoDB")

        # Set batch size to process documents
        filter = {"SEASON_YEAR": '2022'}  # {"GAME_DATE": '2024-11-07'} #
        batch_size = 100
        total_documents = games_collection.count_documents(filter)
        processed_count = 122

        while processed_count < total_documents:
            with games_collection.find(filter).skip(processed_count).limit(batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break

                game_counter = 0

                for document in documents:
                    processed_count += 1
                    logging.info(f'Processing {processed_count} of {total_documents}...')

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
                                stats = synergy_shot_quality(game_data['SR_ID'], stats)
                            except Exception as e:
                                stats = None
                                logging.error(f"Error fetching box score for game_id {game_id}: {e}")

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

        print("Box score stats update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
