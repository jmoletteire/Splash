import logging
from nba_api.stats.endpoints import leaguedashteamstats, leaguehustlestatsteam
from splash_nba.imports import PROXY, HEADERS, CURR_SEASON, get_mongo_collection


def calculate_percentile_rank(value, total):
    result = 1 - ((value - 1) / (total - 1))
    if result < 0 or result > 1:
        return "0.000"
    else:
        return f"{result:.3f}"


def format_stats(team, mode, stats, key_map):
    # Adjust key for opponent stats (NBA API uses "OPP_" before opponent data keys)
    # if opp:
    #     basic_stats = {key.replace("OPP_", ""): value for key, value in basic_stats.items()}

    for key, value in stats.items():
        # Skip unnecessary data, only interested in our chosen fields.
        if key not in key_map:
            continue
        else:
            # Get stat rank
            rank_key = key + "_RANK"
            rank = stats[rank_key] if rank_key in stats else 0

            # Calculate percentile
            pct = calculate_percentile_rank(int(rank), int(team['LEAGUE_TEAMS']['Totals']['Value']))

            # Get updated key name
            key_final = key_map[key]

            # Ensure key_final exists in team
            team.setdefault(key_final, {})

            # Ensure mode exists in team[key_final]
            team[key_final].setdefault(mode, {})

            # If percentage, format as %
            if '%' in key_final:
                team[key_final][mode] = {"Value": f"{value * 100:.1f}%", "Rank": str(rank), "Pct": pct}
            else:
                team[key_final][mode] = {"Value": str(value), "Rank": str(rank), "Pct": pct}


