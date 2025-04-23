import time
import logging
from json import JSONDecodeError

from nba_api.stats.endpoints import commonteamroster, playercareerstats
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS, CURR_SEASON, PREV_SEASON


def update_current_roster(team_id, season_not_started):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
        players_collection = get_mongo_collection('nba_players')
    except Exception as e:
        logging.error(f"\t(Team Rosters) Failed to connect to MongoDB: {e}", exc_info=True)
        return

    try:
        team_data = commonteamroster.CommonTeamRoster(team_id, season=CURR_SEASON, proxy=PROXY, headers=HEADERS).get_normalized_dict()
        team_roster = team_data['CommonTeamRoster']
        team_coaches = team_data['Coaches']
    except Exception as e:
        logging.error(f"\t(Team Rosters) Unable to fetch {CURR_SEASON} roster for team {team_id}: {e}", exc_info=True)
        return

    try:
        team_roster_dict = {}

        # If team has no games played, use previous season player stats
        if season_not_started:
            player_season = PREV_SEASON
        else:
            player_season = CURR_SEASON

        # Get player stats
        for player in team_roster:
            try:
                player_stats = playercareerstats.PlayerCareerStats(player_id=player['PLAYER_ID'], proxy=PROXY, headers=HEADERS).get_normalized_dict()['SeasonTotalsRegularSeason']
            except JSONDecodeError:
                player_stats = []

            player_season_stats = [season_stats for season_stats in player_stats if season_stats['SEASON_ID'] == player_season and season_stats['TEAM_ID'] == team_id]
            try:
                if len(player_season_stats) > 0:
                    player['GP'] = player_season_stats[0]['GP'] if player_season_stats[0]['GP'] is not None else 0
                    player['GS'] = player_season_stats[0]['GS'] if player_season_stats[0]['GS'] is not None else 0
                    player['MIN'] = player_season_stats[0]['MIN'] if player_season_stats[0]['MIN'] is not None else 0

                    try:
                        player['MPG'] = player['MIN'] / player['GP']
                    except ZeroDivisionError:
                        player['MPG'] = 0
                else:
                    player['GP'] = 0
                    player['GS'] = 0
                    player['MIN'] = 0
                    player['MPG'] = 0

                try:
                    player_roto = players_collection.find_one({'PERSON_ID': player['PLAYER_ID']}, {'PlayerRotowires': 1, '_id': 0})['PlayerRotowires'][0]
                    player['Injured'] = player_roto['Injured']
                    player['Injured_Status'] = player_roto['Injured_Status']
                    player['Injury_Location'] = player_roto['Injury_Location']
                    player['Injury_Type'] = player_roto['Injury_Type']
                    player['Injury_Detail'] = player_roto['Injury_Detail']
                    player['Injury_Side'] = player_roto['Injury_Side']
                    player['EST_RETURN'] = player_roto['EST_RETURN']
                except Exception:
                    player['Injured'] = "NO"
                    player['Injured_Status'] = ""
                    player['Injury_Location'] = ""
                    player['Injury_Type'] = ""
                    player['Injury_Detail'] = ""
                    player['Injury_Side'] = ""
                    player['EST_RETURN'] = ""

                # Player dictionary {"player_id": {data}}
                team_roster_dict[str(player['PLAYER_ID'])] = player

            except Exception as e:
                logging.error(f"\t(Team Rosters) Unable to fetch {player['PLAYER']} for team {team_id} for {CURR_SEASON}: {e}", exc_info=True)
                player['GP'] = 0
                player['GS'] = 0
                player['MIN'] = 0
                player['MPG'] = 0
                player['Injured'] = "NO"
                player['Injured_Status'] = ""
                player['Injury_Location'] = ""
                player['Injury_Type'] = ""
                player['Injury_Detail'] = ""
                player['Injury_Side'] = ""
                player['EST_RETURN'] = ""
                team_roster_dict[str(player['PLAYER_ID'])] = player
                continue

        # Update document
        teams_collection.update_one(
            {"TEAM_ID": team_id},
            {"$set": {f"SEASONS.{CURR_SEASON}.ROSTER": team_roster_dict, f"SEASONS.{CURR_SEASON}.COACHES": team_coaches}},
            upsert=True
        )
        logging.info(f"\t(Team Rosters) Updated {CURR_SEASON} roster/coaches for team {team_id}")
    except Exception as e:
        logging.error(f"\t(Team Rosters) Unable to update {CURR_SEASON} roster for team {team_id}: {e}", exc_info=True)


