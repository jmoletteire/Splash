import logging
from nba_api.stats.endpoints import leaguedashteamstats, leaguehustlestatsteam

try:
    # Try to import the local env.py file
    from splash_nba.util.env import PROXY
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")


def fetch_team_stats(team_id, season, season_type):
    # Init return variables
    team_basic_stats = {}
    team_adv_stats = {}
    team_hustle_stats = {}

    for attempt in range(1, 4):
        try:
            # Get basic stats
            basic_stats = leaguedashteamstats.LeagueDashTeamStats(
                season=season, timeout=30, proxy=PROXY
            ).get_normalized_dict()['LeagueDashTeamStats']

            for team in basic_stats:
                if team['TEAM_ID'] == team_id:
                    team_basic_stats = team
                    team_basic_stats['LEAGUE_TEAMS'] = len(basic_stats)
            break
        except Exception as e:
            logging.error(f'Error retrieving basic stats: {e}')

    # Advanced Stats only available since 1996-97.
    if season >= '1996-97':
        for attempt in range(1, 4):
            try:
                adv_stats = leaguedashteamstats.LeagueDashTeamStats(
                    season=season, measure_type_detailed_defense='Advanced', timeout=30, proxy=PROXY
                ).get_normalized_dict()['LeagueDashTeamStats']

                for team in adv_stats:
                    if team['TEAM_ID'] == team_id:
                        team_adv_stats = team
                        team_adv_stats['LEAGUE_TEAMS'] = len(adv_stats)
                break
            except Exception as e:
                logging.error(f'Error retrieving advanced stats: {e}')

    # Hustle Stats only available since 2015-16.
    if season >= '2015-16':
        for attempt in range(1, 4):
            try:
                hustle_stats = leaguehustlestatsteam.LeagueHustleStatsTeam(
                    season=season, timeout=30, proxy=PROXY
                ).get_normalized_dict()['HustleStatsTeam']

                for team in hustle_stats:
                    if team['TEAM_ID'] == team_id:
                        team_hustle_stats = team
                        team_hustle_stats['LEAGUE_TEAMS'] = len(hustle_stats)
                break
            except Exception as e:
                logging.error(f'Error retrieving hustle stats: {e}')

    team_stats = {
        'BASIC': team_basic_stats,
        'ADV': team_adv_stats,
        'HUSTLE': team_hustle_stats
    }

    return team_stats