def fetch_team_stats(seasons: list = None, season_types: list = None, use_proxy: bool = True):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Connect to MongoDB
    try:
        teams_collection = get_mongo_collection('nba_teams')
        logging.info("Connected to MongoDB")
    except Exception as e:
        logging.error(f"Failed to connect to MongoDB: {e}", exc_info=True)
        return

    if seasons is None:
        # List of all seasons
        seasons = [
            "1946-47", "1947-48", "1948-49", "1949-50", "1950-51", "1951-52", "1952-53", "1953-54",
            "1954-55", "1955-56", "1956-57", "1957-58", "1958-59", "1959-60", "1960-61", "1961-62",
            "1962-63", "1963-64", "1964-65", "1965-66", "1966-67", "1967-68", "1968-69", "1969-70",
            "1970-71", "1971-72", "1972-73", "1973-74", "1974-75", "1975-76", "1976-77", "1977-78",
            "1978-79", "1979-80", "1980-81", "1981-82", "1982-83", "1983-84", "1984-85", "1985-86",
            "1986-87", "1987-88", "1988-89", "1989-90", "1990-91", "1991-92", "1992-93", "1993-94",
            "1994-95", "1995-96", "1996-97", "1997-98", "1998-99", "1999-00", "2000-01", "2001-02",
            "2002-03", "2003-04", "2004-05", "2005-06", "2006-07", "2007-08", "2008-09", "2009-10",
            "2010-11", "2011-12", "2012-13", "2013-14", "2014-15", "2015-16", "2016-17", "2017-18",
            "2018-19", "2019-20", "2020-21", "2021-22", "2022-23", "2023-24", "2024-25"
        ]
    if season_types is None:
        # List of all season types
        season_types = ["Regular Season", "Playoffs"]

    # Set proxy usage
    proxy = PROXY if use_proxy else None
    headers = HEADERS if use_proxy else None

    for season in seasons:
        logging.info(f"Fetching stats for season: {season}")
        for season_type in season_types:
            if season_type == "REGULAR SEASON":
                season_type = "Regular Season"
            elif season_type == "PLAYOFFS":
                season_type = "Playoffs"

            logging.info(f"\t{season_type}")
            teams = {}

            if season >= '1996-97':
                # Basic Stats only available since 1996-97.
                try:
                    basic_modes = ['Totals', 'PerGame', 'Per100Possessions']
                    basic_key_map = {
                        'FGM': 'FGM',
                        'FGA': 'FGA',
                        'FG_PCT': 'FG%',
                        'FG3M': '3PM',
                        'FG3A': '3PA',
                        'FG3_PCT': '3P%',
                        'FTM': 'FTM',
                        'FTA': 'FTA',
                        'FT_PCT': 'FT%',
                        'OREB': 'OREB',
                        'DREB': 'DREB',
                        'REB': 'REB',
                        'AST': 'AST',
                        'TOV': 'TOV',
                        'STL': 'STL',
                        'BLK': 'BLK',
                        'PF': 'PF',
                        'PFD': 'PFD',
                        'PTS': 'PTS',
                        'PLUS_MINUS': '+/-'
                    }

                    # Get basic stats
                    for mode in basic_modes:
                        basic_stats = leaguedashteamstats.LeagueDashTeamStats(
                            season=season, season_type_all_star=season_type, per_mode_detailed=mode, timeout=30, proxy=proxy, headers=headers
                        ).get_normalized_dict()['LeagueDashTeamStats']

                        for team_stats in basic_stats:
                            team_id = team_stats['TEAM_ID']
                            if team_id not in teams:
                                teams[team_id] = {}
                            teams[team_id]['LEAGUE_TEAMS'] = {"Totals": {"Value": f"{len(basic_stats)}", "Rank": "0", "Pct": "0.000"}}
                            format_stats(teams[team_id], mode, team_stats, basic_key_map)

                except Exception as e:
                    logging.error(f'Error retrieving basic stats: {e}', exc_info=True)

                # Advanced Stats only available since 1996-97.
                try:
                    adv_key_map = {
                        'OFF_RATING': 'ORTG',
                        'DEF_RATING': 'DRTG',
                        'NET_RATING': 'NRTG',
                        'AST_PCT': 'AST%',
                        'AST_TO': 'AST_TO',
                        'OREB_PCT': 'OREB%',
                        'DREB_PCT': 'DREB%',
                        'REB_PCT': 'REB%',
                        'TM_TOV_PCT': 'TOV%',
                        'EFG_PCT': 'eFG%',
                        'TS_PCT': 'TS%',
                        'PACE': 'PACE',
                        'POSS': 'POSS'
                    }

                    adv_stats = leaguedashteamstats.LeagueDashTeamStats(
                        season=season, season_type_all_star=season_type, measure_type_detailed_defense='Advanced', timeout=30, proxy=proxy, headers=headers
                    ).get_normalized_dict()['LeagueDashTeamStats']

                    for team_stats in adv_stats:
                        team_id = team_stats['TEAM_ID']
                        if team_id not in teams:
                            teams[team_id] = {}
                        format_stats(teams[team_id], 'Totals', team_stats, adv_key_map)

                except Exception as e:
                    logging.error(f'Error retrieving advanced stats: {e}', exc_info=True)

            # Hustle Stats only available since 2015-16.
            if season >= '2015-16':
                try:
                    hustle_key_map = {
                        'CONTESTED_SHOTS': 'CONTESTED_SHOTS',
                        'DEFLECTIONS': 'DEFLECTIONS',
                        'CHARGES_DRAWN': 'CHARGES',
                        'SCREEN_ASSISTS': 'SCREEN_AST',
                        'SCREEN_AST_PTS': 'SCREEN_AST_PTS',
                        'LOOSE_BALLS_RECOVERED': 'LOOSE_BALLS',
                        'OFF_BOXOUTS': 'OFF_BOXOUTS',
                        'DEF_BOXOUTS': 'DEF_BOXOUTS',
                        'BOX_OUTS': 'BOX_OUTS'
                    }

                    modes = ['Totals', 'PerGame']
                    for mode in modes:
                        hustle_stats = leaguehustlestatsteam.LeagueHustleStatsTeam(
                            season=season, season_type_all_star=season_type, per_mode_time=mode, timeout=30, proxy=proxy, headers=headers
                        ).get_normalized_dict()['HustleStatsTeam']

                        for team_stats in hustle_stats:
                            team_id = team_stats['TEAM_ID']
                            if team_id not in teams:
                                teams[team_id] = {}
                            format_stats(teams[team_id], mode, team_stats, hustle_key_map)

                except Exception as e:
                    logging.error(f'Error retrieving hustle stats: {e}', exc_info=True)

            logging.info(f"\t\tFound data for {len(teams.keys())} teams.")

            # Update SEASONS for each team
            for team_id, team_stats in teams.items():
                teams_collection.update_one(
                    {"TEAM_ID": team_id},
                    {"$set": {f"SEASONS.{season}.STATS.{season_type.upper()}": team_stats}},
                    upsert=True
                )

            #
            # If no data for given season, find teams that have season data and set STATS to {}.
            #
            # However, if current season playoffs have not started, and we don't check for
            # `season != CURR_SEASON`, this may erase all team stats for the current season.
            #
            if len(teams.keys()) == 0 and season != CURR_SEASON:
                for team in teams_collection.find({f"SEASONS.{season}": {"$exists": True}}, {"TEAM_ID": 1}):
                    teams_collection.update_one(
                        {"TEAM_ID": team.get("TEAM_ID", 0)},
                        {"$set": {f"SEASONS.{season}.STATS": {}}},
                        upsert=True
                    )


if __name__ == '__main__':
    fetch_team_stats(use_proxy=False)
