import time
import logging
import requests
from datetime import datetime, timedelta
from nba_api.stats.endpoints import ScoreboardV2
from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON


# File path to store the refresh token
TOKEN_FILE = '../../util/refresh_token.txt'


def read_refresh_token():
    """Read the refresh token from a file."""
    try:
        with open(TOKEN_FILE, 'r') as file:
            return file.read().strip()
    except FileNotFoundError:
        logging.error("Refresh token file not found. Ensure you have a valid refresh token stored.")
        return None


def write_refresh_token(new_token):
    """Write the new refresh token to a file."""
    with open(TOKEN_FILE, 'w') as file:
        file.write(new_token)


def refresh_token(refresh_tok):
    # URL for the token request
    token_url = 'https://auth.synergysportstech.com/connect/token'

    # Form data for the token refresh request
    token_payload = {
        'grant_type': 'refresh_token',
        'refresh_token': refresh_tok,
        'scope': 'openid offline_access api.config api.security api.basketball api.sport api.editor',
        'client_id': 'client.basketball.teamsite'
    }

    # Headers for the token request
    token_headers = {
        'accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded',
        'origin': 'https://apps.synergysports.com',
        'referer': 'https://apps.synergysports.com/',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36'
    }

    # Make the POST request to obtain a new token
    return requests.post(token_url, data=token_payload, headers=token_headers)


