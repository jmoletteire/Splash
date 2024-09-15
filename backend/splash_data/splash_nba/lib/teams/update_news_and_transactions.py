import inspect

import requests
import json
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging
import requests
from bs4 import BeautifulSoup


def fetch_og_data(url):
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            og_image = soup.find('meta', property='og:image')

            return {
                'image': og_image['content'] if og_image else None
            }
        return None
    except Exception as e:
        print(f"Failed to fetch OG data: {e}")
        return None


def fetch_team_news():
    # Get the current call stack
    stack = inspect.stack()

    # Check the second item in the stack (the caller)
    # The first item in the stack is the current function itself
    caller_frame = stack[1]

    # Extract the function name of the caller
    caller_function = caller_frame.function

    # Check if the caller is the main script
    if caller_function == '<module>':  # '<module>' indicates top-level execution (like __main__)
        print("Called from main script.")
    else:
        # Connect to MongoDB
        try:
            client = MongoClient(uri)
            db = client.splash
            teams_collection = db.nba_teams
        except Exception as e:
            logging.error(f"Failed to connect to MongoDB: {e}")
            exit(1)

    # Key = NatStat, value = MongoDB
    team_codes = {
        'ATL': 'ATL',
        'BOS': 'BOS',
        'BRK': 'BKN',
        'CHH': 'CHA',
        'CHI': 'CHI',
        'CLE': 'CLE',
        'DAL': 'DAL',
        'DEN': 'DEN',
        'DET': 'DET',
        'GSW': 'GSW',
        'HOU': 'HOU',
        'IND': 'IND',
        'LAC': 'LAC',
        'LAL': 'LAL',
        'MEM': 'MEM',
        'MIA': 'MIA',
        'MIL': 'MIL',
        'MIN': 'MIN',
        'NOP': 'NOP',
        'NYK': 'NYK',
        'OKC': 'OKC',
        'ORL': 'ORL',
        'PHI': 'PHI',
        'PHO': 'PHX',
        'POR': 'POR',
        'SAC': 'SAC',
        'SAS': 'SAS',
        'TOR': 'TOR',
        'UTA': 'UTA',
        'WAS': 'WAS'
    }

    max_news_items = 20  # Set the maximum number of news items you want to keep

    for i, team_code in enumerate(team_codes.keys()):
        try:
            url = f'https://api3.natst.at/2805-2e4f7e/news/NBA/{team_code}'

            # Send GET request to the API
            response = requests.get(url)
            data = json.loads(response.text)
            logging.info(f'\nFetched news for {team_code}')

            team_news = teams_collection.find_one({"ABBREVIATION": team_codes[team_code]})
            if team_news and 'NEWS' in team_news and isinstance(team_news['NEWS'], list):
                existing_news_ids = {news_item['id'] for news_item in team_news['NEWS']}
            else:
                existing_news_ids = set()

            latest_news = []
            for news_item in data['news'].values():
                if news_item['id'] in existing_news_ids:
                    logging.info(f"News item {news_item['id']} already exists, skipping the rest for {team_code}")
                    break

                og_data = fetch_og_data(news_item['url'])
                if og_data:
                    news_item['og_image'] = og_data.get('image')
                latest_news.append(news_item)

            if latest_news:
                # Ensure NEWS is initialized as a list if it doesn't exist
                if not team_news or 'NEWS' not in team_news:
                    teams_collection.update_one(
                        {"ABBREVIATION": team_codes[team_code]},
                        {"$set": {"NEWS": []}},
                        upsert=True
                    )

                # Use $push with $each and $slice to maintain the max size of the NEWS array
                teams_collection.update_one(
                    {"ABBREVIATION": team_codes[team_code]},
                    {
                        "$push": {
                            "NEWS": {
                                "$each": latest_news,
                                "$position": 0,  # Add new items to the beginning
                                "$slice": max_news_items  # Maintain the size of the NEWS array
                            }
                        }
                    },
                    upsert=True
                )
                logging.info(f"Updated news for {team_code} with {len(latest_news)} new items")

        except Exception as e:
            logging.error(f"Failed to retrieve news for {team_code}: {e}\n")


def fetch_team_transactions():
    # Get the current call stack
    stack = inspect.stack()

    # Check the second item in the stack (the caller)
    # The first item in the stack is the current function itself
    caller_frame = stack[1]

    # Extract the function name of the caller
    caller_function = caller_frame.function

    # Check if the caller is the main script
    if caller_function == '<module>':  # '<module>' indicates top-level execution (like __main__)
        print("Called from main script.")
    else:
        # Connect to MongoDB
        try:
            client = MongoClient(uri)
            db = client.splash
            teams_collection = db.nba_teams
        except Exception as e:
            logging.error(f"Failed to connect to MongoDB: {e}")
            exit(1)

    # Key = NatStat, value = MongoDB
    team_codes = {
        'ATL': 'ATL',
        'BOS': 'BOS',
        'BRK': 'BKN',
        'CHH': 'CHA',
        'CHI': 'CHI',
        'CLE': 'CLE',
        'DAL': 'DAL',
        'DEN': 'DEN',
        'DET': 'DET',
        'GSW': 'GSW',
        'HOU': 'HOU',
        'IND': 'IND',
        'LAC': 'LAC',
        'LAL': 'LAL',
        'MEM': 'MEM',
        'MIA': 'MIA',
        'MIL': 'MIL',
        'MIN': 'MIN',
        'NOP': 'NOP',
        'NYK': 'NYK',
        'OKC': 'OKC',
        'ORL': 'ORL',
        'PHI': 'PHI',
        'PHO': 'PHX',
        'POR': 'POR',
        'SAC': 'SAC',
        'SAS': 'SAS',
        'TOR': 'TOR',
        'UTA': 'UTA',
        'WAS': 'WAS'
    }

    for i, team_code in enumerate(team_codes.keys()):
        try:
            url = f'https://api3.natst.at/2805-2e4f7e/transactions/NBA/{team_code}'

            # Send GET request to the API
            response = requests.get(url)
            data = json.loads(response.text)

            teams_collection.update_one(
                {"ABBREVIATION": team_codes[team_code]},
                {"$set": {"RECENT_TRANSACTIONS": data['transaction']}},
                upsert=True
            )
            logging.info(f" Fetched transactions for {i + 1} of 30\n")
        except Exception as e:
            logging.error(f" Failed to retrieve transactions for {team_code}: {e}\n")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info(" Connected to MongoDB")
    except Exception as e:
        logging.error(f" Failed to connect to MongoDB: {e}")
        exit(1)

    fetch_team_transactions()
    fetch_team_news()
