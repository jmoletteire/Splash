import random
import time
import requests
import logging
from datetime import datetime
from nba_api.stats.endpoints import boxscoreadvancedv2
from pymongo import MongoClient
# Testing
try:
    # Try to import the local env.py file
    from splash_nba.util.env import PROXY, URI, CURR_SEASON
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI, CURR_SEASON
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


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


def team_xpts_record(team, season, season_type):
    xpts_for = 0
    xpts_against = 0
    xpts_w = 0
    xpts_l = 0

    for game_id, game_data in team['seasons'][season]['GAMES'].items():
        if game_id[2] == '2':
            game = games_collection.find_one(
                {
                    "GAME_DATE": game_data['GAME_DATE'],
                    f"GAMES.{game_id}": {"$exists": True}
                },
                {
                    f"GAMES.{game_id}": 1,
                    "_id": 0
                }
            )['GAMES'][game_id]

            if 'ADV' in game.keys() and 'BOXSCORE' in game.keys():
                if 'homeTeam' in game['BOXSCORE'].keys():
                    team_ft = {
                        game['BOXSCORE']['homeTeam']['teamId']: game['BOXSCORE']['homeTeam']['statistics']['freeThrowsMade'],
                        game['BOXSCORE']['awayTeam']['teamId']: game['BOXSCORE']['awayTeam']['statistics']['freeThrowsMade']
                    }
                elif 'TeamStats' in game['BOXSCORE'].keys():
                    team_ft = {
                        game['BOXSCORE']['TeamStats'][0]['TEAM_ID']: game['BOXSCORE']['TeamStats'][0]['FTM'],
                        game['BOXSCORE']['TeamStats'][1]['TEAM_ID']: game['BOXSCORE']['TeamStats'][1]['FTM']
                    }
                else:
                    continue

                # Increment xPTS W/L for each team based on result
                teamOneFT = team_ft[game['ADV']['TeamStats'][0]['TEAM_ID']]
                teamTwoFT = team_ft[game['ADV']['TeamStats'][1]['TEAM_ID']]
                teamOnexPTS = game['ADV']['TeamStats'][0]['SQ_TOTAL'] + teamOneFT
                teamTwoxPTS = game['ADV']['TeamStats'][1]['SQ_TOTAL'] + teamTwoFT
                teamOneWins = teamOnexPTS > teamTwoxPTS
                teamTwoWins = teamTwoxPTS > teamOnexPTS

                if team['TEAM_ID'] == game['ADV']['TeamStats'][0]['TEAM_ID']:
                    xpts_for += teamOnexPTS
                    xpts_against += teamTwoxPTS
                    if teamOneWins:
                        xpts_w += 1
                    else:
                        xpts_l += 1
                elif team['TEAM_ID'] == game['ADV']['TeamStats'][1]['TEAM_ID']:
                    xpts_for += teamTwoxPTS
                    xpts_against += teamOnexPTS
                    if teamTwoWins:
                        xpts_w += 1
                    else:
                        xpts_l += 1

    teams_collection.update_one(
        {'TEAM_ID': team['TEAM_ID']},
        {'$set': {
            f'seasons.{season}.STATS.{season_type}.ADV.XPTS_DIFF': xpts_for - xpts_against,
            f'seasons.{season}.STATS.{season_type}.ADV.XPTS_FOR': xpts_for,
            f'seasons.{season}.STATS.{season_type}.ADV.XPTS_AGAINST': xpts_against,
            f'seasons.{season}.xPTS_W': xpts_w,
            f'seasons.{season}.xPTS_L': xpts_l
        }}
    )


def get_sr_ids(adv_boxscore, valid_ids):
    for i, player_adv_stats in enumerate(adv_boxscore['PlayerStats']):
        team = player_adv_stats['TEAM_ABBREVIATION']

        # Query the database
        results = players_collection.aggregate([
            {
                "$search": {
                    "index": "person_id",
                    "equals": {
                        "value": player_adv_stats['PLAYER_ID'],
                        "path": "PERSON_ID"
                    }
                }
            },
            {
                "$project": {
                    "DISPLAY_FIRST_LAST": 1,
                    "SR_ID": 1,
                    "_id": 0,
                }
            }
        ])

        result = list(results)

        if result:
            # Filter the array to only include items present in valid_ids
            try:
                final_sr_id = [sr_id for sr_id in result[0]['SR_ID'][team] if sr_id in valid_ids]
            except Exception:
                final_sr_id = []
            if len(final_sr_id) > 0:
                adv_boxscore['PlayerStats'][i]['SR_ID'] = final_sr_id[0]
            else:
                adv_boxscore['PlayerStats'][i]['SR_ID'] = '0'
        else:
            continue

    return adv_boxscore


