import asyncio
import logging

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from apscheduler.triggers.cron import CronTrigger

# Import your task functions
from splash_nba.lib.games.game_odds import fetch_odds
from splash_nba.live.games import games_daily_update, games_live_update
from splash_nba.live.postgame_team_player_update import check_games_final
from splash_nba.live.teams import teams_daily_update
from splash_nba.live.players import players_daily_update
from splash_nba.lib.players.player_rotowire_news import player_rotowires

# Configure logging
logging.basicConfig(level=logging.INFO)


async def daily_update():
    await games_daily_update()
    await teams_daily_update()
    await players_daily_update()


async def live_update():
    await games_live_update()
    await fetch_odds()


# APScheduler setup
def setup_scheduler():
    scheduler = AsyncIOScheduler()

    loop = asyncio.get_event_loop()

    # Schedule tasks
    # Run `live_update` every 20 seconds (ensures live game updates are always fresh)
    scheduler.add_job(
        lambda: asyncio.run_coroutine_threadsafe(live_update(), loop),  # Runs in a separate task
        IntervalTrigger(seconds=20), coalesce=True, max_instances=1, misfire_grace_time=10,
    )

    # Run `check_games_final` every 20 seconds, but as a separate task
    scheduler.add_job(
        lambda: asyncio.run_coroutine_threadsafe(check_games_final(), loop),  # Runs in a separate task
        IntervalTrigger(seconds=20), coalesce=True, max_instances=1, misfire_grace_time=10,
    )

    scheduler.add_job(
        lambda: asyncio.run_coroutine_threadsafe(player_rotowires(), loop),  # Runs in a separate task
        IntervalTrigger(minutes=30), coalesce=True, max_instances=1, misfire_grace_time=900,
    )

    scheduler.add_job(
        lambda: asyncio.run_coroutine_threadsafe(daily_update(), loop),  # Runs in a separate task
        CronTrigger(hour=2, minute=0, timezone='America/Chicago'),  # 2AM CST
        coalesce=True, max_instances=1, misfire_grace_time=18000,
    )
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
