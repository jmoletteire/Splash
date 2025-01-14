from concurrent.futures import ThreadPoolExecutor
import logging
import schedule
import time
import signal

from splash_nba.lib.games.game_odds import fetch_odds
from splash_nba.lib.players.player_rotowire_news import player_rotowires
from splash_nba.live.games import games_daily_update, games_live_update, reset_flags
from splash_nba.live.players import players_daily_update
from splash_nba.live.postgame_team_player_update import check_games_final
from splash_nba.live.teams import teams_daily_update

executor = ThreadPoolExecutor(max_workers=5)


def safe_task(task):
    """Run task with exception handling."""
    try:
        task()
    except Exception as e:
        logging.error(f"Task {task.__name__} failed: {e}")


def create_thread(task):
    """Submit task to thread pool."""
    executor.submit(safe_task, task)


def daily_update():
    """Run daily update tasks."""
    games_daily_update()
    teams_daily_update()
    players_daily_update()


# Schedule the tasks
# schedule.every(20).seconds.do(create_thread, check_games_final)
schedule.every(20).seconds.do(create_thread, games_live_update)  # Update games
schedule.every(1).minutes.do(create_thread, fetch_odds)  # Update odds
schedule.every(30).minutes.do(create_thread, player_rotowires)  # Update Rotowire news
schedule.every().day.at("00:00").do(create_thread, reset_flags)  # Reset the flag at midnight
schedule.every().day.at("02:00").do(create_thread, daily_update)  # Run every day at 2:00 AM

# Configure logging
logging.basicConfig(level=logging.INFO)


def graceful_shutdown(signum, frame):
    """Handle program termination."""
    logging.info("Shutting down gracefully...")
    executor.shutdown(wait=True)
    exit(0)


signal.signal(signal.SIGINT, graceful_shutdown)

# Main loop
logging.info("Starting scheduler...")
while True:
    schedule.run_pending()
    time.sleep(1)
