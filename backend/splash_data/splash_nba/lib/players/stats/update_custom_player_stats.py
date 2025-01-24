import math
import time
import random
import logging
from pymongo import MongoClient
from collections import defaultdict
from nba_api.stats.endpoints import teamplayeronoffdetails, leaguedashptstats, playerdashptshots, leagueseasonmatchups, \
    leaguedashplayerstats, matchupsrollup

try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI, CURR_SEASON, CURR_SEASON_TYPE
    PROXY = None
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI, CURR_SEASON, CURR_SEASON_TYPE
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")

seasons = [
    '2023-24',
    '2022-23',
    '2021-22',
    '2020-21',
    '2019-20',
    '2018-19',
    '2017-18',
    '2016-17',
    '2015-16',
    '2014-15',
    '2013-14',
    '2012-13',
    '2011-12',
    '2010-11',
    '2009-10',
    '2008-09',
    '2007-08',
    '2006-07',
    '2005-06',
    '2004-05',
    '2003-04',
    '2002-03',
    '2001-02',
    '2000-01',
    '1999-00',
    '1998-99',
    '1997-98',
    '1996-97'
]
season_types = ['REGULAR SEASON', 'PLAYOFFS']


# CHECKED
# TEAM-LEVEL
def update_scoring_breakdown_and_pct_unassisted(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
    except Exception as e:
        logging.error(f'(Scoring Breakdown) Unable to connect to MongoDB: {e}')
        exit(1)

    if season_type == 'PLAYOFFS':
        player_uast = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, measure_type_detailed_defense='Scoring',
                                                                  season=CURR_SEASON,
                                                                  season_type_all_star='Playoffs').get_normalized_dict()[
            'LeagueDashPlayerStats']
    else:
        player_uast = leaguedashplayerstats.LeagueDashPlayerStats(proxy=PROXY, measure_type_detailed_defense='Scoring',
                                                                  season=CURR_SEASON).get_normalized_dict()[
            'LeagueDashPlayerStats']

    num_players = len(player_uast)

    logging.info(f'(Scoring Breakdown) Processing {num_players} for season {CURR_SEASON} {season_type}...')

    uast_keys = list(player_uast[0].keys())[11:26] + list(player_uast[0].keys())[34:49]

    # Initialize dictionaries for each data type
    player_data = defaultdict(lambda: {'scoring': {}})

    # Fill in the player data from each list
    for player in player_uast:
        player_id = player['PLAYER_ID']
        player_data[player_id]['scoring'] = {key: player[key] for key in uast_keys}

    # Update the MongoDB collection
    for player_id, data in player_data.items():
        try:
            players_collection.update_one(
                {'PERSON_ID': player_id, 'TEAM_ID': team_id},
                {'$set': {
                    f'STATS.{CURR_SEASON}.{season_type}.ADV.SCORING_BREAKDOWN': data['scoring'],
                }},
            )
        except Exception as e:
            logging.error(f'(Scoring Breakdown) Unable to add stats for player with ID {player_id}: {e}')
            continue


# CHECKED
# TEAM-LEVEL
def update_matchup_difficulty_and_dps(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(Matchup Diff & DIE) Unable to connect to MongoDB: {e}')
        exit(1)

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
    processed_count = 0
    i = 0

    # Update all ACTIVE players
    while processed_count < total_documents:
        with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'(Matchup Diff & DIE) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                try:
                    if season_type == 'REGULAR SEASON':
                        data = leagueseasonmatchups.LeagueSeasonMatchups(proxy=PROXY, season=CURR_SEASON,
                                                                         def_player_id_nullable=player['PERSON_ID'])
                    else:
                        data = leagueseasonmatchups.LeagueSeasonMatchups(proxy=PROXY, season=CURR_SEASON,
                                                                         season_type_playoffs='Playoffs',
                                                                         def_player_id_nullable=player['PERSON_ID'])

                    try:
                        raw_data = data.get_normalized_dict()['SeasonMatchups']
                    except KeyError:
                        continue

                    if len(raw_data) == 0:
                        continue

                    load = 0  # Matchup Difficulty
                    x_team_pts = 0  # DPS
                    partial_poss = 0

                    for matchup in raw_data:
                        off_player = players_collection.find_one(
                            {'PERSON_ID': matchup['OFF_PLAYER_ID']},
                            {
                                f'STATS.{CURR_SEASON}.{season_type}.ADV.OFFENSIVE_LOAD': 1,
                                f'STATS.{CURR_SEASON}.{season_type}.ADV.OFF_RATING': 1,
                                '_id': 0
                            }
                        )

                        try:
                            partial_poss += matchup['PARTIAL_POSS']
                        except KeyError:
                            partial_poss = 0

                        # Matchup Difficulty
                        try:
                            player_off_load = off_player['STATS'][CURR_SEASON][season_type]['ADV']['OFFENSIVE_LOAD']
                        except KeyError:
                            player_off_load = 0

                        load += player_off_load * matchup['PARTIAL_POSS']

                        try:
                            avg_load = load / partial_poss
                        except ZeroDivisionError:
                            avg_load = 0

                        # DPS
                        try:
                            x_team_ppp = off_player['STATS'][CURR_SEASON][season_type]['ADV']['OFF_RATING'] / 100
                        except KeyError:
                            x_team_ppp = 0

                        x_team_pts += x_team_ppp * matchup['PARTIAL_POSS']

                        try:
                            total_x_ortg = x_team_pts / partial_poss * 100
                        except ZeroDivisionError:
                            total_x_ortg = 0

                        try:
                            net_saved = total_x_ortg - player['STATS'][CURR_SEASON][season_type]['ADV']['DEF_RATING']
                        except KeyError:
                            net_saved = 0

                    players_collection.update_one(
                        {'PERSON_ID': player['PERSON_ID']},
                        {'$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.MATCHUP_DIFFICULTY': avg_load,
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.DEF_IMPACT_EST': net_saved,
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.PARTIAL_POSS': partial_poss,
                        }
                        },
                    )
                except Exception as e:
                    logging.error(f'(Matchup Diff & DIE) Could not process {CURR_SEASON} for player {player["PERSON_ID"]}: {e}')
                    continue


