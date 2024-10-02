import logging
import random
from datetime import datetime

import schedule
import time

from nba_api.live.nba.endpoints import boxscore
from nba_api.stats.endpoints import commonplayoffseries, playerawards, scoreboardv2
from pymongo import MongoClient

from splash_nba.lib.games.fetch_new_games import update_game_data
from splash_nba.lib.games.live_scores import fetch_boxscore, fetch_live_scores
from splash_nba.lib.games.nba_cup import update_current_cup
from splash_nba.lib.games.playoff_bracket import reformat_series_data, get_playoff_bracket_data
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
    update_three_and_ft_rate, update_player_tracking_stats, update_shot_distribution, update_touches_breakdown, \
    update_drive_stats, update_scoring_breakdown_and_pct_unassisted, update_box_creation, update_offensive_load, \
    update_adj_turnover_pct, update_versatility_score, update_matchup_difficulty_and_dps
from splash_nba.lib.players.update_all_players import add_players, restructure_new_docs, update_player_info
from splash_nba.lib.players.update_player_contracts import fetch_player_contract_data, keep_most_informative
from splash_nba.lib.teams.stats.custom_team_stats import three_and_ft_rate
from splash_nba.lib.teams.stats.custom_team_stats_rank import custom_team_stats_rank, \
    current_season_custom_team_stats_rank
from splash_nba.lib.teams.stats.per100 import calculate_and_update_per_100_possessions, \
    current_season_per_100_possessions
from splash_nba.lib.teams.team_cap_sheet import update_team_contract_data
from splash_nba.lib.teams.team_history import update_team_history
from splash_nba.lib.teams.update_team_games import update_games
from splash_nba.lib.teams.standings import update_current_standings
from splash_nba.lib.teams.update_news_and_transactions import fetch_team_transactions, fetch_team_news
from splash_nba.lib.teams.team_seasons import update_current_season
from splash_nba.lib.teams.stats.team_hustle_stats_rank import rank_hustle_stats_current_season
from splash_nba.lib.teams.team_rosters import update_current_roster
from splash_nba.lib.teams.update_last_lineup import get_last_game, get_last_lineup
from splash_nba.util.env import uri, k_current_season, k_current_season_type


def games_live_update():
    try:
        client = MongoClient(uri)
        db = client.splash
        games_collection = db.nba_games
    except Exception as e:
        logging.error(f'(Games Live) Failed to connect to MongoDB: {e}')
        return

    today = datetime.today().strftime('%Y-%m-%d')
    scoreboard = scoreboardv2.ScoreboardV2(game_date=today, day_offset=0).get_normalized_dict()

    try:
        games_today = scoreboard['GameHeader']
        line_scores = scoreboard['LineScore']
    except KeyError as e:
        logging.error(f'(Games Live) Failed to get scores for today: {e}')
        return

    if games_today:
        for game in games_today:
            is_final = game['GAME_STATUS_ID'] == 3
            line_score = [line for line in line_scores if line['GAME_ID'] == game['GAME_ID']]
            if not is_final:
                box_score = boxscore.BoxScore(game_id=game['GAME_ID']).get_dict()['boxscore']
                games_collection.update_one(
                    {'GAME_DATE': today},
                    {'$set': {
                        f'GAMES.{game["GAME_ID"]}.SUMMARY.LineScore': line_score,
                        f'GAMES.{game["GAME_ID"]}.BOXSCORE': box_score
                    }
                    }
                )


