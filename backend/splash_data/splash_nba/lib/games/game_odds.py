import logging
import requests
from datetime import datetime, timedelta, timezone
from splash_nba.imports import get_mongo_collection, PROXY, URI, CURR_SEASON


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


def fetch_odds():
    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        return

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
    games_today_cursor = games_collection.find({'date': today}, {'_id': 0})
    games_tomorrow_cursor = games_collection.find({'date': tomorrow}, {'_id': 0})

    # Convert cursors to dictionaries where gameId is the key
    games_today_dict = {}
    for document in games_today_cursor:
        game_id = document.get('gameId', '0')
        games_today_dict[game_id] = document

    games_tomorrow_dict = {}
    for document in games_tomorrow_cursor:
        game_id = document.get('gameId', '0')
        games_tomorrow_dict[game_id] = document

    # Now loop over nba_today_odds['games'] and update based on gameId
    if nba_today_odds['games']:
        for game in nba_today_odds['games']:
            game_id = game.get('gameId', None)

            if game_id is None:
                continue

            if game_id in games_today_dict.keys():
                games_collection.update_one(
                    {"gameId": game_id},
                    {'$set': {"odds.srMatchId": game['srMatchId']}},
                )

            if game_id in games_tomorrow_dict.keys():
                games_collection.update_one(
                    {"gameId": game_id},
                    {'$set': {"odds.srMatchId": game['srMatchId']}},
                )

    # Get current time in UTC
    now = datetime.now(timezone.utc)

    # Format it to match the desired string
    formatted_date = now.strftime('%a, %d %b %Y %H:%M:%S GMT')

    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'en-US,en;q=0.9',
        'DNT': '1',
        'If-Modified-Since': formatted_date,
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

    for game in games_collection.find({'date': today}, {'_id': 0}):
        try:
            odds_response = requests.get(sr_url + game['odds']['srMatchId'], proxies=PROXY, headers=headers)
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
                {"gameId": game['gameId']},
                {'$set': {"odds.live": live_odds_bookmakers, "odds.book": bookmakers}},
            )

    for game in games_collection.find({'date': tomorrow}, {'_id': 0}):
        try:
            odds_response = requests.get(sr_url + game['odds']['srMatchId'], proxies=PROXY, headers=headers)
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
                {"gameId": game['gameId']},
                {'$set': {"odds.live": live_odds_bookmakers, "odds.book": bookmakers}},
            )


if __name__ == "__main__":
    fetch_odds()
