def lineup_data(player):
    return {
        "personId": str(player["personId"]) if "personId" in player else None,
        "name": player["nameI"] if "nameI" in player else None,
        "number": player["jerseyNum"] if "jerseyNum" in player else None,
        "position": player["position"] if "position" in player else None
    }


def matchup_details(summary, boxscore):
    matchup = f'{boxscore.get("awayTeam", {}).get("teamName", "Away")} @ {boxscore.get("homeTeam", {}).get("teamName", "Home")}'
    officials = ""
    arena = ""
    lineups = {"home": [], "away": []}
    inactive = {"home": "", "away": ""}

    # Officials
    if "officials" in boxscore:
        officials = ", ".join([ref["name"] for ref in boxscore["officials"]])

    # Arena
    if "arena" in boxscore:
        name = boxscore["arena"]["arenaName"] if "arenaName" in boxscore["arena"] else ""
        city = boxscore["arena"]["arenaCity"] if "arenaCity" in boxscore["arena"] else ""
        state = boxscore["arena"]["arenaState"] if "arenaState" in boxscore["arena"] else ""
        arena = f'{name}, {city}, {state}'

    # Lineups
    if "homeTeam" in boxscore:
        if "players" in boxscore["homeTeam"]:
            lineups["home"] = [lineup_data(player) for player in boxscore["homeTeam"]["players"] if player["starter"] == "1"]
            order = [4, 3, 0, 2, 1]  # PG, SG, SF, C, PF
            lineups["home"] = [lineups["home"][i] for i in order]
    if "awayTeam" in boxscore:
        if "players" in boxscore["awayTeam"]:
            lineups["away"] = [lineup_data(player) for player in boxscore["awayTeam"]["players"] if player["starter"] == "1"]
            order = [0, 2, 1, 4, 3]  # SF, C, PF, PG, SG
            lineups["away"] = [lineups["away"][i] for i in order]

    # Inactive
    if "InactivePlayers" in summary:
        try:
            home_id = summary["GameSummary"][0]["HOME_TEAM_ID"]
            away_id = summary["GameSummary"][0]["VISITOR_TEAM_ID"]
        except Exception:
            home_id = 0
            away_id = 0

        inactive["home"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if player["TEAM_ID"] == home_id])
        inactive["away"] = ", ".join([f"{player['FIRST_NAME']} {player['LAST_NAME']}" for player in summary["InactivePlayers"] if player["TEAM_ID"] == away_id])

    return {
        "matchup": matchup,
        "officials": officials,
        "arena": arena,
        "lineups": lineups,
        "inactive": inactive
    }
