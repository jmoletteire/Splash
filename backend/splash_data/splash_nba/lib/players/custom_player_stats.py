import math
import random
import time

from nba_api.stats.endpoints import teamplayeronoffdetails, leaguedashptstats, playerdashptshots, leagueseasonmatchups, \
    leaguedashplayerstats, matchupsrollup
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging
from collections import defaultdict

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


def scoring_breakdown_and_pct_unassisted(season_type):
    for season in seasons:
        if season_type == 'PLAYOFFS':
            player_uast = leaguedashplayerstats.LeagueDashPlayerStats(measure_type_detailed_defense='Scoring',
                                                                      season=season,
                                                                      season_type_all_star='Playoffs').get_normalized_dict()[
                'LeagueDashPlayerStats']
        else:
            player_uast = leaguedashplayerstats.LeagueDashPlayerStats(measure_type_detailed_defense='Scoring',
                                                                      season=season).get_normalized_dict()[
                'LeagueDashPlayerStats']

        num_players = len(player_uast)

        logging.info(f'Processing {num_players} for season {season} {season_type}...')

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
                    {'PERSON_ID': player_id},
                    {'$set': {
                        f'STATS.{season}.{season_type}.ADV.SCORING_BREAKDOWN': data['scoring'],
                    }},
                )
            except Exception as e:
                logging.error(f'Unable to add stats for player with ID {player_id}: {e}')
                continue


def matchup_difficulty_and_dps(season_type):
    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season in stats.keys():
                    if season < '2017-18':
                        continue

                    logging.info(f'Processing {season}...')
                    try:
                        if season_type == 'REGULAR SEASON':
                            data = leagueseasonmatchups.LeagueSeasonMatchups(season=season,
                                                                             def_player_id_nullable=player['PERSON_ID'])
                        else:
                            data = leagueseasonmatchups.LeagueSeasonMatchups(season=season,
                                                                             season_type_playoffs='Playoffs',
                                                                             def_player_id_nullable=player['PERSON_ID'])

                        raw_data = data.get_normalized_dict()['SeasonMatchups']

                        if len(raw_data) == 0:
                            continue

                        load = 0  # Matchup Difficulty
                        x_team_pts = 0  # DPS
                        partial_poss = 0

                        for matchup in raw_data:
                            off_player = players_collection.find_one(
                                {'PERSON_ID': matchup['OFF_PLAYER_ID']},
                                {
                                    f'STATS.{season}.{season_type}.ADV.OFFENSIVE_LOAD': 1,
                                    f'STATS.{season}.{season_type}.ADV.OFF_RATING': 1,
                                    '_id': 0
                                }
                            )

                            partial_poss += matchup['PARTIAL_POSS']

                            # Matchup Difficulty
                            player_off_load = off_player['STATS'][season][season_type]['ADV']['OFFENSIVE_LOAD']
                            load += player_off_load * matchup['PARTIAL_POSS']

                            avg_load = load / partial_poss

                            # DPS
                            x_team_ppp = off_player['STATS'][season][season_type]['ADV']['OFF_RATING'] / 100
                            x_team_pts += x_team_ppp * matchup['PARTIAL_POSS']

                            total_x_ortg = x_team_pts / partial_poss * 100
                            net_saved = total_x_ortg - player['STATS'][season][season_type]['ADV']['DEF_RATING']

                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.MATCHUP_DIFFICULTY': avg_load,
                                f'STATS.{season}.{season_type}.ADV.DEF_IMPACT_EST': net_saved,
                            }
                            },
                        )
                    except Exception as e:
                        logging.error(f'Could not process {season} for player {player["PERSON_ID"]}: {e}')
                        continue


