from nba_api.stats.endpoints import teamplayeronoffdetails, leaguedashptstats, playerdashptshots
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging

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


def touches_breakdown(playoffs):
    # Update each document in the collection
    for i, player in enumerate(players_collection.find()):
        logging.info(f'Processing {i} of {players_collection.count_documents({})}...')
        if 'STATS' in player:
            for season in player['STATS']:
                if season in seasons:

                    # PLAYOFFS
                    if playoffs:
                        try:
                            # Extract the values needed for calculation
                            fga = player['STATS'][season]['PLAYOFFS']['BASIC'].get('FGA', 0)
                            passes = player['STATS'][season]['PLAYOFFS']['ADV']['PASSING'].get('PASSES_MADE', 0)
                            turnovers = player['STATS'][season]['PLAYOFFS']['BASIC'].get('TOV', 0)
                            fouled = player['STATS'][season]['PLAYOFFS']['BASIC'].get('PFD', 0)
                            touches = player['STATS'][season]['PLAYOFFS']['ADV']['TOUCHES'].get('TOUCHES',
                                                                                                1)  # Avoid division by zero
                            # Calculate POSS PER GAME
                            percent_shot = fga / touches
                            percent_pass = passes / touches
                            percent_turnover = turnovers / touches
                            percent_fouled = fouled / touches

                            # Update the document with the new field
                            players_collection.update_one(
                                {'PERSON_ID': player['PERSON_ID']},
                                {'$set': {f'STATS.{season}.PLAYOFFS.ADV.TOUCHES.FGA_PER_TOUCH': percent_shot,
                                          f'STATS.{season}.PLAYOFFS.ADV.TOUCHES.PASSES_PER_TOUCH': percent_pass,
                                          f'STATS.{season}.PLAYOFFS.ADV.TOUCHES.TOV_PER_TOUCH': percent_turnover,
                                          f'STATS.{season}.PLAYOFFS.ADV.TOUCHES.PFD_PER_TOUCH': percent_fouled,
                                          }
                                 }
                            )
                        except Exception as e:
                            print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                            continue

                    # REGULAR SEASON
                    else:
                        try:
                            # Extract the values needed for calculation
                            fga = player['STATS'][season]['BASIC'].get('FGA', 0)
                            passes = player['STATS'][season]['ADV']['PASSING'].get('PASSES_MADE', 0)
                            turnovers = player['STATS'][season]['BASIC'].get('TOV', 0)
                            fouled = player['STATS'][season]['BASIC'].get('PFD', 0)
                            touches = player['STATS'][season]['ADV']['TOUCHES'].get('TOUCHES',
                                                                                    1)  # Avoid division by zero
                            # Calculate POSS PER GAME
                            percent_shot = fga / touches
                            percent_pass = passes / touches
                            percent_turnover = turnovers / touches
                            percent_fouled = fouled / touches

                            # Update the document with the new field
                            players_collection.update_one(
                                {'PERSON_ID': player['PERSON_ID']},
                                {'$set': {f'STATS.{season}.ADV.TOUCHES.FGA_PER_TOUCH': percent_shot,
                                          f'STATS.{season}.ADV.TOUCHES.PASSES_PER_TOUCH': percent_pass,
                                          f'STATS.{season}.ADV.TOUCHES.TOV_PER_TOUCH': percent_turnover,
                                          f'STATS.{season}.ADV.TOUCHES.PFD_PER_TOUCH': percent_fouled,
                                          }
                                 }
                            )
                        except Exception as e:
                            print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                            continue


