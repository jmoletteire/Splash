import re
import logging
import traceback


def convert_playtime(duration_str):
    match = re.match(r"PT(\d+)M([\d.]+)S", duration_str)
    if match:
        minutes = int(match.group(1))
        seconds = round(float(match.group(2)))  # Handle potential float values
        return f"{minutes}:{seconds:02d}"
    return None  # Return None if the format is incorrect


def calculated_stats(stats, team_stats):
    try:
        if stats.get('POSS', None) is not None:
            logging.info(stats['POSS'])
            poss = stats['POSS']
        else:
            poss = team_stats['FGA'] + team_stats['TOV'] + (team_stats['FTA'] * 0.44) - team_stats['Off Rebounds']
    except Exception as e:
        logging.error(f"Error retrieving possessions: {e}")
        logging.error(traceback.format_exc())
        poss = 0

    try:
        if stats.get('OFF_RATING', None) is not None:
            ortg = stats['OFF_RATING']
            ppp = ortg / 100
        else:
            ppp = team_stats['Points'] / poss
    except Exception as e:
        logging.error(f"Error retrieving PPP: {e}")
        logging.error(traceback.format_exc())
        ppp = 0

    try:
        if stats.get('EFG_PCT', None) is not None:
            efg = stats['EFG_PCT']
            pps = efg * 2
        else:
            pps = (team_stats['Points'] - team_stats['FTM']) / team_stats['FGA']
    except Exception as e:
        logging.error(f"Error retrieving PPS: {e}")
        logging.error(traceback.format_exc())
        pps = 0

    try:
        if stats.get('TM_TOV_PCT', None) is not None:
            tov_pct = stats['TM_TOV_PCT']
        else:
            tov_pct = 100 * team_stats["TOV"] / poss
    except Exception as e:
        logging.error(f"Error retrieving Turnover %: {e}")
        logging.error(traceback.format_exc())
        tov_pct = 0

    try:
        if stats.get('AST_PCT', None) is not None:
            ast_pct = stats['AST_PCT']
        else:
            ast_pct = 100 * team_stats["Assists"] / team_stats["FGM"]
    except Exception as e:
        logging.error(f"Error retrieving Assist %: {e}")
        logging.error(traceback.format_exc())
        ast_pct = 0

    team_stats["FG"] = f"{team_stats['FGM']}-{team_stats['FGA']}"
    team_stats["3P"] = f"{team_stats['3PM']}-{team_stats['3PA']}"
    team_stats["FT"] = f"{team_stats['FTM']}-{team_stats['FTA']}"

    try:
        team_stats["Possessions"] = f"{poss:.0f}"
    except Exception as e:
        logging.error(f"Error formatting Possessions: {e}")

    try:
        team_stats["Per Poss"] = f"{ppp:.2f}"
    except Exception as e:
        logging.error(f"Error formatting Per Poss: {e}")

    try:
        team_stats["Per Shot"] = f"{pps:.2f}"
    except Exception as e:
        logging.error(f"Error formatting Per Shot: {e}")

    try:
        team_stats["Turnover %"] = f"{tov_pct:.1f}%"
    except Exception as e:
        logging.error(f"Error formatting Turnover %: {e}")

    try:
        team_stats["Assist %"] = f"{ast_pct:.1f}%"
    except Exception as e:
        logging.error(f"Error formatting Assist %: {e}")

    try:
        if stats.get('AST_TOV', None) is not None:
            team_stats["Assist : Turnover"] = f"{stats['AST_TOV']:.2f}"
        else:
            team_stats["Assist : Turnover"] = team_stats["Assist : Turnover"]
    except Exception as e:
        logging.error(f"Error retrieving Assist / Turnover: {e}")
        logging.error(traceback.format_exc())
        team_stats["Assist : Turnover"] = "0.00"

    return team_stats


def team_stats(stats, adv):
    team_keys = {
        "assists": "Assists",
        "assistsTurnoverRatio": "Assist : Turnover",
        "benchPoints": "Bench Points",
        "biggestLead": "Biggest Lead",
        "blocks": "Blocks",
        "fieldGoalsAttempted": "FGA",
        "fieldGoalsMade": "FGM",
        "fieldGoalsPercentage": "FG%",
        "fieldGoalsEffectiveAdjusted": "eFG%",
        "foulsPersonal": "Fouls",
        "freeThrowsAttempted": "FTA",
        "freeThrowsMade": "FTM",
        "freeThrowsPercentage": "FT%",
        "leadChanges": "Lead Changes",
        "points": "Points",
        "pointsFastBreak": "Fast Break Points",
        "pointsFromTurnovers": "Points off Turnovers",
        "pointsInThePaint": "Points in Paint",
        "pointsSecondChance": "2nd Chance Pts",
        "reboundsDefensive": "Def Rebounds",
        "reboundsOffensive": "Off Rebounds",
        "reboundsTotal": "Rebounds",
        "steals": "Steals",
        "threePointersAttempted": "3PA",
        "threePointersMade": "3PM",
        "threePointersPercentage": "3P%",
        "timeLeading": "Time Leading",
        "timesTied": "Times Tied",
        "trueShootingPercentage": "TS%",
        "turnovers": "Turnovers"
    }
    team_stats = {}
    for key, value in stats.items():
        key_final = team_keys[key] if key in team_keys else key

        if key_final == "Time Leading":
            team_stats[key_final] = convert_playtime(value)
        elif '%' in key_final:
            value_final = round(value * 100, 1) if value != 0 else 0
            team_stats[key_final] = f"{value_final:.1f}%"
        else:
            team_stats[key_final] = str(value)

    try:
        team_stats = calculated_stats(stats if adv is {} else adv, team_stats)
    except Exception as e:
        logging.error(f"Error calculating team advanced stats: {e}")

    return team_stats


