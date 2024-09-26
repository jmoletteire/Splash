import random
import time

from nba_api.stats.endpoints import teamdetails, commonallplayers, playerawards
from pymongo import MongoClient
from splash_nba.util.env import uri
import logging


def player_award_details():
    for year in lg_history_collection.find({}, {"_id": 0}):
        logging.info(year['YEAR'])
        for award_name, award_data in year.items():
            if award_name == 'YEAR' or award_name == 'J':
                continue

            logging.info(award_name)
            for i, player in enumerate(award_data['PLAYERS']):
                result = players_collection.find_one(
                    {'PERSON_ID': player['PLAYER_ID']},
                    {
                        '_id': 0,
                        'FIRST_NAME': 1,
                        'LAST_NAME': 1,
                        'POSITION': 1,
                        f'STATS.{award_data["SEASON"]}.REGULAR SEASON.BASIC': 1
                    }
                )
                if result is None:
                    position = ''
                    team_id = '0'
                    team_abbreviation = ''
                    conf = ''
                    lg_history_collection.update_one(
                        {'YEAR': year['YEAR']},
                        {"$set": {
                            f'{award_name}.PLAYERS.{i}.POSITION': position,
                            f'{award_name}.PLAYERS.{i}.TEAM_ID': team_id,
                            f'{award_name}.PLAYERS.{i}.TEAM_ABBR': team_abbreviation,
                            f'{award_name}.PLAYERS.{i}.CONFERENCE': conf,
                        }}
                    )
                else:
                    try:
                        first_name = result['FIRST_NAME']
                    except KeyError:
                        first_name = ''

                    try:
                        last_name = result['LAST_NAME']
                    except KeyError:
                        last_name = ''

                    try:
                        position = result['POSITION']
                    except KeyError:
                        position = ''

                    try:
                        team_id = result['STATS'][award_data['SEASON']]['REGULAR SEASON']['BASIC']['TEAM_ID']

                        team_data = teams_collection.find_one({'TEAM_ID': team_id}, {'seasons': 1, '_id': 0})
                        conf = team_data['seasons'][award_data['SEASON']]['STANDINGS']['Conference']
                    except KeyError:
                        team_id = '0'
                        conf = ''

                    try:
                        team_abbreviation = result['STATS'][award_data['SEASON']]['REGULAR SEASON']['BASIC']['TEAM_ABBREVIATION']
                    except KeyError:
                        team_abbreviation = ''

                    lg_history_collection.update_one(
                        {'YEAR': year['YEAR']},
                        {"$set": {
                            f'{award_name}.PLAYERS.{i}.FIRST_NAME': first_name,
                            f'{award_name}.PLAYERS.{i}.LAST_NAME': last_name,
                            f'{award_name}.PLAYERS.{i}.POSITION': position,
                            f'{award_name}.PLAYERS.{i}.TEAM_ID': team_id,
                            f'{award_name}.PLAYERS.{i}.TEAM_ABBR': team_abbreviation,
                            f'{award_name}.PLAYERS.{i}.CONFERENCE': conf,
                        }}
                    )


def fetch_player_awards(players):
    awards = {}
    for j, player in enumerate(players):
        try:
            player_awards = playerawards.PlayerAwards(player).get_normalized_dict()['PlayerAwards']

            for award in player_awards:
                season = '19' + award['SEASON'][5:] if award['SEASON'][:4] < '2000' else '20' + award['SEASON'][5:]
                award_name = award['DESCRIPTION']
                award_keys = list(award.keys())[4:10]

                if season not in awards.keys():
                    awards[season] = {}

                if award_name not in awards[season].keys():
                    awards[season][award_name] = {key: award[key] for key in award_keys}
                    awards[season][award_name]['PLAYERS'] = []

                player_data = {
                    'PLAYER_ID': player,
                    'FIRST_NAME': award['FIRST_NAME'],
                    'LAST_NAME': award['LAST_NAME'],
                    'TEAM': award['TEAM']
                }

                for key in award_keys:
                    player_data[key] = award[key]

                awards[season][award_name]['PLAYERS'].append(player_data)

            logging.info(f"Updated {j + 1} of {len(players)}")

            # Pause for a random time between 0.5 and 2 seconds
            time.sleep(random.uniform(0.5, 2.0))

            # Pause 15 seconds for every 50 players
            if j % 50 == 0:
                time.sleep(15)

        except Exception as e:
            logging.error(f"Unable to process player {player}: {e}")
            continue

    for season in awards.keys():
        for award in awards[season].keys():
            lg_history_collection.update_one(
                {"YEAR": season},
                {"$set": {award: awards[season][award]}},
                upsert=True
            )


def fetch_team_awards(team_id):
    team_details = teamdetails.TeamDetails(team_id).get_normalized_dict()
    league_title_years = [team_dict['YEARAWARDED'] for team_dict in team_details['TeamAwardsChampionships']]
    conf_title_years = [team_dict['YEARAWARDED'] for team_dict in team_details['TeamAwardsConf']]
    div_title_years = [team_dict['YEARAWARDED'] for team_dict in team_details['TeamAwardsDiv']]

    for year in league_title_years:
        lg_history_collection.update_one(
            {"YEAR": year},
            {"$set": {"CHAMPION": team_id}},
            upsert=True
        )


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        lg_history_collection = db.nba_league_history
        teams_collection = db.nba_teams
        players_collection = db.nba_players
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")

    #for i, team in enumerate(teams_collection.find({}, {'TEAM_ID': 1, '_id': 0})):
        #logging.info(f"Processing {i + 1} of 30...")
        #fetch_team_awards(team['TEAM_ID'])

    #all_players = commonallplayers.CommonAllPlayers().get_normalized_dict()['CommonAllPlayers']
    #player_ids = [player['PERSON_ID'] for player in all_players]
    #fetch_player_awards(player_ids)
    player_award_details()
