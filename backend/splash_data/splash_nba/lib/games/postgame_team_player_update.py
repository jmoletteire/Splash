import logging
import random
import time
from datetime import datetime, timedelta, timezone

import nba_api
import schedule
from nba_api.stats.endpoints import scoreboardv2
from pymongo import MongoClient

from splash_nba.lib.players.player_gamelogs import gamelogs
from splash_nba.lib.players.stats.custom_player_stats_rank import current_season_custom_stats_rank
from splash_nba.lib.players.stats.per75 import current_season_per_75
from splash_nba.lib.players.stats.player_career_stats import update_player_career_stats
from splash_nba.lib.players.stats.player_hustle_stats import update_player_hustle_stats, \
    update_player_playoff_hustle_stats
from splash_nba.lib.players.stats.player_stats import update_player_stats, update_player_playoff_stats
from splash_nba.lib.players.stats.shooting_stat_rank import current_season_shooting_stat_ranks
from splash_nba.lib.players.stats.shot_chart_data import get_shot_chart_data
from splash_nba.lib.players.stats.update_custom_player_stats import update_player_on_off, update_poss_per_game, \
    update_three_and_ft_rate, update_player_tracking_stats, update_touches_breakdown, update_shot_distribution, \
    update_drive_stats, update_scoring_breakdown_and_pct_unassisted, update_versatility_score, update_box_creation, \
    update_offensive_load, update_adj_turnover_pct, update_matchup_difficulty_and_dps
from splash_nba.lib.teams.standings import update_current_standings
from splash_nba.lib.teams.stats.custom_team_stats import three_and_ft_rate
from splash_nba.lib.teams.stats.custom_team_stats_rank import current_season_custom_team_stats_rank
from splash_nba.lib.teams.stats.per100 import current_season_per_100_possessions
from splash_nba.lib.teams.stats.team_hustle_stats_rank import rank_hustle_stats_current_season
from splash_nba.lib.teams.team_history import update_team_history
from splash_nba.lib.teams.team_rosters import update_current_roster
from splash_nba.lib.teams.team_seasons import update_current_season
from splash_nba.lib.teams.update_last_lineup import get_last_game, get_last_lineup
from splash_nba.util.env import uri, k_current_season, k_current_season_type
import threading

# Global flag to indicate if update_teams or update_players are running
is_updating = False
update_lock = threading.Lock()


def check_games_final():
    logging.info(f'Checking games final... [{datetime.now()}]')
    global is_updating
    today = datetime.today().strftime('%Y-%m-%d')

    game_doc = games_collection.find_one({'GAME_DATE': today}, {f'GAMES': 1})
    games = game_doc['GAMES']
    if games:
        for game_id, game_data in games.items():
            if game_data.get('FINAL', False):
                if game_data.get('UPDATED', False):
                    logging.info(f'Game {game_id} already finalized & updated.')
                    continue
                logging.info(f'Game {game_id} is final, updating teams/players...')
                teams = [game_data['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'], game_data['SUMMARY']['GameSummary'][0]['VISITOR_TEAM_ID']]

                # Acquire the lock to set is_updating to True
                with update_lock:
                    is_updating = True
                try:
                    update_teams(teams)
                    update_players(teams)
                    games_collection.update_one({'GAME_DATE': today}, {'$set': {f'GAMES.{game_id}.UPDATED': True}})
                finally:
                    # Release the lock and set is_updating to False
                    with update_lock:
                        is_updating = False
            else:
                logging.info(f'Game {game_id} not final, skipping...')


def update_teams(team_ids):
    """
    Runs every day at 3AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """

    logging.info("Updating team (post-game)...")
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
                    filtered_doc['seasons'] = {key: doc['seasons'][key] for key in doc['seasons'] if
                                               key == k_current_season}
                    current_season_per_100_possessions(team_doc=filtered_doc, playoffs=k_current_season_type == 'PLAYOFFS')
                    time.sleep(15)

                    # Current Roster/Rotation & Coaches (~400-500 API calls)
                    logging.info("Roster & Coaches...")
                    season_not_started = True if doc['seasons'][k_current_season]['GP'] == 0 else False
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

        rank_hustle_stats_current_season()
        three_and_ft_rate(seasons=[k_current_season], season_type=k_current_season_type)
        current_season_custom_team_stats_rank()

        # Standings (min. 30 API calls [more if tiebreakers])
        logging.info("Standings (min. 30 API calls)...")
        update_current_standings()
    except Exception as e:
        logging.error(f"(Teams Daily) Error updating teams: {e}")


