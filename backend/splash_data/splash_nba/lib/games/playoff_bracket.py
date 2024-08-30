from nba_api.stats.endpoints import commonplayoffseries, boxscoresummaryv2
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging

# List of seasons
seasons = [
    #'2023-24',
    #'2022-23',
    #'2021-22',
    #'2020-21',
    #'2019-20',
    #'2018-19',
    #'2017-18',
    #'2016-17',
    #'2015-16',
    #'2014-15',
    #'2013-14',
    #'2012-13',
    #'2011-12',
    #'2010-11',
    #'2009-10',
    #'2008-09',
    #'2007-08',
    #'2006-07',
    #'2005-06',
    #'2004-05',
    #'2003-04',
    #'2002-03',
    #'2001-02',
    #'2000-01',
    #'1999-00',
    '1998-99',
    #'1997-98',
    #'1996-97',
    #'1995-96',
    #'1994-95',
    #'1993-94',
    #'1992-93',
    #'1991-92',
    #'1990-91',
    #'1989-90',
    #'1988-89',
    #'1987-88',
    #'1986-87',
    #'1985-86',
    #'1984-85'
]

eastConfTeamIds = [
    1610612737,
    1610612738,
    1610612739,
    1610612741,
    1610612748,
    1610612749,
    1610612751,
    1610612752,
    1610612753,
    1610612754,
    1610612755,
    1610612761,
    1610612764,
    1610612765,
    1610612766
]

westConfTeamIds = [
    1610612740,
    1610612742,
    1610612743,
    1610612744,
    1610612745,
    1610612746,
    1610612747,
    1610612750,
    1610612756,
    1610612757,
    1610612758,
    1610612759,
    1610612760,
    1610612762,
    1610612763,
]


def get_playoff_bracket_data(season, playoff_data):
    rounds = {
        '1': 'First Round',
        '2': 'Conf Semi-Finals',
        '3': 'Conf Finals',
        '4': 'NBA Finals'
    }

    logging.info(f'Processing {season}...')

    # Printing or further processing the reformatted data
    for series_id, games_list in playoff_data.items():
        logging.info(f'Series {series_id}')

        po_round = rounds[series_id[-2]]

        series = {
            'SERIES_ID': series_id,
            'TEAM_ONE': games_list[0]['HOME_TEAM_ID'],
            'TEAM_ONE_ABBR':
                teams_collection.find_one({'TEAM_ID': games_list[0]['HOME_TEAM_ID']}, {'_id': 0, 'ABBREVIATION': 1})[
                    'ABBREVIATION'],
            'TEAM_ONE_SEED': teams_collection.find_one({'TEAM_ID': games_list[0]['HOME_TEAM_ID']},
                                                       {'_id': 0, f'seasons.{season}.STANDINGS.PlayoffRank': 1})[
                'seasons'][season]['STANDINGS']['PlayoffRank'],
            'TEAM_TWO': games_list[0]['VISITOR_TEAM_ID'],
            'TEAM_TWO_ABBR':
                teams_collection.find_one({'TEAM_ID': games_list[0]['VISITOR_TEAM_ID']}, {'_id': 0, 'ABBREVIATION': 1})[
                    'ABBREVIATION'],
            'TEAM_TWO_SEED': teams_collection.find_one({'TEAM_ID': games_list[0]['VISITOR_TEAM_ID']},
                                                       {'_id': 0, f'seasons.{season}.STANDINGS.PlayoffRank': 1})[
                'seasons'][season]['STANDINGS']['PlayoffRank'],
            'GAMES': []
        }

        for i, game in enumerate(games_list):
            # Query the collection to find the document containing the game_id
            game_id = game['GAME_ID']
            series['GAMES'].append({})
            series['GAMES'][i]['GAME_ID'] = game_id

            game_data = games_collection.find_one({"GAMES." + game_id: {"$exists": True}})

            if game_data:
                # Extract the score and date
                game_info = game_data['GAMES'][game_id]
                series['GAMES'][i]['GAME_DATE'] = game_data['GAME_DATE']
                series['GAMES'][i]['HOME_SCORE'] = game_info['BOXSCORE']['TeamStats'][0]['PTS'] if \
                game_info['BOXSCORE']['TeamStats'][0]['TEAM_ID'] == game['HOME_TEAM_ID'] else \
                game_info['BOXSCORE']['TeamStats'][1]['PTS']
                series['GAMES'][i]['AWAY_SCORE'] = game_info['BOXSCORE']['TeamStats'][0]['PTS'] if \
                game_info['BOXSCORE']['TeamStats'][0]['TEAM_ID'] == game['VISITOR_TEAM_ID'] else \
                game_info['BOXSCORE']['TeamStats'][1]['PTS']

                if i == 0:
                    series['TEAM_ONE_WINS'] = game_info['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_WINS']
                    series['TEAM_TWO_WINS'] = game_info['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_LOSSES']

            else:
                logging.info(f"Game ID {game_id} not found in the collection, gathering data...")

                summary = boxscoresummaryv2.BoxScoreSummaryV2(game_id=game_id).get_normalized_dict()

                series['TEAM_ONE_WINS'] = summary['SeasonSeries'][0]['HOME_TEAM_WINS'] if game['HOME_TEAM_ID'] == \
                                                                                          series['TEAM_ONE'] else \
                summary['SeasonSeries'][0]['HOME_TEAM_LOSSES']
                series['TEAM_TWO_WINS'] = summary['SeasonSeries'][0]['HOME_TEAM_WINS'] if game['HOME_TEAM_ID'] == \
                                                                                          series['TEAM_TWO'] else \
                summary['SeasonSeries'][0]['HOME_TEAM_LOSSES']

                series['GAMES'][i]['GAME_DATE'] = summary['GameSummary'][0]['GAME_DATE_EST']
                series['GAMES'][i]['HOME_SCORE'] = summary['LineScore'][0]['PTS'] if summary['LineScore'][0][
                                                                                         'TEAM_ID'] == game[
                                                                                         'HOME_TEAM_ID'] else \
                summary['LineScore'][1]['PTS']
                series['GAMES'][i]['AWAY_SCORE'] = summary['LineScore'][0]['PTS'] if summary['LineScore'][0][
                                                                                         'TEAM_ID'] == game[
                                                                                         'VISITOR_TEAM_ID'] else \
                summary['LineScore'][1]['PTS']

        playoff_collection.update_one(
            {'SEASON': season},
            {'$set': {f'{po_round}.{series_id}': series}},
            upsert=True
        )


