import re
from datetime import datetime

from pymongo import MongoClient
from unidecode import unidecode

from splash_nba.util.env import uri
import logging
import requests
import json
from bs4 import BeautifulSoup


def player_synergy_ids(team, team_sr_id):
    # URL template for fetching player news
    url = f"https://basketball.synergysportstech.com/api/teams/{team_sr_id}/players"

    # Headers from your browser request
    headers = {
        'accept': 'application/json, text/plain, */*',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9',
        'authorization': 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjhDRjI4QTUzNTUzOURFMDU3ODFEOEFCRkQ5QUY4QUY1IiwidHlwIjoiYXQrand0In0.eyJpc3MiOiJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tIiwibmJmIjoxNzMxOTY1OTU0LCJpYXQiOjE3MzE5NjU5NTQsImV4cCI6MTczMTk2NjU1NCwiYXVkIjpbImFwaS5jb25maWciLCJhcGkuc2VjdXJpdHkiLCJhcGkuYmFza2V0YmFsbCIsImFwaS5zcG9ydCIsImFwaS5lZGl0b3IiLCJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tL3Jlc291cmNlcyJdLCJzY29wZSI6WyJvcGVuaWQiLCJhcGkuY29uZmlnIiwiYXBpLnNlY3VyaXR5IiwiYXBpLmJhc2tldGJhbGwiLCJhcGkuc3BvcnQiLCJhcGkuZWRpdG9yIiwib2ZmbGluZV9hY2Nlc3MiXSwiYW1yIjpbInB3ZCJdLCJjbGllbnRfaWQiOiJjbGllbnQuYmFza2V0YmFsbC50ZWFtc2l0ZSIsInN1YiI6IjY1OGIyMTNlYjE0YzE3OGRmYzgzOWExZiIsImF1dGhfdGltZSI6MTczMTAyMDQ5OSwiaWRwIjoibG9jYWwiLCJlbWFpbCI6ImphY2ttb2xlQG91dGxvb2suY29tIiwibmFtZSI6IkphY2sgTW9sZXR0ZWlyZSIsInNpZCI6IkVCQzgzNTA3NkEzQzdBQzdGQTM1N0Q5QTQwRUZENzFFIn0.WtZTIwWprqJtmy-wf5-_P6USaxG7D8obFRNwHTqmiaLKxm7AGZaOHnHaG43Rga6GoKV9GC0zstDQP6JYwxLfdme2sEVduL1i-x7NeGKj95K4CdsFi_iWKhtPWKV0zcHg6sE3_eSx4SyIc8e2h_CnkZu6dT181MUmF2k8w79cQ3q1z5P9XJAJDWSeNbUn05fZJiiLwqKS75FCaNm3cqv4gBtgD9aIlj8l8ZRsCYn9Ed3Eo-0K9dos-69s4gO9NB3t1yVsulyW2ol8BELFDV__JHctfizo5BFHWWByG8hcV6IzCckJ45KPyMP3f3LOfsEYQuqJmxOHk6WCqJfPrOUghw',
        'origin': 'https://apps.synergysports.com',
        'referer': 'https://apps.synergysports.com/',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        'sec-fetch-site': 'cross-site'
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        total_players = len(response.json()["result"])
        for i, player in enumerate(response.json()['result']):
            logging.info(f'Processing {i + 1} of {total_players}...')

            # Define the search criteria
            try:
                player_id = player['ids']
                sr_id = player['id']
            except KeyError:
                continue

            # Query the database
            results = players_collection.aggregate([
                {
                    "$search": {
                        "index": "person_id",
                        "equals": {
                            "value": player_id,
                            "path": "PERSON_ID"
                        }
                    }
                },
                {
                    "$project": {
                        "PERSON_ID": 1,
                        "DISPLAY_FIRST_LAST": 1,
                        "_id": 0,
                    }
                }
            ])

            result = list(results)

            # If a match is found, update the SR_ID
            if result:
                player_id = result[0]["PERSON_ID"]
                players_collection.update_one(
                    {"PERSON_ID": player_id},
                    {"$push": {f"SR_ID.{team}": sr_id}}
                )
                logging.info(f"Added SR ID for {result[0]['DISPLAY_FIRST_LAST']}")
            else:
                logging.info(f"No match found for player {player['name']}.")
                continue

    else:
        logging.error(f"Failed to get players. Status code: {response.status_code}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    players_collection = db.nba_players
    teams_collection = db.nba_teams

    for team in teams_collection.find({}, {'SR_ID': 1, 'ABBREVIATION': 1, '_id': 0}).skip(14):
        logging.info(f"Processing {team['ABBREVIATION']}...")
        if team['SR_ID']:
            player_synergy_ids(team['ABBREVIATION'], team['SR_ID'])
        else:
            logging.info(f"No SR_ID for {team['ABBREVIATION']}")
            continue
