from collections import defaultdict

from nba_api.stats.endpoints import iststandings
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging

seasons = ['2023-24']


def fetch_all_cups():
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


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    client = MongoClient(uri)
    db = client.splash
    cup_collection = db.nba_cup_history
    fetch_all_cups()
