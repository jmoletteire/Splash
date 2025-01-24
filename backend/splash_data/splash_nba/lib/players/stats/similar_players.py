import logging
import numpy as np
import pandas as pd
from pymongo import MongoClient
from sklearn.metrics.pairwise import euclidean_distances

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI, CURR_SEASON, CURR_SEASON_TYPE
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import URI, CURR_SEASON, CURR_SEASON_TYPE
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def get_nested_value(data, path):
    """Fetch nested values from a dictionary given a path with dot notation."""
    for key in path.split('.'):
        data = data.get(key, None)
        if data is None:
            return None
    return data


def update_similar_players():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    client = MongoClient(URI)
    db = client.splash
    players_collection = db.nba_players

    # Define the rank stats to use for similarity comparison
    rank_stat_paths = [
        "BASIC.PTS_PER_75_RANK",
        "BASIC.REB_PER_75_RANK",
        "ADV.PASSING.AST_PER_75_RANK",
        "BASIC.STL_PER_75_RANK",
        "BASIC.BLK_PER_75_RANK",
        "BASIC.TOV_PER_75_RANK",
        "BASIC.3PAr_RANK",
        "BASIC.FT_PER_FGA_RANK",
        "ADV.MIN_RANK",
        "ADV.USG_PCT_RANK",
        "ADV.TS_PCT_RANK",
        "ADV.OFFENSIVE_LOAD_RANK",
        "ADV.BOX_CREATION_RANK",
        "ADV.ADJ_TOV_PCT_RANK",
        "ADV.VERSATILITY_SCORE_RANK",
        "ADV.MATCHUP_DIFFICULTY_RANK",
        "ADV.DEF_IMPACT_EST_RANK",
        "ADV.SCORING_BREAKDOWN.PCT_UAST_FGM_RANK",
        "ADV.DRIVES.DRIVES_PER_75_RANK",
        "ADV.TOUCHES.FGA_PER_TOUCH_RANK",
        "ADV.TOUCHES.PASSES_PER_TOUCH_RANK",
        "ADV.TOUCHES.TOV_PER_TOUCH_RANK",
        "ADV.TOUCHES.PFD_PER_TOUCH_RANK",
        "ADV.TOUCHES.AVG_SEC_PER_TOUCH_RANK",
        "ADV.TOUCHES.AVG_DRIB_PER_TOUCH_RANK",
        "ADV.REBOUNDING.REB_CHANCE_PCT_ADJ_RANK",
        "ADV.SHOOTING.SHOT_TYPE.Catch and Shoot.FGA_FREQUENCY_RANK",
        "ADV.SHOOTING.SHOT_TYPE.Pull Ups.FGA_FREQUENCY_RANK",
        "ADV.SHOOTING.SHOT_TYPE.Lees than 10 ft.FGA_FREQUENCY_RANK"
    ]

    all_players = list(players_collection.find({f"STATS.{CURR_SEASON}": {"$exists": True}}))
    count = len(all_players)
    # suggs = list(players_collection.find({'PERSON_ID': 1630591, "STATS": {"$exists": True}}))

    # Prepare a dictionary to store the results
    similar_players_dict = {}

    # Iterate over each player and each season
    for i, player in enumerate(all_players):
        player_id = player["PERSON_ID"]
        similar_players_dict[player_id] = {}
        logging.info(f'Processing {i + 1} of {count} ({player["DISPLAY_FIRST_LAST"]})')

        # Get ranks for the player for the specified stats
        stats = player.get("STATS", {}).get(CURR_SEASON, {}).get(CURR_SEASON_TYPE, {})
        if not stats:
            continue

        player_ranks = [get_nested_value(stats, path) for path in rank_stat_paths]

        # Skip if player ranks are incomplete
        if any(rank is None for rank in player_ranks):
            continue

        # Collect rank data for all players for this season
        player_data = []
        player_ids = []

        for other_player in all_players:
            other_player_data = {
                'PERSON_ID': other_player["PERSON_ID"] if "PERSON_ID" in other_player else 0,
                'NAME': other_player["DISPLAY_FI_LAST"] if "DISPLAY_FI_LAST" in other_player else '',
                'TEAM_ID': other_player["TEAM_ID"] if "TEAM_ID" in other_player else 0,
                'POSITION': other_player["POSITION"] if "POSITION" in other_player else '',
            }
            other_player_stats = other_player["STATS"].get(CURR_SEASON, {}).get(CURR_SEASON_TYPE, {})

            if not other_player_stats:
                continue

            other_player_ranks = [get_nested_value(other_player_stats, path) for path in rank_stat_paths]

            # Skip if ranks are incomplete for the other player
            if any(rank is None for rank in other_player_ranks):
                continue

            player_data.append(other_player_ranks)
            player_ids.append(other_player_data)

        # Calculate similarity (Euclidean distance) only if player_data is not empty
        if player_data:
            player_df = pd.DataFrame(player_data, index=player_ids, columns=rank_stat_paths)
            distances = euclidean_distances([player_ranks], player_df.values)[0]

            # Normalize distances to similarity scores between 0 and 100
            max_dist = np.max(distances)
            min_dist = np.min(distances)
            similarity_scores = 100 * (1 - (distances - min_dist) / (max_dist - min_dist))

            # Get top 5 similar players with their similarity scores
            similar_player_indices = similarity_scores.argsort()[::-1][1:6]

            # Add similarity score to each similar player's dictionary
            similar_players = []
            for idx in similar_player_indices:
                similar_player = player_ids[idx]
                similar_player["SIMILARITY_SCORE"] = similarity_scores[idx]
                similar_players.append(similar_player)

            # Update the MongoDB document with the similar players and their scores
            players_collection.update_one(
                {"PERSON_ID": player_id},
                {"$set": {f'STATS.{CURR_SEASON}.{CURR_SEASON_TYPE}.SIMILAR_PLAYERS': similar_players}},
            )


