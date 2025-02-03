import logging
from itertools import groupby
from collections import defaultdict
from nba_api.stats.endpoints import leaguestandings, leaguedashteamstats
from splash_nba.imports import get_mongo_collection, PROXY, CURR_SEASON


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
                    break_tie_multiple_teams(season, teams, 'DivisionRank', standings, 0)
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
                    break_tie_multiple_teams(season, teams, 'PlayoffRank', standings, 0)
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
            proxy=PROXY,
            season=season,
            team_id_nullable=team1['TeamID'],
            opponent_team_id=team2['TeamID']
        ).get_normalized_dict()['LeagueDashTeamStats']

        team1_pct = 0
        team2_pct = 0

        if team1_vs_team2:
            team1_pct = team1_vs_team2[0]['W_PCT']
            team2_pct = 1 - team1_pct

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
                # (3) Better winning percentage against teams in own division (only if teams are in the same division).
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
                                            proxy=PROXY,
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
                                                proxy=PROXY,
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


def break_tie_multiple_teams(season, teams, rank, standings, step):
    def sort_and_group_teams(teams, key):
        teams.sort(key=key, reverse=True)
        grouped_teams = []
        for key_value, group in groupby(teams, key=key):
            grouped_teams.append(list(group))
        return grouped_teams

    original_rank = teams[0][rank]  # Assume all teams start with the same rank

    if original_rank == 0:
        original_rank = 1

    def update_team_ranks(grouped_teams, starting_rank, step):
        current_rank = starting_rank
        for group in grouped_teams:
            if len(group) == 1:
                group[0][rank] = current_rank
                logging.info(f"{group[0]['TeamCity']} assigned rank {current_rank} based on criteria {step}.")
            elif len(group) == 2:
                group[0][rank] = current_rank
                group[1][rank] = current_rank
                logging.info(f"{group[0]['TeamCity']} and {group[1]['TeamCity']} assigned ranks {current_rank}.")
                break_tie_two_teams(season, group, rank, standings)
            else:
                step += 1
                break_tie_multiple_teams(season, group, rank, standings, step)
            current_rank += len(group)

    # Step 0: Better overall winning percentage
    if step == 0:
        grouped_teams = sort_and_group_teams(teams, lambda team: team['WinPCT'])
        update_team_ranks(grouped_teams, original_rank, step)

    # Step 1: Division winner
    if step == 1:
        grouped_teams = sort_and_group_teams(teams, lambda team: 1 if team['DivisionRank'] == 1 else 0)
        update_team_ranks(grouped_teams, original_rank, step)

    # Step 2: Better winning percentage in games against each other
    if step == 2:
        grouped_teams = sort_and_group_teams(teams, lambda team: calculate_head_to_head_pct(team, teams, season))
        update_team_ranks(grouped_teams, original_rank, step)

    # Step 3: Better winning percentage against teams in own division
    if step == 3:
        grouped_teams = sort_and_group_teams(teams, lambda team: team['DivisionRecord'])
        update_team_ranks(grouped_teams, original_rank, step)

    # Step 4: Better winning percentage against teams in own conference
    if step == 4:
        grouped_teams = sort_and_group_teams(teams, lambda team: team['ConferenceRecord'])
        update_team_ranks(grouped_teams, original_rank, step)

    # Step 5: Better winning percentage against playoff teams in own conference
    if step == 5:
        grouped_teams = sort_and_group_teams(teams, lambda team: calculate_playoff_win_pct(team, standings, season, own_conference=True))
        update_team_ranks(grouped_teams, original_rank, step)

    # Step 6: Better winning percentage against playoff teams in opposite conference
    if step == 6:
        grouped_teams = sort_and_group_teams(teams, lambda team: calculate_playoff_win_pct(team, standings, season, own_conference=False))
        update_team_ranks(grouped_teams, original_rank, step)

    # Step 7: Better net points, all games
    if step == 7:
        grouped_teams = sort_and_group_teams(teams, lambda team: team['DiffPointsPG'] * (team['WINS'] + team['LOSSES']))
        update_team_ranks(grouped_teams, original_rank, step)


def calculate_head_to_head_pct(team, teams, season):
    win_count = 0
    game_count = 0
    for opponent in teams:
        if team['TeamID'] != opponent['TeamID']:
            team_vs_opp = leaguedashteamstats.LeagueDashTeamStats(
                proxy=PROXY,
                season=season,
                team_id_nullable=team['TeamID'],
                opponent_team_id=opponent['TeamID']
            ).get_normalized_dict()['LeagueDashTeamStats']

            if team_vs_opp:
                win_count += team_vs_opp[0]['W']
                game_count += team_vs_opp[0]['GP']

    return win_count / game_count if game_count > 0 else 0.0


def calculate_playoff_win_pct(team, standings, season, own_conference=True):
    if season < '2019-20':
        eligible_teams = [t['TeamID'] for t in standings if t['Conference'] == team['Conference'] and t['PlayoffRank'] <= 10]
    else:
        eligible_teams = [t['TeamID'] for t in standings if t['Conference'] == team['Conference'] and t['PlayoffRank'] <= 8]

    if not own_conference:
        eligible_teams = [t['TeamID'] for t in standings if t['Conference'] != team['Conference']]

    win_count = 0
    game_count = 0
    for opponent in eligible_teams:
        if team['TeamID'] != opponent:
            team_vs_opp = leaguedashteamstats.LeagueDashTeamStats(
                proxy=PROXY,
                season=season,
                team_id_nullable=team['TeamID'],
                opponent_team_id=opponent
            ).get_normalized_dict()['LeagueDashTeamStats']

            if team_vs_opp:
                win_count += team_vs_opp[0]['W']
                game_count += team_vs_opp[0]['GP']

    return win_count / game_count if game_count > 0 else 0.0