def versatility_score(season_type):
    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 750
    i = 750

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season, season_stats in stats.items():
                    if season < '2017-18':
                        continue
                    elif season_type not in season_stats.keys():
                        continue
                    try:
                        if season_type == 'PLAYOFFS':
                            matchups = matchupsrollup.MatchupsRollup(def_player_id_nullable=player['PERSON_ID'], season=season, season_type_playoffs='Playoffs').get_normalized_dict()
                        else:
                            matchups = matchupsrollup.MatchupsRollup(def_player_id_nullable=player['PERSON_ID'], season=season).get_normalized_dict()

                        t_G = matchups['MatchupsRollup'][0]['PERCENT_OF_TIME']
                        t_F = matchups['MatchupsRollup'][1]['PERCENT_OF_TIME']
                        t_C = matchups['MatchupsRollup'][2]['PERCENT_OF_TIME']

                        score = 1 - ((abs(t_G - (1/3)) + abs(t_F - (1/3)) + abs(t_C - (1/3))) / (4/3))

                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.VERSATILITY_SCORE': score
                            }
                            },
                        )
                    except Exception as e:
                        logging.error(f"Could not process Versatility Score for player {player['PERSON_ID']}: {e}")

                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(random.uniform(0.5, 1.0))


def defensive_points_saved(season_type):
    def expected_pts(player_data, matchup_data):
        try:
            xFTM = (player_data.get('FTA_PER_75', 0) / 75) * matchup_data['PARTIAL_POSS'] * player_data.get('FT_PCT', 0)
        except ZeroDivisionError:
            xFTM = 0

        try:
            xFG2M = ((player_data.get('FGA_PER_75', 0) - player_data.get('FG3A_PER_75', 0)) / 75) * matchup_data[
                'PARTIAL_POSS'] * (
                            (player_data.get('FGM', 0) - player_data.get('FG3M', 0)) / (
                            player_data.get('FGA', 0) - player_data.get('FG3A', 0)))
        except ZeroDivisionError:
            xFG2M = 0

        try:
            xFG3M = (player_data.get('FG3A_PER_75', 0) / 75) * matchup_data['PARTIAL_POSS'] * player_data.get('FG3_PCT',
                                                                                                              0)
        except ZeroDivisionError:
            xFG3M = 0

        try:
            xTOV = (player_data.get('TOV_PER_75', 0) / 75) * matchup_data['PARTIAL_POSS']
        except ZeroDivisionError:
            xTOV = 0

        try:
            xBLKA = (player_data.get('BLKA_PER_75', 0) / 75) * matchup_data['PARTIAL_POSS']
        except ZeroDivisionError:
            xBLKA = 0

        xPTS = ((xFG2M * 2) + (xFG3M * 3) + xFTM) - (xBLKA * player_data['PPS']) - (xTOV * player_data['PPP'])

        return xPTS

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season in stats.keys():
                    if season < '2017-18':
                        continue

                    logging.info(f'Processing {season}...')
                    try:
                        if season_type == 'REGULAR SEASON':
                            data = leagueseasonmatchups.LeagueSeasonMatchups(season=season,
                                                                             def_player_id_nullable=player['PERSON_ID'])
                        else:
                            data = leagueseasonmatchups.LeagueSeasonMatchups(season=season,
                                                                             season_type_playoffs='Playoffs',
                                                                             def_player_id_nullable=player['PERSON_ID'])

                        raw_data = data.get_normalized_dict()['SeasonMatchups']
                        dps = 0
                        partial_poss = 0

                        for matchup in raw_data:
                            off_player = players_collection.find_one(
                                {'PERSON_ID': matchup['OFF_PLAYER_ID']},
                                {
                                    f'STATS.{season}.{season_type}.BASIC.FGM': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FGA': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FG3M': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FG3A': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FT_PCT': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FG3_PCT': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FGA_PER_75': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FG3A_PER_75': 1,
                                    f'STATS.{season}.{season_type}.BASIC.FTA_PER_75': 1,
                                    f'STATS.{season}.{season_type}.BASIC.TOV_PER_75': 1,
                                    f'STATS.{season}.{season_type}.BASIC.BLKA_PER_75': 1,
                                    f'STATS.{season}.{season_type}.BASIC.PTS': 1,
                                    f'STATS.2023-24.{season_type}.ADV.OFF_RATING': 1,
                                    '_id': 0
                                }
                            )

                            player_stats = off_player['STATS'][season][season_type]['BASIC']

                            try:
                                player_stats['PPS'] = off_player['STATS'][season][season_type]['BASIC']['PTS'] / \
                                                      off_player['STATS'][season][season_type]['BASIC']['FGA']
                            except ZeroDivisionError:
                                player_stats['PPS'] = 1

                            try:
                                player_stats['PPP'] = off_player['STATS']['2023-24'][season_type]['ADV'][
                                                          'OFF_RATING'] / 100
                            except ZeroDivisionError:
                                player_stats['PPP'] = 1

                            x_pts = expected_pts(player_stats, matchup)

                            player_pts = matchup['PLAYER_PTS']
                            blk_pts = matchup['MATCHUP_BLK'] * player_stats['PPS']
                            tov_pts = matchup['MATCHUP_TOV'] * player_stats['PPP']

                            dps += (x_pts - (player_pts - blk_pts - tov_pts))
                            partial_poss += matchup['PARTIAL_POSS']

                        try:
                            dps_per_75 = (dps / partial_poss) * 75
                        except ZeroDivisionError:
                            dps_per_75 = 0

                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.DEF_PTS_SAVED': dps,
                                f'STATS.{season}.{season_type}.ADV.PARTIAL_POSS': partial_poss,
                                f'STATS.{season}.{season_type}.ADV.DPS_PER_75': dps_per_75,
                            }
                            },
                        )
                    except Exception as e:
                        logging.error(f'Could not process {season} for player {player["PERSON_ID"]}: {e}')
                        continue


