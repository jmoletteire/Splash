from pymongo import MongoClient
from splash_nba.util.env import uri
import logging
import requests
import json


def update_team_contract_data():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams

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

        teams_collection.update_one(
            {"TEAM_ID": team['TEAM_ID']},
            {"$set": {'CAP_SHEET': contracts}},
        )