def fetch_roster(team_id, season):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}", exc_info=True)
        return

    try:
        team_data = commonteamroster.CommonTeamRoster(team_id, season=season, proxy=PROXY, headers=HEADERS).get_normalized_dict()
        team_roster = team_data['CommonTeamRoster']
        team_coaches = team_data['Coaches']
    except Exception as e:
        logging.error(f"Unable to fetch {season} roster for team {team_id}: {e}", exc_info=True)
        return

    try:
        team_roster_dict = {}

        for player in team_roster:
            player_stats = playercareerstats.PlayerCareerStats(player_id=player['PLAYER_ID'], proxy=PROXY, headers=HEADERS).get_normalized_dict()['SeasonTotalsRegularSeason']
            player_season_stats = [season_stats for season_stats in player_stats if season_stats['SEASON_ID'] == season and season_stats['TEAM_ID'] == team_id]
            try:
                if len(player_season_stats) > 0:
                    player['GP'] = player_season_stats[0]['GP'] if player_season_stats[0]['GP'] is not None else 0
                    player['GS'] = player_season_stats[0]['GS'] if player_season_stats[0]['GS'] is not None else 0
                    player['MIN'] = player_season_stats[0]['MIN'] if player_season_stats[0]['MIN'] is not None else 0
                    if player['GP'] > 0:
                        player['MPG'] = player['MIN'] / player['GP']
                    else:
                        player['MPG'] = 0
                else:
                    player['GP'] = 0
                    player['GS'] = 0
                    player['MIN'] = 0
                    player['MPG'] = 0

                # Player dictionary {"player_id": {data}}
                team_roster_dict[str(player['PLAYER_ID'])] = player
            except Exception as e:
                logging.error(f"Unable to fetch {player['PLAYER']} for team {team_id} for {season}: {e}", exc_info=True)
                player['GP'] = 0
                player['GS'] = 0
                player['MIN'] = 0
                player['MPG'] = 0
                team_roster_dict[str(player['PLAYER_ID'])] = player
                continue

        # Update document
        teams_collection.update_one(
            {"TEAM_ID": team_id},
            {"$set": {f"SEASONS.{season}.ROSTER": team_roster_dict, f"SEASONS.{season}.COACHES": team_coaches}},
            upsert=True
        )
        logging.info(f"Updated {season} roster for team {team_id}")
    except Exception as e:
        logging.error(f"Unable to update {season} roster for team {team_id}: {e}", exc_info=True)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
        players_collection = get_mongo_collection('nba_players')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}", exc_info=True)
        exit(1)

    try:
        # All Teams
        for i, doc in enumerate(teams_collection.find({}, {"TEAM_ID": 1, "SEASONS": 1, "_id": 0})):
            team = doc['TEAM_ID']
            season_not_started = True if doc['SEASONS'][CURR_SEASON]['GP'] == 0 else False
            update_current_roster(team_id=team, season_not_started=season_not_started)
            #seasons = doc['SEASONS']
            #for season in seasons.keys():
            #    if season < '1980-81':
            #        fetch_roster(team, season)
            #        time.sleep(2)
            logging.info(f"Processed {i + 1} of 30")
            time.sleep(30)
        logging.info("Done")
    except Exception as e:
        logging.error(f"Error updating team rosters: {e}", exc_info=True)
