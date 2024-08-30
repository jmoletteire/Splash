from nba_api.stats.endpoints import leaguestandings, leaguedashteamstats
from pymongo import MongoClient
from splash_nba.util.env import uri, k_current_season
import logging
from collections import defaultdict


eastConfTeamIds = [
    1610612737,
    1610612738,
    1610612739,
    1610612741,
    1610612748,
    1610612749,
    1610612751,
    1610612752,
    1610612753,
    1610612754,
    1610612755,
    1610612761,
    1610612764,
    1610612765,
    1610612766
]

westConfTeamIds = [
    1610612740,
    1610612742,
    1610612743,
    1610612744,
    1610612745,
    1610612746,
    1610612747,
    1610612750,
    1610612756,
    1610612757,
    1610612758,
    1610612759,
    1610612760,
    1610612762,
    1610612763,
]


def determine_tiebreakers(season, standings):
    # Group teams by Division and DivisionRank
    division_rank_groups = defaultdict(lambda: defaultdict(list))
    for team in standings:
        division_rank_groups[team['Division']][team['DivisionRank']].append(team)

    # Iterate over each DivisionRank group
    for division, rank_groups in division_rank_groups.items():
        for rank, teams in rank_groups.items():
            if len(teams) > 1:
                logging.info(f"Tie for {rank} detected in {division} Division involving {len(teams)} teams.")
                if len(teams) == 2:
                    # Handle tiebreaker for two teams
                    break_tie_two_teams(season, teams, 'DivisionRank', standings)
                else:
                    # Handle tiebreaker for more than two teams
                    break_tie_multiple_teams(season, teams, 'DivisionRank', standings)
            else:
                logging.info(f"No tie for {rank} in {division} Division")

    # Group teams by PlayoffRank
    playoff_rank_groups = defaultdict(lambda: defaultdict(list))
    for team in standings:
        playoff_rank_groups[team['Conference']][team['PlayoffRank']].append(team)

    # Iterate over each PlayoffRank group
    for conference, rank_groups in playoff_rank_groups.items():
        for rank, teams in rank_groups.items():
            if len(teams) > 1:
                logging.info(f"Tie detected for {conference} {rank}-seed involving {len(teams)} teams.")
                if len(teams) == 2:
                    # Handle tiebreaker for two teams
                    break_tie_two_teams(season, teams, 'PlayoffRank', standings)
                else:
                    # Handle tiebreaker for more than two teams
                    break_tie_multiple_teams(season, teams, 'PlayoffRank', standings)
            else:
                logging.info(f"No tie for {conference} {rank}-seed")

    standings.sort(key=lambda x: x['PlayoffRank'])

    if season < '2015-16':
        division_winners = defaultdict(list)
        non_division_winners = defaultdict(list)
        for team in standings:
            if team['DivisionRank'] == 1:
                division_winners[team['Conference']].append(team)
            else:
                non_division_winners[team['Conference']].append(team)

        if season < '2006-07':
            for conference in division_winners.keys():
                # Sort the division winners
                division_winners[conference].sort(key=lambda x: x['PlayoffRank'])

                # Promote the division winners
                for i, team in enumerate(division_winners[conference]):
                    # Move the division winner into the appropriate spot
                    team['PlayoffRank'] = i + 1

                # Reassign PlayoffRank for non-division winners who were previously in the top 2 or 3
                for i, team in enumerate(non_division_winners[conference]):
                    team['PlayoffRank'] = len(division_winners[conference]) + i + 1
        else:
            for conference in division_winners.keys():
                # Sort the division winners that need to move into the top 4
                division_winners[conference].sort(key=lambda x: x['PlayoffRank'])
                non_division_winners[conference].sort(key=lambda x: x['PlayoffRank'])

                top4 = division_winners[conference] + non_division_winners[conference][0]
                top4.sort(key=lambda x: x['PlayoffRank'])

                # Promote the division winners into the top 4
                for i, team in enumerate(top4):
                    # Move the division winner into the appropriate top 4 spot
                    team['PlayoffRank'] = i + 1

                # Reassign PlayoffRank for non-division winners who were previously in the top 4
                for i, team in enumerate(non_division_winners[conference][1:]):
                    team['PlayoffRank'] = 4 + i + 1