def poss_per_game(playoffs):
    # Update each document in the collection
    for i, player in enumerate(players_collection.find()):
        logging.info(f'Processing {i} of {players_collection.count_documents({})}...')
        if 'STATS' in player:
            for season in player['STATS']:
                if season in seasons:
                    try:

                        # PLAYOFFS
                        if playoffs:
                            # Extract the values needed for calculation
                            poss = player['STATS'][season]['PLAYOFFS']['ADV'].get('POSS', 0)
                            gp = player['STATS'][season]['PLAYOFFS']['ADV'].get('GP', 1)  # Avoid division by zero
                            # Calculate POSS PER GAME
                            poss_per_game = poss / gp

                            # Update the document with the new field
                            players_collection.update_one(
                                {'PERSON_ID': player['PERSON_ID']},
                                {'$set': {f'STATS.{season}.PLAYOFFS.ADV.POSS_PER_GM': poss_per_game}
                                 }
                            )

                        # REGULAR SEASON
                        else:
                            # Extract the values needed for calculation
                            poss = player['STATS'][season]['ADV'].get('POSS', 0)
                            gp = player['STATS'][season]['ADV'].get('GP', 1)  # Avoid division by zero
                            # Calculate POSS PER GAME
                            poss_per_game = poss / gp

                            # Update the document with the new field
                            players_collection.update_one(
                                {'PERSON_ID': player['PERSON_ID']},
                                {'$set': {f'STATS.{season}.ADV.POSS_PER_GM': poss_per_game}
                                 }
                            )

                    except Exception as e:
                        print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                        continue


def shot_distribution(playoffs):
    if not playoffs:
        logging.info('Regular Season...\n')
    else:
        logging.info('Playoffs...\n')

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
                        team_id = stats[season]['BASIC'].get('TEAM_ID', None)

                        if team_id is None:
                            continue

                        # PLAYOFFS
                        if playoffs:
                            player_shooting = playerdashptshots.PlayerDashPtShots(team_id=team_id, player_id=player_id,
                                                                                  season=season, season_type_all_star='Playoffs'
                                                                                  ).get_normalized_dict()

                            shot_type = player_shooting['GeneralShooting']
                            closest_defender = player_shooting['ClosestDefenderShooting']

                            try:
                                for j in range(len(shot_type)):
                                    shot_type_keys = list(shot_type[j].keys())[6:]

                                    players_collection.update_one(
                                        {'PERSON_ID': player_id},
                                        {'$set': {
                                            f'STATS.{season}.PLAYOFFS.ADV.SHOOTING.SHOT_TYPE.{shot_type[j]["SHOT_TYPE"]}': {key: shot_type[j][key] for key in shot_type_keys}
                                        }
                                        },
                                    )
                                for j in range(len(closest_defender)):
                                    closest_defender_keys = list(closest_defender[j].keys())[6:]

                                    players_collection.update_one(
                                        {'PERSON_ID': player_id},
                                        {'$set': {
                                            f'STATS.{season}.PLAYOFFS.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender[j]["CLOSE_DEF_DIST_RANGE"]}': {key: closest_defender[j][key] for key in closest_defender_keys}
                                        }
                                        },
                                    )
                            except Exception as e:
                                logging.error(f'Unable to add stats for {player_id}: {e}')
                                continue

                        # REGULAR SEASON
                        else:
                            player_shooting = playerdashptshots.PlayerDashPtShots(team_id=team_id, player_id=player_id,
                                                                                  season=season).get_normalized_dict()

                            shot_type = player_shooting['GeneralShooting']
                            closest_defender = player_shooting['ClosestDefenderShooting']

                            try:
                                for j in range(len(shot_type)):
                                    shot_type_keys = list(shot_type[j].keys())[6:]

                                    players_collection.update_one(
                                        {'PERSON_ID': player_id},
                                        {'$set': {
                                            f'STATS.{season}.ADV.SHOOTING.SHOT_TYPE.{shot_type[j]["SHOT_TYPE"]}': {key: shot_type[j][key] for key in shot_type_keys}
                                        }
                                        },
                                    )
                                for j in range(len(closest_defender)):
                                    closest_defender_keys = list(closest_defender[j].keys())[6:]

                                    players_collection.update_one(
                                        {'PERSON_ID': player_id},
                                        {'$set': {
                                            f'STATS.{season}.ADV.SHOOTING.CLOSEST_DEFENDER.{closest_defender[j]["CLOSE_DEF_DIST_RANGE"]}': {key: closest_defender[j][key] for key in closest_defender_keys}
                                        }
                                        },
                                    )
                            except Exception as e:
                                logging.error(f'Unable to add stats for {player_id}: {e}')
                                continue
            except Exception as e:
                logging.error(f'Unable to add stats for {player["PERSON_ID"]}: {e}')
                continue