def adj_turnover_pct(season_type):
    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season, season_stats in stats.items():
                    if season_type not in season_stats.keys():
                        continue

                    try:
                        tov = (season_stats[season_type]['BASIC']['TOV_PER_75'] / 75) * 100
                        off_load = season_stats[season_type]['ADV']['OFFENSIVE_LOAD']

                        adj_tov_pct = tov / off_load

                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.ADJ_TOV_PCT': adj_tov_pct
                            }
                            },
                        )
                    except Exception as e:
                        logging.error(f'Could not process {season} for player {player["PERSON_ID"]}: {e}')
                        continue


def offensive_load(season_type):
    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season, season_stats in stats.items():
                    if season_type not in season_stats.keys():
                        continue

                    try:
                        ast = (season_stats[season_type]['BASIC']['AST_PER_75'] / 75) * 100
                        tov = (season_stats[season_type]['BASIC']['TOV_PER_75'] / 75) * 100
                        fga = (season_stats[season_type]['BASIC']['FGA_PER_75'] / 75) * 100
                        fta = (season_stats[season_type]['BASIC']['FTA_PER_75'] / 75) * 100
                        box_create = (season_stats[season_type]['ADV']['BOX_CREATION'] / 75) * 100

                        off_load = ((ast - (0.38 * box_create)) * 0.75) + fga + (fta * 0.44) + box_create + tov

                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.OFFENSIVE_LOAD': off_load
                            }
                            },
                        )
                    except Exception as e:
                        logging.error(f'Could not process {season} for player {player["PERSON_ID"]}: {e}')
                        continue


def box_creation(season_type):
    def calculate_3pt_proficiency(three_pa, three_p_percent):
        # Calculate the sigmoid part of the formula
        sigmoid_value = 2 / (1 + math.exp(-three_pa)) - 1

        # Multiply by the three-point percentage
        three_pt_proficiency = sigmoid_value * three_p_percent

        return three_pt_proficiency

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season, season_stats in stats.items():
                    if season_type not in season_stats.keys():
                        continue

                    try:
                        ast = (season_stats[season_type]['BASIC']['AST_PER_75'] / 75) * 100
                        pts = (season_stats[season_type]['BASIC']['PTS_PER_75'] / 75) * 100
                        tov = (season_stats[season_type]['BASIC']['TOV_PER_75'] / 75) * 100
                        fg3a = (season_stats[season_type]['BASIC']['FG3A_PER_75'] / 75) * 100
                        fg3_pct = season_stats[season_type]['BASIC']['FG3_PCT']

                        three_pt_prof = calculate_3pt_proficiency(fg3a, fg3_pct)
                        box_create = ast * 0.1843 + (pts + tov) * 0.0969 - 2.3021 * three_pt_prof + 0.0582 * (
                                    ast * (pts + tov) * three_pt_prof) - 1.1942
                        box_create = box_create * 0.75

                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.BOX_CREATION': box_create
                            }
                            },
                        )
                    except Exception as e:
                        logging.error(f'Could not process {season} for player {player["PERSON_ID"]}: {e}')
                        continue