def synergy_game_ids():
    teams_map = {
        'Atlanta': 1610612737,
        'Boston': 1610612738,
        'Cleveland': 1610612739,
        'NewOrleans': 1610612740,
        'Chicago': 1610612741,
        'Dallas': 1610612742,
        'Denver': 1610612743,
        'GoldenState': 1610612744,
        'Houston': 1610612745,
        'LAClippers': 1610612746,
        'LALakers': 1610612747,
        'Miami': 1610612748,
        'Milwaukee': 1610612749,
        'Minnesota': 1610612750,
        'Brooklyn': 1610612751,
        'NewYork': 1610612752,
        'Orlando': 1610612753,
        'Indiana': 1610612754,
        'Philadelphia': 1610612755,
        'Phoenix': 1610612756,
        'Portland': 1610612757,
        'Sacramento': 1610612758,
        'SanAntonio': 1610612759,
        'OklahomaCity': 1610612760,
        'Toronto': 1610612761,
        'Utah': 1610612762,
        'Memphis': 1610612763,
        'Washington': 1610612764,
        'Detroit': 1610612765,
        'Charlotte': 1610612766
    }

    access_token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IkJGMDlBOEMwNjBGMDdFMDU0QjhBRTg0OTE5REQyMUQ0IiwidHlwIjoiYXQrand0In0.eyJpc3MiOiJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tIiwibmJmIjoxNzM0MTk1NDM0LCJpYXQiOjE3MzQxOTU0MzQsImV4cCI6MTczNDE5NjAzNCwiYXVkIjpbImFwaS5jb25maWciLCJhcGkuc2VjdXJpdHkiLCJhcGkuYmFza2V0YmFsbCIsImFwaS5zcG9ydCIsImFwaS5lZGl0b3IiLCJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tL3Jlc291cmNlcyJdLCJzY29wZSI6WyJvcGVuaWQiLCJhcGkuY29uZmlnIiwiYXBpLnNlY3VyaXR5IiwiYXBpLmJhc2tldGJhbGwiLCJhcGkuc3BvcnQiLCJhcGkuZWRpdG9yIiwib2ZmbGluZV9hY2Nlc3MiXSwiYW1yIjpbInB3ZCJdLCJjbGllbnRfaWQiOiJjbGllbnQuYmFza2V0YmFsbC50ZWFtc2l0ZSIsInN1YiI6IjY1OGIyMTNlYjE0YzE3OGRmYzgzOWExZiIsImF1dGhfdGltZSI6MTczMzg2MTMzOSwiaWRwIjoibG9jYWwiLCJlbWFpbCI6ImphY2ttb2xlQG91dGxvb2suY29tIiwibmFtZSI6IkphY2sgTW9sZXR0ZWlyZSIsInNpZCI6IkIwNjJERTBENzU1M0Y3MkFGNDU3MTIzQ0YyODgyN0RCIn0.RLRSYm4H0XmitFITJ2vouZmttEA0ZOT91UXjw6PUxmo8ipn9z7Lm8UHgFFyhgIGhLlURc-YMYMIbTi3wWdBQEIjQIgz9ESEUAUw5AQffe9_v6ckaoqe0siOm_Qd5WVGUoj7qYEqFir98Yxua9TMSxB0HSGy0V9B3cS4xwVon-4tmNEhPd1KlI_TugAPd10mHkTmU0WukMIwSpEM7Ww2eY3_cVMwbaenq89AJx4t8F2w7dW6iooQ8Ijs3zbWKOD9UmgZ01GbnirNvE4tXQSTVWcufhGltzfNMcpvenaZTqioCLH3GhHX7IBg4x4FQdNp4iXqG98gya6ciWvyO9S2tyQ'

    # URL for the data you want to access
    url = 'https://basketball.synergysportstech.com/api/games'

    # Headers from your browser request
    headers = {
        'accept': 'application/json, text/plain, */*',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9',
        'authorization': f'Bearer {access_token}',
        'content-type': 'application/json; charset=UTF-8',
        'origin': 'https://apps.synergysports.com',
        'referer': 'https://apps.synergysports.com/',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        'x-synergy-client': 'ProductVersion=2024.10.31.4116; ProductName=Basketball.TeamSite'
    }

    # Payload from your browser request
    payload = {
        "excludeGamesWithoutCompetition": True,
        "seasonIds": [
            #"59af08c917120e9c9a9797ff",  # 2017-18
            #"5b6e102011ef0d11039af1e3",  # 2018-19
            #"5d51e0c6f52909811e13ee2d",  # 2019-20
            #"5fce72f5f68e52f827c39b4c",  # 2020-21
            #"6120261cea4488c9fd5c57c5",  # 2021-22
            #"62fe65fb2c6c3881c0cf66ba",  # 2022-23
            #"651b131d1507a2202c01094c",  # 2023-24
            "66ec94cbd172189f95bf08b2"   # 2024-25
        ],
        "competitionIds": None,
        "skip": 512,
        "statuses": [4, 1, 2, 3, 5],
        "sort": "utc:desc"
    }

    # Make the POST request
    response = requests.post(url, headers=headers, json=payload)

    # Check response status and print data if successful
    if response.status_code == 200:
        data = response.json()

        for game in data['result']:
            teams = game['name'].split('@')

            try:
                home_id = teams_map[teams[1]]
            except Exception as e:
                logging.error(f'Unable to parse Home Team ID: {e}')
                continue

            try:
                away_id = teams_map[teams[0]]
            except Exception as e:
                logging.error(f'Unable to parse Away Team ID: {e}')
                continue

            game_date = game['localDate'][0:10]
            logging.info(f'{game_date} ({game["id"]})')

            game_day = games_collection.find_one({'GAME_DATE': game_date}, {'GAMES': 1, '_id': 0})

            if game_day:
                for game_id, game_data in game_day['GAMES'].items():
                    try:
                        summary = game_data.get('SUMMARY', {}).get('GameSummary', {})[0]
                    except Exception:
                        logging.error('Could not parse game summary')
                        continue

                    if summary['HOME_TEAM_ID'] == home_id and summary['VISITOR_TEAM_ID'] == away_id:
                        games_collection.update_one({'GAME_DATE': game_date}, {'$set': {f'GAMES.{game_id}.SR_ID': game['id']}})
            else:
                logging.info(f'Game not found for {game_date}')

    else:
        logging.error(f'Failed to retrieve data. Status code: {response.status_code}')