def synergy_shot_quality(sr_id, adv_boxscore):
    # URL for Synergy data
    url = f'https://basketball.synergysportstech.com/api/games/{sr_id}/playerboxscores/extended?take=1024'

    # Headers from your browser request
    headers = {
        'accept': 'application/json, text/plain, */*',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9',
        'authorization': 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkJGMDlBOEMwNjBGMDdFMDU0QjhBRTg0OTE5REQyMUQ0IiwidHlwIjoiYXQrand0In0.eyJpc3MiOiJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tIiwibmJmIjoxNzM0MTk1NDM0LCJpYXQiOjE3MzQxOTU0MzQsImV4cCI6MTczNDE5NjAzNCwiYXVkIjpbImFwaS5jb25maWciLCJhcGkuc2VjdXJpdHkiLCJhcGkuYmFza2V0YmFsbCIsImFwaS5zcG9ydCIsImFwaS5lZGl0b3IiLCJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tL3Jlc291cmNlcyJdLCJzY29wZSI6WyJvcGVuaWQiLCJhcGkuY29uZmlnIiwiYXBpLnNlY3VyaXR5IiwiYXBpLmJhc2tldGJhbGwiLCJhcGkuc3BvcnQiLCJhcGkuZWRpdG9yIiwib2ZmbGluZV9hY2Nlc3MiXSwiYW1yIjpbInB3ZCJdLCJjbGllbnRfaWQiOiJjbGllbnQuYmFza2V0YmFsbC50ZWFtc2l0ZSIsInN1YiI6IjY1OGIyMTNlYjE0YzE3OGRmYzgzOWExZiIsImF1dGhfdGltZSI6MTczMzg2MTMzOSwiaWRwIjoibG9jYWwiLCJlbWFpbCI6ImphY2ttb2xlQG91dGxvb2suY29tIiwibmFtZSI6IkphY2sgTW9sZXR0ZWlyZSIsInNpZCI6IkIwNjJERTBENzU1M0Y3MkFGNDU3MTIzQ0YyODgyN0RCIn0.RLRSYm4H0XmitFITJ2vouZmttEA0ZOT91UXjw6PUxmo8ipn9z7Lm8UHgFFyhgIGhLlURc-YMYMIbTi3wWdBQEIjQIgz9ESEUAUw5AQffe9_v6ckaoqe0siOm_Qd5WVGUoj7qYEqFir98Yxua9TMSxB0HSGy0V9B3cS4xwVon-4tmNEhPd1KlI_TugAPd10mHkTmU0WukMIwSpEM7Ww2eY3_cVMwbaenq89AJx4t8F2w7dW6iooQ8Ijs3zbWKOD9UmgZ01GbnirNvE4tXQSTVWcufhGltzfNMcpvenaZTqioCLH3GhHX7IBg4x4FQdNp4iXqG98gya6ciWvyO9S2tyQ',
        'origin': 'https://apps.synergysports.com',
        'referer': 'https://apps.synergysports.com/',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        'sec-fetch-site': 'cross-site'
    }

    # Make the GET request
    response = requests.get(url, headers=headers)
    adv_boxscore['TeamStats'][0]['SQ_TOTAL'] = 0
    adv_boxscore['TeamStats'][1]['SQ_TOTAL'] = 0

    # If GET request successful
    if response.status_code == 200:
        sr_data = response.json()
        ids = []

        for player in sr_data['result']:
            if 'id' in player:
                ids.append(player['player']['id'])

        # Append SR_IDs to each player in box score
        adv_boxscore = get_sr_ids(adv_boxscore, ids)

        for player in sr_data['result']:
            if 'player' not in player or 'team' not in player:
                continue

            for i, player_adv_stats in enumerate(adv_boxscore['PlayerStats']):
                if player_adv_stats['SR_ID']:
                    if player_adv_stats['SR_ID'] == player['player']['id']:
                        team_index = 0 if adv_boxscore['TeamStats'][0]['TEAM_ABBREVIATION'] == player['team']['abbr'] else 1

                        if 'shotQualityTotal' not in player:
                            pts = player.get('points', 0)
                            ftm = player.get('freeThrowsMade', 0)
                            adv_boxscore['PlayerStats'][i]['SQ_TOTAL'] = (pts - ftm)
                            adv_boxscore['TeamStats'][team_index]['SQ_TOTAL'] += (pts - ftm)
                        else:
                            adv_boxscore['PlayerStats'][i]['SQ_TOTAL'] = player['shotQualityTotal']
                            adv_boxscore['TeamStats'][team_index]['SQ_TOTAL'] += player['shotQualityTotal']
                else:
                    continue

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
    client = MongoClient(URI)
    db = client.splash
    players_collection = db.nba_players
    teams_collection = db.nba_teams
    games_collection = db.nba_games
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

                            stats = synergy_shot_quality(game_data['SR_ID'], stats)
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

    logging.info("\nUpdating xPTS W-L...")
    season = '2024-25'
    season_type = 'REGULAR SEASON'
    for i, team in enumerate(teams_collection.find({}, {'TEAM_ID': 1, f'seasons.{season}.GAMES': 1, '_id': 0})):
        logging.info(f'Processing {i + 1} of 30')
        team_xpts_record(team, season, season_type)