def passes_and_touches(playoffs):
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

        # PLAYOFFS
        if playoffs:
            player_touches = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Possessions',
                                                                 season=season,
                                                                 season_type_all_star='Playoffs').get_normalized_dict()[
                'LeagueDashPtStats']
            player_passing = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Passing',
                                                                 season=season,
                                                                 season_type_all_star='Playoffs').get_normalized_dict()[
                'LeagueDashPtStats']

            num_players = len(player_touches)

            logging.info(f'Processing {num_players} for season {season}...')

            touch_keys = list(player_touches[0].keys())[9:15]
            passing_keys = list(player_passing[0].keys())[8:]

            for i in range(0, num_players):
                try:
                    players_collection.update_one(
                        {'PERSON_ID': player_touches[i]['PLAYER_ID']},
                        {'$set': {
                            f'STATS.{season}.PLAYOFFS.ADV.TOUCHES': {key: player_touches[i][key] for key in touch_keys},
                            f'STATS.{season}.PLAYOFFS.ADV.PASSING': {key: player_passing[i][key] for key in
                                                                     passing_keys}
                        }
                        },
                    )
                except Exception as e:
                    logging.error(f'Unable to add stats for {player_touches[i]["PLAYER_NAME"]}: {e}')
                    continue

        # REGULAR SEASON
        else:
            player_touches = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Possessions',
                                                                 season=season).get_normalized_dict()[
                'LeagueDashPtStats']
            player_passing = leaguedashptstats.LeagueDashPtStats(player_or_team='Player', pt_measure_type='Passing',
                                                                 season=season).get_normalized_dict()[
                'LeagueDashPtStats']

            num_players = len(player_touches)

            logging.info(f'Processing {num_players} for season {season}...')

            touch_keys = list(player_touches[0].keys())[9:15]
            passing_keys = list(player_passing[0].keys())[8:]

            for i in range(0, num_players):
                try:
                    players_collection.update_one(
                        {'PERSON_ID': player_touches[i]['PLAYER_ID']},
                        {'$set': {f'STATS.{season}.ADV.TOUCHES': {key: player_touches[i][key] for key in touch_keys},
                                  f'STATS.{season}.ADV.PASSING': {key: player_passing[i][key] for key in passing_keys}
                                  }
                         },
                    )
                except Exception as e:
                    logging.error(f'Unable to add stats for {player_touches[i]["PLAYER_NAME"]}: {e}')
                    continue


def player_on_off(playoffs):
    for season in seasons:
        logging.info(f'Processing season {season}...')
        for team in teams_collection.find({}, {'TEAM_ID': 1, '_id': 0}):
            logging.info(f'Processing team {team["TEAM_ID"]}...')

            # PLAYOFFS
            if playoffs:
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
                    poss = player_on[i]['POSS']  # Possessions played with team

                    for key in keys:
                        on_value = player_on[i][key]
                        off_value = player_off[i][key]
                        on_off_value = on_value - off_value

                        # Check if player has existing stats for this season
                        existing_stats = players_collection.find_one(
                            {'PERSON_ID': player_id},
                            {'_id': 0, f'STATS.{season}.ADV.{key}_ON_OFF': 1, f'STATS.{season}.ADV.POSS': 1}
                        )

                        # If existing, calculate weighted average on/off by possessions played.
                        if existing_stats and f'STATS.{season}.ADV.{key}_ON_OFF' in existing_stats['STATS'][season][
                            'ADV']:
                            existing_on_off = existing_stats['STATS'][season]['ADV'][key + '_ON_OFF']
                            existing_poss = existing_stats['STATS'][season]['ADV']['POSS']

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
                            {'$set': {f'STATS.{season}.ADV.{key}_ON_OFF': new_on_off_value,
                                      f'STATS.{season}.ADV.POSS': new_poss}}
                        )
                logging.info(f'Added data for {len(player_on)} players for {season}.')


