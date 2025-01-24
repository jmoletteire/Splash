import asyncio
import logging
import time

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from apscheduler.triggers.cron import CronTrigger

# Import your task functions
from splash_nba.lib.games.game_odds import fetch_odds
from splash_nba.live.games import games_daily_update, games_live_update, reset_flags
# from splash_nba.live.postgame_team_player_update import check_games_final
from splash_nba.live.teams import teams_daily_update
from splash_nba.live.players import players_daily_update
from splash_nba.lib.players.player_rotowire_news import player_rotowires

# Configure logging
logging.basicConfig(level=logging.INFO)

# Dictionary to store locks for each task
task_locks = {}


async def safe_task(task, name, timeout=30):
    """
    Run the task with exception handling, timeout, and no overlap.
    """
    # Create a lock for the task if it doesn't exist
    if name not in task_locks:
        task_locks[name] = asyncio.Lock()

    async with task_locks[name]:
        try:
            logging.info(f"\nStarting task: {name}\n")
            # Set a timeout for the task
            await asyncio.wait_for(task(), timeout=timeout)
        except asyncio.TimeoutError:
            logging.error(f"Task {name} timed out.\n")
        except Exception as e:
            logging.error(f"Task {name} failed: {e}\n")


# Task wrappers
async def games_live_update_task():
    start_time = time.time()
    await safe_task(games_live_update, "games_live_update", timeout=60)
    end_time = time.time()
    elapsed_time = end_time - start_time
    logging.info(f"\ngames_live_update_task completed in {elapsed_time:.2f} seconds\n")


# async def check_games_final_task():
#     start_time = time.time()
#     await safe_task(check_games_final, "check_games_final", timeout=600)
#     end_time = time.time()
#     elapsed_time = end_time - start_time
#     logging.info(f"\ncheck_games_final_task completed in {elapsed_time:.2f} seconds\n")


async def fetch_odds_task():
    start_time = time.time()
    await safe_task(fetch_odds, "fetch_odds", timeout=60)
    end_time = time.time()
    elapsed_time = end_time - start_time
    logging.info(f"\nfetch_odds_task completed in {elapsed_time:.2f} seconds\n")


async def player_rotowires_task():
    start_time = time.time()
    await safe_task(player_rotowires, "player_rotowires", timeout=300)
    end_time = time.time()
    elapsed_time = end_time - start_time
    logging.info(f"\nplayer_rotowires_task completed in {elapsed_time:.2f} seconds\n")


async def daily_update_task():
    start_time = time.time()
    await safe_task(
        lambda: asyncio.gather(
            games_daily_update(),
            teams_daily_update(),
            players_daily_update(),
        ),
        "daily_update",
        timeout=10800,  # 3 hours
    )
    end_time = time.time()
    elapsed_time = end_time - start_time
    logging.info(f"\ndaily_update_task completed in {elapsed_time:.2f} seconds\n")


async def reset_flags_task():
    await safe_task(reset_flags, "reset_flags", timeout=60)


# APScheduler setup
def setup_scheduler():
    scheduler = AsyncIOScheduler()

    # Schedule tasks
    scheduler.add_job(games_live_update_task, IntervalTrigger(seconds=20), coalesce=True)
    scheduler.add_job(fetch_odds_task, IntervalTrigger(minutes=1), coalesce=True)
    scheduler.add_job(player_rotowires_task, IntervalTrigger(minutes=30), coalesce=True)
    scheduler.add_job(reset_flags_task, CronTrigger(hour=0, minute=0), coalesce=True)
    scheduler.add_job(daily_update_task, CronTrigger(hour=2, minute=0), coalesce=True)

    scheduler.start()
    logging.info("Scheduler started...")
    return scheduler


async def main():
    logging.info("Starting main application...")

    # Set up the scheduler
    scheduler = setup_scheduler()

    try:
        # Keep the event loop running
        while True:
            await asyncio.sleep(1)
    except (KeyboardInterrupt, SystemExit):
        logging.info("Shutting down scheduler...")
        if scheduler:
            scheduler.shutdown()

if __name__ == "__main__":
    asyncio.run(main())
