import json
import logging
import requests
from bs4 import BeautifulSoup
from splash_nba.imports import get_mongo_collection


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
        logging.error(f"(Team News) Failed to fetch image for {url}: {e}")
        return None


def fetch_team_news():
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Team News) Failed to connect to MongoDB: {e}")
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
            logging.info(f'(Team News) Fetched news for {team_code}')

            team_news = teams_collection.find_one({"ABBREVIATION": team_codes[team_code]})
            if team_news and 'NEWS' in team_news and isinstance(team_news['NEWS'], list):
                existing_news_ids = {news_item['id'] for news_item in team_news['NEWS']}
            else:
                existing_news_ids = set()

            latest_news = []
            for news_item in data['news'].values():
                if news_item['id'] in existing_news_ids:
                    logging.info(f"(Team News) News item {news_item['id']} already exists, skipping the rest for {team_code}")
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
                logging.info(f"(Team News) Updated news for {team_code} with {len(latest_news)} new items")

        except Exception as e:
            logging.error(f"(Team News) Failed to retrieve news for {team_code}: {e}\n")


def fetch_team_transactions():
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Team Transactions) Failed to connect to MongoDB: {e}")
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
            logging.info(f"(Team Transactions) Fetched transactions for {i + 1} of 30\n")
        except Exception as e:
            logging.error(f"(Team Transactions) Failed to retrieve transactions for {team_code}: {e}\n")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
        logging.info(" Connected to MongoDB")
    except Exception as e:
        logging.error(f" Failed to connect to MongoDB: {e}")
        exit(1)

    fetch_team_transactions()
    fetch_team_news()