def three_and_ft_rate(playoffs):
    # Update each document in the collection
    for i, player in enumerate(players_collection.find()):
        logging.info(f'Processing {i} of {players_collection.count_documents({})}...')
        if 'STATS' in player:
            for season in player['STATS']:
                if season in seasons:

                    # PLAYOFFS
                    if playoffs:
                        try:
                            # Extract the values needed for calculation
                            fg3a = player['STATS'][season]['PLAYOFFS']['BASIC'].get('FG3A', 0)
                            fta = player['STATS'][season]['PLAYOFFS']['BASIC'].get('FTA', 0)
                            ftm = player['STATS'][season]['PLAYOFFS']['BASIC'].get('FTM', 0)
                            fga = player['STATS'][season]['PLAYOFFS']['BASIC'].get('FGA', 1)  # Avoid division by zero
                            fgm = player['STATS'][season]['PLAYOFFS']['BASIC'].get('FGM', 1)
                            # Calculate 3PAr
                            three_pt_rate = fg3a / fga
                            fta_rate = fta / fga
                            ft_per_fgm = ftm / fgm

                            # Update the document with the new field
                            players_collection.update_one(
                                {'PERSON_ID': player['PERSON_ID']},
                                {'$set': {f'STATS.{season}.PLAYOFFS.BASIC.3PAr': three_pt_rate,
                                          f'STATS.{season}.PLAYOFFS.BASIC.FTAr': fta_rate,
                                          f'STATS.{season}.PLAYOFFS.BASIC.FT_PER_FGM': ft_per_fgm}
                                 }
                            )

                        except Exception as e:
                            print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                            continue

                    # REGULAR SEASON
                    else:
                        try:
                            # Extract the values needed for calculation
                            fg3a = player['STATS'][season]['BASIC'].get('FG3A', 0)
                            fta = player['STATS'][season]['BASIC'].get('FTA', 0)
                            ftm = player['STATS'][season]['BASIC'].get('FTM', 0)
                            fga = player['STATS'][season]['BASIC'].get('FGA', 1)  # Avoid division by zero
                            fgm = player['STATS'][season]['BASIC'].get('FGM', 1)
                            # Calculate 3PAr
                            three_pt_rate = fg3a / fga
                            fta_rate = fta / fga
                            ft_per_fgm = ftm / fgm

                            # Update the document with the new field
                            players_collection.update_one(
                                {'PERSON_ID': player['PERSON_ID']},
                                {'$set': {f'STATS.{season}.BASIC.3PAr': three_pt_rate,
                                          f'STATS.{season}.BASIC.FTAr': fta_rate,
                                          f'STATS.{season}.BASIC.FT_PER_FGM': ft_per_fgm}
                                 }
                            )

                        except Exception as e:
                            print(f"Key error for document with _id {player['PERSON_ID']}: {e}")
                            continue


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    teams_collection = db.nba_teams
    logging.info("Connected to MongoDB")

    # logging.info("\nAdding 3PAr and FTAr data...\n")
    # three_and_ft_rate(playoffs=True)

    # logging.info("\nAdding Player On/Off data...\n")
    # player_on_off(playoffs=True)

    # logging.info("\nAdding Player Tracking data...\n")
    # passes_and_touches(playoffs=True)

    logging.info("\nAdding Shot Distribution data...\n")
    shot_distribution(playoffs=True)

    # logging.info("\nAdding Poss Per Game data...\n")
    # poss_per_game(playoffs=True)

    # logging.info("\nAdding Touches Breakdown data...\n")
    # touches_breakdown(playoffs=True)

    logging.info("Update complete.")
