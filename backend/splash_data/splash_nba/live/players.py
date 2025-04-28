import logging
import time
from numpy import random
from datetime import datetime
from nba_api.stats.endpoints import playerawards
from splash_nba.lib.players.player_gamelogs import gamelogs
from splash_nba.lib.players.stats.custom_player_stats_rank import current_season_custom_stats_rank
from splash_nba.lib.players.stats.per75 import current_season_per_75
from splash_nba.lib.players.stats.player_career_stats import update_player_career_stats
from splash_nba.lib.players.stats.player_hustle_stats import update_player_hustle_stats
from splash_nba.lib.players.stats.player_stats import update_player_stats
from splash_nba.lib.players.stats.shooting_stat_rank import current_season_shooting_stat_ranks
from splash_nba.lib.players.stats.shot_chart_data import get_shot_chart_data
from splash_nba.lib.players.stats.similar_players import update_similar_players
from splash_nba.lib.players.stats.update_custom_player_stats import update_player_on_off, update_poss_per_game, \
    update_three_and_ft_rate, update_player_tracking_stats, update_shot_distribution, update_touches_breakdown, \
    update_drive_stats, update_scoring_breakdown_and_pct_unassisted, update_box_creation, update_offensive_load, \
    update_adj_turnover_pct, update_versatility_score, update_matchup_difficulty_and_dps
from splash_nba.lib.players.update_all_players import add_players, restructure_new_docs, update_player_info
from splash_nba.lib.players.update_player_contracts import fetch_player_contract_data, keep_most_informative
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS, CURR_SEASON, CURR_SEASON_TYPE