def update_game_data():
    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games')
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        # Fetch only games that are from the current season and have occurred before today
        today = datetime.today().strftime('%Y-%m-%d')
        query = {
            'SEASON_YEAR': CURR_SEASON[:4],
            'GAME_DATE': {'$lt': today}
        }

        # Add Summary and Box Score data for games on past dates
        for game_date in games_collection.find(query, {'_id': 0}):
            for game_id, game_data in game_date['GAMES'].items():
                game_data['SUMMARY'] = fetch_box_score_summary(game_id)
                game_data['ADV'] = fetch_box_score_adv(game_id)

    except Exception as e:
        logging.error(f"Error fetching scores: {e}")


def fetch_upcoming_games(game_date):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games')
        teams_collection = get_mongo_collection('nba_teams')

    except Exception as e:
        logging.error(f"(Upcoming Games) Failed to connect to MongoDB: {e}")
        return

    # Map season type codes to names
    season_type_map = {
        '1': 'PRE_SEASON',
        '2': 'REGULAR_SEASON',
        '3': 'ALL_STAR',
        '4': 'PLAYOFFS',
        '5': 'PLAY_IN',
        '6': 'IST_FINAL'
    }
    try:
        scoreboard = ScoreboardV2(proxy=PROXY, game_date=game_date, day_offset=0)
        games = scoreboard.get_normalized_dict()
    except Exception as e:
        logging.error(f"(Upcoming Games) Failed to fetch games for {game_date}: {e}")
        return

    if len(games['GameHeader']) > 0:
        season = games['GameHeader'][0]['SEASON']
        season_type = games['GameHeader'][0]['GAME_ID'][2]

        games_map = {}
        for i in range(0, len(games['GameHeader'])):
            game_id = games['GameHeader'][i]['GAME_ID']
            games_map[game_id] = {
                'SUMMARY': {
                    'GameSummary': [header for header in games['GameHeader'] if header['GAME_ID'] == game_id],
                    'LineScore': [linescore for linescore in games['LineScore'] if linescore['GAME_ID'] == game_id],
                    'LastMeeting': [last_meeting for last_meeting in games['LastMeeting'] if last_meeting['GAME_ID'] == game_id]
                }
            }

            if len(games_map[game_id]['SUMMARY']['LineScore']) > 0:
                linescore = games_map[game_id]['SUMMARY']['LineScore']
                for i, team in enumerate(linescore):
                    team_data = teams_collection.find_one({'TEAM_ID': team['TEAM_ID']}, {f'seasons.{CURR_SEASON}.WINS': 1, f'seasons.{CURR_SEASON}.LOSSES': 1, '_id': 0})
                    if team_data is None:
                        continue
                    else:
                        try:
                            games_map[game_id]['SUMMARY']['LineScore'][i]['TEAM_WINS_LOSSES'] = f"{team_data['seasons'][CURR_SEASON]['WINS']}-{team_data['seasons'][CURR_SEASON]['LOSSES']}"
                        except Exception:
                            continue

        games_collection.update_one(
            {'GAME_DATE': game_date},
            {'$set': {'SEASON_YEAR': season,
                      'SEASON_CODE': f'{season_type}{season}',
                      'SEASON_TYPE': season_type_map[season_type],
                      'GAME_DATE': game_date,
                      'GAMES': games_map
                      }
             },
            upsert=True
        )


def fetch_games_for_date_range(start_date, end_date):
    current_date = start_date
    i = 0
    while current_date <= end_date:
        logging.info(f"Fetching games for {current_date.strftime('%Y-%m-%d')}")
        fetch_upcoming_games(current_date.strftime('%Y-%m-%d'))

        i += 1
        current_date += timedelta(days=1)

        # Pause 15 seconds every 25 days processed
        if i % 25 == 0:
            time.sleep(15)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games')
        logging.info("Connected to MongoDB")

    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")

    try:
        # Define date range
        start_date = datetime(2024, 11, 15)
        end_date = datetime(2024, 11, 15)

        # Fetch games for each date in the range
        #fetch_games_for_date_range(start_date, end_date)

        synergy_game_ids()

    except Exception as e:
        logging.error(f"Failed to fetch games for date range: {e.with_traceback()}")
