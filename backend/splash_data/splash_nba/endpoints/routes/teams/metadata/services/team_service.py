import logging
from .utils.team_helpers import get_standings, get_seasons


def process_team_data(teams):
    """Processes games and returns summarized data."""
    try:
        # Transform the keys
        teams_final = [
            {
                "sportId": team["SPORT_ID"],
                "teamId": str(team["TEAM_ID"]),
                "abbv": team["ABBREVIATION"],
                "city": team["CITY"],
                "name": team["NICKNAME"],
                "seasons": get_seasons(team)
            }
            for team in teams
        ]

        return teams_final

    except Exception as e:
        logging.error(f"(process_scoreboard) Error processing scoreboard: {e}")
        return []