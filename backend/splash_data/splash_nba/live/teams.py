import logging
import time
from datetime import datetime
from splash_nba.lib.misc.update_transactions import update_transactions
from splash_nba.lib.teams.stats.custom_team_stats import three_and_ft_rate
from splash_nba.lib.teams.stats.custom_team_stats_rank import current_season_custom_team_stats_rank
from splash_nba.lib.teams.stats.per100 import current_season_per_100_possessions
from splash_nba.lib.teams.team_cap_sheet import update_team_contract_data
from splash_nba.lib.teams.team_history import update_team_history
from splash_nba.lib.teams.update_team_games import update_team_games
from splash_nba.lib.teams.standings import update_current_standings
from splash_nba.lib.teams.update_news_and_transactions import fetch_team_transactions, fetch_team_news
from splash_nba.lib.teams.team_seasons import update_current_season
from splash_nba.lib.teams.stats.team_hustle_stats_rank import rank_hustle_stats_current_season
from splash_nba.lib.teams.team_rosters import update_current_roster
from splash_nba.lib.teams.update_last_lineup import get_last_game, get_last_lineup
from splash_nba.imports import get_mongo_collection, CURR_SEASON, CURR_SEASON_TYPE


async def update_teams(team_ids):
    """
    Runs every day at 3AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    logging.info("Updating team (post-game)...")

    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f'(Teams Daily) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    try:
        for team_id in team_ids:
            with teams_collection.find({"TEAM_ID": team_id}, {"TEAM_ID": 1, f"seasons": 1, "_id": 0}) as cursor:
                documents = list(cursor)
                if not documents:
                    return

                for doc in documents:
                    team = doc['TEAM_ID']

                    if team == 0:
                        continue

                    logging.info(f"Processing team {team}")

                    # Team History (30 API calls)
                    logging.info("History...")
                    update_team_history(team_id=team)
                    time.sleep(15)

                    # Season Stats (120 API calls)
                    logging.info("Stats...")
                    update_current_season(team_id=team)
                    # Filter seasons to only include the current season key
                    filtered_doc = doc.copy()
                    filtered_doc['seasons'] = {key: doc['seasons'][key] for key in doc['seasons'] if key == CURR_SEASON}
                    current_season_per_100_possessions(team_doc=filtered_doc, playoffs=CURR_SEASON_TYPE == 'PLAYOFFS')
                    time.sleep(15)

                    # Current Roster/Rotation & Coaches (~400-500 API calls)
                    logging.info("Roster & Coaches...")
                    season_not_started = True if doc['seasons'][CURR_SEASON]['GP'] == 0 else False
                    update_current_roster(team_id=team, season_not_started=season_not_started)
                    time.sleep(30)

                    # Last Starting Lineup (0 API Calls)
                    logging.info("Last Starting Lineup...")
                    # Get most recent game by date
                    game_id, game_date = get_last_game(doc['seasons'])
                    # Get starting lineup for most recent game
                    last_starting_lineup = get_last_lineup(team, game_id, game_date)
                    # Update document
                    teams_collection.update_one(
                        {"TEAM_ID": team},
                        {"$set": {"LAST_STARTING_LINEUP": last_starting_lineup}},
                    )
                    logging.info(f"\t(Team Last Lineup) Updated last starting lineup for team {team_id}")

                    # Pause 15 seconds between teams
                    time.sleep(15)

        # After looping through all teams, calculate ranks/standings
        rank_hustle_stats_current_season()
        three_and_ft_rate(seasons=[CURR_SEASON], season_type=CURR_SEASON_TYPE)
        current_season_custom_team_stats_rank()

        # Standings (min. 30 API calls [more if tiebreakers])
        logging.info("Standings (min. 30 API calls)...")
        update_current_standings()
    except Exception as e:
        logging.error(f"(Teams Daily) Error updating teams: {e}")


def teams_daily_update():
    """
    Runs every day at 3AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """
    try:
        teams_collection = get_mongo_collection('nba_teams')
        games_collection = get_mongo_collection('nba_games')
    except Exception as e:
        logging.error(f'(Teams Daily) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    logging.info("Updating teams (daily)...")
    try:
        # Games (0 API calls)
        logging.info("Team Games (0 API calls)...")

        # Sort the documents in nba_games collection by GAME_DATE in descending order
        sorted_games_cursor = games_collection.find(
            {"SEASON_YEAR": CURR_SEASON[0:4]},
            {"GAME_DATE": 1, "GAMES": 1, "_id": 0}
        ).sort("GAME_DATE", -1)

        # Process the games in batches
        for i, game_day in enumerate(sorted_games_cursor):
            logging.info(f"Processing {game_day['GAME_DATE']}...")
            update_team_games(game_day)
    except Exception as e:
        logging.error(f"(Teams Daily) Error updating team game logs: {e}", exc_info=True)

    try:
        # News & Transactions (NATSTAT - 60 API calls)'
        logging.info("News & Transactions (0 API calls)...")
        fetch_team_transactions()
        fetch_team_news()
        update_transactions()
    except Exception as e:
        logging.error(f"(Teams Daily) Error updating team news & transactions: {e}", exc_info=True)

    try:
        # Cap Sheet (0 API calls)
        logging.info("Cap Sheet (0 API calls)...")
        update_team_contract_data()
    except Exception as e:
        logging.error(f"(Teams Daily) Error updating team contracts: {e}", exc_info=True)

        # Loop through all documents in the collection
        batch_size = 10
        total_documents = teams_collection.count_documents({})
        processed_count = 0
        i = 0
        while processed_count < total_documents:
            with teams_collection.find({}, {"TEAM_ID": 1, f"seasons": 1, "_id": 0}).skip(processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for doc in documents:
                    team = doc['TEAM_ID']
                    i += 1

                    if team == 0:
                        continue

                    logging.info(f"Processing team {team} ({i} of 30)...")

                    try:
                        # Team History (30 API calls)
                        logging.info("History (30 API calls)...")
                        update_team_history(team_id=team)
                        time.sleep(15)
                    except Exception as e:
                        logging.error(f"(Teams Daily) Error updating team {team} history: {e}", exc_info=True)

                    # Season Stats (120 API calls)
                    try:
                        logging.info("Stats (120 API calls)...")
                        update_current_season(team_id=team)
                        # Filter seasons to only include the current season key
                        filtered_doc = doc.copy()
                        filtered_doc['seasons'] = {key: doc['seasons'][key] for key in doc['seasons'] if
                                                   key == CURR_SEASON}
                        current_season_per_100_possessions(team_doc=filtered_doc,
                                                           playoffs=CURR_SEASON_TYPE == 'PLAYOFFS')
                        time.sleep(15)
                    except Exception as e:
                        logging.error(f"(Teams Daily) Error updating team {team} stats: {e}", exc_info=True)

                    try:
                        # Current Roster & Coaches (~400-500 API calls)
                        logging.info("Roster & Coaches (~400-500 API calls)...")
                        season_not_started = True if doc['seasons'][CURR_SEASON]['GP'] == 0 else False
                        update_current_roster(team_id=team, season_not_started=season_not_started)
                        time.sleep(30)
                    except Exception as e:
                        logging.error(f"(Teams Daily) Error updating team {team} roster: {e}", exc_info=True)

                    try:
                        # Last Starting Lineup (0 API Calls)
                        logging.info("Last Starting Lineup (0 API calls)...")

                        # Get most recent game by date
                        game_id, game_date = get_last_game(doc['seasons'])

                        # Get starting lineup for most recent game
                        last_starting_lineup = get_last_lineup(team, game_id, game_date)

                        # Update document
                        teams_collection.update_one(
                            {"TEAM_ID": team},
                            {"$set": {"LAST_STARTING_LINEUP": last_starting_lineup}},
                        )
                    except Exception as e:
                        logging.error(f"(Teams Daily) Error updating team {team} last lineup: {e}", exc_info=True)

                    # Pause 15 seconds between teams
                    time.sleep(15)

        # Hustle Stat Rank
        try:
            rank_hustle_stats_current_season()
        except Exception as e:
            logging.error(f"(Teams Daily) Error updating hustle stat ranks: {e}", exc_info=True)

        # 3PAr + FTr
        try:
            three_and_ft_rate(seasons=[CURR_SEASON], season_type=CURR_SEASON_TYPE)
        except Exception as e:
            logging.error(f"(Teams Daily) Error updating 3PAr + FTr: {e}", exc_info=True)

        # Custom Stat Ranks
        try:
            current_season_custom_team_stats_rank()
        except Exception as e:
            logging.error(f"(Teams Daily) Error updating custom team stat ranks: {e}", exc_info=True)

        # Standings
        try:
            # Standings (min. 30 API calls [more if tiebreakers])
            logging.info("Standings (min. 30 API calls)...")
            update_current_standings()
        except Exception as e:
            logging.error(f"(Teams Daily) Error updating standings: {e}", exc_info=True)
