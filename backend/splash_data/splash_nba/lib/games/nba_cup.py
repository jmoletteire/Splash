import inspect
from collections import defaultdict

import requests
from nba_api.stats.endpoints import iststandings
from pymongo import MongoClient
from splash_nba.util.env import uri, k_current_season
import logging


def update_current_cup():
    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        cup_collection = db.nba_cup_history
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    try:
        teams = iststandings.ISTStandings(season=k_current_season).get_dict()['teams']
    except Exception as e:
        logging.error(f"NBA Cup data unavailable: {e}")
        return

    # Initialize a dictionary to group teams by istGroup
    grouped_teams = defaultdict(list)
    conference_teams = defaultdict(list)

    sorted_teams = sorted(teams, key=lambda x: (x['istGroup'], x['istGroupRank']))

    # Group teams
    for team in sorted_teams:
        grouped_teams[team['istGroup']].append(team)
        conference_teams[team['conference']].append(team)

    # Sort the teams
    for group in grouped_teams.keys():
        # Sort the teams in this group by 'istGroupRank'
        group_standings = sorted(grouped_teams[group], key=lambda x: x['istGroupRank'])

        # Update the database with the sorted array of teams
        cup_collection.update_one(
            {'SEASON': k_current_season},
            {'$set': {f'GROUP.{group_standings[0]["conference"]}.{group}': group_standings}},
            upsert=True
        )

    for conf in conference_teams.keys():
        wildcard_standings = sorted(conference_teams[conf], key=lambda x: x['istWildcardRank'])

        # Update the database with the sorted array of teams
        cup_collection.update_one(
            {'SEASON': k_current_season},
            {'$set': {f'WILD CARD.{wildcard_standings[0]["conference"]}': wildcard_standings}},
            upsert=True
        )

    # Fetching the JSON data from the URL
    url = f"https://cdn.nba.com/static/json/staticData/brackets/{k_current_season[0:4]}/ISTBracket.json"
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        json_data = response.json()
        cup_collection.update_one(
            {'SEASON': k_current_season},
            {'$set': {f'KNOCKOUT': json_data['bracket']['istBracketSeries']}},
            upsert=True
        )


def flag_cup_games(season=None):

    # Define the query inline, only adding 'SEASON' if a season is provided
    query = {'SEASON': season} if season else {}

    cups = list(cup_collection.find(query, {'SEASON': 1, 'GROUP': 1, 'KNOCKOUT': 1, '_id': 0}))
    for cup in cups:
        season_code = f"2{cup['SEASON'][:4]}"
        logging.info(cup['SEASON'])
        for conf, groups in cup['GROUP'].items():
            logging.info(conf)
            for group, teams in groups.items():
                logging.info(group)
                for team in teams:
                    for i, game in enumerate(team['games']):
                        logging.info(f'({team["teamAbbreviation"]}) {i + 1} of {len(team["games"])}')
                        # Query to find & update the document
                        games_collection.find_one_and_update({
                            "SEASON_CODE": season_code,
                            f"GAMES.{game['gameId']}": {"$exists": True}
                        },
                            {
                                "$set": {f"GAMES.{game['gameId']}.SUMMARY.GameSummary.0.NBA_CUP": f'NBA Cup - {group}'}
                            },
                        )


def fetch_all_cups():
    seasons = ['2023-24']

    for season in seasons:
        teams = iststandings.ISTStandings(season=season).get_dict()['teams']

        # Initialize a dictionary to group teams by istGroup
        grouped_teams = defaultdict(list)
        conference_teams = defaultdict(list)

        sorted_teams = sorted(teams, key=lambda x: (x['istGroup'], x['istGroupRank']))

        # Group teams
        for team in sorted_teams:
            grouped_teams[team['istGroup']].append(team)
            conference_teams[team['conference']].append(team)

        # Sort the teams
        for group in grouped_teams.keys():
            # Sort the teams in this group by 'istGroupRank'
            group_standings = sorted(grouped_teams[group], key=lambda x: x['istGroupRank'])

            # Update the database with the sorted array of teams
            cup_collection.update_one(
                {'SEASON': season},
                {'$set': {f'GROUP.{group_standings[0]["conference"]}.{group}': group_standings}},
                upsert=True
            )

        for conf in conference_teams.keys():
            wildcard_standings = sorted(conference_teams[conf], key=lambda x: x['istWildcardRank'])

            # Update the database with the sorted array of teams
            cup_collection.update_one(
                {'SEASON': season},
                {'$set': {f'WILD CARD.{wildcard_standings[0]["conference"]}': wildcard_standings}},
                upsert=True
            )

        # Fetching the JSON data from the URL
        url = f"https://cdn.nba.com/static/json/staticData/brackets/{season[0:4]}/ISTBracket.json"
        response = requests.get(url)

        # Check if the request was successful
        if response.status_code == 200:
            json_data = response.json()
            cup_collection.update_one(
                {'SEASON': season},
                {'$set': {f'KNOCKOUT': json_data['bracket']['istBracketSeries']}},
                upsert=True
            )


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    client = MongoClient(uri)
    db = client.splash
    cup_collection = db.nba_cup_history
    games_collection = db.nba_games
    # fetch_all_cups()
    flag_cup_games(season='2024-25')