# CHECKED
# TEAM-LEVEL
def update_versatility_score(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
    except Exception as e:
        logging.error(f'(Versatility) Unable to connect to MongoDB: {e}')
        exit(1)

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
    processed_count = 0
    i = 0

    # Update all ACTIVE players
    while processed_count < total_documents:
        with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'(Versatility) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                try:
                    if season_type == 'PLAYOFFS':
                        matchups = matchupsrollup.MatchupsRollup(proxy=PROXY, def_player_id_nullable=player['PERSON_ID'], season=CURR_SEASON, season_type_playoffs='Playoffs').get_normalized_dict()
                    else:
                        matchups = matchupsrollup.MatchupsRollup(proxy=PROXY, def_player_id_nullable=player['PERSON_ID'], season=CURR_SEASON).get_normalized_dict()

                    try:
                        t_G = matchups['MatchupsRollup'][0]['PERCENT_OF_TIME']
                    except Exception:
                        t_G = 0
                    try:
                        t_F = matchups['MatchupsRollup'][1]['PERCENT_OF_TIME']
                    except Exception:
                        t_F = 0
                    try:
                        t_C = matchups['MatchupsRollup'][2]['PERCENT_OF_TIME']
                    except Exception:
                        t_C = 0

                    score = 1 - ((abs(t_G - (1/3)) + abs(t_F - (1/3)) + abs(t_C - (1/3))) / (4/3))

                    players_collection.update_one(
                        {'PERSON_ID': player['PERSON_ID']},
                        {'$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.VERSATILITY_SCORE': score
                        }
                        },
                    )
                except Exception as e:
                    logging.error(f"(Versatility) Could not process Versatility Score for player {player['PERSON_ID']}: {e}")

                # Pause for a random time between 0.5 and 1 second
                time.sleep(random.uniform(0.5, 1.0))


# CHECKED
# TEAM-LEVEL
def update_adj_turnover_pct(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(cTOV) Unable to connect to MongoDB: {e}')
        exit(1)

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
    processed_count = 0
    i = 0

    # Update all ACTIVE players
    while processed_count < total_documents:
        with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'(cTOV) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                try:
                    try:
                        tov = (player['STATS'][CURR_SEASON][season_type]['BASIC']['TOV_PER_75'] / 75) * 100
                    except KeyError:
                        tov = 0
                    try:
                        off_load = player['STATS'][CURR_SEASON][season_type]['ADV']['OFFENSIVE_LOAD']
                    except KeyError:
                        off_load = 0

                    try:
                        adj_tov_pct = tov / off_load
                    except ZeroDivisionError:
                        adj_tov_pct = 0

                    players_collection.update_one(
                        {'PERSON_ID': player['PERSON_ID']},
                        {'$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.ADJ_TOV_PCT': adj_tov_pct
                        }
                        },
                    )
                except Exception as e:
                    logging.error(f'(cTOV) Could not process {CURR_SEASON} for player {player["PERSON_ID"]}: {e}')
                    continue