def update_current_standings():
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Standings) Failed to connect to MongoDB: {e}")
        return

    try:
        logging.info(f"(Standings) Updating standings for Season: {CURR_SEASON}")
        standings = leaguestandings.LeagueStandings(season=CURR_SEASON, proxy=PROXY).get_normalized_dict()['Standings']
        determine_tiebreakers(CURR_SEASON, standings)

        for i, team in enumerate(standings):
            team['SOS'], team['rSOS'] = calculate_strength_of_schedule(team, CURR_SEASON)

            # Update STANDINGS data for each team
            teams_collection.update_one(
                {"TEAM_ID": team['TeamID']},
                {"$set": {
                    f"seasons.{CURR_SEASON}.STANDINGS": team,
                    f"seasons.{CURR_SEASON}.GP": (team["WINS"] + team["LOSSES"]),
                    f"seasons.{CURR_SEASON}.WINS": team["WINS"],
                    f"seasons.{CURR_SEASON}.LOSSES": team["LOSSES"],
                    f"seasons.{CURR_SEASON}.WIN_PCT": team["WinPCT"],
                    f"seasons.{CURR_SEASON}.CONF_RANK": team["PlayoffRank"],
                    f"seasons.{CURR_SEASON}.DIV_RANK": team["DivisionRank"],
                }},
                upsert=True
            )
            logging.info(f"(Standings) Updated {i + 1} of {len(standings)}\n")

        strength_of_schedule_rank()
    except Exception as e:
        logging.error(f"(Standings) Unable to update standings: {e}")


def calculate_strength_of_schedule(team, season):
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Standings) Failed to connect to MongoDB: {e}")
        return

    if season < '2017-18':
        return 0.000

    team_season = teams_collection.find_one({'TEAM_ID': team['TeamID']}, {f'seasons.{season}.GAMES': 1})
    team_games = team_season.get('seasons', {}).get(season, {}).get('GAMES', {})
    opp_win_pct = 0.000
    rem_opp_win_pct = 0.000
    rem_games = 0

    if team_games:
        for game_id, game_data in team_games.items():
            if game_id[2] == '2':
                if game_data['RESULT'] == 'W' or game_data['RESULT'] == 'L':
                    opp = teams_collection.find_one({'TEAM_ID': game_data['OPP']}, {f'seasons.{season}.STANDINGS.WinPCT': 1, '_id': 0})
                    try:
                        opp_seasons = opp.get('seasons', {})
                        opp_season = opp_seasons.get(season, {})
                        opp_standings = opp_season.get('STANDINGS', {})
                        opp_win_pct += opp_standings.get('WinPCT', 0)
                    except Exception:
                        continue
                else:
                    opp = teams_collection.find_one({'TEAM_ID': game_data['OPP']}, {f'seasons.{season}.STANDINGS.WinPCT': 1, '_id': 0})
                    try:
                        opp_seasons = opp.get('seasons', {})
                        opp_season = opp_seasons.get(season, {})
                        opp_standings = opp_season.get('STANDINGS', {})
                        rem_opp_win_pct += opp_standings.get('WinPCT', 0)
                        rem_games += 1
                    except Exception:
                        continue

    sos = opp_win_pct / (team['WINS'] + team['LOSSES'])
    r_sos = rem_opp_win_pct / rem_games
    return sos, r_sos


def strength_of_schedule_rank():
    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Standings) Failed to connect to MongoDB: {e}")
        return

    stats = ['SOS', 'rSOS']

    for stat in stats:
        pipeline = [
            {
                "$setWindowFields": {
                    "sortBy": {
                        f"seasons.{CURR_SEASON}.STANDINGS.{stat}": 1
                    },
                    "output": {
                        f"seasons.{CURR_SEASON}.STANDINGS.{stat}_RANK": {
                            "$documentNumber": {}
                        }
                    }
                }
            }
        ]

        # Execute the pipeline and get the results
        results = list(teams_collection.aggregate(pipeline))

        # Update each document with the new rank field
        for result in results:
            res = result['seasons'][CURR_SEASON]['STANDINGS'][f'{stat}_RANK']

            try:
                teams_collection.update_one(
                    {"_id": result["_id"]},
                    {"$set": {f"seasons.{CURR_SEASON}.STANDINGS.{stat}_RANK": res}}
                )
            except Exception as e:
                logging.error(f"Failed to add SOS_RANK to database: {e}")
                continue


def fetch_all_standings():
    seasons = [
        #'2020-21'
        #'2005-06',
        #'2004-05',
        #'2003-04',
        '2002-03',
        #'2001-02',
        #'2000-01',
        #'1999-00',
        #'1998-99',
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
            standings = leaguestandings.LeagueStandings(season=season, proxy=PROXY).get_normalized_dict()['Standings']
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
            logging.error(f"Unable to fetch standings: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}")
        exit(1)

    #fetch_all_standings()
    update_current_standings()
