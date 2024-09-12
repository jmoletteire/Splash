from nba_api.stats.endpoints import drafthistory, commonplayerinfo, playerawards
from pymongo import MongoClient
from splash_nba.util.env import uri
from datetime import datetime
import logging


def age_at_draft(year, birth_date):
    try:
        # Step 1: Parse the Year and set the date to July 1st of that year
        july_first = datetime(int(year), 7, 1)

        # Step 2: Parse the birthdate string
        birth_date = datetime.strptime(birth_date, "%Y-%m-%dT%H:%M:%S")

        # Step 3: Calculate age
        age = july_first.year - birth_date.year

        # Step 4: Check if the person has already had their birthday by July 1st of the given year
        if (july_first.month, july_first.day) < (birth_date.month, birth_date.day):
            age -= 1
    except Exception as e:
        logging.error(e)
        age = 0

    return age


def get_awards(player):
    award_checks = {
        'hof': 0,
        'mvp': 0,
        'all_nba': 0,
        'all_star': 0,
        'roty': 0,
    }
    result = players_collection.find_one({'PERSON_ID': player}, {'AWARDS': 1, '_id': 0})

    if result is None:
        awards = playerawards.PlayerAwards(player_id=player).get_normalized_dict()['PlayerAwards']
        for award in awards:
            if award['DESCRIPTION'] == 'Hall of Fame Inductee':
                award_checks['hof'] = 1
            elif award['DESCRIPTION'] == 'NBA Most Valuable Player':
                award_checks['mvp'] = 1
            elif award['DESCRIPTION'] == 'All-NBA':
                award_checks['all_nba'] = 1
            elif award['DESCRIPTION'] == 'NBA All-Star':
                award_checks['all_star'] = 1
            elif award['DESCRIPTION'] == 'NBA Rookie of the Year':
                award_checks['roty'] = 1
    else:
        if 'Hall of Fame Inductee' in result['AWARDS'].keys():
            award_checks['hof'] = 1
        if 'NBA Most Valuable Player' in result['AWARDS'].keys():
            award_checks['mvp'] = 1
        if 'All-NBA' in result['AWARDS'].keys():
            award_checks['all_nba'] = 1
        if 'NBA All-Star' in result['AWARDS'].keys():
            award_checks['all_star'] = 1
        if 'NBA Rookie of the Year' in result['AWARDS'].keys():
            award_checks['roty'] = 1

    return award_checks


def get_additional_info():
    for draft in draft_collection.find():
        year = draft['YEAR']
        hof = 0
        mvp = 0
        all_nba = 0
        all_star = 0
        for player in draft['SELECTIONS']:
            try:
                player_data = commonplayerinfo.CommonPlayerInfo(player['PERSON_ID']).get_normalized_dict()['CommonPlayerInfo'][0]
                player['POSITION'] = player_data['POSITION']
                player['AGE'] = age_at_draft(year, player_data['BIRTHDATE'])
                player['HEIGHT'] = player_data['HEIGHT']
                player['WEIGHT'] = player_data['WEIGHT']
                player['LAST_PLAYED'] = player_data['TO_YEAR']

                awards = get_awards(player['PERSON_ID'])
                player['HOF'] = awards['hof']
                player['MVP'] = awards['mvp']
                player['ALL_NBA'] = awards['all_nba']
                player['ALL_STAR'] = awards['all_star']
                player['ROTY'] = awards['roty']

                hof += awards['hof']
                mvp += awards['mvp']
                all_nba += awards['all_nba']
                all_star += awards['all_star']

                logging.info(f" Added info for player {player}")
            except Exception as e:
                logging.error(f" Failed to add info for {player}: {e}")

        draft_collection.update_one(
            {"YEAR": draft['YEAR']},
            {"$set": {
                "SELECTIONS": draft['SELECTIONS'],
                "HOF": hof,
                "MVP": mvp,
                "ALL_NBA": all_nba,
                "ALL_STAR": all_star,
            }},
        )


def draft_history():
    draft_hist = drafthistory.DraftHistory().get_normalized_dict()['DraftHistory']

    # Organize the data into the desired format
    organized_data = {}
    for entry in draft_hist:
        year = entry['SEASON']
        if year not in organized_data:
            organized_data[year] = {
                "DRAFT_YEAR": year,
                "SELECTIONS": []
            }
        organized_data[year]['SELECTIONS'].append(entry)

    try:
        # Insert or update the draft history in MongoDB
        for draft in organized_data.values():
            draft_collection.update_one(
                {"YEAR": draft["DRAFT_YEAR"]},
                {"$set": draft},
                upsert=True
            )
        logging.info("Updated draft histories.")
    except Exception as e:
        logging.error(f"Error updating draft history: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    client = MongoClient(uri)
    db = client.splash
    draft_collection = db.nba_draft_history
    players_collection = db.nba_players
    logging.info("Connected to MongoDB")

    #draft_history()
    get_additional_info()
