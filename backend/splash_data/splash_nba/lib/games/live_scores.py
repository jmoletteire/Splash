import nba_api
import logging
from nba_api.live.nba.endpoints import scoreboard
from splash_nba.imports import get_mongo_collection, PROXY


# Function to fetch box score stats for a game
def fetch_live_scores():
    scores = scoreboard.ScoreBoard(proxy=PROXY).get_dict()['scoreboard']['games']
    return scores


def fetch_boxscore(today, game_id):
    try:
        games_collection = get_mongo_collection('nba_games')
    except Exception as e:
        logging.error(f'(Live Box Score) Failed to connect to MongoDB: {e}')
        return

    boxscore = nba_api.live.nba.endpoints.boxscore.BoxScore(game_id=game_id).get_dict()['boxscore']

    games_collection.update_one(
        {'GAME_DATE': today},
        {'$set': {f'GAMES.{game_id}.BOXSCORE': boxscore}}
    )


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        games_collection = get_mongo_collection('nba_games')

        print("Box score stats update complete.")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")