def break_tie_two_teams(season, teams, rank, standings):
    team1, team2 = teams

    # (0) Better overall winning percentage
    if team1['WinPCT'] > team2['WinPCT']:
        logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on overall Win%.")
        team2[rank] += 1
    elif team2['WinPCT'] > team1['WinPCT']:
        logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on overall Win%.")
        team1[rank] += 1
    else:
        # (1) Better winning percentage in games against each other.
        team1_vs_team2 = leaguedashteamstats.LeagueDashTeamStats(
            season=season,
            team_id_nullable=team1['TeamID'],
            opponent_team_id=team2['TeamID']
        ).get_normalized_dict()['LeagueDashTeamStats']

        team1_pct = 0
        team2_pct = 0

        if team1_vs_team2:
            team1_pct = team1_vs_team2[0]['W_PCT']
            team2_pct = 1 - team1_pct

        logging.info(team1_pct)
        logging.info(team2_pct)
        if team1_pct > team2_pct:
            logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on head-to-head.")
            team2[rank] += 1
        elif team2_pct > team1_pct:
            logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on head-to-head.")
            team1[rank] += 1
        else:
            # (2) Division winner
            if team1['DivisionRank'] == 1 and team2['DivisionRank'] > 1:
                logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on division winner.")
                team2[rank] += 1
            elif team2['DivisionRank'] == 1 and team1['DivisionRank'] > 1:
                logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on division winner.")
                team1[rank] += 1
            else:
                # (3) Better winning percentage against teams in own division (only if tied teams are in the same division).
                if team1['Division'] == team2['Division'] and team1['DivisionRecord'] > team2['DivisionRecord']:
                    logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on division record.")
                    team2[rank] += 1
                elif team1['Division'] == team2['Division'] and team2['DivisionRecord'] > team1['DivisionRecord']:
                    logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on division record.")
                    team1[rank] += 1
                else:
                    # (4) Better winning percentage against teams in own conference.
                    if team1['ConferenceRecord'] > team2['ConferenceRecord']:
                        logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on conference record.")
                        team2[rank] += 1
                    elif team2['ConferenceRecord'] > team1['ConferenceRecord']:
                        logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on conference record.")
                        team1[rank] += 1
                    else:
                        # (5) Better winning percentage against playoff teams in own conference.
                        win_pcts = []
                        if season < '2019-20':
                            eastPlayoffEligible = [team['TeamID'] for team in standings if team['Conference'] == 'East' and team['PlayoffRank'] <= 10]
                            westPlayoffEligible = [team['TeamID'] for team in standings if team['Conference'] == 'West' and team['PlayoffRank'] <= 10]
                        else:
                            eastPlayoffEligible = [team['TeamID'] for team in standings if team['Conference'] == 'East' and team['PlayoffRank'] <= 8]
                            westPlayoffEligible = [team['TeamID'] for team in standings if team['Conference'] == 'West' and team['PlayoffRank'] <= 8]

                        for team in teams:
                            conf_teams = eastPlayoffEligible if team['Conference'] == 'East' else westPlayoffEligible
                            total_games = 0
                            total_wins = 0
                            for opponent in conf_teams:
                                if team != opponent:
                                    try:
                                        team_vs_opp = leaguedashteamstats.LeagueDashTeamStats(
                                            season=season,
                                            team_id_nullable=team['TeamID'],
                                            opponent_team_id=opponent
                                        ).get_normalized_dict()['LeagueDashTeamStats']

                                        if team_vs_opp:
                                            total_games += team_vs_opp[0]['GP']
                                            total_wins += team_vs_opp[0]['W']
                                    except Exception as e:
                                        logging.error(
                                            f"Error fetching win percentage for {team['TeamCity']} against {opponent['TeamCity']}: {e}")

                            # Average win percentage across all tied teams
                            try:
                                total_win_pct = total_wins / total_games
                            except ZeroDivisionError:
                                total_win_pct = 0.0

                            win_pcts.append(total_win_pct)

                        if win_pcts[0] > win_pcts[1]:
                            logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on win % vs playoff-eligible in own conference.")
                            team2[rank] += 1
                        elif win_pcts[1] > win_pcts[0]:
                            logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on win % vs playoff-eligible in own conference.")
                            team1[rank] += 1
                        else:
                            # (6) Better winning percentage against playoff teams in opposite conference.
                            win_pcts = []
                            for team in teams:
                                conf_teams = westPlayoffEligible if team['Conference'] == 'East' else eastPlayoffEligible
                                total_games = 0
                                total_wins = 0
                                for opponent in conf_teams:
                                    if team != opponent:
                                        try:
                                            team_vs_opp = leaguedashteamstats.LeagueDashTeamStats(
                                                season=season,
                                                team_id_nullable=team['TeamID'],
                                                opponent_team_id=opponent
                                            ).get_normalized_dict()['LeagueDashTeamStats']

                                            if team_vs_opp:
                                                total_games += team_vs_opp[0]['GP']
                                                total_wins += team_vs_opp[0]['W']
                                        except Exception as e:
                                            logging.error(
                                                f"Error fetching win percentage for {team['TeamCity']} against {opponent['TeamCity']}: {e}")

                                # Average win percentage across all tied teams
                                try:
                                    total_win_pct = total_wins / total_games
                                except ZeroDivisionError:
                                    total_win_pct = 0.0

                                win_pcts.append(total_win_pct)

                                if win_pcts[0] > win_pcts[1]:
                                    logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on win % vs playoff-eligible in opposite conference.")
                                    team2[rank] += 1
                                elif win_pcts[1] > win_pcts[0]:
                                    logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on win % vs playoff-eligible in opposite conference.")
                                    team1[rank] += 1
                                else:
                                    # (7) Better net points, all games.
                                    team1_net_pts = team1['DiffPointsPG'] * (team1['WINS'] + team1['LOSSES'])
                                    team2_net_pts = team2['DiffPointsPG'] * (team2['WINS'] + team2['LOSSES'])
                                    if team1_net_pts > team2_net_pts:
                                        logging.info(f"{team1['TeamCity']} wins the tiebreaker against {team2['TeamCity']} based on net points.")
                                        team2[rank] += 1
                                    elif team2_net_pts > team1_net_pts:
                                        logging.info(f"{team2['TeamCity']} wins the tiebreaker against {team1['TeamCity']} based on net points.")
                                        team1[rank] += 1
                                    else:
                                        logging.info("The tiebreaker couldn't be determined with the given criteria.")