def drive_stats(season_type):
    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season, season_stats in stats.items():
                    if season < '2013-2014':
                        break

                    if season_type not in season_stats.keys():
                        continue

                    try:
                        touches = season_stats[season_type]['ADV']['TOUCHES']['TOUCHES']
                        drives = season_stats[season_type]['ADV']['DRIVES']['DRIVES']
                        drive_pts = season_stats[season_type]['ADV']['DRIVES']['DRIVE_PTS']
                        drive_fga = season_stats[season_type]['ADV']['DRIVES']['DRIVE_FGA']
                        drive_fta = season_stats[season_type]['ADV']['DRIVES']['DRIVE_FTA']
                        drive_ftm = season_stats[season_type]['ADV']['DRIVES']['DRIVE_FTM']

                        try:
                            drive_ts = drive_pts / (2 * (drive_fga + (0.44 * drive_fta)))
                        except ZeroDivisionError:
                            drive_ts = 0

                        try:
                            drive_ft_per_fga = drive_ftm / drive_fga
                        except ZeroDivisionError:
                            drive_ft_per_fga = 0

                        try:
                            drives_per_touch = drives / touches
                        except ZeroDivisionError:
                            drives_per_touch = 0

                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_TS_PCT': drive_ts,
                                f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVE_FT_PER_FGA': drive_ft_per_fga,
                                f'STATS.{season}.{season_type}.ADV.DRIVES.DRIVES_PER_TOUCH': drives_per_touch
                            }
                            },
                        )
                    except Exception as e:
                        logging.error(f'Could not process {season} for player {player["PERSON_ID"]}: {e}')
                        continue


def touches_breakdown(season_type):
    # Update each document in the collection
    for i, player in enumerate(players_collection.find()):
        logging.info(f'Processing {i} of {players_collection.count_documents({})}...')
        if 'STATS' in player:
            for season in player['STATS']:
                if season in seasons:
                    try:
                        # Extract the values needed for calculation
                        fga = player['STATS'][season][season_type]['BASIC'].get('FGA', 0)
                        passes = player['STATS'][season][season_type]['ADV']['PASSING'].get('PASSES_MADE', 0)
                        turnovers = player['STATS'][season][season_type]['BASIC'].get('TOV', 0)
                        fouled = player['STATS'][season][season_type]['BASIC'].get('PFD', 0)
                        touches = player['STATS'][season][season_type]['ADV']['TOUCHES'].get('TOUCHES',
                                                                                             1)  # Avoid division by zero

                        # Calculate touch splits
                        percent_shot = fga / touches
                        percent_pass = passes / touches
                        percent_turnover = turnovers / touches
                        percent_fouled = fouled / touches

                        # Update the document with the new field
                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {f'STATS.{season}.{season_type}.ADV.TOUCHES.FGA_PER_TOUCH': percent_shot,
                                      f'STATS.{season}.{season_type}.ADV.TOUCHES.PASSES_PER_TOUCH': percent_pass,
                                      f'STATS.{season}.{season_type}.ADV.TOUCHES.TOV_PER_TOUCH': percent_turnover,
                                      f'STATS.{season}.{season_type}.ADV.TOUCHES.PFD_PER_TOUCH': percent_fouled,
                                      }
                             }
                        )
                    except Exception as e:
                        print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                        continue