def reformat_pre2002_series_data(season, games):
    series_dict = {}
    team_series_map = {}
    round_counter = 1
    series_counter = 1
    series_num_map = {
        1: {
            'East': {
                1: 0,
                2: 1,
                3: 2,
                4: 3,
                5: 3,
                6: 2,
                7: 1,
                8: 0
            },
            'West': {
                1: 4,
                2: 5,
                3: 6,
                4: 7,
                5: 7,
                6: 6,
                7: 5,
                8: 4
            }
        },
        2: {
            'East': {
                1: 0,
                8: 0,
                2: 1,
                7: 1,
                3: 1,
                6: 1,
                4: 0,
                5: 0
            },
            'West': {
                1: 2,
                8: 2,
                2: 3,
                7: 3,
                3: 3,
                6: 3,
                4: 2,
                5: 2
            }
        },
        3: {
            'East': 0,
            'West': 1
        }
    }

    # Iterate over the games
    for game in games:
        home_team = game['HOME_TEAM_ID']
        visitor_team = game['VISITOR_TEAM_ID']

        home_team_data = teams_collection.find_one(
            {'TEAM_ID': home_team},
            {
                f'seasons.{season}.STANDINGS.Conference': 1,
                f'seasons.{season}.STANDINGS.PlayoffRank': 1,
                '_id': 0
            }
        )

        conf = home_team_data['seasons'][season]['STANDINGS']['Conference']
        seed = home_team_data['seasons'][season]['STANDINGS']['PlayoffRank']

        # Create a unique key for the matchup, sorting to make it order-independent
        matchup_key = tuple(sorted([home_team, visitor_team]))

        # If this matchup hasn't been assigned a series ID, create a new one
        if matchup_key not in team_series_map:
            if round_counter == 1:  # FIRST ROUND
                series_id = f"004{season[2:4]}001{series_num_map[round_counter][conf][seed]}"
            elif round_counter == 2:  # CONF SEMIS
                series_id = f"004{season[2:4]}002{series_num_map[round_counter][conf][seed]}"
            elif round_counter == 3:  # CONF FINALS
                series_id = f"004{season[2:4]}003{series_num_map[round_counter][conf]}"
            else:
                series_id = f"004{season[2:4]}0040"

            team_series_map[matchup_key] = series_id

            if round_counter == 1 and series_counter == 8:
                round_counter += 1
                series_counter = 1
            elif round_counter == 2 and series_counter == 4:
                round_counter += 1
                series_counter = 1
            elif round_counter == 3 and series_counter == 2:
                round_counter += 1
                series_counter = 1
            else:
                series_counter += 1

        else:
            series_id = team_series_map[matchup_key]

        # Assign the new series ID to the game
        game['SERIES_ID'] = series_id

        # Initialize the list for the series_id if it doesn't exist
        if series_id not in series_dict:
            series_dict[series_id] = []

        # Append the game data to the corresponding series_id
        series_dict[series_id].append(game)

    # Sort the series_dict by SERIES_ID in ascending order
    sorted_series_dict = dict(sorted(series_dict.items()))

    print(sorted_series_dict)

    return sorted_series_dict


def reformat_series_data(games):
    series_dict = {}

    for game in games:
        series_id = game['SERIES_ID']

        # Initialize the list for the series_id if it doesn't exist
        if series_id not in series_dict:
            series_dict[series_id] = []

        # Append the game data to the corresponding series_id
        series_dict[series_id].append(game)

    return series_dict


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams
    games_collection = db.nba_games
    playoff_collection = db.nba_playoff_history
    logging.info("Connected to MongoDB")

    for season in seasons:
        playoff_games = commonplayoffseries.CommonPlayoffSeries(season=season).get_normalized_dict()['PlayoffSeries']

        if season <= '2000-01':
            series_data = reformat_pre2002_series_data(season, playoff_games)
        else:
            series_data = reformat_series_data(playoff_games)

        get_playoff_bracket_data(season, series_data)
