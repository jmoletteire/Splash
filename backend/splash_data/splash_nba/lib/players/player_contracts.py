import json
import logging
import requests
from splash_nba.imports import get_mongo_collection


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
              __typename
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
                __typename
              }
              __typename
            }
            __typename
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
                __typename
              }
              __typename
            }
            __typename
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
              __typename
            }
            __typename
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
        print(json.dumps(data, indent=2))  # Pretty-print the JSON response
    else:
        print(f"Request failed with status code {response.status_code}")
        print(response.text)


# Function to fetch paginated data
def fetch_paginated_data(url, variables, headers):
    all_data = []

    while True:
        # Define the query payload
        payload = {
            "operationName": "nba_pageContractsList",
            "variables": variables,
            "query": """
            query nba_pageContractsList($position: nba_PlayerPositionTypes, $sortBy: nba_PlayerSortBy, $limit: Int, $after: String) {
              nba_playerList(
                position: $position
                sortBy: $sortBy
                first: $limit
                after: $after
              ) {
                total
                pageInfo {
                  hasNextPage
                  startCursor
                  endCursor
                }
                edges {
                  node {
                    id
                    teamId
                    nbaDebut
                    positions
                    contractType
                    contractAmountTotal
                    contractAverageSalary
                    contractYearsTotal
                    contractStartYear
                    contractStartTeamId
                    contractStartTeamTriName
                    contractFreeAgentYear
                    contractFreeAgentType
                    contractSignedUsing
                    ranking
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
            player_list = data['data']['nba_playerList']

            # Append the current page of data to the all_data list
            all_data.extend(player_list['edges'])

            # Check if there's another page
            if player_list['pageInfo']['hasNextPage']:
                # Update the 'after' variable for the next request
                variables['after'] = player_list['pageInfo']['endCursor']
            else:
                # No more pages left, break the loop
                break
        else:
            print(f"Request failed with status code {response.status_code}")
            print(response.text)
            break

    return all_data


if __name__ == '__main__':
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
    logging.info("Connected to MongoDB")

    # Define the GraphQL endpoint
    url = "https://fanspo.com/api/graphql"

    # Define the initial query variables
    variables = {
        "sortBy": {
            "name": "contractAmountTotal",
            "direction": "desc"
        },
        "limit": 200,
        "after": None  # Initially set to None for the first request
    }

    variables_two = {
        "playerId": player_id
    }

    # Define the headers
    headers = {
        "Content-Type": "application/json"
    }

    # Fetch all paginated data
    all_contracts = fetch_paginated_data(url, variables, headers)

    for player in all_contracts:
        player_data = player['node']

        contract_keys = [
            "contractType",
            "contractAmountTotal",
            "contractAverageSalary",
            "contractYearsTotal",
            "contractStartYear",
            "contractStartTeamId",
            "contractStartTeamTriName",
            "contractFreeAgentYear",
            "contractFreeAgentType"
        ]

        contract_data = {key: player_data[key] for key in contract_keys}

        players_collection.update_one(
            {"PERSON_ID": int(player_data["id"])},
            {"$set": {'CONTRACT': contract_data}},
        )

        logging.info(f"Updated {player_data['id']}")