def shot_distribution(season_type):
    avail_seasons = [
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
    ]

    # Set the batch size
    batch_size = 25  # Adjust this value based on your needs and system performance

    # Get the total number of documents
    num_players = players_collection.count_documents({})

    # Process documents in batches
    for batch_start in range(0, num_players, batch_size):
        logging.info(f'Processing batch starting at {batch_start}')
        players = players_collection.find().skip(batch_start).limit(batch_size)

        for i, player in enumerate(players):
            try:
                logging.info(f'Processing {i + 1} of {num_players} players...')

                stats = player.get('STATS', None)

                if stats is None:
                    continue

                player_id = player['PERSON_ID']

                for season in stats:
                    if season in avail_seasons:
                        team_id = stats[season][season_type]['BASIC'].get('TEAM_ID', None)

                        if team_id is None:
                            continue

                        if season_type == 'PLAYOFFS':
                            player_shooting = playerdashptshots.PlayerDashPtShots(team_id=team_id,
                                                                                  player_id=player_id,
                                                                                  season=season,
                                                                                  season_type_all_star='Playoffs'
                                                                                  ).get_normalized_dict()
                        else:
                            player_shooting = playerdashptshots.PlayerDashPtShots(team_id=team_id,
                                                                                  player_id=player_id,
                                                                                  season=season
                                                                                  ).get_normalized_dict()

                        shot_type = player_shooting['GeneralShooting']
                        closest_defender = player_shooting['ClosestDefenderShooting']

                        try:
                            for j in range(len(shot_type)):
                                shot_type_keys = list(shot_type[j].keys())[6:]

                                players_collection.update_one(
                                    {'PERSON_ID': player_id},
                                    {'$set': {
                                        f'STATS.{season}.{season_type}.ADV.SHOOTING.SHOT_TYPE.{shot_type[j]["SHOT_TYPE"]}': {
                                            key: shot_type[j][key] for key in shot_type_keys}
                                    }
                                    },
                                )
                            for j in range(len(closest_defender)):
                                closest_defender_keys = list(closest_defender[j].keys())[6:]

                                players_collection.update_one(
                                    {'PERSON_ID': player_id},
                                    {'$set': {
                                        f'STATS.{season}.{season_type}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender[j]["CLOSE_DEF_DIST_RANGE"]}': {
                                            key: closest_defender[j][key] for key in closest_defender_keys}
                                    }
                                    },
                                )
                        except Exception as e:
                            logging.error(f'Unable to add stats for {player_id}: {e}')
                            continue
            except Exception as e:
                logging.error(f'Unable to add stats for {player["PERSON_ID"]}: {e}')
                continue


def player_tracking_stats(season_type):
    avail_seasons = [
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
    ]

    for season in avail_seasons:
        if season_type == 'PLAYOFFS':
            player_touches = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Possessions',
                                                                 season=season,
                                                                 season_type_all_star='Playoffs').get_normalized_dict()[
                'LeagueDashPtStats']
            player_passing = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Passing',
                                                                 season=season,
                                                                 season_type_all_star='Playoffs').get_normalized_dict()[
                'LeagueDashPtStats']
            player_drives = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Drives',
                                                                season=season,
                                                                season_type_all_star='Playoffs').get_normalized_dict()[
                'LeagueDashPtStats']
            player_rebounding = \
                leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Rebounding',
                                                    season=season,
                                                    season_type_all_star='Playoffs').get_normalized_dict()[
                    'LeagueDashPtStats']
        else:
            player_touches = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Possessions',
                                                                 season=season).get_normalized_dict()[
                'LeagueDashPtStats']
            player_passing = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Passing',
                                                                 season=season).get_normalized_dict()[
                'LeagueDashPtStats']
            player_drives = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Drives',
                                                                season=season).get_normalized_dict()[
                'LeagueDashPtStats']
            player_rebounding = \
                leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Rebounding',
                                                    season=season).get_normalized_dict()[
                    'LeagueDashPtStats']

        num_players = len(player_drives)

        logging.info(f'Processing {num_players} for season {season} {season_type}...')

        touch_keys = list(player_touches[0].keys())[9:15]
        passing_keys = list(player_passing[0].keys())[8:]
        drives_keys = list(player_drives[0].keys())[8:]
        rebounding_keys = list(player_rebounding[0].keys())[8:]

        # Initialize dictionaries for each data type
        player_data = defaultdict(lambda: {'touches': {}, 'passing': {}, 'drives': {}, 'rebounding': {}})

        # Fill in the player data from each list
        for player in player_touches:
            player_id = player['PLAYER_ID']
            player_data[player_id]['touches'] = {key: player[key] for key in touch_keys}

        for player in player_passing:
            player_id = player['PLAYER_ID']
            player_data[player_id]['passing'] = {key: player[key] for key in passing_keys}

        for player in player_drives:
            player_id = player['PLAYER_ID']
            player_data[player_id]['drives'] = {key: player[key] for key in drives_keys}

        for player in player_rebounding:
            player_id = player['PLAYER_ID']
            player_data[player_id]['rebounding'] = {key: player[key] for key in rebounding_keys}

        # Update the MongoDB collection
        for player_id, data in player_data.items():
            try:
                players_collection.update_one(
                    {'PERSON_ID': player_id},
                    {'$set': {
                        f'STATS.{season}.{season_type}.ADV.TOUCHES': data['touches'],
                        f'STATS.{season}.{season_type}.ADV.PASSING': data['passing'],
                        f'STATS.{season}.{season_type}.ADV.DRIVES': data['drives'],
                        f'STATS.{season}.{season_type}.ADV.REBOUNDING': data['rebounding'],
                    }},
                )
            except Exception as e:
                logging.error(f'Unable to add stats for player with ID {player_id}: {e}')
                continue