def find_similar_players():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    client = MongoClient(URI)
    db = client.splash
    players_collection = db.nba_players

    # Define the rank stats to use for similarity comparison
    rank_stat_paths = [
        "BASIC.PTS_PER_75_RANK",
        "BASIC.REB_PER_75_RANK",
        "ADV.PASSING.AST_PER_75_RANK",
        "BASIC.STL_PER_75_RANK",
        "BASIC.BLK_PER_75_RANK",
        "BASIC.TOV_PER_75_RANK",
        "BASIC.3PAr_RANK",
        "BASIC.FT_PER_FGA_RANK",
        "ADV.MIN_RANK",
        "ADV.USG_PCT_RANK",
        "ADV.TS_PCT_RANK",
        "ADV.OFFENSIVE_LOAD_RANK",
        "ADV.BOX_CREATION_RANK",
        "ADV.ADJ_TOV_PCT_RANK",
        "ADV.VERSATILITY_SCORE_RANK",
        "ADV.MATCHUP_DIFFICULTY_RANK",
        "ADV.DEF_IMPACT_EST_RANK",
        "ADV.SCORING_BREAKDOWN.PCT_UAST_FGM_RANK",
        "ADV.DRIVES.DRIVES_PER_75_RANK",
        "ADV.TOUCHES.FGA_PER_TOUCH_RANK",
        "ADV.TOUCHES.PASSES_PER_TOUCH_RANK",
        "ADV.TOUCHES.TOV_PER_TOUCH_RANK",
        "ADV.TOUCHES.PFD_PER_TOUCH_RANK",
        "ADV.TOUCHES.AVG_SEC_PER_TOUCH_RANK",
        "ADV.TOUCHES.AVG_DRIB_PER_TOUCH_RANK",
        "ADV.REBOUNDING.REB_CHANCE_PCT_ADJ_RANK",
        "ADV.SHOOTING.SHOT_TYPE.Catch and Shoot.FGA_FREQUENCY_RANK",
        "ADV.SHOOTING.SHOT_TYPE.Pull Ups.FGA_FREQUENCY_RANK",
        "ADV.SHOOTING.SHOT_TYPE.Lees than 10 ft.FGA_FREQUENCY_RANK"
    ]

    all_players = list(players_collection.find({"STATS": {"$exists": True}}))
    count = len(all_players)
    # suggs = list(players_collection.find({'PERSON_ID': 1630591, "STATS": {"$exists": True}}))

    # Prepare a dictionary to store the results
    similar_players_dict = {}

    # Iterate over each player and each season
    for i, player in enumerate(all_players):
        player_id = player["PERSON_ID"]
        similar_players_dict[player_id] = {}
        logging.info(f'Processing {i + 1} of {count} ({player["DISPLAY_FIRST_LAST"]})')

        for season, season_types in player["STATS"].items():
            for season_type, stats in season_types.items():
                if season_type not in ['REGULAR SEASON', 'PLAYOFFS']:
                    continue

                # Get ranks for the player for the specified stats
                player_ranks = [get_nested_value(stats, path) for path in rank_stat_paths]

                # Skip if player ranks are incomplete
                if any(rank is None for rank in player_ranks):
                    continue

                # Collect rank data for all players for this season
                player_data = []
                player_ids = []

                for other_player in all_players:
                    other_player_data = {
                        'PERSON_ID': other_player["PERSON_ID"] if "PERSON_ID" in other_player else 0,
                        'NAME': other_player["DISPLAY_FI_LAST"] if "DISPLAY_FI_LAST" in other_player else '',
                        'TEAM_ID': other_player["TEAM_ID"] if "TEAM_ID" in other_player else 0,
                        'POSITION': other_player["POSITION"] if "POSITION" in other_player else '',
                    }
                    other_player_stats = other_player["STATS"].get(season, {}).get(season_type, {})

                    if not other_player_stats:
                        continue

                    other_player_data['TEAM_ID'] = other_player_stats.get('BASIC', {}).get('TEAM_ID', 0)
                    other_player_ranks = [get_nested_value(other_player_stats, path) for path in rank_stat_paths]

                    # Skip if ranks are incomplete for the other player
                    if any(rank is None for rank in other_player_ranks):
                        continue

                    player_data.append(other_player_ranks)
                    player_ids.append(other_player_data)

                # Calculate similarity (Euclidean distance) only if player_data is not empty
                if player_data:
                    player_df = pd.DataFrame(player_data, index=player_ids, columns=rank_stat_paths)
                    distances = euclidean_distances([player_ranks], player_df.values)[0]

                    # Normalize distances to similarity scores between 0 and 100
                    max_dist = np.max(distances)
                    min_dist = np.min(distances)
                    similarity_scores = 100 * (1 - (distances - min_dist) / (max_dist - min_dist))

                    # Get top 5 similar players with their similarity scores
                    similar_player_indices = similarity_scores.argsort()[::-1][1:6]

                    # Add similarity score to each similar player's dictionary
                    similar_players = []
                    for idx in similar_player_indices:
                        similar_player = player_ids[idx]
                        similar_player["SIMILARITY_SCORE"] = similarity_scores[idx]
                        similar_players.append(similar_player)

                    # Update the MongoDB document with the similar players and their scores
                    players_collection.update_one(
                        {"PERSON_ID": player_id},
                        {"$set": {f'STATS.{season}.{season_type}.SIMILAR_PLAYERS': similar_players}},
                    )


# Run the function and get similar players
if __name__ == '__main__':
    find_similar_players()
    # update_similar_players()