def break_tie_multiple_teams(season, teams, rank, standings):
    # (1) Division winner
    if rank == 'PlayoffRank':
        division_winners = [team for team in teams if team['DivisionRank'] == 1]
        non_division_winners = []
        if division_winners:
            logging.info(f"Division winners found in tiebreaker group: {[team['TeamCity'] for team in division_winners]}")
            for team in teams:
                if team not in division_winners:
                    team['PlayoffRank'] += len(division_winners)
                    non_division_winners.append(team)
            if len(non_division_winners) > 0:
                if len(non_division_winners) == 2:
                    break_tie_two_teams(season, non_division_winners, rank, standings)
                else:
                    break_tie_multiple_teams(season, non_division_winners, rank, standings)
            teams = division_winners

    if len(teams) == 2:
        break_tie_two_teams(season, teams, rank, standings)
    else:
        # (2) Better winning percentage in all games among the tied teams.
        win_pcts = {}

        for team in teams:
            total_games = 0
            total_wins = 0
            for opponent in teams:
                if team != opponent:
                    team1_id = team['TeamID']
                    team2_id = opponent['TeamID']

                    try:
                        team_vs_opp = leaguedashteamstats.LeagueDashTeamStats(
                            season=season,
                            team_id_nullable=team1_id,
                            opponent_team_id=team2_id
                        ).get_normalized_dict()['LeagueDashTeamStats']

                        if team_vs_opp:
                            total_games += team_vs_opp[0]['GP']
                            total_wins += team_vs_opp[0]['W']
                    except Exception as e:
                        logging.error(
                            f"Error fetching win percentage for {team['TeamCity']} against {opponent['TeamCity']}: {e}")

            # Average win percentage across all tied teams
            try:
                total_win_pct = total_wins / total_games
            except ZeroDivisionError:
                total_win_pct = 0.0

            win_pcts[team['TeamID']] = total_win_pct

        # Sort the teams by their average winning percentage in descending order
        sorted_teams = sorted(teams, key=lambda x: win_pcts[x['TeamID']], reverse=True)

        # Adjust rank based on the sorted order
        base_rank = sorted_teams[0][rank]
        for i, team in enumerate(sorted_teams):
            team[rank] = base_rank + i
            logging.info(f"{team['TeamCity']} assigned rank {team[rank]} based on tiebreaker.")


def update_current_standings():
    try:
        logging.info(f"Updating standings for Season: {k_current_season}")
        standings = leaguestandings.LeagueStandings(season=k_current_season).get_normalized_dict()['Standings']
        determine_tiebreakers(k_current_season, standings)

        for i, team in enumerate(standings):
            # Update STANDINGS data for each team
            teams_collection.update_one(
                {"TEAM_ID": team['TeamID']},
                {"$set": {f"seasons.{k_current_season}.STANDINGS": team}},
                upsert=True
            )
            logging.info(f"Updated {i + 1} of {len(standings)}\n")
    except Exception as e:
        logging.error(f"Unable to update standings: {e}")


def fetch_all_standings():
    seasons = [
        #'2005-06',
        #'2004-05',
        #'2003-04',
        #'2002-03',
        #'2001-02',
        #'2000-01',
        #'1999-00',
        '1998-99',
        #'1997-98',
        #'1996-97',
        #'1995-96',
        #'1994-95',
        #'1993-94',
        #'1992-93',
        #'1991-92',
        #'1990-91',
        #'1989-90',
        #'1988-89',
        #'1987-88',
        #'1986-87',
        #'1985-86',
        #'1984-85'
    ]

    for season in seasons:
        logging.info(f"Fetching standings for Season: {season}")

        try:
            standings = leaguestandings.LeagueStandings(season=season).get_normalized_dict()['Standings']
            determine_tiebreakers(season, standings)

            for i, team in enumerate(standings):
                # Add STANDINGS data for each team
                teams_collection.update_one(
                    {"TEAM_ID": team["TeamID"]},
                    {"$set": {f"seasons.{season}.STANDINGS": team}},
                    upsert=True
                )
                logging.info(f"Fetched {i + 1} of {len(standings)}\n")
        except Exception as e:
            logging.error(f"Unable to fetch standings: {e.with_traceback()}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        client = MongoClient(uri)
        db = client.splash
        teams_collection = db.nba_teams
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    fetch_all_standings()
    # update_current_standings()