def three_and_ft_rate(season_type):
    # Update each document in the collection
    for i, player in enumerate(players_collection.find()):
        logging.info(f'Processing {i} of {players_collection.count_documents({})}...')
        if 'STATS' in player:
            for season in player['STATS']:
                if season in seasons:
                    try:
                        # Extract the values needed for calculation
                        fg3a = player['STATS'][season][season_type]['BASIC'].get('FG3A', 0)
                        fta = player['STATS'][season][season_type]['BASIC'].get('FTA', 0)
                        ftm = player['STATS'][season][season_type]['BASIC'].get('FTM', 0)
                        fga = player['STATS'][season][season_type]['BASIC'].get('FGA', 1)  # Avoid division by zero

                        # Calculate 3PAr
                        three_pt_rate = fg3a / fga
                        fta_rate = fta / fga
                        ft_per_fga = ftm / fga

                        # Update the document with the new field
                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {f'STATS.{season}.{season_type}.BASIC.3PAr': three_pt_rate,
                                      f'STATS.{season}.{season_type}.BASIC.FTAr': fta_rate,
                                      f'STATS.{season}.{season_type}.BASIC.FT_PER_FGA': ft_per_fga}
                             }
                        )

                    except Exception as e:
                        print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                        continue


def poss_per_game(season_type):
    # Update each document in the collection
    for i, player in enumerate(players_collection.find()):
        logging.info(f'Processing {i} of {players_collection.count_documents({})}...')
        if 'STATS' in player:
            for season in player['STATS']:
                if season in seasons:
                    try:
                        # Extract the values needed for calculation
                        poss = player['STATS'][season][season_type]['ADV'].get('POSS', 0)
                        gp = player['STATS'][season][season_type]['ADV'].get('GP', 1)  # Avoid division by zero

                        # Calculate POSS PER GAME
                        poss_per_game = poss / gp

                        # Update the document with the new field
                        players_collection.update_one(
                            {'PERSON_ID': player['PERSON_ID']},
                            {'$set': {f'STATS.{season}.{season_type}.ADV.POSS_PER_GM': poss_per_game}
                             }
                        )

                    except Exception as e:
                        print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                        continue


