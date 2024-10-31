import re
from datetime import datetime

from pymongo import MongoClient
from splash_nba.util.env import uri
import logging
import requests
import json
from bs4 import BeautifulSoup


def player_rotowire_ids():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players

    # URL template for fetching player news
    url = "https://www.rotowire.com/basketball/tables/injury-report.php?team=ALL&pos=ALL"

    response = requests.get(url)

    if response.status_code == 200:
        for player in response.json():
            # Define the search criteria
            player_name = player['player']
            team_abbreviation = player['team']
            roto_id = player['ID']

            # Aggregation pipeline for fuzzy matching
            pipeline = [
                {
                    "$search": {
                        "index": "person_id",  # Replace with your actual search index name
                        "text": {
                            "query": player_name,
                            "path": "DISPLAY_FIRST_LAST",
                            "fuzzy": {"maxEdits": 2}  # Adjust maxEdits as needed
                        }
                    }
                },
                {
                    "$match": {"TEAM_ABBREVIATION": team_abbreviation}
                },
                {
                    "$limit": 1
                }
            ]

            # Execute the search
            result = list(players_collection.aggregate(pipeline))

            # If a match is found, update the ROTO_ID
            if result:
                player_id = result[0]["PERSON_ID"]
                players_collection.update_one(
                    {"PERSON_ID": player_id},
                    {"$set": {"ROTO_ID": roto_id}}
                )
                logging.info(f"Added Roto ID for {player['player']}")
            else:
                print("No close match found for player.")

    else:
        logging.error(f"Failed to fetch injury report. Status code: {response.status_code}")

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


def player_rotowire_injuries():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players

    # Base URL for the initial JSON data and the player page
    injury_report_url = "https://www.rotowire.com/basketball/tables/injury-report.php?team=ALL&pos=ALL"
    base_url = "https://www.rotowire.com"

    # Step 1: Fetch the JSON data from the injury report page
    response = requests.get(injury_report_url)
    data = response.json()

    # Step 2: Iterate through each player in the JSON data
    injury_dates = {}  # Dictionary to store player names and their estimated return dates

    for item in data:
        player_url = base_url + item["URL"]

        # Step 3: Fetch the player page
        player_response = requests.get(player_url)
        player_soup = BeautifulSoup(player_response.text, 'html.parser')

        # Step 4: Find the injury data div and extract the date
        injury_data_divs = player_soup.find_all("div", class_="p-card__injury-data")

        if len(injury_data_divs) > 1:  # Check if there is a second div
            # Extract the date from the second div
            est_return_div = injury_data_divs[1]
            est_return_date = est_return_div.find("b").get_text(strip=True)
            player_name = item["player"]  # Assuming 'Name' key contains the player's name
            injury_dates[player_name] = est_return_date
            players_collection.update_one({'ROTO_ID': item['ID']}, {"$set": {"PlayerRotowires.0.EST_RETURN": est_return_date}})
            logging.info(f"{player_name}: {est_return_date}")


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
        url = f"{base_url}?playerId={player_id}&limit=10&offset=0"
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
    #player_rotowire_ids()
    player_rotowire_news()
    player_rotowire_injuries()
