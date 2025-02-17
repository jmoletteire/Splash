import re


def get_game_status(game):
    if 'BOXSCORE' in game:
        if game['BOXSCORE']['gameStatusText'] == 'pregame':
            return 'Pregame'

    if 'SUMMARY' in game:
        if 'GameSummary' not in game['SUMMARY']:
            return ''

        summary = game['SUMMARY']['GameSummary'][0]
        status = summary.get('GAME_STATUS_ID', 0)

        if status == 1:
            # Upcoming
            return summary['GAME_STATUS_TEXT'].replace(" ET", "").replace(" ", "")
        elif status == 2:
            # End Quarter
            if summary['LIVE_PC_TIME'] == ":0.0" or summary['LIVE_PC_TIME'] == "     ":
                if summary['LIVE_PERIOD'] == 1:
                    return 'End 1st'
                elif summary['LIVE_PERIOD'] == 2:
                    return 'HALF'
                elif summary['LIVE_PERIOD'] == 3:
                    return 'End 3rd'
                elif summary['LIVE_PERIOD'] == 4:
                    return 'Final'
                elif summary['LIVE_PERIOD'] == 5:
                    return 'Final/OT'
                else:
                    return f'Final/{summary["LIVE_PERIOD"] - 4}OT'
            else:
                # Game in-progress
                if summary['LIVE_PERIOD'] <= 4:
                    if summary['LIVE_PERIOD'] == 1:
                        return f'{summary["LIVE_PERIOD"]}st {summary["LIVE_PC_TIME"]}'
                    elif summary['LIVE_PERIOD'] == 2:
                        return f'{summary["LIVE_PERIOD"]}nd {summary["LIVE_PC_TIME"]}'
                    elif summary['LIVE_PERIOD'] == 3:
                        return f'{summary["LIVE_PERIOD"]}rd {summary["LIVE_PC_TIME"]}'
                    elif summary['LIVE_PERIOD'] == 4:
                        return f'{summary["LIVE_PERIOD"]}th {summary["LIVE_PC_TIME"]}'
                    else:
                        return ''
                elif summary['LIVE_PERIOD'] == 5:
                    return f'OT {summary["LIVE_PC_TIME"]}'
                else:
                    return f'{summary["LIVE_PERIOD"] - 4}OT {summary["LIVE_PC_TIME"]}'

        elif status == 3:
            # Game Final
            if summary['LIVE_PERIOD'] == 4:
                return 'Final'
            elif summary['LIVE_PERIOD'] == 5:
                return 'Final/OT'
            else:
                return f'Final/{summary["LIVE_PERIOD"] - 4}OT'
        else:
            return ''
    else:
        return ''


def summarize_game(id, game):
    summary = game["SUMMARY"]["GameSummary"][0]
    line_score = game["SUMMARY"]["LineScore"]
    return {
        "sportId": 0,
        "season": summary["SEASON"],
        "gameId": str(id) if not isinstance(id, str) else id,
        "homeTeamId": str(summary["HOME_TEAM_ID"]) if not isinstance(summary["HOME_TEAM_ID"], str) else summary["HOME_TEAM_ID"],
        "awayTeamId": str(summary["VISITOR_TEAM_ID"]) if not isinstance(summary["VISITOR_TEAM_ID"], str) else summary["VISITOR_TEAM_ID"],
        "homeScore": line_score[0]["PTS"] if line_score[0]["TEAM_ID"] == summary["HOME_TEAM_ID"] else line_score[1]["PTS"],
        "awayScore": line_score[0]["PTS"] if line_score[0]["TEAM_ID"] == summary["VISITOR_TEAM_ID"] else line_score[1]["PTS"],
        "broadcast": summary["NATL_TV_BROADCASTER_ABBREVIATION"],
        "gameClock": get_game_status(game),
        "date": summary["GAME_DATE_EST"][0:10]
    }


