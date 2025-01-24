import logging
import requests
import json
import difflib
from pymongo import MongoClient

try:
    # Try to import the local env.py file
    from splash_nba.util.env import PROXY, URI
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def is_similar(description1, description2, threshold=0.4):
    similarity = difflib.SequenceMatcher(None, description1, description2).ratio()
    return similarity >= threshold


def keep_most_informative(records):
    unique_records = []
    seen_combinations = {}

    for record in records:
        # Create a key based on the teamId, year, month, and transactionType
        key = (record['teamId'], record['date'][:4], record['date'][5:7], record['transactionType'])

        if key not in seen_combinations:
            seen_combinations[key] = record
        else:
            existing_record = seen_combinations[key]
            if is_similar(existing_record['description'], record['description']):
                # Choose the record with the most informative description
                if len(record['description']) > len(existing_record['description']):
                    seen_combinations[key] = record
            else:
                unique_records.append(record)

    unique_records.extend(seen_combinations.values())
    return unique_records


def fetch_player_contract_data(url, player_id, headers):

    # Define the query payload
    payload = {
        "operationName": "nba_playerPage",
        "variables": player_id,
        "query": """
        query nba_playerPage($playerId: String!) {
          nba_player(id: $playerId) {
            id
            firstName
            lastName
            fullName
            fromYear
            toYear
            isActive
            headshotURL
            siloURL
            team {
              id
              city
              shortName
              longName
              urlName
              triName
              primaryColor
              secondaryColor
              tertiaryColor
            }
            contracts {
              contractType
              amountTotal
              startYear
              yearsTotal
              averageSalary
              freeAgentYear
              freeAgentType
              notes
              signedUsing
              signingBonus
              sourceLink
              sourceText
              years {
                teamId
                teamName
                age
                baseSalary
                blockTradeClause
                capHit
                deadCap
                deadYear
                fromYear
                incentive
                noTradeClause
                nonGuaranteed
                partiallyGuaranteed
                playerOption
                qualifyingOffer
                teamOption
                toYear
              }
            }
          }
          nba_player(id: $playerId) {
            id
            agents {
              id
              firstName
              fullName
              agencyName
              agencyWebsite
              headshotURL
              isActive
              rank {
                id
                contractTotalValue
                contractSeasonValue
                contractCount
                teamCount
                teamNames
                teamIds
                ranking
              }
            }
          }
          nba_player(id: $playerId) {
            id
            transactions {
              id
              date
              description
              teamId
              toTeamId
              fromTeamId
              transactionType
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
        player_contract = data['data']['nba_player']['contracts']
        player_transactions = data['data']['nba_player']['transactions']
        return player_contract, player_transactions
    else:
        print(f"Request failed with status code {response.status_code}")
        print(response.text)


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(URI)
    db = client.splash
    players_collection = db.nba_players
    logging.info("Connected to MongoDB")

    # Define the GraphQL endpoint
    url = "https://fanspo.com/api/graphql"

    # Define the headers
    headers = {
        "Content-Type": "application/json"
    }

    # Start updating from index
    starting_index = 0

    # Update each document in the collection starting from index
    for i, player in enumerate(players_collection.find({"ROSTERSTATUS": 'Active'}).skip(starting_index)):
        logging.info(f'Processing {starting_index + i} of {players_collection.count_documents({"ROSTERSTATUS": "Active"})}...')

        player_id = str(player['PERSON_ID'])

        # Define the initial query variables
        variables = {
            "playerId": player_id
        }

        # Fetch all paginated data
        contracts, transactions = fetch_player_contract_data(url, variables, headers)
        transactions = keep_most_informative(transactions)

        players_collection.update_one(
            {"PERSON_ID": int(player_id)},
            {"$set": {'CONTRACTS': contracts, 'TRANSACTIONS': transactions}},
        )
