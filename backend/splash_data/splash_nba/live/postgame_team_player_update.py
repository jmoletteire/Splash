import logging
import time
import threading
import schedule
from datetime import datetime, timedelta, timezone
from splash_nba.live.players import update_players
from splash_nba.live.teams import update_teams
from splash_nba.util.mongo_connect import get_mongo_collection

# Global flag to indicate if update_teams or update_players are running
is_updating = False
update_lock = threading.Lock()


async def check_games_final():
    logging.info(f'Checking games final... [{datetime.now()}]')

    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        games_collection = get_mongo_collection('nba_games')
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    global is_updating
    today = datetime.today().strftime('%Y-%m-%d')

    game_doc = games_collection.find_one({'GAME_DATE': today}, {f'GAMES': 1})
    games = game_doc['GAMES']
    if games:
        for game_id, game_data in games.items():
            if game_data.get('FINAL', False):
                if game_data.get('UPDATED', False):
                    logging.info(f'Game {game_id} already finalized & updated. [{datetime.now()}]')
                    continue
                logging.info(f'Game {game_id} is final, updating teams/players... [{datetime.now()}]')
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
                logging.info(f'Game {game_id} not final, skipping... [{datetime.now()}]')


if __name__ == '__main__':
    # Schedule the tasks
    schedule.every(10).seconds.do(check_games_final)  # Update games

    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        games_collection = get_mongo_collection('nba_games')
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

    # update_teams(played_list)
    # update_players(played_list)
    check_games_final()

    while True:
        schedule.run_pending()
        time.sleep(1)  # Wait for 1 second between checking the schedule
