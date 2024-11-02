from pymongo import MongoClient
from sklearn.metrics.pairwise import euclidean_distances
import pandas as pd
from splash_nba.util.env import uri
import logging


def get_nested_value(data, path):
    """Fetch nested values from a dictionary given a path with dot notation."""
    for key in path.split('.'):
        data = data.get(key, None)
        if data is None:
            return None
    return data


def find_similar_players():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players

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
                    "ADV.DRIVES.DRIVES_PER_75_RANK"
                ]

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

                    other_player_ranks = [get_nested_value(other_player_stats, path) for path in rank_stat_paths]

                    # Skip if ranks are incomplete for the other player
                    if any(rank is None for rank in other_player_ranks):
                        continue

                    player_data.append(other_player_ranks)
                    player_ids.append(other_player_data)

                # Calculate similarity (Euclidean distance)
                player_df = pd.DataFrame(player_data, index=player_ids, columns=rank_stat_paths)
                distances = euclidean_distances([player_ranks], player_df.values)[0]
                similar_player_indices = distances.argsort()[1:6]  # Skip self (distance 0)

                # Get top 5 similar players
                similar_players = [player_ids[idx] for idx in similar_player_indices]

                # similar_players_dict[player_id][season] = similar_players
                players_collection.update_one(
                    {"PERSON_ID": player_id},
                    {"$set": {f'STATS.{season}.{season_type}.SIMILAR_PLAYERS': similar_players}},
                )


# Run the function and get similar players
if __name__ == '__main__':
    find_similar_players()

# Output or store the similar players as needed
# Example: print(similar players for a specific player and season)
# for player_id, seasons in similar_players.items():
#    print(f"Player {player_id}:")
#    for season, sim_players in seasons.items():
#        print(f"  Season {season}: {sim_players}")
