import re
from datetime import datetime

from pymongo import MongoClient
from splash_nba.util.env import uri
import logging
import requests
import json


def player_rotowire_ids():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    logging.info("Connected to MongoDB")

    # URL template for fetching player news
    url = "https://www.rotowire.com/basketball/tables/rotations.php"

    response = requests.get(url)

    if response.status_code == 200:
        team_rotations = response.json().get("rotations", {})

        for team, players in team_rotations.items():
            for player in players:
                # Update the player's document with the news data
                players_collection.update_one(
                    {"DISPLAY_FIRST_LAST": player['player'], "TEAM_ABBREVIATION": player['team']},
                    {"$set": {"ROTO_ID": player['id']}}
                )
                logging.info(f"Added Roto ID for {player['player']}")
    else:
        logging.error(f"Failed to fetch news for rotations. Status code: {response.status_code}")


def player_rotowire_news_short(player_id):
    if player_id == '':
        return ['', '', '', '', '', '', '', '', '', '']

    # URL template for fetching player news
    url = f"https://www.rotowire.com/basketball/ajax/get-more-updates.php?type=player&itemID={player_id}&lastUpdateTime={datetime.today().strftime('%Y-%m-%d')}%2013%3A22%3A52.377&numUpdates=10"

    response = requests.get(url)

    if response.status_code == 200:
        html_content = response.json().get("updatesHTML", {})
    else:
        return ['', '', '', '', '', '', '', '', '', '']

    # Regex pattern to match and extract the text within news-update__news, including link text but excluding the link
    pattern = r'<div class="news-update__news">([\w\W]+?)</div>'

    # Finding all matches
    news_updates_raw = re.findall(pattern, html_content)

    # Cleaning each match to remove the actual URLs but keep link text
    news_updates = []
    for news in news_updates_raw:
        # Remove <a> tags but keep the link text
        clean_text = re.sub(r'<a [^>]+>([^<]+)</a>', r'\1', news)
        news_updates.append(clean_text.strip())

    # Display extracted news updates
    return news_updates


def player_rotowire_news():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    logging.info("Connected to MongoDB")

    # URL template for fetching player news
    base_url = "https://stats-prod.nba.com/wp-json/statscms/v1/rotowire/player/"

    # Find all active players in the collection
    active_players = players_collection.find({"ROSTERSTATUS": "Active"}, {"PERSON_ID": 1, "ROTO_ID": 1, "_id": 0})
    total_players = players_collection.count_documents({"ROSTERSTATUS": "Active"})

    for i, player in enumerate(active_players):
        logging.info(f"Processing {i + 1} of {total_players}")
        player_id = player.get("PERSON_ID", None)
        roto_id = player.get("ROTO_ID", '')
        if not player_id:
            continue  # Skip if no PERSON_ID is found

        # Fetch news data for the player
        url = f"{base_url}?playerId={player_id}"
        response = requests.get(url)

        if response.status_code == 200:
            news_data = response.json().get("PlayerRotowires", [])
            news_shorts = player_rotowire_news_short(roto_id)

            for j, news in enumerate(news_data):
                try:
                    news_data[j]['ListItemShort'] = news_shorts[j]
                except Exception:
                    news_data[j]['ListItemShort'] = ''

            # Update the player's document with the news data
            players_collection.update_one(
                {"PERSON_ID": player_id},
                {"$set": {"PlayerRotowires": news_data}}
            )
            logging.info(f"Updated news for player {player_id}")
        else:
            logging.error(f"Failed to fetch news for player {player_id}. Status code: {response.status_code}")

    logging.info("News data update complete.")


if __name__ == "__main__":
    # player_rotowire_ids()
    player_rotowire_news()
