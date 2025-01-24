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


def team_synergy_ids():
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    teams_collection = db.nba_teams

    # URL template for fetching player news
    url = "https://basketball.synergysportstech.com/api/leagues/54457dce300969b132fcfb34/teamswithstats"

    # Headers from your browser request
    headers = {
        'accept': 'application/json, text/plain, */*',
        'accept-encoding': 'gzip, deflate, br, zstd',
        'accept-language': 'en-US,en;q=0.9',
        'authorization': 'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjhDRjI4QTUzNTUzOURFMDU3ODFEOEFCRkQ5QUY4QUY1IiwidHlwIjoiYXQrand0In0.eyJpc3MiOiJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tIiwibmJmIjoxNzMxMjczOTE5LCJpYXQiOjE3MzEyNzM5MTksImV4cCI6MTczMTI3NDUxOSwiYXVkIjpbImFwaS5jb25maWciLCJhcGkuc2VjdXJpdHkiLCJhcGkuYmFza2V0YmFsbCIsImFwaS5zcG9ydCIsImFwaS5lZGl0b3IiLCJodHRwczovL2F1dGguc3luZXJneXNwb3J0c3RlY2guY29tL3Jlc291cmNlcyJdLCJzY29wZSI6WyJvcGVuaWQiLCJhcGkuY29uZmlnIiwiYXBpLnNlY3VyaXR5IiwiYXBpLmJhc2tldGJhbGwiLCJhcGkuc3BvcnQiLCJhcGkuZWRpdG9yIiwib2ZmbGluZV9hY2Nlc3MiXSwiYW1yIjpbInB3ZCJdLCJjbGllbnRfaWQiOiJjbGllbnQuYmFza2V0YmFsbC50ZWFtc2l0ZSIsInN1YiI6IjY1OGIyMTNlYjE0YzE3OGRmYzgzOWExZiIsImF1dGhfdGltZSI6MTczMTAyMDQ5OSwiaWRwIjoibG9jYWwiLCJlbWFpbCI6ImphY2ttb2xlQG91dGxvb2suY29tIiwibmFtZSI6IkphY2sgTW9sZXR0ZWlyZSIsInNpZCI6IkVCQzgzNTA3NkEzQzdBQzdGQTM1N0Q5QTQwRUZENzFFIn0.OP-kEOXWVSYKebAgpEN7biUwTd_kredUZA1oj1UwAVV25KsvDfXh-VbdGqOiqNRGwqKDO04JFDh7gDpKjvLQs7dIKxBJ_w9wOvVd2d-P8feVpnhRfJnrO_ayNVKbHTyEcpXP2X6yx24TzP7a1f5l8Z2wDyi1ZZA4esQJJZOwta795VOycXoXvy9fr_0wUAYgYzD4y93ObDfAtOPXYXSFgFVqmSj4jPcWBb8zFPlaqfvj3dHiR912GTJHoPZ5kIGfy1MjIucWnX8h_AGD6yWZWQQziYPpqOLa54NrNouQtewQ16qd5sELkDiqdn4IUcBdVwAki-du_ZH49KEEO6vEyw',
        'origin': 'https://apps.synergysports.com',
        'referer': 'https://apps.synergysports.com/',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
        'sec-fetch-site': 'cross-site'
    }

    payload = {"seasonId": "66ec94cbd172189f95bf08b2",
               "competitionIds": [
                   "560100ac8dc7a24394b955ef",
                   "560100ac8dc7a24394b955ee",
                   "60cbbbb6a30289aed3a4e830",
                   "651ee9487b33040f529bc19d",
                   "651eeb0996628e43f40cbf59"
               ],
               "conferenceIds": None,
               "divisionIds": None,
               "teamAId": None,
               "teamBId": None,
               "type": None,
               "offensiveRole": None,
               "transferStatus": None,
               "comparisonGroupId": "648ac7b0a79824aa31db2b4d",
               "view": None,
               "take": 6000,
               "sportId": "570aaedc46c5d11de0f8c0bc"}

    response = requests.post(url, headers=headers, json=payload)

    if response.status_code == 200:
        for team in response.json()['result']:
            # Define the search criteria
            team_id = team['idsTeam']
            sr_id = team['id']

            try:
                teams_collection.update_one(
                    {"TEAM_ID": team_id},
                    {"$set": {"SR_ID": sr_id}}
                )
                logging.info(f"Added SR ID for {team['fullName']}")
            except Exception as e:
                print(f"No match found for team {team['fullName']}.")

    else:
        logging.error(f"Failed to get teams. Status code: {response.status_code}")


if __name__ == "__main__":
    team_synergy_ids()