def games_daily_update():
    """
    Runs every day at 2:30AM.\n
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
    playoff_games = commonplayoffseries.CommonPlayoffSeries(season=k_current_season).get_normalized_dict()[
        'PlayoffSeries']
    if not playoff_games:
        logging.info("(Games Daily) No playoff games found.")
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
            # Team History
            logging.info("History...")
            update_team_history(team_id=team)

            # Season Stats
            logging.info("Stats...")
            update_current_season(team_id=team)

            # Filter seasons to only include the current season key
            filtered_doc = doc.copy()
            filtered_doc['seasons'] = {key: doc['seasons'][key] for key in doc['seasons'] if key == k_current_season}
            current_season_per_100_possessions(team_doc=filtered_doc, playoffs=k_current_season_type == 'PLAYOFFS')

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
        current_season_custom_team_stats_rank()
    except Exception as e:
        logging.error(f"(Teams Daily) Error updating teams: {e}")


def players_daily_update():
    """
    Runs every day at 3:30AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """

    def player_info():
        # Player Info
        logging.info("Player Info...")
        try:
            add_players()
            restructure_new_docs()
            update_player_info()
        except Exception as e:
            logging.error(f"(Player Info) Error adding players: {e}")

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

        # CUSTOM STATS (Calculated)
        update_player_on_off(k_current_season_type)  # ON/OFF
        update_poss_per_game(k_current_season_type)  # POSS PER G
        update_three_and_ft_rate(k_current_season_type)  # 3PAr, FTAr, FT/FGA
        update_player_tracking_stats(k_current_season_type)  # TOUCHES, PASSING, DRIVES, REBOUNDING, SPEED/DISTANCE
        update_touches_breakdown(k_current_season_type)  # % PASS, % SHOOT, % TOV, % FOULED
        update_shot_distribution(k_current_season_type)  # SHOT TYPE, CLOSEST DEFENDER
        update_drive_stats(k_current_season_type)  # DRIVE %, DRIVE TS%, DRIVE FT/FGA
        update_scoring_breakdown_and_pct_unassisted(k_current_season_type)  # % UAST
        update_box_creation(k_current_season_type)  # BOX CREATION
        update_offensive_load(k_current_season_type)  # OFF LOAD
        update_adj_turnover_pct(k_current_season_type)  # cTOV
        update_versatility_score(k_current_season_type)  # VERSATILITY
        update_matchup_difficulty_and_dps(k_current_season_type)  # MATCHUP DIFF & DIE

        # PER 75
        current_season_per_75(k_current_season_type == 'PLAYOFFS')

        # Rank
        current_season_custom_stats_rank()
        current_season_shooting_stat_ranks(k_current_season_type)

    def player_career_stats():
        # Stats
        logging.info("Player Career Stats...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active'})
        processed_count = 0
        i = 0

        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active'},
                                         {'PERSON_ID': 1, 'STATS': 1, 'CAREER': 1, '_id': 0}).skip(
                    processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
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

    def player_game_logs():
        # Game Logs
        logging.info("Player Game Logs...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active'})
        processed_count = 0
        i = 0

        # Loop through all ACTIVE players
        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active'}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(
                    processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
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

    def player_shot_charts():
        # Shot Charts
        logging.info("Player Shot Charts...")

        # Set batch size to process documents
        batch_size = 25
        total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active'})
        processed_count = 0
        i = 0
        keep_league_avg = True

        # Loop through all ACTIVE players
        while processed_count < total_documents:
            with players_collection.find({'ROSTERSTATUS': 'Active'}, {'PERSON_ID': 1, 'TEAM_ID': 1, '_id': 0}).skip(
                    processed_count).limit(
                    batch_size).batch_size(batch_size) as cursor:
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

    def player_contracts_and_trans():
        # Contracts & Transactions
        logging.info("Player Contracts & Transactions...")

        # Update all ACTIVE players
        for i, player in enumerate(players_collection.find({'ROSTERSTATUS': 'Active'}, {'PERSON_ID': 1, '_id': 0})):
            logging.info(f'Processing {i + 1} of {players_collection.count_documents({"ROSTERSTATUS": "Active"})}...')

            try:
                player_id = str(player['PERSON_ID'])

                # Define the GraphQL endpoint
                url = "https://fanspo.com/api/graphql"

                # Define the headers
                headers = {
                    "Content-Type": "application/json"
                }

                # Define the initial query variables
                variables = {
                    "playerId": player_id
                }

                # Fetch all paginated data
                contracts, transactions = fetch_player_contract_data(url, variables, headers)
                transactions = keep_most_informative(transactions)

                players_collection.update_one(
                    {"PERSON_ID": int(player_id)},
                    {"$set": {'CONTRACTS': contracts, 'TRANSACTIONS': transactions}},
                )
            except Exception as e:
                logging.error(
                    f'(Player Contracts) Could not process contract data for Player {player["PERSON_ID"]}: {e}')
                continue

    def player_awards():
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Connect to MongoDB
        client = MongoClient(uri)
        db = client.splash
        players_collection = db.nba_players

        logging.info("Player Awards...")

        keys = [
            'DESCRIPTION',
            'ALL_NBA_TEAM_NUMBER',
            'SEASON',
            'CONFERENCE',
            'TYPE'
        ]
        players = players_collection.count_documents({'ROSTERSTATUS': 'Active'})

        # Update awards for all ACTIVE players
        for i, player in enumerate(players_collection.find({'ROSTERSTATUS': 'Active'}, {"PERSON_ID": 1, "_id": 0})):
            try:
                player_awards = playerawards.PlayerAwards(player["PERSON_ID"]).get_normalized_dict()['PlayerAwards']

                awards = {}

                for award in player_awards:
                    if award['DESCRIPTION'] not in awards.keys():
                        awards[award['DESCRIPTION']] = [{key: award[key] for key in keys}]
                    else:
                        awards[award['DESCRIPTION']].append({key: award[key] for key in keys})

                players_collection.update_one(
                    {"PERSON_ID": player["PERSON_ID"]},
                    {"$set": {"AWARDS": awards}},
                )

                logging.info(f"(Player Awards) Updated {i + 1} of {players}")

            except Exception as e:
                logging.error(f"(Player Awards) Unable to process player {player['PERSON_ID']}: {e}")

            # Pause for a random time between 0.5 and 2 seconds
            time.sleep(random.uniform(0.5, 2.0))

            # Pause 15 seconds for every 50 players
            if i % 50 == 0:
                time.sleep(15)

    logging.info("Updating players (daily)...")

    # INFO
    try:
        player_info()
        #print('Skip')
    except Exception as e:
        logging.error(f"Error updating player info: {e}")

    # STATS
    try:
        #player_stats()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player stats: {e}")

    # CAREER
    try:
        #player_career_stats()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player career stats: {e}")

    # GAME LOGS
    try:
        #player_game_logs()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player game logs: {e}")

    # SHOT CHART
    try:
        #player_shot_charts()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player shot charts: {e}")

    # CONTRACT & TRANSACTIONS
    try:
        player_contracts_and_trans()
        #print('Skip')
    except Exception as e:
        logging.error(f"Error updating player contracts & transactions: {e}")

    # AWARDS
    try:
        #player_awards()
        print('Skip')
    except Exception as e:
        logging.error(f"Error updating player awards: {e}")


# Schedule the tasks
# schedule.every(1).minute.do(games_live_update)  # Run every 1 minute
# schedule.every().day.at("02:30").do(games_daily_update())  # Run every day at 2:30 AM
# schedule.every().day.at("03:00").do(teams_daily_update())  # Run every day at 3:00 AM
# schedule.every().day.at("03:30").do(players_daily_update())  # Run every day at 3:30 AM

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

    # games_daily_update()
    teams_daily_update()
    # players_daily_update()

    #while True:
    #schedule.run_pending()
    #time.sleep(1)  # Wait for 1 second between checking the schedule