# CHECKED
# TEAM-LEVEL
def update_offensive_load(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(Offensive Load) Unable to connect to MongoDB: {e}')
        exit(1)

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
    processed_count = 0
    i = 0

    # Update all ACTIVE players
    while processed_count < total_documents:
        with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'(Offensive Load) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                try:
                    try:
                        ast = (player['STATS'][CURR_SEASON][season_type]['BASIC']['AST_PER_75'] / 75) * 100
                    except KeyError:
                        ast = 0
                    try:
                        tov = (player['STATS'][CURR_SEASON][season_type]['BASIC']['TOV_PER_75'] / 75) * 100
                    except KeyError:
                        tov = 0
                    try:
                        fga = (player['STATS'][CURR_SEASON][season_type]['BASIC']['FGA_PER_75'] / 75) * 100
                    except KeyError:
                        fga = 0
                    try:
                        fta = (player['STATS'][CURR_SEASON][season_type]['BASIC']['FTA_PER_75'] / 75) * 100
                    except KeyError:
                        fta = 0
                    try:
                        box_create = (player['STATS'][CURR_SEASON][season_type]['ADV']['BOX_CREATION'] / 75) * 100
                    except KeyError:
                        box_create = 0

                    off_load = ((ast - (0.38 * box_create)) * 0.75) + fga + (fta * 0.44) + box_create + tov

                    players_collection.update_one(
                        {'PERSON_ID': player['PERSON_ID']},
                        {'$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.OFFENSIVE_LOAD': off_load
                        }
                        },
                    )
                except Exception as e:
                    logging.error(f'(Offensive Load) Could not process {CURR_SEASON} for player {player["PERSON_ID"]}: {e}')
                    continue


# CHECKED
# TEAM-LEVEL
def update_box_creation(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(Box Creation) Unable to connect to MongoDB: {e}')
        exit(1)

    def calculate_3pt_proficiency(three_pa, three_p_percent):
        # Calculate the sigmoid part of the formula
        sigmoid_value = 2 / (1 + math.exp(-three_pa)) - 1

        # Multiply by the three-point percentage
        three_pt_proficiency = sigmoid_value * three_p_percent

        return three_pt_proficiency

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
    processed_count = 0
    i = 0

    # Update all ACTIVE players
    while processed_count < total_documents:
        with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'(Box Creation) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                try:
                    try:
                        ast = (player['STATS'][CURR_SEASON][season_type]['BASIC']['AST_PER_75'] / 75) * 100
                    except KeyError:
                        ast = 0
                    try:
                        pts = (player['STATS'][CURR_SEASON][season_type]['BASIC']['PTS_PER_75'] / 75) * 100
                    except KeyError:
                        pts = 0
                    try:
                        tov = (player['STATS'][CURR_SEASON][season_type]['BASIC']['TOV_PER_75'] / 75) * 100
                    except KeyError:
                        tov = 0
                    try:
                        fg3a = (player['STATS'][CURR_SEASON][season_type]['BASIC']['FG3A_PER_75'] / 75) * 100
                    except KeyError:
                        fg3a = 0
                    try:
                        fg3_pct = player['STATS'][CURR_SEASON][season_type]['BASIC']['FG3_PCT']
                    except KeyError:
                        fg3_pct = 0

                    three_pt_prof = calculate_3pt_proficiency(fg3a, fg3_pct)
                    box_create = ast * 0.1843 + (pts + tov) * 0.0969 - 2.3021 * three_pt_prof + 0.0582 * (
                            ast * (pts + tov) * three_pt_prof) - 1.1942
                    box_create = box_create * 0.75

                    players_collection.update_one(
                        {'PERSON_ID': player['PERSON_ID']},
                        {'$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.BOX_CREATION': box_create
                        }
                        },
                    )
                except Exception as e:
                    logging.error(f'(Box Creation) Could not process {CURR_SEASON} for player {player["PERSON_ID"]}: {e}')
                    continue


