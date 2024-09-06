from datetime import datetime, timedelta

from nba_api.stats.endpoints import leaguegamefinder, ScoreboardV2
from pymongo import MongoClient

from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_basic import fetch_box_score_stats
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.util.env import uri
import logging


def fetch_new_games():
    try:
        # Fetch all games using LeagueGameFinder without any parameters
        all_games = leaguegamefinder.LeagueGameFinder(league_id_nullable='00').get_normalized_dict()['LeagueGameFinderResults']

        # Filter out games with duplicate GAME_IDs
        seen_game_ids = set()
        games = []
        for game in all_games:
            if game['GAME_ID'] not in seen_game_ids:
                seen_game_ids.add(game['GAME_ID'])
                games.append(game)

        # Keys to view
        keys_to_view = [
            'SEASON_ID',
            'GAME_ID',
            'GAME_DATE'
        ]

        # Map season type codes to names
        season_type_map = {
            '1': 'PRE_SEASON',
            '2': 'REGULAR_SEASON',
            '3': 'ALL_STAR',
            '4': 'PLAYOFFS',
            '5': 'PLAY_IN',
            '6': 'IST_FINAL'
        }

        dates_added = []
        games_added = []

        for game in games:
            print(game)
            game = {key: game[key] for key in keys_to_view}

            season_id = game['SEASON_ID']
            season_type = season_type_map.get(season_id[0], 'UNKNOWN')
            season_year = season_id[1:]

            game_date = game['GAME_DATE']
            game_id = game['GAME_ID']

            # Check if the document for the specific game date exists
            existing_doc = games_collection.find_one({'SEASON_YEAR': season_year, 'SEASON_TYPE': season_type, 'GAME_DATE': game_date})

            if existing_doc:
                # If reached last populated date, stop
                if game_id in existing_doc['GAMES'].keys():
                    break
                # Else if populating new date, add game
                else:
                    game['SUMMARY'] = fetch_box_score_summary(game_id)
                    game['BOXSCORE'] = fetch_box_score_stats(game_id)
                    game['ADV'] = fetch_box_score_adv(game_id)

                    games_collection.update_one(
                        {'_id': existing_doc['_id']},
                        {'$set': {f'GAMES.{game_id}': game}}
                    )
                    games_added.append(game_id)
            else:
                # Create a new document for the game date
                game['SUMMARY'] = fetch_box_score_summary(game_id)
                game['BOXSCORE'] = fetch_box_score_stats(game_id)
                game['ADV'] = fetch_box_score_adv(game_id)

                new_doc = {
                    'SEASON_YEAR': season_year,
                    'SEASON_CODE': season_id,
                    'SEASON_TYPE': season_type,
                    'GAME_DATE': game_date,
                    'GAMES': {game_id: game}
                }
                games_collection.insert_one(new_doc)
                dates_added.append(game_date)
                games_added.append(game_id)

        logging.info(f'Complete! Added {len(games_added)} game(s) for {len(dates_added)} date(s).')

    except Exception as e:
        logging.error(f"Error fetching scores: {e}")


def fetch_upcoming_games(game_date):
    # Map season type codes to names
    season_type_map = {
        '1': 'PRE_SEASON',
        '2': 'REGULAR_SEASON',
        '3': 'ALL_STAR',
        '4': 'PLAYOFFS',
        '5': 'PLAY_IN',
        '6': 'IST_FINAL'
    }

    scoreboard = ScoreboardV2(game_date=game_date, day_offset=0)
    games = scoreboard.get_normalized_dict()

    if len(games['GameHeader']) > 0:
        season = games['GameHeader'][0]['SEASON']
        season_type = games['GameHeader'][0]['GAME_ID'][2]

        games_map = {}
        for i in range(0, len(games['GameHeader'])):
            game_id = games['GameHeader'][i]['GAME_ID']
            games_map[game_id] = {
                'SUMMARY': {
                    'GameSummary': [] if games['GameHeader'] == [] else [games['GameHeader'][i]],
                    'LineScore': [linescore for linescore in games['LineScore'] if linescore['GAME_ID'] == game_id],
                    'LastMeeting': [] if games['LastMeeting'] == [] else [games['LastMeeting'][i]]
                }
            }

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
    while current_date <= end_date:
        logging.info(f"Fetching games for {current_date.strftime('%Y-%m-%d')}")
        fetch_upcoming_games(current_date.strftime('%Y-%m-%d'))
        current_date += timedelta(days=1)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
        logging.info("Connected to MongoDB")

    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")

    try:
        # Define date range
        start_date = datetime(2024, 10, 4)
        end_date = datetime(2025, 4, 13)

        # Fetch games for each date in the range
        fetch_games_for_date_range(start_date, end_date)
    except Exception as e:
        logging.error(f"Failed to fetch games for date range: {e.with_traceback()}")
