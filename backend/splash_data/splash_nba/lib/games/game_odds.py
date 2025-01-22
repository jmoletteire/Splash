import time
from datetime import datetime, timedelta

import requests
from nba_api.stats.endpoints import leaguegamefinder, ScoreboardV2
from pymongo import MongoClient

from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_basic import fetch_box_score_stats
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.util.env import uri, k_current_season
import logging


def draft_kings_odds():
    url = 'https://sportsbook-nash.draftkings.com/api/sportscontent/dkusnj/v1/leagues/42648'
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        dk_odds = response.json()
    else:
        logging.error(f"Failed to fetch DraftKings odds")
        return

    games = {}
    for event in dk_odds['events']:
        games[event['id']] = {
            'id': event['id'],
            'name': event['name'],
            'homeId': event['participants'][0]['id'],
            'awayId': event['participants'][1]['id']
        }

    for market in dk_odds['markets']:
        if market['eventId'] not in games.keys():
            continue
        games[market['eventId']]['marketId'] = market['id']


async def fetch_odds():
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    # Fetch the data from the URL
    url = "https://cdn.nba.com/static/json/liveData/odds/odds_todaysGames.json"
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        nba_today_odds = response.json()
    else:
        logging.error(f"Failed to fetch NBA.com odds")
        return

    # Fetch only games that are from the current season and have occurred before today
    today = datetime.today().strftime('%Y-%m-%d')
    tomorrow = (datetime.today() + timedelta(days=1)).strftime('%Y-%m-%d')

    # Retrieve games for today and tomorrow, extract the GAMES dictionaries
    games_today_cursor = games_collection.find({'GAME_DATE': today}, {'GAMES': 1, '_id': 0})
    games_tomorrow_cursor = games_collection.find({'GAME_DATE': tomorrow}, {'GAMES': 1, '_id': 0})

    # Convert cursors to dictionaries where gameId is the key
    games_today_dict = {}
    for document in games_today_cursor:
        games_today_dict.update(document.get('GAMES', {}))

    games_tomorrow_dict = {}
    for document in games_tomorrow_cursor:
        games_tomorrow_dict.update(document.get('GAMES', {}))

    # Now loop over nba_today_odds['games'] and update based on gameId
    if nba_today_odds['games']:
        for game_data in nba_today_odds['games']:
            game_id = game_data.get('gameId', None)

            if game_id is None:
                continue

            if game_id in games_today_dict:
                games_collection.update_one(
                    {"GAME_DATE": today},
                    {'$set': {f"GAMES.{game_id}.ODDS.srMatchId": game_data['srMatchId']}},
                )

            if game_id in games_tomorrow_dict:
                games_collection.update_one(
                    {"GAME_DATE": tomorrow},
                    {'$set': {f"GAMES.{game_id}.ODDS.srMatchId": game_data['srMatchId']}},
                )

    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'en-US,en;q=0.9',
        'DNT': '1',
        'If-Modified-Since': 'Fri, 11 Oct 2024 00:07:35 GMT',
        'If-None-Match': '"a0c9264cc7b6cc93cb69187079a5cb14f99418d6"',
        'Origin': 'https://www.nba.com',
        'Referer': 'https://www.nba.com/',
        'Sec-CH-UA': '"Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
        'Sec-CH-UA-Mobile': '?0',
        'Sec-CH-UA-Platform': '"macOS"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'cross-site',
        'Priority': 'u=1, i'
    }
    sr_url = 'https://uswidgets.fn.sportradar.com/sportradarmlb/en_us/Etc:UTC/gismo/match_bookmakerodds_multi/'

    for game_date in games_collection.find({'GAME_DATE': today}, {'_id': 0}):
        for game_id, game_data in game_date['GAMES'].items():
            try:
                odds_response = requests.get(sr_url + game_data['ODDS']['srMatchId'], headers=headers)
            except Exception:
                continue

            # Check if the request was successful
            if odds_response.status_code == 200:
                live_odds = odds_response.json()
            else:
                logging.error(f"Failed to fetch SportRadar odds: {odds_response.status_code}")
                continue

            try:
                live_odds_bookmakers = live_odds['doc'][0]['data']['liveoddsbookmakers']
            except KeyError:
                # logging.error(f"Live odds unavailable")
                live_odds_bookmakers = []

            try:
                bookmakers = live_odds['doc'][0]['data']['bookmakers']
            except KeyError:
                # logging.error(f"Book odds unavailable")
                bookmakers = []

            if len(bookmakers) > 0:
                games_collection.update_one(
                    {"GAME_DATE": today},
                    {'$set': {f"GAMES.{game_id}.ODDS.LIVE": live_odds_bookmakers, f"GAMES.{game_id}.ODDS.BOOK": bookmakers}},
                )

    for game_date in games_collection.find({'GAME_DATE': tomorrow}, {'_id': 0}):
        for game_id, game_data in game_date['GAMES'].items():
            try:
                odds_response = requests.get(sr_url + game_data['ODDS']['srMatchId'], headers=headers)
            except Exception:
                continue

            # Check if the request was successful
            if odds_response.status_code == 200:
                live_odds = odds_response.json()
            else:
                logging.error(f"Failed to fetch SportRadar odds: {odds_response.status_code}")
                continue

            try:
                live_odds_bookmakers = live_odds['doc'][0]['data']['liveoddsbookmakers']
            except KeyError:
                # logging.error(f"Live odds unavailable")
                live_odds_bookmakers = []

            try:
                bookmakers = live_odds['doc'][0]['data']['bookmakers']
            except KeyError:
                # logging.error(f"Book odds unavailable")
                bookmakers = []

            if len(bookmakers) > 0:
                games_collection.update_one(
                    {"GAME_DATE": tomorrow},
                    {'$set': {f"GAMES.{game_id}.ODDS.LIVE": live_odds_bookmakers, f"GAMES.{game_id}.ODDS.BOOK": bookmakers}},
                )


if __name__ == "__main__":
    fetch_odds()
