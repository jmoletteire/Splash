import time
from datetime import datetime, timedelta

import openai
import requests
from nba_api.stats.endpoints import leaguegamefinder, ScoreboardV2
from openai import OpenAI
from pymongo import MongoClient

from splash_nba.lib.games.fetch_adv_boxscore import fetch_box_score_adv
from splash_nba.lib.games.fetch_boxscore_basic import fetch_box_score_stats
from splash_nba.lib.games.fetch_boxscore_summary import fetch_box_score_summary
from splash_nba.util.env import uri, k_current_season, openai_api_key, k_prev_season, k_current_season_type
import logging


# Function to generate points of emphasis for each team
def generate_points_of_emphasis(home_id, away_id):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Set your OpenAI API key
    if not openai_api_key:
        logging.error("OpenAI API key not found. Set the API key properly.")
        return

    openai.api_key = openai_api_key

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
        teams_collection = db.nba_teams

    except Exception as e:
        logging.error(f"(Upcoming Games) Failed to connect to MongoDB: {e}")
        return

    home_team = teams_collection.find_one({"TEAM_ID": home_id}, {f'seasons.{k_current_season}': 1, f'seasons.{k_prev_season}': 1})
    away_team = teams_collection.find_one({"TEAM_ID": away_id}, {f'seasons.{k_current_season}': 1, f'seasons.{k_prev_season}': 1})

    home_season = k_current_season if home_team['seasons'][k_current_season]['GP'] > 0 else k_prev_season
    away_season = k_current_season if away_team['seasons'][k_current_season]['GP'] > 0 else k_prev_season

    home_team_name = f'{home_team["seasons"][home_season]["TEAM_CITY"]} {home_team["seasons"][home_season]["TEAM_NAME"]}'
    away_team_name = f'{away_team["seasons"][away_season]["TEAM_CITY"]} {away_team["seasons"][away_season]["TEAM_NAME"]}'
    home_team_stats = home_team['seasons'][home_season]['STATS']['REGULAR SEASON']
    away_team_stats = away_team['seasons'][away_season]['STATS']['REGULAR SEASON']

    prompt = f"""
        Analyze the following statistics and generate 3 points of emphasis for each NBA team in the upcoming game between the {home_team_name} (Home) and the {away_team_name} (Away):
        
        {home_team_name}:
        - Offensive Rating: {home_team_stats['ADV']['OFF_RATING']} (Rank: {home_team_stats['ADV']['OFF_RATING_RANK']})
        - Defensive Rating: {home_team_stats['ADV']['DEF_RATING']} (Rank: {home_team_stats['ADV']['DEF_RATING_RANK']})
        - Pace: {home_team_stats['ADV']['PACE']} (Rank: {home_team_stats['ADV']['PACE_RANK']}) 
        - Effective FG%: {100 * home_team_stats['ADV']['EFG_PCT']}% (Rank: {home_team_stats['ADV']['EFG_PCT_RANK']})
        - Free Throw %: {100 * home_team_stats['BASIC']['FT_PCT']}% (Rank: {home_team_stats['BASIC']['FT_PCT_RANK']})
        - FT / FGA : {home_team_stats['BASIC']['FT_PER_FGA']} (Rank: {home_team_stats['BASIC']['FT_PER_FGA_RANK']})
        - Offensive Rebound %: {100 * home_team_stats['ADV']['OREB_PCT']}% (Rank: {home_team_stats['ADV']['OREB_PCT_RANK']})
        - Team Turnover %: {100 * home_team_stats['ADV']['TM_TOV_PCT']}% (Rank: {home_team_stats['ADV']['TM_TOV_PCT_RANK']})
        
        {away_team_name}:
        - Offensive Rating: {away_team_stats['ADV']['OFF_RATING']} (Rank: {away_team_stats['ADV']['OFF_RATING_RANK']})
        - Defensive Rating: {away_team_stats['ADV']['DEF_RATING']} (Rank: {away_team_stats['ADV']['DEF_RATING_RANK']})
        - Pace: {away_team_stats['ADV']['PACE']} (Rank: {away_team_stats['ADV']['PACE_RANK']}) 
        - Effective FG%: {100 * away_team_stats['ADV']['EFG_PCT']}% (Rank: {away_team_stats['ADV']['EFG_PCT_RANK']})
        - Free Throw %: {100 * away_team_stats['BASIC']['FT_PCT']}% (Rank: {away_team_stats['BASIC']['FT_PCT_RANK']})
        - FT / FGA : {away_team_stats['BASIC']['FT_PER_FGA']} (Rank: {away_team_stats['BASIC']['FT_PER_FGA_RANK']})
        - Offensive Rebound %: {100 * away_team_stats['ADV']['OREB_PCT']}% (Rank: {away_team_stats['ADV']['OREB_PCT_RANK']})
        - Team Turnover %: {100 * away_team_stats['ADV']['TM_TOV_PCT']}% (Rank: {away_team_stats['ADV']['TM_TOV_PCT_RANK']})
        
        Generate 3 points of emphasis for each team to increase their chances of winning, and keep it to 2 sentences or less.
        """

    # Call OpenAI GPT model using the new API structure
    try:
        response = openai.chat.completions.create(
            model="gpt-4o-mini",  # Use GPT-4 or gpt-3.5-turbo
            messages=[
                {"role": "system", "content": "You are an expert NBA analyst."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=500,
            temperature=0.7
        )
        return response.choices[0].message.content.strip()

    except Exception as e:
        logging.error(f"Failed to generate points of emphasis: {e}")
        return None


def update_game_data():
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        # Fetch the data from the URL
        url = "https://cdn.nba.com/static/json/liveData/odds/odds_todaysGames.json"
        response = requests.get(url)

        # Check if the request was successful
        if response.status_code == 200:
            odds_data = response.json()

        # Fetch only games that are from the current season and have occurred before today
        today = datetime.today().strftime('%Y-%m-%d')
        query = {
            'SEASON_YEAR': k_current_season[:4],
            'GAME_DATE': {'$lt': today}
        }

        # Add Summary and Box Score data for games on past dates
        for game_date in games_collection.find(query, {'_id': 0}):
            for game_id, game_data in game_date['GAMES'].items():
                game_data['SUMMARY'] = fetch_box_score_summary(game_id)
                game_data['ADV'] = fetch_box_score_adv(game_id)
                # game_data['ODDS'] = fetch_odds(odds_data, game_id)

    except Exception as e:
        logging.error(f"Error fetching scores: {e}")


def fetch_upcoming_games(game_date):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games

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
                    'GameSummary': [header for header in games['GameHeader'] if header['GAME_ID'] == game_id],
                    'LineScore': [linescore for linescore in games['LineScore'] if linescore['GAME_ID'] == game_id],
                    'LastMeeting': [last_meeting for last_meeting in games['LastMeeting'] if last_meeting['GAME_ID'] == game_id]
                }
            }

        # Convert game_date to a datetime object
        #game_date_str = datetime.strptime(game_date, '%Y-%m-%d').date()

        # Get today's date
        #today = datetime.today().date()

        # Calculate the date 7 days from now
        #seven_days_from_now = today + timedelta(days=7)

        # Check if the game_date is within the next 7 days
        #if today <= game_date_str <= seven_days_from_now:
           #for game_id, game_data in games_map.items():
                #game_data['SUMMARY']['PointsOfEmphasis'] = generate_points_of_emphasis(game_data['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'], game_data['SUMMARY']['GameSummary'][0]['VISITOR_TEAM_ID'])
                #print(game_data['SUMMARY']['PointsOfEmphasis'])

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
        current_date += timedelta(days=i)

        # Pause 15 seconds every 25 days processed
        if i % 25 == 0:
            time.sleep(15)


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
