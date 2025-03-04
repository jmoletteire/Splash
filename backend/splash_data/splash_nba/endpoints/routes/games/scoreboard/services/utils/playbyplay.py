import logging
from .stats import convert_playtime


def play_by_play(pbp):
    pbp_final = []

    for play in pbp:
        play_final = {
            'action': str(play.get('actionNumber', '0')),
            'clock': convert_playtime(play.get('clock', '')),
            'period': str(play.get('period', '0')),
            'teamId': str(play.get('teamId', '0')),
            'personId': str(play.get('personId', '0')),
            'playerNameI': str(play.get('playerNameI', '')),
            'possession': str(play.get('possession', '0')),
            'scoreHome': str(play.get('scoreHome', '')),
            'scoreAway': str(play.get('scoreAway', '')),
            'isFieldGoal': str(play.get('isFieldGoal', '0')),
            'description': str(play.get('description', '')),
            'xLegacy': str(play.get('xLegacy', '0')),
            'yLegacy': str(play.get('yLegacy', '0')),
        }
        pbp_final.append(play_final)

    return pbp_final
