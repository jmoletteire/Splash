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
        team_min = int(team_stats['minutesCalculated'][2:-1]) / 5
    except Exception as e:
        team_min = 48

    try:
        poss = stats['team']['fieldGoalsAttempted'] + stats['team']['turnovers'] + (stats['team']['freeThrowsAttempted'] * 0.44) - stats['team']['reboundsOffensive']
    except Exception as e:
        poss = 0

    try:
        ppp = stats['team']['points'] / poss
    except Exception as e:
        ppp = 0

    try:
        pps = stats['team']['points'] / stats['team']['fieldGoalsAttempted']
    except Exception as e:
        pps = 0

    try:
        tov_pct = 100 * stats["team"]["turnovers"] / poss
    except Exception as e:
        tov_pct = 0

    try:
        ast_pct = 100 * stats["team"]["assists"] / stats["team"]["fieldGoalsMade"]
    except Exception as e:
        ast_pct = 0

    team_stats["FG"] = f"{team_stats['FGM']}-{team_stats['FGA']}"
    team_stats["3P"] = f"{team_stats['3PM']}-{team_stats['3PA']}"
    team_stats["FT"] = f"{team_stats['FTM']}-{team_stats['FTA']}"
    team_stats["Possessions"] = f"{poss:.0f}"
    team_stats["Pace"] = f"{48 * poss / team_min:.1f}"
    team_stats["Per Poss"] = f"{ppp:.2f}"
    team_stats["Per Shot"] = f"{pps:.2f}"
    team_stats["Turnover %"] = f"{tov_pct:.1f}%"
    team_stats["Assist %"] = f"{ast_pct:.1f}%"
    team_stats["Assist : Turnover"] = f"{stats['team']['assistsTurnoverRatio']:.2f}"

    return team_stats


def team_stats(stats):
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
    for key, value in list(stats["team"].items()):
        key_final = team_keys[key] if key in team_keys else key

        if key_final == "Time Leading":
            team_stats[key_final] = convert_playtime(value)
        elif '%' in key_final:  # better check than .find('%') is not None
            value_final = round(value * 100, 1) if value != 0 else 0
            team_stats[key_final] = f"{value_final:.1f}%"
        else:
            team_stats[key_final] = str(value)

    team_stats = calculated_stats(stats, team_stats)

    return team_stats


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


def stats_to_strings(stats):
    # Convert team statistics to strings
    stats["team"] = team_stats(stats)

    # Convert player statistics to strings
    for player in stats["players"]:
        for key, value in player.items():
            if key == "statistics":
                for stat_key, stat in value.items():
                    if stat_key == "minutes":
                        stat = convert_playtime(stat)
                    if stat_key == "plusMinusPoints":
                        stat = int(stat)
                    if stat in [0, "0", "0-0", "0:00"] and stat_key not in ["fieldGoalsMade", "threePointersMade", "freeThrowsMade", "fieldGoalsAttempted", "threePointersAttempted", "freeThrowsAttempted"]:
                        value[stat_key] = None
                    else:
                        value[stat_key] = str(stat)
            else:
                player[key] = str(value)

    # Return updated dictionary
    return stats


def stats(boxscore, status):
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

    stats["home"] = stats_to_strings(stats["home"])
    stats["away"] = stats_to_strings(stats["away"])

    stats["home"]["players"] = [player_game_data(player, status) for player in stats["home"]["players"]]
    stats["away"]["players"] = [player_game_data(player, status) for player in stats["away"]["players"]]

    return stats