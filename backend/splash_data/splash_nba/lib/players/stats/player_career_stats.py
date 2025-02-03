import time
import random
import logging
from nba_api.stats.endpoints import playercareerstats
from splash_nba.imports import get_mongo_collection, PROXY


def update_player_career_stats(player):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')

    player_totals = playercareerstats.PlayerCareerStats(proxy=PROXY, player_id=player).get_normalized_dict()
    player_per_game = playercareerstats.PlayerCareerStats(proxy=PROXY, player_id=player, per_mode36='PerGame').get_normalized_dict()

    reg_totals = player_totals['CareerTotalsRegularSeason']
    reg_totals_by_season = player_totals['SeasonTotalsRegularSeason']
    playoff_totals = player_totals['CareerTotalsPostSeason']
    playoff_totals_by_season = player_totals['SeasonTotalsPostSeason']
    college_totals = player_totals['CareerTotalsCollegeSeason']
    college_totals_by_season = player_totals['SeasonTotalsCollegeSeason']

    reg_per_game = player_per_game['CareerTotalsRegularSeason']
    reg_per_game_by_season = player_per_game['SeasonTotalsRegularSeason']
    playoff_per_game = player_per_game['CareerTotalsPostSeason']
    playoff_per_game_by_season = player_per_game['SeasonTotalsPostSeason']
    college_per_game = player_per_game['CareerTotalsCollegeSeason']
    college_per_game_by_season = player_per_game['SeasonTotalsCollegeSeason']

    reg_final = {}
    reg_by_season_final = {}
    playoff_final = {}
    playoff_by_season_final = {}
    college_final = {}
    college_by_season_final = {}

    stat_keys = [
        'MIN',
        'GP',
        'GS',
        'MIN',
        'FGM',
        'FGA',
        'FG_PCT',
        'FG3M',
        'FG3A',
        'FG3_PCT',
        'FTM',
        'FTA',
        'FT_PCT',
        'PTS',
        'REB',
        'AST',
        'STL',
        'BLK',
        'TOV'
    ]

    # TOTALS
    if len(reg_totals) > 0:
        reg_final = {key: reg_totals[0][key] for key in stat_keys}
        if len(reg_per_game) > 0:
            reg_final['MPG'] = reg_per_game[0]['MIN']
            reg_final['PPG'] = reg_per_game[0]['PTS']
            reg_final['RPG'] = reg_per_game[0]['REB']
            reg_final['APG'] = reg_per_game[0]['AST']
            reg_final['SPG'] = reg_per_game[0]['STL']
            reg_final['BPG'] = reg_per_game[0]['BLK']
            reg_final['TOPG'] = reg_per_game[0]['TOV']

    if len(playoff_totals) > 0:
        playoff_final = {key: playoff_totals[0][key] for key in stat_keys}
        if len(playoff_per_game) > 0:
            playoff_final['MPG'] = playoff_per_game[0]['MIN']
            playoff_final['PPG'] = playoff_per_game[0]['PTS']
            playoff_final['RPG'] = playoff_per_game[0]['REB']
            playoff_final['APG'] = playoff_per_game[0]['AST']
            playoff_final['SPG'] = playoff_per_game[0]['STL']
            playoff_final['BPG'] = playoff_per_game[0]['BLK']
            playoff_final['TOPG'] = playoff_per_game[0]['TOV']

    if len(college_totals) > 0:
        college_final = {key: college_totals[0][key] for key in stat_keys}
        if len(college_per_game) > 0:
            college_final['MPG'] = college_per_game[0]['MIN']
            college_final['PPG'] = college_per_game[0]['PTS']
            college_final['RPG'] = college_per_game[0]['REB']
            college_final['APG'] = college_per_game[0]['AST']
            college_final['SPG'] = college_per_game[0]['STL']
            college_final['BPG'] = college_per_game[0]['BLK']
            college_final['TOPG'] = college_per_game[0]['TOV']

    # BY SEASON
    if len(reg_totals_by_season) > 0:
        reg_totals_by_season.sort(key=lambda x: x['SEASON_ID'])
        reg_by_season_final = reg_totals_by_season
        if len(reg_per_game_by_season) > 0:
            reg_per_game_by_season.sort(key=lambda x: x['SEASON_ID'])
            for i, season in enumerate(reg_per_game_by_season):
                reg_by_season_final[i]['MPG'] = season['MIN']
                reg_by_season_final[i]['PPG'] = season['PTS']
                reg_by_season_final[i]['RPG'] = season['REB']
                reg_by_season_final[i]['APG'] = season['AST']
                reg_by_season_final[i]['SPG'] = season['STL']
                reg_by_season_final[i]['BPG'] = season['BLK']
                reg_by_season_final[i]['TOPG'] = season['TOV']

                if season['SEASON_ID'] >= '1996-97':
                    adv_stats = players_collection.find_one(
                        {'PERSON_ID': player}, {
                            f'STATS.{season["SEASON_ID"]}.REGULAR SEASON.ADV': 1,
                            '_id': 0
                        }
                    )['STATS'][season["SEASON_ID"]]['REGULAR SEASON']['ADV']

                    reg_by_season_final[i]['EFG_PCT'] = adv_stats['EFG_PCT']
                    reg_by_season_final[i]['TS_PCT'] = adv_stats['TS_PCT']
                    reg_by_season_final[i]['USG_PCT'] = adv_stats['USG_PCT']

                    if season['SEASON_ID'] >= '2007-08':
                        try:
                            reg_by_season_final[i]['ORTG_ON_OFF'] = adv_stats['OFF_RATING_ON_OFF']
                            reg_by_season_final[i]['DRTG_ON_OFF'] = adv_stats['DEF_RATING_ON_OFF']
                            reg_by_season_final[i]['NRTG_ON_OFF'] = adv_stats['NET_RATING_ON_OFF']
                        except KeyError:
                            reg_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                            reg_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                            reg_by_season_final[i]['NRTG_ON_OFF'] = 0.0

                        if season['SEASON_ID'] >= '2017-18':
                            try:
                                reg_by_season_final[i]['DEF_IMPACT_EST'] = adv_stats['DEF_IMPACT_EST']
                            except KeyError:
                                reg_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

                else:
                    reg_by_season_final[i]['EFG_PCT'] = 0.0
                    reg_by_season_final[i]['TS_PCT'] = 0.0
                    reg_by_season_final[i]['USG_PCT'] = 0.0
                    reg_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                    reg_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                    reg_by_season_final[i]['NRTG_ON_OFF'] = 0.0
                    reg_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

    if len(playoff_totals_by_season) > 0:
        playoff_totals_by_season.sort(key=lambda x: x['SEASON_ID'])
        playoff_by_season_final = playoff_totals_by_season
        if len(playoff_per_game_by_season) > 0:
            playoff_per_game_by_season.sort(key=lambda x: x['SEASON_ID'])
            for i, season in enumerate(playoff_per_game_by_season):
                playoff_by_season_final[i]['MPG'] = season['MIN']
                playoff_by_season_final[i]['PPG'] = season['PTS']
                playoff_by_season_final[i]['RPG'] = season['REB']
                playoff_by_season_final[i]['APG'] = season['AST']
                playoff_by_season_final[i]['SPG'] = season['STL']
                playoff_by_season_final[i]['BPG'] = season['BLK']
                playoff_by_season_final[i]['TOPG'] = season['TOV']

                if season['SEASON_ID'] >= '1996-97':
                    adv_stats = players_collection.find_one(
                        {'PERSON_ID': player}, {
                            f'STATS.{season["SEASON_ID"]}.PLAYOFFS.ADV': 1,
                            '_id': 0
                        }
                    )['STATS'][season["SEASON_ID"]]['PLAYOFFS']['ADV']

                    playoff_by_season_final[i]['EFG_PCT'] = adv_stats['EFG_PCT']
                    playoff_by_season_final[i]['TS_PCT'] = adv_stats['TS_PCT']
                    playoff_by_season_final[i]['USG_PCT'] = adv_stats['USG_PCT']

                    if season['SEASON_ID'] >= '2007-08':
                        try:
                            playoff_by_season_final[i]['ORTG_ON_OFF'] = adv_stats['OFF_RATING_ON_OFF']
                            playoff_by_season_final[i]['DRTG_ON_OFF'] = adv_stats['DEF_RATING_ON_OFF']
                            playoff_by_season_final[i]['NRTG_ON_OFF'] = adv_stats['NET_RATING_ON_OFF']
                        except KeyError:
                            playoff_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                            playoff_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                            playoff_by_season_final[i]['NRTG_ON_OFF'] = 0.0

                        if season['SEASON_ID'] >= '2017-18':
                            try:
                                playoff_by_season_final[i]['DEF_IMPACT_EST'] = adv_stats['DEF_IMPACT_EST']
                            except KeyError:
                                playoff_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

                else:
                    playoff_by_season_final[i]['EFG_PCT'] = 0.0
                    playoff_by_season_final[i]['TS_PCT'] = 0.0
                    playoff_by_season_final[i]['USG_PCT'] = 0.0
                    playoff_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                    playoff_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                    playoff_by_season_final[i]['NRTG_ON_OFF'] = 0.0
                    playoff_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

    if len(college_totals_by_season) > 0:
        college_totals_by_season.sort(key=lambda x: x['SEASON_ID'])
        college_by_season_final = college_totals_by_season
        if len(college_per_game_by_season) > 0:
            college_per_game_by_season.sort(key=lambda x: x['SEASON_ID'])
            for i, season in enumerate(college_per_game_by_season):
                college_by_season_final[i]['MPG'] = season['MIN']
                college_by_season_final[i]['PPG'] = season['PTS']
                college_by_season_final[i]['RPG'] = season['REB']
                college_by_season_final[i]['APG'] = season['AST']
                college_by_season_final[i]['SPG'] = season['STL']
                college_by_season_final[i]['BPG'] = season['BLK']
                college_by_season_final[i]['TOPG'] = season['TOV']

    players_collection.update_one(
        {'PERSON_ID': player},
        {'$set': {
            'CAREER.REGULAR SEASON.TOTALS': reg_final,
            'CAREER.REGULAR SEASON.SEASONS': reg_by_season_final,
            'CAREER.PLAYOFFS.TOTALS': playoff_final,
            'CAREER.PLAYOFFS.SEASONS': playoff_by_season_final,
            'CAREER.COLLEGE.TOTALS': college_final,
            'CAREER.COLLEGE.SEASONS': college_by_season_final,
        }}
    )


