from nba_api.stats.endpoints import commonplayoffseries
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging

# List of seasons
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
    '1996-97',
    '1995-96',
    '1994-95',
    '1993-94',
    '1992-93',
    '1991-92',
    '1990-91',
    '1989-90',
    '1988-89',
    '1987-88',
    '1986-87',
    '1985-86'
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
            'TEAM_ONE_ABBR': teams_collection.find_one({'TEAM_ID': games_list[0]['HOME_TEAM_ID']}, {'_id': 0, 'ABBREVIATION': 1})['ABBREVIATION'],
            'TEAM_ONE_SEED': teams_collection.find_one({'TEAM_ID': games_list[0]['HOME_TEAM_ID']}, {'_id': 0, f'seasons.{season}.STANDINGS.PlayoffRank': 1})['seasons'][season]['STANDINGS']['PlayoffRank'],
            'TEAM_TWO': games_list[0]['VISITOR_TEAM_ID'],
            'TEAM_TWO_ABBR': teams_collection.find_one({'TEAM_ID': games_list[0]['VISITOR_TEAM_ID']}, {'_id': 0, 'ABBREVIATION': 1})['ABBREVIATION'],
            'TEAM_TWO_SEED': teams_collection.find_one({'TEAM_ID': games_list[0]['VISITOR_TEAM_ID']}, {'_id': 0, f'seasons.{season}.STANDINGS.PlayoffRank': 1})['seasons'][season]['STANDINGS']['PlayoffRank'],
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
                series['GAMES'][i]['HOME_SCORE'] = game_info['BOXSCORE']['TeamStats'][0]['PTS'] if game_info['BOXSCORE']['TeamStats'][0]['TEAM_ID'] == game['HOME_TEAM_ID'] else game_info['BOXSCORE']['TeamStats'][1]['PTS']
                series['GAMES'][i]['AWAY_SCORE'] = game_info['BOXSCORE']['TeamStats'][0]['PTS'] if game_info['BOXSCORE']['TeamStats'][0]['TEAM_ID'] == game['VISITOR_TEAM_ID'] else game_info['BOXSCORE']['TeamStats'][1]['PTS']

                if i == 0:
                    series['TEAM_ONE_WINS'] = game_info['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_WINS']
                    series['TEAM_TWO_WINS'] = game_info['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_LOSSES']
            else:
                print(f"Game ID {game_id} not found in the collection")

        playoff_collection.update_one(
            {'SEASON': season},
            {'$set': {f'{po_round}.{series_id}': series}},
            upsert=True
        )


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

        series_data = reformat_series_data(playoff_games)
        get_playoff_bracket_data(season, series_data)