def update_players(team_ids):
    def player_stats():
        # Stats
        logging.info("Player Stats...")

        # BASIC, ADV, HUSTLE
        if k_current_season_type == 'REGULAR SEASON':
            update_player_stats()
            update_player_hustle_stats()
        else:
            update_player_playoff_stats()
            update_player_playoff_hustle_stats()

        for team_id in team_ids:
            logging.info(f"\nProcessing team {team_id}\n")
            # CUSTOM STATS (Calculated)
            try:
                update_player_on_off(k_current_season_type, team_id)  # ON/OFF
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Player On/Off for team {team_id}: {e}")

            try:
                update_poss_per_game(k_current_season_type, team_id)  # POSS PER G
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Poss Per Game for team {team_id}: {e}")

            try:
                update_three_and_ft_rate(k_current_season_type, team_id)  # 3PAr, FTAr, FT/FGA
            except Exception as e:
                logging.error(f"(Player Stats) Error updating 3PAr & FTr for team {team_id}: {e}")

            try:
                update_player_tracking_stats(k_current_season_type, team_id)  # TOUCHES, PASSING, DRIVES, REBOUNDING, SPEED/DISTANCE
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Player Tracking for team {team_id}: {e}")

            try:
                update_touches_breakdown(k_current_season_type, team_id)  # % PASS, % SHOOT, % TOV, % FOULED
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Touches Breakdown for team {team_id}: {e}")

            try:
                update_shot_distribution(k_current_season_type, team_id)  # SHOT TYPE, CLOSEST DEFENDER
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Shot Distribution for team {team_id}: {e}")

            try:
                update_drive_stats(k_current_season_type, team_id)  # DRIVE %, DRIVE TS%, DRIVE FT/FGA
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Drives for team {team_id}: {e}")

            try:
                update_scoring_breakdown_and_pct_unassisted(k_current_season_type, team_id)  # % UAST
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Scoring Breakdown for team {team_id}: {e}")

            try:
                update_versatility_score(k_current_season_type, team_id)  # VERSATILITY
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Versatility for team {team_id}: {e}")

            # PER POSS STATS
            current_season_per_75(k_current_season_type == 'PLAYOFFS', team_id)
            update_box_creation(k_current_season_type, team_id)  # BOX CREATION
            update_offensive_load(k_current_season_type, team_id)  # OFF LOAD
            update_adj_turnover_pct(k_current_season_type, team_id)  # cTOV

        for team_id in team_ids:
            update_matchup_difficulty_and_dps(k_current_season_type, team_id)  # MATCHUP DIFF & DIE

        # Rank
        current_season_custom_stats_rank()
        current_season_shooting_stat_ranks(k_current_season_type)

    def player_career_stats(team_id):
        # Stats
        logging.info("Player Career Stats...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
        processed_count = 0
        i = 0

        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id},
                                         {'PERSON_ID': 1, 'STATS': 1, 'CAREER': 1, '_id': 0}).skip(processed_count).limit(batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for player in documents:
                    i += 1
                    logging.info(f'(Career Stats) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                    try:
                        update_player_career_stats(player['PERSON_ID'])
                    except Exception as e:
                        logging.error(
                            f'(Career Stats) Could not update career stats for player {player["PERSON_ID"]}: {e}')
                        continue

                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(random.uniform(0.5, 1.0))

                # Pause 15 seconds every 25 players
                time.sleep(15)

    def player_game_logs(team_id):
        # Game Logs
        logging.info("Player Game Logs...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
        processed_count = 0
        i = 0

        # Loop through all ACTIVE players
        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for player in documents:
                    i += 1
                    logging.info(
                        f'\n(Player Game Logs) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                    try:
                        # Pass player, current season, and current season type
                        gamelogs(player['PERSON_ID'], k_current_season, k_current_season_type)
                    except Exception as e:
                        logging.error(
                            f'(Player Game Logs) Could not add game logs for player {player["PERSON_ID"]}: {e}')
                        continue
                    # Pause for a random time between 0.5 and 1 second between each player
                    time.sleep(random.uniform(0.5, 1.0))

                # Pause 10 seconds every 25 players
                time.sleep(10)

    def player_shot_charts(team_id):
        # Shot Charts
        logging.info("Player Shot Charts...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
        processed_count = 0
        i = 0
        keep_league_avg = True

        # Loop through all ACTIVE players
        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'TEAM_ID': 1, '_id': 0}).skip(processed_count).limit(batch_size).batch_size(batch_size) as cursor:
                documents = list(cursor)
                if not documents:
                    break
                processed_count += len(documents)

                for player in documents:
                    i += 1
                    logging.info(
                        f'\n(Player Shot Charts) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                    try:
                        get_shot_chart_data(
                            player['PERSON_ID'],
                            player['TEAM_ID'],
                            k_current_season,
                            'Regular Season' if k_current_season_type == 'REGULAR SEASON' else 'Playoffs',
                            keep_league_avg
                        )
                        keep_league_avg = False
                    except Exception as e:
                        logging.error(
                            f'(Player Shot Charts) Could not process shot chart for Player {player["PERSON_ID"]}: {e}')
                        continue

                    # Pause for a random time between 0.5 and 1 second between players
                    time.sleep(random.uniform(0.5, 1.0))

                # Pause 30 seconds every 25 players
                time.sleep(30)

    logging.info("Updating players (daily)...")

    # STATS
    try:
        player_stats()
        # print('Skip Player Stats')
    except Exception as e:
        logging.error(f"Error updating player stats: {e}")

    # CAREER
    try:
        for team_id in team_ids:
            player_career_stats(team_id)
        # print('Skip Player Career')
    except Exception as e:
        logging.error(f"Error updating player career stats: {e}")

    # GAME LOGS
    try:
        for team_id in team_ids:
            player_game_logs(team_id)
        # print('Skip Player Game Logs')
    except Exception as e:
        logging.error(f"Error updating player game logs: {e}")

    # SHOT CHART
    try:
        for team_id in team_ids:
            player_shot_charts(team_id)
        # print('Skip Player Shot Charts')
    except Exception as e:
        logging.error(f"Error updating player shot charts: {e}")


# Schedule the tasks
schedule.every(10).seconds.do(check_games_final)  # Update games

try:
    # Configure logging
    logging.basicConfig(level=logging.INFO)

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

teams_dict = {
    1610612737: 'ATL',
    1610612738: 'BOS',
    1610612751: 'BKN',
    1610612739: 'CLE',
    1610612766: 'CHA',
    1610612741: 'CHI',
    1610612742: 'DAL',
    1610612743: 'DEN',
    1610612765: 'DET',
    1610612744: 'GSW',
    1610612745: 'HOU',
    1610612754: 'IND',
    1610612746: 'LAC',
    1610612747: 'LAL',
    1610612763: 'MEM',
    1610612748: 'MIA',
    1610612749: 'MIL',
    1610612750: 'MIN',
    1610612740: 'NOP',
    1610612752: 'NYK',
    1610612760: 'OKC',
    1610612753: 'ORL',
    1610612755: 'PHI',
    1610612756: 'PHX',
    1610612757: 'POR',
    1610612758: 'SAC',
    1610612759: 'SAS',
    1610612761: 'TOR',
    1610612762: 'UTA',
    1610612764: 'WAS'
}

played_list = list(teams_dict.keys())

update_teams(played_list)
update_players(played_list)
check_games_final()

while True:
    schedule.run_pending()
    time.sleep(1)  # Wait for 1 second between checking the schedule
