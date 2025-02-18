from .matchup import matchup_details
from .stats import stats


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
    adv = game.get("ADV", {})

    if summary is None:
        return {"matchup": {f"Away @ Home"}, "stats": {}}

    if boxscore is None:
        game_summary = summary["GameSummary"][0]
        line_score = summary["LineScore"]
        awayName = line_score[1]["NICKNAME"] if line_score[0]["TEAM_ID"] == game_summary["HOME_TEAM_ID"] else line_score[0]["NICKNAME"]
        homeName = line_score[0]["NICKNAME"] if line_score[0]["TEAM_ID"] == game_summary["HOME_TEAM_ID"] else line_score[1]["NICKNAME"]
        return {"matchup": {f"{awayName} @ {homeName}"}, "stats": {}}

    status = game.get("SUMMARY", {}).get("GameSummary", {})[0].get("GAME_STATUS_ID", 0)

    return {
        "matchup": matchup_details(summary, boxscore),
        "stats": stats(status, boxscore, adv)
    }