# CHECKED
# TEAM-LEVEL
def update_drive_stats(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(Drives) Unable to connect to MongoDB: {e}')
        exit(1)

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})
    processed_count = 0
    i = 0

    # Update all ACTIVE players
    while processed_count < total_documents:
        with players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'(Drives) Processing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                try:
                    try:
                        touches = player['STATS'][CURR_SEASON][season_type]['ADV']['TOUCHES']['TOUCHES']
                    except KeyError:
                        touches = 0
                    try:
                        drives = player['STATS'][CURR_SEASON][season_type]['ADV']['DRIVES']['DRIVES']
                    except KeyError:
                        drives = 0
                    try:
                        drive_pts = player['STATS'][CURR_SEASON][season_type]['ADV']['DRIVES']['DRIVE_PTS']
                    except KeyError:
                        drive_pts = 0
                    try:
                        drive_fga = player['STATS'][CURR_SEASON][season_type]['ADV']['DRIVES']['DRIVE_FGA']
                    except KeyError:
                        drive_fga = 0
                    try:
                        drive_fta = player['STATS'][CURR_SEASON][season_type]['ADV']['DRIVES']['DRIVE_FTA']
                    except KeyError:
                        drive_fta = 0
                    try:
                        drive_ftm = player['STATS'][CURR_SEASON][season_type]['ADV']['DRIVES']['DRIVE_FTM']
                    except KeyError:
                        drive_ftm = 0

                    # DRIVE TRUE SHOOTING
                    try:
                        drive_ts = drive_pts / (2 * (drive_fga + (0.44 * drive_fta)))
                    except ZeroDivisionError:
                        drive_ts = 0

                    # DRIVE FT/FGA
                    try:
                        drive_ft_per_fga = drive_ftm / drive_fga
                    except ZeroDivisionError:
                        drive_ft_per_fga = 0

                    # DRIVE %
                    try:
                        drives_per_touch = drives / touches
                    except ZeroDivisionError:
                        drives_per_touch = 0

                    players_collection.update_one(
                        {'PERSON_ID': player['PERSON_ID']},
                        {'$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.DRIVES.DRIVE_TS_PCT': drive_ts,
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.DRIVES.DRIVE_FT_PER_FGA': drive_ft_per_fga,
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.DRIVES.DRIVES_PER_TOUCH': drives_per_touch
                        }
                        },
                    )
                except Exception as e:
                    logging.error(f'(Drives) Could not process {CURR_SEASON} for player {player["PERSON_ID"]}: {e}')
                    continue


# CHECKED
# TEAM-LEVEL
def update_touches_breakdown(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(Touches Breakdown) Unable to connect to MongoDB: {e}')
        exit(1)

    docs = players_collection.count_documents({"ROSTERSTATUS": "Active", "TEAM_ID": team_id})

    # Update each document in the collection
    for i, player in enumerate(players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})):
        logging.info(f'(Touches Breakdown) Processing {i} of {docs}...')
        try:
            # Extract the values needed for calculation
            try:
                fga = player['STATS'][CURR_SEASON][season_type]['BASIC'].get('FGA', 0)
            except KeyError:
                fga = 0
            try:
                passes = player['STATS'][CURR_SEASON][season_type]['ADV']['PASSING'].get('PASSES_MADE', 0)
            except KeyError:
                passes = 0
            try:
                turnovers = player['STATS'][CURR_SEASON][season_type]['BASIC'].get('TOV', 0)
            except KeyError:
                turnovers = 0
            try:
                fouled = player['STATS'][CURR_SEASON][season_type]['BASIC'].get('PFD', 0)
            except KeyError:
                fouled = 0
            try:
                touches = player['STATS'][CURR_SEASON][season_type]['ADV']['TOUCHES'].get('TOUCHES', 1)
            except KeyError:
                touches = 0

            # Calculate touch splits
            try:
                percent_shot = fga / touches
                percent_pass = passes / touches
                percent_turnover = turnovers / touches
                percent_fouled = fouled / touches
            except ZeroDivisionError:
                percent_shot = 0
                percent_pass = 0
                percent_turnover = 0
                percent_fouled = 0

            # Update the document with the new field
            players_collection.update_one(
                {'PERSON_ID': player['PERSON_ID']},
                {'$set': {f'STATS.{CURR_SEASON}.{season_type}.ADV.TOUCHES.FGA_PER_TOUCH': percent_shot,
                          f'STATS.{CURR_SEASON}.{season_type}.ADV.TOUCHES.PASSES_PER_TOUCH': percent_pass,
                          f'STATS.{CURR_SEASON}.{season_type}.ADV.TOUCHES.TOV_PER_TOUCH': percent_turnover,
                          f'STATS.{CURR_SEASON}.{season_type}.ADV.TOUCHES.PFD_PER_TOUCH': percent_fouled,
                          }
                 }
            )
        except Exception as e:
            print(f"(Touches Breakdown) Error updating Touches Breakdown for player {player['PERSON_ID']}: {e}")
            continue