def player_stats(status, stats, adv):
    player_stats = []
    player_adv_keys = {
        "EFG_PCT": "eFG%",
        "TS_PCT": "TS%",
        "USG_PCT": "USG%",
        "POSS": "POSS"
    }
    player_keys = {
        "assists": "AST",
        "blocks": "BLK",
        "fieldGoalsAttempted": "FGA",
        "fieldGoalsMade": "FGM",
        "foulsPersonal": "PF",
        "freeThrowsAttempted": "FTA",
        "freeThrowsMade": "FTM",
        "minutes": "MIN",
        "points": "PTS",
        "plusMinusPoints": "+/-",
        "reboundsDefensive": "DRB",
        "reboundsOffensive": "ORB",
        "reboundsTotal": "REB",
        "steals": "STL",
        "threePointersAttempted": "3PA",
        "threePointersMade": "3PM",
        "turnovers": "TO"
    }

    for i, player in enumerate(stats):
        new_player = player_game_data(player, status)
        statistics = {}

        # BASIC
        for key, value in player.items():
            if key == "statistics":
                for stat_key, stat in value.items():
                    if stat_key in player_keys:
                        stat_key_final = player_keys[stat_key]

                        if stat_key == "minutes":
                            stat = convert_playtime(stat)
                        if stat_key == "plusMinusPoints":
                            stat = int(stat)
                        if stat in [0, "0", "0-0", "0:00"] and stat_key not in ["fieldGoalsMade", "threePointersMade", "freeThrowsMade", "fieldGoalsAttempted", "threePointersAttempted", "freeThrowsAttempted"]:
                            statistics[stat_key_final] = None
                        else:
                            statistics[stat_key_final] = str(stat)

        # Add computed fields after iteration
        statistics["FG"] = f"{statistics.get('FGM', '0')}-{statistics.get('FGA', '0')}"
        statistics["3P"] = f"{statistics.get('3PM', '0')}-{statistics.get('3PA', '0')}"
        statistics["FT"] = f"{statistics.get('FTM', '0')}-{statistics.get('FTA', '0')}"

        # ADV
        if adv is not None:
            if len(adv) > i:
                for stat_key, stat_name in player_adv_keys.items():
                    if stat_key in adv[i]:
                        if '%' in stat_name:
                            stat = adv[i][stat_key] if adv[i][stat_key] is not None else 0
                            stat_final = round(stat * 100, 1) if stat != 0 else 0
                            statistics[stat_name] = f"{stat_final:.1f}%"
                        else:
                            statistics[stat_name] = str(adv[i][stat_key])

        new_player["statistics"] = statistics
        player_stats.append(new_player)

    return player_stats


def player_game_data(player, status):
    return {
        "personId": str(player["personId"]) if "personId" in player else None,
        "order": str(player["order"]) if "order" in player else None,
        "name": player["nameI"] if "nameI" in player else None,
        "number": player["jerseyNum"] if "jerseyNum" in player else None,
        "position": player["position"] if "position" in player else None,
        "inGame": player["oncourt"] if "oncourt" in player and status == 2 else None,
        "starter": str(player["starter"]) if "starter" in player else None,
        "statistics": player["statistics"] if "statistics" in player else None,
    }


def stats_to_strings(status, stats, adv):
    # Convert team statistics to strings
    try:
        stats["team"] = team_stats(stats["team"] if "team" in stats else {}, adv["team"] if "team" in adv else {})
    except Exception as e:
        logging.error(f"Error retrieving team stats: {e}")

    # Convert player statistics to strings
    try:
        stats["players"] = player_stats(status, stats["players"] if "players" in stats else [], adv["players"] if "players" in adv else [])
    except Exception as e:
        logging.error(f"Error retrieving player stats: {e}")

    # Return updated dictionary
    return stats


def game_stats(status, boxscore, adv):
    # Create stats dictionary
    stats = {
        "home": {
            "team": boxscore.get("homeTeam", {}).get("statistics", {}),
            "players": boxscore.get("homeTeam", {}).get("players", []),
        },
        "away": {
            "team": boxscore.get("awayTeam", {}).get("statistics", {}),
            "players": boxscore.get("awayTeam", {}).get("players", []),
        },
    }

    stats["home"] = stats_to_strings(status, stats["home"], adv["home"] if "home" in adv else {})
    stats["away"] = stats_to_strings(status, stats["away"], adv["away"] if "away" in adv else {})

    return stats
