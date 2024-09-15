import logging
import schedule
import time
from pymongo import MongoClient

from splash_nba.lib.teams.update_team_games import update_games
from splash_nba.lib.teams.standings import update_current_standings
from splash_nba.lib.teams.update_news_and_transactions import fetch_team_transactions, fetch_team_news
from splash_nba.lib.teams.team_seasons import update_current_season
from splash_nba.lib.teams.stats.team_hustle_stats_rank import rank_hustle_stats_current_season
from splash_nba.lib.teams.historic_rosters import fetch_roster
from splash_nba.lib.teams.update_last_lineup import get_last_game, get_last_lineup
from splash_nba.util.env import uri, k_current_season


def games_daily_update():
    return


def teams_daily_update():
    """
    Runs every day at 3AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """

    logging.info("Updating team seasons...")
    try:
        # Games
        logging.info("\nGames...")
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
        logging.info("\nStandings...")
        update_current_standings()

        # News & Transactions
        logging.info("\nNews & Transactions...")
        fetch_team_transactions()
        fetch_team_news()

        # Loop through all documents in the collection
        for i, doc in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "seasons": 1, "_id": 0})):
            team = doc['TEAM_ID']

            if team == 0:
                continue

            # Season Stats
            logging.info(f"\nStats...")
            update_current_season(team_id=team)

            # Current Roster & Coaches
            logging.info(f"\nRoster & Coaches...")
            fetch_roster(team_id=team, season=k_current_season)

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
    except Exception as e:
        logging.error(f"Error updating team season: {e}")


# Schedule the tasks
# schedule.every(1).hour.do(teams_hourly_update)  # Run every 1 hour
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

    #while True:
        #schedule.run_pending()
        #time.sleep(1)  # Wait for 1 second between checking the schedule