def player_on_off(season_type):
    avail_seasons = [
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
        '2007-08'
    ]

    for season in avail_seasons:
        logging.info(f'Processing season {season}...')
        for team in teams_collection.find({}, {'TEAM_ID': 1, '_id': 0}):
            if team['TEAM_ID'] == 0:
                continue

            logging.info(f'Processing team {team["TEAM_ID"]}...')

            # PLAYOFFS
            if season_type == 'PLAYOFFS':
                player_on_off = teamplayeronoffdetails.TeamPlayerOnOffDetails(team_id=team['TEAM_ID'], season=season,
                                                                              season_type_all_star='Playoffs',
                                                                              measure_type_detailed_defense='Advanced').get_normalized_dict()

                player_on = player_on_off['PlayersOnCourtTeamPlayerOnOffDetails']
                player_off = player_on_off['PlayersOffCourtTeamPlayerOnOffDetails']

                keys = ['OFF_RATING', 'DEF_RATING', 'NET_RATING']
                for i in range(len(player_on)):
                    player_id = player_on[i]['VS_PLAYER_ID']  # Player ID

                    for key in keys:
                        on_value = player_on[i][key]
                        off_value = player_off[i][key]
                        on_off_value = on_value - off_value

                        # Update the document with the new field
                        players_collection.update_one(
                            {'PERSON_ID': player_id},
                            {'$set': {f'STATS.{season}.PLAYOFFS.ADV.{key}_ON_OFF': on_off_value}}
                        )
                logging.info(f'Added data for {len(player_on)} players for {season}.')

            # REGULAR SEASON
            else:
                player_on_off = teamplayeronoffdetails.TeamPlayerOnOffDetails(team_id=team['TEAM_ID'], season=season,
                                                                              measure_type_detailed_defense='Advanced').get_normalized_dict()

                player_on = player_on_off['PlayersOnCourtTeamPlayerOnOffDetails']
                player_off = player_on_off['PlayersOffCourtTeamPlayerOnOffDetails']

                keys = ['OFF_RATING', 'DEF_RATING', 'NET_RATING']
                for i in range(len(player_on)):
                    player_id = player_on[i]['VS_PLAYER_ID']  # Player ID

                    for key in keys:
                        on_value = player_on[i][key]
                        off_value = player_off[i][key]
                        on_off_value = on_value - off_value

                        stat_name = f'{key}_ON_OFF'
                        poss = player_on[i]['POSS']  # Possessions played with team

                        # Check player's existing stats for this season
                        existing_stats = players_collection.find_one(
                            {'PERSON_ID': player_id},
                            {'_id': 0, f'STATS.{season}.{season_type}.ADV.{key}_ON_OFF': 1,
                             f'STATS.{season}.{season_type}.ADV.{stat_name}_POSS': 1}
                        )

                        # If existing, calculate weighted average on/off by possessions played for each team.
                        if existing_stats and stat_name in existing_stats['STATS'][season][season_type]['ADV']:
                            existing_on_off = existing_stats['STATS'][season][season_type]['ADV'][stat_name]
                            existing_poss = existing_stats['STATS'][season][season_type]['ADV'][f'{stat_name}_POSS']

                            # Calculate weighted average
                            new_on_off_value = ((existing_on_off * existing_poss) + (on_off_value * poss)) / (
                                    existing_poss + poss)
                            new_poss = existing_poss + poss
                        else:
                            new_on_off_value = on_off_value
                            new_poss = poss

                        # Update the document with the new field
                        players_collection.update_one(
                            {'PERSON_ID': player_id},
                            {'$set': {
                                f'STATS.{season}.{season_type}.ADV.{stat_name}_POSS': new_poss,
                                f'STATS.{season}.{season_type}.ADV.{stat_name}': new_on_off_value
                            }
                            }
                        )

            logging.info(f'Added data for {len(player_on)} players for {season} {season_type}.')


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

    # logging.info("\nAdding Player On/Off data...\n")
    # player_on_off(season_types[0])
    # player_on_off(season_types[1])

    # logging.info("\nAdding Poss Per Game data...\n")
    # poss_per_game(season_types[0])
    # poss_per_game(season_types[1])

    # logging.info("\nAdding 3PAr and FTAr data...\n")
    # three_and_ft_rate(season_types[0])
    # three_and_ft_rate(season_types[1])

    # logging.info("\nAdding Passes and Touches data...\n")
    # player_tracking_stats(season_types[0])
    # player_tracking_stats(season_types[1])

    # logging.info("\nAdding Touches Breakdown data...\n")
    # touches_breakdown(season_types[0])
    # touches_breakdown(season_types[1])

    # logging.info("\nAdding Shot Distribution data...\n")
    # shot_distribution(season_types[0])
    # shot_distribution(season_types[1])

    # logging.info("\nAdding DRIVE STATS data...\n")
    # drive_stats(season_types[0])
    # drive_stats(season_types[1])

    # logging.info("\nAdding SCORING BREAKDOWN data...\n")
    # scoring_breakdown_and_pct_unassisted(season_types[0])
    # scoring_breakdown_and_pct_unassisted(season_types[1])

    # logging.info("\nAdding BOX CREATION data...\n")
    # box_creation(season_types[0])
    # box_creation(season_types[1])

    # logging.info("\nAdding OFFENSIVE LOAD data...\n")
    # offensive_load(season_types[0])
    # offensive_load(season_types[1])

    # logging.info("\nAdding cTOV data...\n")
    # adj_turnover_pct(season_types[0])
    # adj_turnover_pct(season_types[1])

    # logging.info("\nAdding DPS data...\n")
    # defensive_points_saved(season_types[0])
    # defensive_points_saved(season_types[1])

    # logging.info("\nAdding Versatility Score data...\n")
    # versatility_score(season_types[0])
    # versatility_score(season_types[1])

    logging.info("\nAdding Matchup Difficulty data...\n")
    # matchup_difficulty_and_dps(season_types[0])
    matchup_difficulty_and_dps(season_types[1])

    logging.info("Update complete.")