# CHECKED
# TEAM-LEVEL
def update_shot_distribution(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(Shot Distribution) Unable to connect to MongoDB: {e}')
        exit(1)

    # Set the batch size
    batch_size = 25

    # Get the total number of ACTIVE players
    num_players = players_collection.count_documents({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id})

    # Process documents in batches
    for batch_start in range(0, num_players, batch_size):
        logging.info(f'(Shot Distribution) Processing batch starting at {batch_start}')
        players = players_collection.find({'ROSTERSTATUS': 'Active', 'TEAM_ID': team_id}, {'PERSON_ID': 1, 'TEAM_ID': 1, '_id': 0}).skip(batch_start).limit(batch_size)

        for i, player in enumerate(players):
            logging.info(f'(Shot Distribution) Processing {i + 1} of {num_players} players...')

            try:
                player_id = player['PERSON_ID']
            except KeyError:
                continue

            if season_type == 'PLAYOFFS':
                player_shooting = playerdashptshots.PlayerDashPtShots(proxy=PROXY, team_id=team_id,
                                                                      player_id=player_id,
                                                                      season=CURR_SEASON,
                                                                      season_type_all_star='Playoffs'
                                                                      ).get_normalized_dict()
            else:
                try:
                    player_shooting = playerdashptshots.PlayerDashPtShots(proxy=PROXY, team_id=team_id,
                                                                          player_id=player_id,
                                                                          season=CURR_SEASON
                                                                          ).get_normalized_dict()
                except Exception:
                    player_shooting = {'GeneralShooting': [], 'ClosestDefenderShooting': []}

            shot_type = player_shooting['GeneralShooting']
            closest_defender = player_shooting['ClosestDefenderShooting']

            try:
                if shot_type:
                    for j in range(len(shot_type)):
                        shot_type_keys = list(shot_type[j].keys())[6:]

                        players_collection.update_one(
                            {'PERSON_ID': player_id},
                            {'$set': {
                                f'STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type[j]["SHOT_TYPE"]}': {
                                    key: shot_type[j][key] for key in shot_type_keys}
                            }
                            },
                        )
                if closest_defender:
                    for j in range(len(closest_defender)):
                        closest_defender_keys = list(closest_defender[j].keys())[6:]

                        players_collection.update_one(
                            {'PERSON_ID': player_id},
                            {'$set': {
                                f'STATS.{CURR_SEASON}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender[j]["CLOSE_DEF_DIST_RANGE"]}': {
                                    key: closest_defender[j][key] for key in closest_defender_keys}
                            }
                            },
                        )
            except Exception as e:
                logging.error(f'(Shot Distribution) Unable to add stats for {player_id}: {e}')
                continue


# CHECKED
# TEAM-LEVEL
def update_player_tracking_stats(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
    except Exception as e:
        logging.error(f'(Player Tracking) Unable to connect to MongoDB: {e}')
        exit(1)

    if season_type == 'PLAYOFFS':
        player_touches = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Possessions',
                                                             season=CURR_SEASON,
                                                             season_type_all_star='Playoffs').get_normalized_dict()[
            'LeagueDashPtStats']
        player_passing = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Passing',
                                                             season=CURR_SEASON,
                                                             season_type_all_star='Playoffs').get_normalized_dict()[
            'LeagueDashPtStats']
        player_drives = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Drives',
                                                            season=CURR_SEASON,
                                                            season_type_all_star='Playoffs').get_normalized_dict()[
            'LeagueDashPtStats']
        player_rebounding = \
            leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Rebounding',
                                                season=CURR_SEASON,
                                                season_type_all_star='Playoffs').get_normalized_dict()[
                'LeagueDashPtStats']
        player_speed_dist = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='SpeedDistance',
                                                                season=CURR_SEASON,
                                                                season_type_all_star='Playoffs').get_normalized_dict()[
            'LeagueDashPtStats']
    else:
        try:
            player_touches = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Possessions',
                                                                 season=CURR_SEASON).get_normalized_dict()[
                'LeagueDashPtStats']
        except Exception:
            player_touches = []

        try:
            player_passing = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Passing',
                                                                 season=CURR_SEASON).get_normalized_dict()[
                'LeagueDashPtStats']
        except Exception:
            player_passing = []

        try:
            player_drives = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Drives',
                                                                season=CURR_SEASON).get_normalized_dict()[
                'LeagueDashPtStats']
        except Exception:
            player_drives = []

        try:
            player_rebounding = \
                leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='Rebounding',
                                                    season=CURR_SEASON).get_normalized_dict()[
                    'LeagueDashPtStats']
        except Exception:
            player_rebounding = []

        try:
            player_speed_dist = leaguedashptstats.LeagueDashPtStats(proxy=PROXY, player_or_team='Player', team_id_nullable=team_id, pt_measure_type='SpeedDistance',
                                                                    season=CURR_SEASON).get_normalized_dict()[
                'LeagueDashPtStats']
        except Exception:
            player_speed_dist = []

    num_players = len(player_speed_dist)

    logging.info(f'(Player Tracking) Processing {num_players} for season {CURR_SEASON} {season_type}...')

    touch_keys = list(player_touches[0].keys())[9:15] if len(player_touches) > 0 else []
    passing_keys = list(player_passing[0].keys())[8:] if len(player_passing) > 0 else []
    drives_keys = list(player_drives[0].keys())[8:] if len(player_drives) > 0 else []
    rebounding_keys = list(player_rebounding[0].keys())[8:] if len(player_rebounding) > 0 else []
    speed_dist_keys = list(player_speed_dist[0].keys())[8:] if len(player_speed_dist) > 0 else []

    # Initialize dictionaries for each data type
    player_data = defaultdict(lambda: {'touches': {}, 'passing': {}, 'drives': {}, 'rebounding': {}, 'speed_dist': {}})

    # Fill in the player data from each list
    if player_touches:
        for player in player_touches:
            player_id = player['PLAYER_ID']
            player_data[player_id]['touches'] = {key: player[key] for key in touch_keys}
    else:
        for player_id in player_data.keys():
            player_data[player_id]['touches'] = {}

    if player_passing:
        for player in player_passing:
            player_id = player['PLAYER_ID']
            player_data[player_id]['passing'] = {key: player[key] for key in passing_keys}
    else:
        for player_id in player_data.keys():
            player_data[player_id]['passing'] = {}

    if player_drives:
        for player in player_drives:
            player_id = player['PLAYER_ID']
            player_data[player_id]['drives'] = {key: player[key] for key in drives_keys}
    else:
        for player_id in player_data.keys():
            player_data[player_id]['drives'] = {}

    if player_rebounding:
        for player in player_rebounding:
            player_id = player['PLAYER_ID']
            player_data[player_id]['rebounding'] = {key: player[key] for key in rebounding_keys}
    else:
        for player_id in player_data.keys():
            player_data[player_id]['rebounding'] = {}

    if player_speed_dist:
        for player in player_speed_dist:
            player_id = player['PLAYER_ID']
            player_data[player_id]['speed_dist'] = {key: player[key] for key in speed_dist_keys}
    else:
        for player_id in player_data.keys():
            player_data[player_id]['speed_dist'] = {}

    # Update the MongoDB collection
    for player_id, data in player_data.items():
        try:
            players_collection.update_one(
                {'PERSON_ID': player_id},
                {'$set': {
                    f'STATS.{CURR_SEASON}.{season_type}.ADV.TOUCHES': data['touches'],
                    f'STATS.{CURR_SEASON}.{season_type}.ADV.PASSING': data['passing'],
                    f'STATS.{CURR_SEASON}.{season_type}.ADV.DRIVES': data['drives'],
                    f'STATS.{CURR_SEASON}.{season_type}.ADV.REBOUNDING': data['rebounding'],
                    f'STATS.{CURR_SEASON}.{season_type}.HUSTLE.SPEED': data['speed_dist'],
                }},
            )
        except Exception as e:
            logging.error(f'(Player Tracking) Unable to add stats for player with ID {player_id}: {e}')
            continue


