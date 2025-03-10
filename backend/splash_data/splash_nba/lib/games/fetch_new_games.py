import time
import logging
from datetime import datetime, timedelta
from nba_api.stats.endpoints import ScoreboardV2
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON


def fetch_upcoming_games(game_date):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games_unwrapped')
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
        logging.error(f"(Upcoming Games) Failed to fetch games for {game_date}: {e}", exc_info=True)
        return

    if len(games['GameHeader']) > 0:
        season = games['GameHeader'][0]['SEASON']
        season_type = games['GameHeader'][0]['GAME_ID'][2]

        for i in range(0, len(games['GameHeader'])):
            details = games['GameHeader'][i]
            games_collection.update_one(
                {'gameId': details['GAME_ID']},
                {'$set': {'date': game_date,
                          'season': season,
                          'seasonCode': f'{season_type}{season}',
                          'seasonType': season_type_map[season_type],
                          'homeTeamId': details['HOME_TEAM_ID'],
                          'awayTeamId': details['VISITOR_TEAM_ID'],
                          'broadcast': details['BROADCAST'],
                          'gameClock': "",
                          'status': "1",
                          "matchup": {},
                          "stats": {},
                          "pbp": []
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

    try:
        # Define date range
        start_date = datetime(2024, 11, 15)
        end_date = datetime(2024, 11, 15)

        # Fetch games for each date in the range
        fetch_games_for_date_range(start_date, end_date)

    except Exception as e:
        logging.error(f"Failed to fetch games for date range: {e}", exc_info=True)