def player_career_stats(player):
    player_totals = playercareerstats.PlayerCareerStats(proxy=PROXY, player_id=player).get_normalized_dict()
    player_per_game = playercareerstats.PlayerCareerStats(proxy=PROXY, player_id=player, per_mode36='PerGame').get_normalized_dict()

    reg_totals = player_totals['CareerTotalsRegularSeason']
    reg_totals_by_season = player_totals['SeasonTotalsRegularSeason']
    playoff_totals = player_totals['CareerTotalsPostSeason']
    playoff_totals_by_season = player_totals['SeasonTotalsPostSeason']
    college_totals = player_totals['CareerTotalsCollegeSeason']
    college_totals_by_season = player_totals['SeasonTotalsCollegeSeason']

    reg_per_game = player_per_game['CareerTotalsRegularSeason']
    reg_per_game_by_season = player_per_game['SeasonTotalsRegularSeason']
    playoff_per_game = player_per_game['CareerTotalsPostSeason']
    playoff_per_game_by_season = player_per_game['SeasonTotalsPostSeason']
    college_per_game = player_per_game['CareerTotalsCollegeSeason']
    college_per_game_by_season = player_per_game['SeasonTotalsCollegeSeason']

    reg_final = {}
    reg_by_season_final = {}
    playoff_final = {}
    playoff_by_season_final = {}
    college_final = {}
    college_by_season_final = {}

    stat_keys = [
        'MIN',
        'GP',
        'GS',
        'MIN',
        'FGM',
        'FGA',
        'FG_PCT',
        'FG3M',
        'FG3A',
        'FG3_PCT',
        'FTM',
        'FTA',
        'FT_PCT',
        'PTS',
        'REB',
        'AST',
        'STL',
        'BLK',
        'TOV'
    ]

    # TOTALS
    if len(reg_totals) > 0:
        reg_final = {key: reg_totals[0][key] for key in stat_keys}
        if len(reg_per_game) > 0:
            reg_final['MPG'] = reg_per_game[0]['MIN']
            reg_final['PPG'] = reg_per_game[0]['PTS']
            reg_final['RPG'] = reg_per_game[0]['REB']
            reg_final['APG'] = reg_per_game[0]['AST']
            reg_final['SPG'] = reg_per_game[0]['STL']
            reg_final['BPG'] = reg_per_game[0]['BLK']
            reg_final['TOPG'] = reg_per_game[0]['TOV']

    if len(playoff_totals) > 0:
        playoff_final = {key: playoff_totals[0][key] for key in stat_keys}
        if len(playoff_per_game) > 0:
            playoff_final['MPG'] = playoff_per_game[0]['MIN']
            playoff_final['PPG'] = playoff_per_game[0]['PTS']
            playoff_final['RPG'] = playoff_per_game[0]['REB']
            playoff_final['APG'] = playoff_per_game[0]['AST']
            playoff_final['SPG'] = playoff_per_game[0]['STL']
            playoff_final['BPG'] = playoff_per_game[0]['BLK']
            playoff_final['TOPG'] = playoff_per_game[0]['TOV']

    if len(college_totals) > 0:
        college_final = {key: college_totals[0][key] for key in stat_keys}
        if len(college_per_game) > 0:
            college_final['MPG'] = college_per_game[0]['MIN']
            college_final['PPG'] = college_per_game[0]['PTS']
            college_final['RPG'] = college_per_game[0]['REB']
            college_final['APG'] = college_per_game[0]['AST']
            college_final['SPG'] = college_per_game[0]['STL']
            college_final['BPG'] = college_per_game[0]['BLK']
            college_final['TOPG'] = college_per_game[0]['TOV']

    # BY SEASON
    if len(reg_totals_by_season) > 0:
        reg_totals_by_season.sort(key=lambda x: x['SEASON_ID'])
        reg_by_season_final = reg_totals_by_season
        if len(reg_per_game_by_season) > 0:
            reg_per_game_by_season.sort(key=lambda x: x['SEASON_ID'])
            for i, season in enumerate(reg_per_game_by_season):
                reg_by_season_final[i]['MPG'] = season['MIN']
                reg_by_season_final[i]['PPG'] = season['PTS']
                reg_by_season_final[i]['RPG'] = season['REB']
                reg_by_season_final[i]['APG'] = season['AST']
                reg_by_season_final[i]['SPG'] = season['STL']
                reg_by_season_final[i]['BPG'] = season['BLK']
                reg_by_season_final[i]['TOPG'] = season['TOV']

                if season['SEASON_ID'] >= '1996-97':
                    adv_stats = players_collection.find_one(
                        {'PERSON_ID': player}, {
                            f'STATS.{season["SEASON_ID"]}.REGULAR SEASON.ADV': 1,
                            '_id': 0
                         }
                    )['STATS'][season["SEASON_ID"]]['REGULAR SEASON']['ADV']

                    reg_by_season_final[i]['EFG_PCT'] = adv_stats['EFG_PCT']
                    reg_by_season_final[i]['TS_PCT'] = adv_stats['TS_PCT']
                    reg_by_season_final[i]['USG_PCT'] = adv_stats['USG_PCT']

                    if season['SEASON_ID'] >= '2007-08':
                        try:
                            reg_by_season_final[i]['ORTG_ON_OFF'] = adv_stats['OFF_RATING_ON_OFF']
                            reg_by_season_final[i]['DRTG_ON_OFF'] = adv_stats['DEF_RATING_ON_OFF']
                            reg_by_season_final[i]['NRTG_ON_OFF'] = adv_stats['NET_RATING_ON_OFF']
                        except KeyError:
                            reg_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                            reg_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                            reg_by_season_final[i]['NRTG_ON_OFF'] = 0.0

                        if season['SEASON_ID'] >= '2017-18':
                            try:
                                reg_by_season_final[i]['DEF_IMPACT_EST'] = adv_stats['DEF_IMPACT_EST']
                            except KeyError:
                                reg_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

                else:
                    reg_by_season_final[i]['EFG_PCT'] = 0.0
                    reg_by_season_final[i]['TS_PCT'] = 0.0
                    reg_by_season_final[i]['USG_PCT'] = 0.0
                    reg_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                    reg_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                    reg_by_season_final[i]['NRTG_ON_OFF'] = 0.0
                    reg_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

    if len(playoff_totals_by_season) > 0:
        playoff_totals_by_season.sort(key=lambda x: x['SEASON_ID'])
        playoff_by_season_final = playoff_totals_by_season
        if len(playoff_per_game_by_season) > 0:
            playoff_per_game_by_season.sort(key=lambda x: x['SEASON_ID'])
            for i, season in enumerate(playoff_per_game_by_season):
                playoff_by_season_final[i]['MPG'] = season['MIN']
                playoff_by_season_final[i]['PPG'] = season['PTS']
                playoff_by_season_final[i]['RPG'] = season['REB']
                playoff_by_season_final[i]['APG'] = season['AST']
                playoff_by_season_final[i]['SPG'] = season['STL']
                playoff_by_season_final[i]['BPG'] = season['BLK']
                playoff_by_season_final[i]['TOPG'] = season['TOV']

                if season['SEASON_ID'] >= '1996-97':
                    adv_stats = players_collection.find_one(
                        {'PERSON_ID': player}, {
                            f'STATS.{season["SEASON_ID"]}.PLAYOFFS.ADV': 1,
                            '_id': 0
                        }
                    )['STATS'][season["SEASON_ID"]]['PLAYOFFS']['ADV']

                    playoff_by_season_final[i]['EFG_PCT'] = adv_stats['EFG_PCT']
                    playoff_by_season_final[i]['TS_PCT'] = adv_stats['TS_PCT']
                    playoff_by_season_final[i]['USG_PCT'] = adv_stats['USG_PCT']

                    if season['SEASON_ID'] >= '2007-08':
                        try:
                            playoff_by_season_final[i]['ORTG_ON_OFF'] = adv_stats['OFF_RATING_ON_OFF']
                            playoff_by_season_final[i]['DRTG_ON_OFF'] = adv_stats['DEF_RATING_ON_OFF']
                            playoff_by_season_final[i]['NRTG_ON_OFF'] = adv_stats['NET_RATING_ON_OFF']
                        except KeyError:
                            playoff_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                            playoff_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                            playoff_by_season_final[i]['NRTG_ON_OFF'] = 0.0

                        if season['SEASON_ID'] >= '2017-18':
                            try:
                                playoff_by_season_final[i]['DEF_IMPACT_EST'] = adv_stats['DEF_IMPACT_EST']
                            except KeyError:
                                playoff_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

                else:
                    playoff_by_season_final[i]['EFG_PCT'] = 0.0
                    playoff_by_season_final[i]['TS_PCT'] = 0.0
                    playoff_by_season_final[i]['USG_PCT'] = 0.0
                    playoff_by_season_final[i]['ORTG_ON_OFF'] = 0.0
                    playoff_by_season_final[i]['DRTG_ON_OFF'] = 0.0
                    playoff_by_season_final[i]['NRTG_ON_OFF'] = 0.0
                    playoff_by_season_final[i]['DEF_IMPACT_EST'] = 0.0

    if len(college_totals_by_season) > 0:
        college_totals_by_season.sort(key=lambda x: x['SEASON_ID'])
        college_by_season_final = college_totals_by_season
        if len(college_per_game_by_season) > 0:
            college_per_game_by_season.sort(key=lambda x: x['SEASON_ID'])
            for i, season in enumerate(college_per_game_by_season):
                college_by_season_final[i]['MPG'] = season['MIN']
                college_by_season_final[i]['PPG'] = season['PTS']
                college_by_season_final[i]['RPG'] = season['REB']
                college_by_season_final[i]['APG'] = season['AST']
                college_by_season_final[i]['SPG'] = season['STL']
                college_by_season_final[i]['BPG'] = season['BLK']
                college_by_season_final[i]['TOPG'] = season['TOV']

    players_collection.update_one(
        {'PERSON_ID': player},
        {'$set': {
            'CAREER.REGULAR SEASON.TOTALS': reg_final,
            'CAREER.REGULAR SEASON.SEASONS': reg_by_season_final,
            'CAREER.PLAYOFFS.TOTALS': playoff_final,
            'CAREER.PLAYOFFS.SEASONS': playoff_by_season_final,
            'CAREER.COLLEGE.TOTALS': college_final,
            'CAREER.COLLEGE.SEASONS': college_by_season_final,
        }}
    )


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
    teams_collection = get_mongo_collection('nba_teams')
    logging.info("Connected to MongoDB")

    # Set batch size to process documents
    batch_size = 25
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, 'CAREER': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                if 'CAREER' not in player or not player['CAREER']:
                    try:
                        player_career_stats(player['PERSON_ID'])
                    except Exception as e:
                        logging.error(f'Could not add career stats for player {player["PERSON_ID"]}: {e}')
                        continue

                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(random.uniform(0.5, 1.0))

            # Pause 15 seconds every 25 players
            #time.sleep(15)