async def update_players(team_ids):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    try:
        players_collection = get_mongo_collection('nba_players')
    except Exception as e:
        logging.error(f'(Players Daily) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    def player_stats():
        # Stats
        logging.info("Player Stats...")

        for team_id in team_ids:
            logging.info(f"\nProcessing team {team_id}\n")

            # BASIC, ADV, HUSTLE
            try:
                update_player_stats(CURR_SEASON_TYPE, team_id)
            except Exception as e:
                logging.error(f"(Player Stats) Error updating BASIC/ADV stats for team {team_id}: {e}", exc_info=True)

            try:
                update_player_hustle_stats(CURR_SEASON_TYPE, team_id)
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Player Hustle Stats for team {team_id}: {e}")

            # CUSTOM STATS (Calculated)
            try:
                update_player_on_off(CURR_SEASON_TYPE, team_id)  # ON/OFF
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Player On/Off for team {team_id}: {e}")

            try:
                update_poss_per_game(CURR_SEASON_TYPE, team_id)  # POSS PER G
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Poss Per Game for team {team_id}: {e}")

            try:
                update_three_and_ft_rate(CURR_SEASON_TYPE, team_id)  # 3PAr, FTAr, FT/FGA
            except Exception as e:
                logging.error(f"(Player Stats) Error updating 3PAr & FTr for team {team_id}: {e}")

            try:
                update_player_tracking_stats(CURR_SEASON_TYPE, team_id)  # TOUCHES, PASSING, DRIVES, REBOUNDING, SPEED/DISTANCE
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Player Tracking for team {team_id}: {e}")

            try:
                update_touches_breakdown(CURR_SEASON_TYPE, team_id)  # % PASS, % SHOOT, % TOV, % FOULED
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Touches Breakdown for team {team_id}: {e}")

            try:
                update_shot_distribution(CURR_SEASON_TYPE, team_id)  # SHOT TYPE, CLOSEST DEFENDER
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Shot Distribution for team {team_id}: {e}")

            try:
                update_drive_stats(CURR_SEASON_TYPE, team_id)  # DRIVE %, DRIVE TS%, DRIVE FT/FGA
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Drives for team {team_id}: {e}")

            try:
                update_scoring_breakdown_and_pct_unassisted(CURR_SEASON_TYPE, team_id)  # % UAST
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Scoring Breakdown for team {team_id}: {e}")

            try:
                update_versatility_score(CURR_SEASON_TYPE, team_id)  # VERSATILITY
            except Exception as e:
                logging.error(f"(Player Stats) Error updating Versatility for team {team_id}: {e}")

            # PER POSS STATS
            current_season_per_75(CURR_SEASON_TYPE == 'PLAYOFFS', team_id)
            update_box_creation(CURR_SEASON_TYPE, team_id)  # BOX CREATION
            update_offensive_load(CURR_SEASON_TYPE, team_id)  # OFF LOAD
            update_adj_turnover_pct(CURR_SEASON_TYPE, team_id)  # cTOV

        for team_id in team_ids:
            update_matchup_difficulty_and_dps(CURR_SEASON_TYPE, team_id)  # MATCHUP DIFF & DIE

        # Rank
        current_season_custom_stats_rank()
        current_season_shooting_stat_ranks(CURR_SEASON_TYPE)

        # Similar Players
        update_similar_players()

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
                        gamelogs(player['PERSON_ID'], CURR_SEASON, CURR_SEASON_TYPE)
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
                            CURR_SEASON,
                            'Regular Season' if CURR_SEASON_TYPE == 'REGULAR SEASON' else 'Playoffs',
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


async def players_daily_update():
    """
    Runs every day at 3:30AM.\n
    Updates STATS, STANDINGS, ROSTER, COACHES, GAMES, and miscellaneous data
    for each team.
    """
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    try:
        players_collection = get_mongo_collection('nba_players')
    except Exception as e:
        logging.error(f'(Players Daily) Failed to connect to MongoDB [{datetime.now()}]: {e}')
        return

    def player_info():
        # Player Info
        logging.info("Player Info...")

        try:
            add_players()
            restructure_new_docs()
            update_player_info()
        except Exception as e:
            logging.error(f"(Player Info) Error adding players: {e}", exc_info=True)

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
                    f'(Player Contracts) Could not process contract data for Player {player["PERSON_ID"]}: {e}', exc_info=True)
                continue

    def player_awards():
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
                player_awards = playerawards.PlayerAwards(player["PERSON_ID"], proxy=PROXY, headers=HEADERS).get_normalized_dict()['PlayerAwards']

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
                logging.error(f"(Player Awards) Unable to process player {player['PERSON_ID']}: {e}", exc_info=True)

            # Pause for a random time between 0.5 and 2 seconds
            time.sleep(random.uniform(0.5, 2.0))

            # Pause 15 seconds for every 50 players
            if i % 50 == 0:
                time.sleep(15)

    logging.info("Updating players (daily)...")

    # INFO
    try:
        player_info()
        # logging.info('Skip Player Info')
    except Exception as e:
        logging.error(f"Error updating player info: {e}", exc_info=True)

    # CONTRACT & TRANSACTIONS
    try:
        player_contracts_and_trans()
        # logging.info('Skip Player Contracts')
    except Exception as e:
        logging.error(f"Error updating player contracts & transactions: {e}", exc_info=True)

    # AWARDS
    try:
        player_awards()
        # logging.info('Skip Player Awards')
    except Exception as e:
        logging.error(f"Error updating player awards: {e}", exc_info=True)

    # STATS
    try:
        teams = [
            1610612737,  # ATL
            1610612738,  # BOS
            1610612751,  # BKN
            1610612739,  # CLE
            1610612766,  # CHA
            1610612741,  # CHI
            1610612742,  # DAL
            1610612743,  # DEN
            1610612765,  # DET
            1610612744,  # GSW
            1610612745,  # HOU
            1610612754,  # IND
            1610612746,  # LAC
            1610612747,  # LAL
            1610612763,  # MEM
            1610612748,  # MIA
            1610612749,  # MIL
            1610612750,  # MIN
            1610612740,  # NOP
            1610612752,  # NYK
            1610612760,  # OKC
            1610612753,  # ORL
            1610612755,  # PHI
            1610612756,  # PHX
            1610612757,  # POR
            1610612758,  # SAC
            1610612759,  # SAS
            1610612761,  # TOR
            1610612762,  # UTA
            1610612764,  # WAS
        ]
        await update_players(teams)
    except Exception as e:
        logging.error(f"Error updating players: {e}", exc_info=True)