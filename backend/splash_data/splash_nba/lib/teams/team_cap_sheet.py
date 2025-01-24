import json
import logging
import requests
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import uri
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import uri
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def merge_contracts(contracts):
    merged_contracts = {}

    for contract in contracts['contracts']:
        player_id = contract['player']['id']
        contract_type = contract['contractType']

        if player_id in merged_contracts:
            # Merge the contracts by year
            for year in contract['years']:
                start_year = str(year['fromYear'])

                # Check if the year already exists
                if start_year in merged_contracts[player_id]['years']:
                    # If the year already exists, keep the upcoming contract's year data
                    if contract_type == 'upcoming':
                        merged_contracts[player_id]['years'][start_year] = year
                else:
                    # If the year doesn't exist, add it to the map
                    merged_contracts[player_id]['years'][start_year] = year

            # Update the contractType if it's an upcoming contract
            if contract_type == 'upcoming':
                merged_contracts[player_id]['contractType'] = 'upcoming'
        else:
            # First time adding this player's contract
            merged_contracts[player_id] = contract.copy()
            # Convert years to a map
            merged_contracts[player_id]['years'] = {
                str(year['fromYear']): year for year in contract['years']
            }

    # Convert the merged contracts map back to a list
    return list(merged_contracts.values())


def add_totals_row(contracts):
    years = [
        '\'24-25',
        '\'25-26',
        '\'26-27',
        '\'27-28',
        '\'28-29',
        '\'29-30',
    ]

    totals_row = {
        'player': {'id': 'totals', 'firstName': '', 'lastName': 'Total'},
        'years': {
            f"20{year[1:3]}": {'capHit': 0, 'age': '0'} for year in years
        }
    }

    age_sums = {}  # To store the sum of ages for each year
    player_counts = {}  # To store the count of players for each year

    # Iterate over each contract and sum the cap hits and ages
    for contract in contracts['contracts']:
        for year_key in totals_row['years'].keys():
            if year_key in contract['years']:
                totals_row['years'][year_key]['capHit'] += contract['years'][year_key]['capHit']

                # Parse the age string and count the players for calculating the average age
                age_string = contract['years'][year_key].get('age', '')
                if age_string:
                    age = float(age_string)
                    if age > 0:
                        age_sums[year_key] = age_sums.get(year_key, 0) + age
                        player_counts[year_key] = player_counts.get(year_key, 0) + 1

    # Calculate the average age for each year and round to one decimal place
    for year_key in totals_row['years'].keys():
        if player_counts.get(year_key, 0) > 0:
            average_age = age_sums[year_key] / player_counts[year_key]
            totals_row['years'][year_key]['age'] = f"{average_age:.1f}"
        else:
            totals_row['years'][year_key]['age'] = '0'

    # Add the totals row to the contracts list
    contracts['contracts'].append(totals_row)
    return contracts


def update_team_contract_data():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams
    players_collection = db.nba_players

    # Define the GraphQL endpoint
    url = "https://fanspo.com/api/graphql"

    # Define the headers
    headers = {
        "Content-Type": "application/json"
    }

    team_id_map = {
        1610612737: '1',
        1610612738: '2',
        1610612751: '3',
        1610612766: '4',
        1610612741: '5',
        1610612739: '6',
        1610612742: '7',
        1610612743: '8',
        1610612765: '9',
        1610612744: '10',
        1610612745: '11',
        1610612754: '12',
        1610612746: '13',
        1610612747: '14',
        1610612763: '15',
        1610612748: '16',
        1610612749: '17',
        1610612750: '18',
        1610612740: '19',
        1610612752: '20',
        1610612760: '21',
        1610612753: '22',
        1610612755: '23',
        1610612756: '24',
        1610612757: '25',
        1610612758: '26',
        1610612759: '27',
        1610612761: '28',
        1610612762: '29',
        1610612764: '30'
    }

    # Update each document in the collection starting from index
    for i, team in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "_id": 0})):
        if team['TEAM_ID'] != 0:
            logging.info(f'(Team Contracts) Processing {i + 1} of 30...')

            # Define the initial query variables
            variables = {
                "teamId": team_id_map[team['TEAM_ID']],
                "seasonId": "_2024"
            }

            # Fetch all paginated data
            contracts = fetch_team_contract_data(url, variables, headers)
            contracts['contracts'] = merge_contracts(contracts)
            add_totals_row(contracts)

            position_map = {
                'Guard': 'G',
                'Guard-Forward': 'G-F',
                'Forward-Guard': 'F-G',
                'Forward': 'F',
                'Forward-Center': 'F-C',
                'Center-Forward': 'C-F',
                'Center': 'C',
                '': ''
            }

            for contract in contracts['contracts']:
                if contract['player']['id'] != 'totals':
                    player = players_collection.find_one({'PERSON_ID': int(contract['playerId'])}, {'_id': 0, 'POSITION': 1})
                    if player:
                        position = player.get('POSITION', None)
                        if position is not None:
                            contract['position'] = position_map[position]

            teams_collection.update_one(
                {"TEAM_ID": team['TEAM_ID']},
                {"$set": {'CAP_SHEET': contracts}},
            )


