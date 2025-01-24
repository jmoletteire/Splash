import logging
import requests
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import uri, news_api_key
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import uri, news_api_key
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def add_article_to_mongo(article):
    try:
        client = MongoClient(uri)
        latest_news_articles = client.splash.latest_news_articles

        # Check if an article with the same URL already exists
        existing_article = latest_news_articles.find_one({'url': article['url']})

        if existing_article:
            logging.info(f"Article already exists in the database: {article['url']}")
        else:
            latest_news_articles.insert_one(article)
            logging.info(f"New article added: {article['title']}")

    except Exception as e:
        logging.error(f"Failed to add article to MongoDB: {e}")


def format_articles(articles):
    formatted_articles = []

    for article in articles:
        cleaned_article = {
            'source': article['source']['name'],
            'title': article['title'],
            'description': article['description'],
            'url': article['url'],
            'date': article['publishedAt'],
            'imageUrl': article['urlToImage']
        }

        formatted_articles.append(cleaned_article)
        add_article_to_mongo(cleaned_article)


def fetch_latest_news_articles():
    logging.basicConfig(level=logging.INFO)

    news_api = 'https://newsapi.org/v2/top-headlines?'
    parameters = f'country=us&category=sports&pageSize=100&apiKey={news_api_key}'
    url = news_api + parameters

    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        news = response.json()
        if news['articles']:
            format_articles(news['articles'])
    else:
        logging.error(f"Failed to fetch latest news")
        return


if __name__ == '__main__':
    client = MongoClient(uri)
    latest_news_collection = client.splash.latest_news_articles

    fetch_latest_news_articles()
    news = latest_news_collection.find()
    print(list(news))
