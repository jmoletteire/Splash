import logging
import schedule
import time

from nba_api.stats.endpoints import commonplayoffseries
from pymongo import MongoClient

from splash_nba.lib.games.fetch_new_games import update_game_data
from splash_nba.lib.games.nba_cup import update_current_cup
from splash_nba.lib.games.playoff_bracket import reformat_series_data, get_playoff_bracket_data
from splash_nba.lib.teams.stats.custom_team_stats import three_and_ft_rate
from splash_nba.lib.teams.stats.custom_team_stats_rank import custom_team_stats_rank
from splash_nba.lib.teams.stats.per100 import calculate_and_update_per_100_possessions
from splash_nba.lib.teams.team_cap_sheet import update_team_contract_data
from splash_nba.lib.teams.update_team_games import update_games
from splash_nba.lib.teams.standings import update_current_standings
from splash_nba.lib.teams.update_news_and_transactions import fetch_team_transactions, fetch_team_news
from splash_nba.lib.teams.team_seasons import update_current_season
from splash_nba.lib.teams.stats.team_hustle_stats_rank import rank_hustle_stats_current_season
from splash_nba.lib.teams.team_rosters import update_current_roster
from splash_nba.lib.teams.update_last_lineup import get_last_game, get_last_lineup
from splash_nba.util.env import uri, k_current_season, k_current_season_type


def games_daily_update():
    """
    Runs every day at 3AM.\n
    Updates games, NBA Cup, and playoff data for each team.
    """
    # Games
    logging.info("Games/Scores..")
    update_game_data()

    # NBA Cup
    logging.info("NBA Cup...")
    update_current_cup()

    # Playoffs
    logging.info("Playoffs...")
    playoff_games = commonplayoffseries.CommonPlayoffSeries(season=k_current_season).get_normalized_dict()['PlayoffSeries']
    if playoff_games == 0:
        return
    else:
        series_data = reformat_series_data(playoff_games)
        get_playoff_bracket_data(k_current_season, series_data)


def teams_daily_update():
    """
    Runs every day at 3AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """

    logging.info("Updating teams (daily)...")
    try:
        # Games
        logging.info("Games...")
        # Sort the documents in nba_games collection by GAME_DATE in descending order
        sorted_games_cursor = games_collection.find(
            {"SEASON_YEAR": k_current_season[0:4]},
            {"GAME_DATE": 1, "GAMES": 1, "_id": 0}
        ).sort("GAME_DATE", -1)

        # Process the games in batches
        for i, game_day in enumerate(sorted_games_cursor):
            logging.info(f"Processing {game_day['GAME_DATE']}...")
            update_games(game_day)

        # Standings
        logging.info("Standings...")
        update_current_standings()

        # News & Transactions
        logging.info("News & Transactions...")
        fetch_team_transactions()
        fetch_team_news()

        # Cap Sheet
        logging.info("Cap Sheet...")
        update_team_contract_data()

        # Loop through all documents in the collection
        for i, doc in enumerate(teams_collection.find({}, {"TEAM_ID": 1, f"seasons": 1, "_id": 0})):
            team = doc['TEAM_ID']

            if team == 0:
                continue

            logging.info(f"Processing team {team} ({i + 1} of 30)...")
            # Season Stats
            logging.info("Stats...")
            update_current_season(team_id=team)

            # Filter seasons to only include the current season key
            filtered_doc = doc.copy()
            filtered_doc['seasons'] = {key: doc['seasons'][key] for key in doc['seasons'] if key == k_current_season}
            calculate_and_update_per_100_possessions(team_doc=filtered_doc, playoffs=True if k_current_season_type == 'PLAYOFFS' else False)

            # Current Roster & Coaches
            logging.info("Roster & Coaches...")
            season_not_started = True if doc['seasons'][k_current_season]['GP'] == 0 else False
            update_current_roster(team_id=team, season_not_started=season_not_started)

            # Last Starting Lineup
            # Get most recent game by date
            game_id, game_date = get_last_game(doc['seasons'])

            # Get starting lineup for most recent game
            last_starting_lineup = get_last_lineup(team, game_id, game_date)

            # Update document
            teams_collection.update_one(
                {"TEAM_ID": team},
                {"$set": {"LAST_STARTING_LINEUP": last_starting_lineup}},
            )

        rank_hustle_stats_current_season()
        three_and_ft_rate(seasons=[k_current_season], season_type=k_current_season_type)
        custom_team_stats_rank()
    except Exception as e:
        logging.error(f"Error updating team season: {e}")


# Schedule the tasks
# schedule.every(1).hour.do(teams_hourly_update)  # Run every 1 hour
# schedule.every().day.at("02:30").do(games_daily_update())  # Run every day at 2:30 AM
# schedule.every().day.at("03:00").do(teams_daily_update())  # Run every day at 3:00 AM


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash

        games_collection = db.nba_games

        teams_collection = db.nba_teams

        players_collection = db.nba_players
        player_shots_collection = db.nba_player_shot_data

        playoff_collection = db.nba_playoff_history
        cup_collection = db.nba_cup_history

        draft_collection = db.nba_draft_history

        transactions_collection = db.nba_transactions

        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    teams_daily_update()
    #games_daily_update()

    #while True:
        #schedule.run_pending()
        #time.sleep(1)  # Wait for 1 second between checking the schedule