def fetch_team_contract_data(url, variables, headers):

    # Define the query payload
    payload = {
        "operationName": "nba_tmTeamContracts",
        "variables": variables,
        "query": """
    query nba_tmTeamContracts($teamId: String!, $seasonId: nba_SeasonIds, $extraIds: [String]) {
      nba_tradeMachineTeam(teamId: $teamId, seasonId: $seasonId) {
        teamId
        seasonId
        isHardCapped
        hardCapReasons
        contracts(extraPlayerIds: $extraIds) {
          playerId
          contractType
          startYear
          startTeamId
          amountTotal
          notes
          averageSalary
          signedUsing
          updatedAt
          years {
            age
            teamId
            fromYear
            toYear
            baseSalary
            nonGuaranteed
            partiallyGuaranteed
            qualifyingOffer
            playerOption
            teamOption
            deadYear
            capHit
            deadCap
          }
          player {
            id
            teamId
            firstName
            lastName
            fullName
            fromYear
          }
        }
      }
    }
    """
    }

    # Make the POST request
    response = requests.post(url, headers=headers, data=json.dumps(payload))

    # Check for errors
    if response.status_code == 200:
        # Parse the JSON response
        data = response.json()
        team_contracts = data['data']['nba_tradeMachineTeam']
        return team_contracts
    else:
        logging.error(f"(Team Contracts) Request failed with status code {response.status_code}: {response.text}")


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams
    players_collection = db.nba_players
    logging.info("Connected to MongoDB")

    # Define the GraphQL endpoint
    url = "https://fanspo.com/api/graphql"

    # Define the headers
    headers = {
        "Content-Type": "application/json"
    }

    team_id_map = {
        1610612737: '1',
        1610612738: '2',
        1610612751: '3',
        1610612766: '4',
        1610612741: '5',
        1610612739: '6',
        1610612742: '7',
        1610612743: '8',
        1610612765: '9',
        1610612744: '10',
        1610612745: '11',
        1610612754: '12',
        1610612746: '13',
        1610612747: '14',
        1610612763: '15',
        1610612748: '16',
        1610612749: '17',
        1610612750: '18',
        1610612740: '19',
        1610612752: '20',
        1610612760: '21',
        1610612753: '22',
        1610612755: '23',
        1610612756: '24',
        1610612757: '25',
        1610612758: '26',
        1610612759: '27',
        1610612761: '28',
        1610612762: '29',
        1610612764: '30'
    }

    # Start updating from index
    starting_index = 0

    # Update each document in the collection starting from index
    for i, team in enumerate(teams_collection.find().skip(starting_index)):
        logging.info(f'Processing {starting_index + i} of 30...')

        # Define the initial query variables
        variables = {
            "teamId": team_id_map[team['TEAM_ID']],
            "seasonId": "_2024"
        }

        # Fetch all paginated data
        contracts = fetch_team_contract_data(url, variables, headers)
        contracts['contracts'] = merge_contracts(contracts)
        add_totals_row(contracts)

        position_map = {
            'Guard': 'G',
            'Guard-Forward': 'G-F',
            'Forward-Guard': 'F-G',
            'Forward': 'F',
            'Forward-Center': 'F-C',
            'Center-Forward': 'C-F',
            'Center': 'C',
            '': ''
        }

        for contract in contracts['contracts']:
            if contract['player']['id'] != 'totals':
                player = players_collection.find_one({'PERSON_ID': int(contract['playerId'])}, {'_id': 0, 'POSITION': 1})
                if player:
                    position = player.get('POSITION', None)
                    if position is not None:
                        contract['position'] = position_map[position]

        teams_collection.update_one(
            {"TEAM_ID": team['TEAM_ID']},
            {"$set": {'CAP_SHEET': contracts}},
        )
