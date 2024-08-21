from pymongo import MongoClient
from splash_nba.util.env import uri
import logging
import requests
import json


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
        return player_contract
    else:
        print(f"Request failed with status code {response.status_code}")
        print(response.text)


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    logging.info("Connected to MongoDB")

    # Define the GraphQL endpoint
    url = "https://fanspo.com/api/graphql"

    # Define the headers
    headers = {
        "Content-Type": "application/json"
    }

    # Start updating from the 1372nd document
    starting_index = 1692

    # Update each document in the collection starting from the 1372nd
    for i, player in enumerate(players_collection.find().skip(starting_index)):
        logging.info(f'Processing {starting_index + i} of {players_collection.count_documents({})}...')

        player_id = str(player['PERSON_ID'])

        # Define the initial query variables
        variables = {
            "playerId": player_id
        }

        # Fetch all paginated data
        contracts = fetch_player_contract_data(url, variables, headers)

        players_collection.update_one(
            {"PERSON_ID": int(player_id)},
            {"$set": {'CONTRACTS': contracts}},
        )
