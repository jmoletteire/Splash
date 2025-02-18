import re


def convert_playtime(duration_str):
    match = re.match(r"PT(\d+)M([\d.]+)S", duration_str)
    if match:
        minutes = int(match.group(1))
        seconds = round(float(match.group(2)))  # Handle potential float values
        return f"{minutes}:{seconds:02d}"
    return None  # Return None if the format is incorrect


def calculated_stats(stats, team_stats):
    try:
        poss = stats['POSS']
    except KeyError:
        try:
            poss = stats['fieldGoalsAttempted'] + stats['turnovers'] + (stats['freeThrowsAttempted'] * 0.44) - stats['reboundsOffensive']
        except Exception:
            poss = 0
    try:
        ppp = stats['OFF_RATING'] / 100
    except KeyError:
        try:
            ppp = stats['points'] / poss
        except Exception:
            ppp = 0

    try:
        pps = stats['EFG_PCT'] * 2
    except KeyError:
        try:
            pps = (stats['points'] - stats['freeThrowsMade']) / stats['fieldGoalsAttempted']
        except Exception:
            pps = 0

    try:
        tov_pct = stats['TM_TOV_PCT']
    except KeyError:
        try:
            tov_pct = 100 * stats["turnovers"] / poss
        except Exception:
            tov_pct = 0

    try:
        ast_pct = stats['AST_PCT']
    except KeyError:
        try:
            ast_pct = 100 * stats["assists"] / stats["fieldGoalsMade"]
        except Exception:
            ast_pct = 0

    team_stats["FG"] = f"{team_stats['FGM']}-{team_stats['FGA']}"
    team_stats["3P"] = f"{team_stats['3PM']}-{team_stats['3PA']}"
    team_stats["FT"] = f"{team_stats['FTM']}-{team_stats['FTA']}"
    team_stats["Possessions"] = f"{poss:.0f}"
    team_stats["Per Poss"] = f"{ppp:.2f}"
    team_stats["Per Shot"] = f"{pps:.2f}"
    team_stats["Turnover %"] = f"{tov_pct:.1f}%"
    team_stats["Assist %"] = f"{ast_pct:.1f}%"
    team_stats["Assist : Turnover"] = f"{stats['assistsTurnoverRatio']:.2f}"

    return team_stats


def team_stats(stats, adv=None):
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
    for key, value in list(stats.items()):
        key_final = team_keys[key] if key in team_keys else key

        if key_final == "Time Leading":
            team_stats[key_final] = convert_playtime(value)
        elif '%' in key_final:
            value_final = round(value * 100, 1) if value != 0 else 0
            team_stats[key_final] = f"{value_final:.1f}%"
        else:
            team_stats[key_final] = str(value)

    team_stats = calculated_stats(stats if adv is None else adv, team_stats)

    return team_stats


def player_stats(stats, adv=None):
    player_stats = []
    player_adv_keys = ["EFG_PCT", "TS_PCT", "USG_PCT", "POSS"]
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
        new_player = {}

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
                            new_player[stat_key_final] = None
                        else:
                            new_player[stat_key_final] = str(stat)
            else:
                new_player[key] = str(value)

        new_player["FG"] = f"{new_player['FGM']}-{new_player['FGA']}"
        new_player["3P"] = f"{new_player['3PM']}-{new_player['3PA']}"
        new_player["FT"] = f"{new_player['FTM']}-{new_player['FTA']}"

        # ADV
        if adv is not None:
            if len(adv) > i:
                for key in player_adv_keys:
                    if key in adv[i]:
                        new_player[key] = str(adv[i][key])
                    else:
                        continue

        player_stats.append(new_player)

    return stats


def player_game_data(player, status):
    return {
        "personId": str(player["personId"]) if "personId" in player else None,
        "name": player["nameI"] if "nameI" in player else None,
        "number": player["jerseyNum"] if "jerseyNum" in player else None,
        "position": player["position"] if "position" in player else None,
        "inGame": player["oncourt"] if "oncourt" in player and status == 2 else None,
        "starter": str(player["starter"]) if "starter" in player else None,
        "statistics": player["statistics"] if "statistics" in player else None,
    }


def stats_to_strings(stats, adv=None):
    # Convert team statistics to strings
    stats["team"] = team_stats(stats["team"] if "team" in stats else {}, adv["team"] if "team" in adv else None)

    # Convert player statistics to strings
    stats["players"] = player_stats(stats["players"] if "players" in stats else {}, adv["players"] if "players" in adv else None)

    # Return updated dictionary
    return stats


def stats(status, boxscore, adv):
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

    stats["home"] = stats_to_strings(stats["home"], adv["home"] if "home" in adv else None)
    stats["away"] = stats_to_strings(stats["away"], adv["away"] if "away" in adv else None)

    stats["home"]["players"] = [player_game_data(player, status) for player in stats["home"]["players"]]
    stats["away"]["players"] = [player_game_data(player, status) for player in stats["away"]["players"]]

    return stats