# CHECKED
# TEAM-LEVEL
def update_three_and_ft_rate(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
    except Exception as e:
        logging.error(f'(3PAr & FTAr) Unable to connect to MongoDB: {e}')
        exit(1)

    docs = players_collection.count_documents({"ROSTERSTATUS": "Active", "TEAM_ID": team_id})

    # Update each document in the collection
    for i, player in enumerate(players_collection.find({"ROSTERSTATUS": "Active", "TEAM_ID": team_id})):
        logging.info(f'(3PAr & FTAr) Processing {i + 1} of {docs}...')
        try:
            # Extract the values needed for calculation
            try:
                fg3a = player['STATS'][CURR_SEASON][season_type]['BASIC'].get('FG3A', 0)
            except KeyError:
                fg3a = 0
            try:
                fta = player['STATS'][CURR_SEASON][season_type]['BASIC'].get('FTA', 0)
            except KeyError:
                fta = 0
            try:
                ftm = player['STATS'][CURR_SEASON][season_type]['BASIC'].get('FTM', 0)
            except KeyError:
                ftm = 0
            try:
                fga = player['STATS'][CURR_SEASON][season_type]['BASIC'].get('FGA', 0)
            except KeyError:
                fga = 0

            # Calculate 3PAr, FTAr, FT/FGA
            try:
                three_pt_rate = fg3a / fga
                fta_rate = fta / fga
                ft_per_fga = ftm / fga
            except ZeroDivisionError:
                three_pt_rate = 0
                fta_rate = 0
                ft_per_fga = 0

            # Update the document with the new field
            players_collection.update_one(
                {'PERSON_ID': player['PERSON_ID']},
                {'$set': {f'STATS.{CURR_SEASON}.{season_type}.BASIC.3PAr': three_pt_rate,
                          f'STATS.{CURR_SEASON}.{season_type}.BASIC.FTAr': fta_rate,
                          f'STATS.{CURR_SEASON}.{season_type}.BASIC.FT_PER_FGA': ft_per_fga}
                 }
            )

        except Exception as e:
            print(f"(3PAr & FTAr) Error adding 3PAr and FTAr for player {player['PERSON_ID']}: {e}")
            continue


# CHECKED
# TEAM-LEVEL
def update_poss_per_game(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
    except Exception as e:
        logging.error(f'(Poss Per Game) Unable to connect to MongoDB: {e}')
        exit(1)

    docs = players_collection.count_documents({"ROSTERSTATUS": "Active", "TEAM_ID": team_id})

    # Update all ACTIVE players
    for i, player in enumerate(players_collection.find({"ROSTERSTATUS": "Active", "TEAM_ID": team_id})):
        logging.info(f'(Poss Per Game) Processing {i} of {docs}...')
        try:
            # Extract the values needed for calculation
            try:
                poss = player['STATS'][CURR_SEASON][season_type]['ADV'].get('POSS', 0)
            except KeyError:
                poss = 0
            try:
                gp = player['STATS'][CURR_SEASON][season_type]['ADV'].get('GP', 0)
            except KeyError:
                gp = 0

            # Calculate POSS PER GAME
            try:
                poss_per_game = poss / gp
            except ZeroDivisionError:
                poss_per_game = 0

            # Update the document with the new field
            players_collection.update_one(
                {'PERSON_ID': player['PERSON_ID']},
                {'$set': {f'STATS.{CURR_SEASON}.{season_type}.ADV.POSS_PER_GM': poss_per_game}
                 }
            )

        except Exception as e:
            print(f"(Poss Per Game) Error calculating Poss per Game for player {player['PERSON_ID']}: {e}")
            continue


# CHECKED
# TEAM-LEVEL
def update_player_on_off(season_type, team_id):
    try:
        # Configure logging
        logging.basicConfig(level=logging.INFO)

        # Replace with your MongoDB connection string
        client = MongoClient(URI)
        db = client.splash
        players_collection = db.nba_players
        teams_collection = db.nba_teams
    except Exception as e:
        logging.error(f'(Player On/Off) Unable to connect to MongoDB: {e}')
        exit(1)

    logging.info(f'(Player On/Off) Processing season {CURR_SEASON}...')
    for team in teams_collection.find({'TEAM_ID': team_id}, {'TEAM_ID': 1, '_id': 0}):
        if team['TEAM_ID'] == 0:
            continue

        logging.info(f'(Player On/Off) Processing team {team["TEAM_ID"]}...')

        # PLAYOFFS
        if season_type == 'PLAYOFFS':
            player_on_off = teamplayeronoffdetails.TeamPlayerOnOffDetails(proxy=PROXY, team_id=team['TEAM_ID'], season=CURR_SEASON,
                                                                          season_type_all_star='Playoffs',
                                                                          measure_type_detailed_defense='Advanced').get_normalized_dict()

            player_on = player_on_off['PlayersOnCourtTeamPlayerOnOffDetails']
            player_off = player_on_off['PlayersOffCourtTeamPlayerOnOffDetails']

            keys = ['OFF_RATING', 'DEF_RATING', 'NET_RATING']
            for i in range(len(player_on)):
                player_id = player_on[i]['VS_PLAYER_ID']  # Player ID

                for key in keys:
                    try:
                        on_value = player_on[i][key]
                    except KeyError:
                        on_value = 0

                    try:
                        off_value = player_off[i][key]
                    except KeyError:
                        off_value = 0

                    on_off_value = on_value - off_value

                    # Update the document with the new field
                    players_collection.update_one(
                        {'PERSON_ID': player_id},
                        {'$set': {f'STATS.{CURR_SEASON}.PLAYOFFS.ADV.{key}_ON_OFF': on_off_value}}
                    )
            logging.info(f'(Player On/Off) Added data for {len(player_on)} players for {CURR_SEASON}.')

        # REGULAR SEASON
        else:
            player_on_off = teamplayeronoffdetails.TeamPlayerOnOffDetails(proxy=PROXY, team_id=team['TEAM_ID'], season=CURR_SEASON,
                                                                          measure_type_detailed_defense='Advanced').get_normalized_dict()

            player_on = player_on_off['PlayersOnCourtTeamPlayerOnOffDetails']
            player_off = player_on_off['PlayersOffCourtTeamPlayerOnOffDetails']

            keys = ['OFF_RATING', 'DEF_RATING', 'NET_RATING']
            for i in range(len(player_on)):
                player_id = player_on[i]['VS_PLAYER_ID']  # Player ID

                for key in keys:
                    try:
                        on_value = player_on[i][key]
                    except KeyError:
                        on_value = 0

                    try:
                        off_value = player_off[i][key]
                    except KeyError:
                        off_value = 0

                    on_off_value = on_value - off_value

                    stat_name = f'{key}_ON_OFF'

                    try:
                        poss = player_on[i]['POSS']  # Possessions played with team
                    except KeyError:
                        poss = 0

                    # Check player's existing stats for this season
                    existing_stats = players_collection.find_one(
                        {'PERSON_ID': player_id},
                        {'_id': 0, f'STATS.{CURR_SEASON}.{season_type}.ADV.{key}_ON_OFF': 1,
                         f'STATS.{CURR_SEASON}.{season_type}.ADV.{stat_name}_POSS': 1}
                    )

                    # If existing, calculate weighted average on/off by possessions played for each team.
                    if existing_stats and stat_name in existing_stats['STATS'][CURR_SEASON][season_type]['ADV']:
                        existing_on_off = existing_stats['STATS'][CURR_SEASON][season_type]['ADV'][stat_name]
                        existing_poss = existing_stats['STATS'][CURR_SEASON][season_type]['ADV'][f'{stat_name}_POSS']

                        # Calculate weighted average
                        try:
                            new_on_off_value = ((existing_on_off * existing_poss) + (on_off_value * poss)) / (
                                    existing_poss + poss)
                        except ZeroDivisionError:
                            new_on_off_value = 0

                        new_poss = existing_poss + poss
                    else:
                        new_on_off_value = on_off_value
                        new_poss = poss

                    # Update the document with the new field
                    players_collection.update_one(
                        {'PERSON_ID': player_id},
                        {'$set': {
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.{stat_name}_POSS': new_poss,
                            f'STATS.{CURR_SEASON}.{season_type}.ADV.{stat_name}': new_on_off_value
                        }
                        }
                    )

        logging.info(f'(Player On/Off) Added data for {len(player_on)} players for {CURR_SEASON} {season_type}.')


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(URI)
    db = client.splash
    players_collection = db.nba_players
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

    # logging.info("\nAdding Player On/Off data...\n")
    # player_on_off(season_types[0])
    # player_on_off(season_types[1])

    # logging.info("\nAdding Poss Per Game...\n")
    # poss_per_game(season_types[0])
    # poss_per_game(season_types[1])

    # logging.info("\nAdding 3PAr and FTAr...\n")
    # three_and_ft_rate(season_types[0])
    # three_and_ft_rate(season_types[1])

    # logging.info("\nAdding Player Tracking data...\n")
    # player_tracking_stats(season_types[0])
    # player_tracking_stats(season_types[1])

    # logging.info("\nAdding Touches Breakdown...\n")
    # touches_breakdown(season_types[0])
    # touches_breakdown(season_types[1])

    # logging.info("\nAdding Shot Distribution...\n")
    # shot_distribution(season_types[0])
    # shot_distribution(season_types[1])

    # logging.info("\nAdding Drives...\n")
    # drive_stats(season_types[0])
    # drive_stats(season_types[1])

    # logging.info("\nAdding Scoring Breakdown...\n")
    # scoring_breakdown_and_pct_unassisted(season_types[0])
    # scoring_breakdown_and_pct_unassisted(season_types[1])

    # logging.info("\nAdding Box Creation...\n")
    # box_creation(season_types[0])
    # box_creation(season_types[1])

    # logging.info("\nAdding Offensive Load...\n")
    # offensive_load(season_types[0])
    # offensive_load(season_types[1])

    # logging.info("\nAdding cTOV...\n")
    # adj_turnover_pct(season_types[0])
    # adj_turnover_pct(season_types[1])

    # logging.info("\nAdding DPS...\n")
    # defensive_points_saved(season_types[0])
    # defensive_points_saved(season_types[1])

    # logging.info("\nAdding Versatility Score...\n")
    # versatility_score(season_types[0])
    # versatility_score(season_types[1])

    # logging.info("\nAdding Matchup Difficulty...\n")
    # matchup_difficulty_and_dps(season_types[0])
    # matchup_difficulty_and_dps(season_types[1])

    logging.info("Update complete.")