def specific_game(game):
    summary = game.get("SUMMARY", {})
    boxscore = game.get("BOXSCORE", {})

    if summary is None:
        return {"matchup": {f"Away @ Home"}, "stats": {}}

    if boxscore is None:
        game_summary = summary["GameSummary"][0]
        line_score = summary["LineScore"]
        awayName = line_score[1]["NICKNAME"] if line_score[0]["TEAM_ID"] == game_summary["HOME_TEAM_ID"] else line_score[0]["NICKNAME"]
        homeName = line_score[0]["NICKNAME"] if line_score[0]["TEAM_ID"] == game_summary["HOME_TEAM_ID"] else line_score[1]["NICKNAME"]
        return {"matchup": {f"{awayName} @ {homeName}"}, "stats": {}}

    status = game.get("SUMMARY", {}).get("GameSummary", {})[0].get("GAME_STATUS_ID", 0)
    matchup = f'{boxscore.get("awayTeam", {}).get("teamName", "")} @ {boxscore.get("homeTeam", {}).get("teamName", "")}'
    officials = ""
    arena = ""
    lineups = {"home": [], "away": []}
    inactive = {"home": "", "away": ""}

    def lineup_player_data(player):
        return {
            "personId": str(player["personId"]) if "personId" in player else None,
            "name": player["nameI"] if "nameI" in player else None,
            "number": player["jerseyNum"] if "jerseyNum" in player else None,
            "position": player["position"] if "position" in player else None
        }

    def convert_to_strings(stats):
        def convert_playtime(duration_str):
            match = re.match(r"PT(\d+)M([\d.]+)S", duration_str)
            if match:
                minutes = int(match.group(1))
                seconds = round(float(match.group(2)))  # Handle potential float values
                return f"{minutes}:{seconds:02d}"
            return None  # Return None if the format is incorrect

        # Convert team statistics to strings
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

        stats["team"] = team_stats

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

    def select_fields(player):
        return {
            "personId": str(player["personId"]) if "personId" in player else None,
            "name": player["nameI"] if "nameI" in player else None,
            "number": player["jerseyNum"] if "jerseyNum" in player else None,
            "position": player["position"] if "position" in player else None,
            "inGame": player["oncourt"] if "oncourt" in player and status == 2 else None,
            "starter": str(player["starter"]) if "starter" in player else None,
            "statistics": player["statistics"] if "statistics" in player else None,
        }

    if "officials" in boxscore:
        officials = ", ".join([ref["name"] for ref in boxscore["officials"]])
    if "arena" in boxscore:
        name = boxscore["arena"]["arenaName"] if "arenaName" in boxscore["arena"] else ""
        city = boxscore["arena"]["arenaCity"] if "arenaCity" in boxscore["arena"] else ""
        state = boxscore["arena"]["arenaState"] if "arenaState" in boxscore["arena"] else ""
        arena = f'{name}, {city}, {state}'
    if "homeTeam" in boxscore:
        if "players" in boxscore["homeTeam"]:
            lineups["home"] = [lineup_player_data(player) for player in boxscore["homeTeam"]["players"] if player["starter"] == "1"]
            order = [4, 3, 0, 2, 1]  # PG, SG, SF, C, PF
            lineups["home"] = [lineups["home"][i] for i in order]
    if "awayTeam" in boxscore:
        if "players" in boxscore["awayTeam"]:
            lineups["away"] = [lineup_player_data(player) for player in boxscore["awayTeam"]["players"] if player["starter"] == "1"]
            order = [0, 2, 1, 4, 3]  # SF, C, PF, PG, SG
            lineups["away"] = [lineups["away"][i] for i in order]
    if "InactivePlayers" in summary:
        try:
            home_id = summary["GameSummary"][0]["HOME_TEAM_ID"]
            away_id = summary["GameSummary"][0]["VISITOR_TEAM_ID"]
        except Exception:
            home_id = 0
            away_id = 0

        inactive["home"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if player["TEAM_ID"] == home_id])
        inactive["away"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if player["TEAM_ID"] == away_id])

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

    stats["home"] = convert_to_strings(stats["home"])
    stats["away"] = convert_to_strings(stats["away"])

    return {
        "matchup": {
            "matchup": matchup,
            "officials": officials,
            "arena": arena,
            "lineups": lineups,
            "inactive": inactive
        },
        "stats": {
            "home": {
                "team": stats["home"]["team"],
                "players": [select_fields(player) for player in stats["home"]["players"]]
            },
            "away": {
                "team": stats["away"]["team"],
                "players": [select_fields(player) for player in stats["away"]["players"]]
            },
        }
    }
