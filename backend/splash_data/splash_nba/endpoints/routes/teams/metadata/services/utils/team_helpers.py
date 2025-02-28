def get_standings(season_data):
    standings = season_data.get("STANDINGS", {})

    if standings.get("ClinchedConferenceTitle", "-") == 1:
        clinched = " -z"
    elif standings.get("ClinchedDivisionTitle", "-") == 1:
        clinched = " -y"
    elif standings.get("ClinchedPlayoffBirth", "-") == 1:
        clinched = " -x"
    elif standings.get("EliminatedConference", "-") == 1:
        clinched = " -e"
    else:
        clinched = ""

    win_pct = f'{standings.get("WinPCT", 0.000):.3f}' if standings.get("WinPCT", "-") is not None else "-"
    conf_gb = str(standings.get("ConferenceGamesBack", "-")) if standings.get("ConferenceGamesBack", "-") not in [None, 0] else "-"
    div_gb = str(standings.get("DivisionGamesBack", "-")) if standings.get("DivisionGamesBack", "-") not in [None, 0] else "-"
    home_record = standings.get("HOME", "-") if standings.get("HOME", "-") is not None else "-"
    road_record = standings.get("ROAD", "-") if standings.get("ROAD", "-") is not None else "-"
    conf_record = standings.get("ConferenceRecord", "-") if standings.get("ConferenceRecord", "-") is not None else "-"
    div_record = standings.get("DivisionRecord", "-") if standings.get("DivisionRecord", "-") is not None else "-"
    last_10 = standings.get("L10", "-") if standings.get("L10", "-") is not None else "-"
    streak = standings.get("strCurrentStreak", "-") if standings.get("strCurrentStreak", "-") is not None else "-"
    vs_over_500 = standings.get("OppOver500", "-") if standings.get("OppOver500", "-") is not None else "-"
    sos = f'{standings.get("SOS", 0.000):.3f}' if standings.get("SOS", "-") is not None else "-"
    r_sos = f'{standings.get("rSOS", 0.000):.3f}' if standings.get("rSOS", "-") is not None else "-"

    return {
        "Clinched": clinched,
        "PCT": win_pct,
        "ConfGB": conf_gb,
        "DivGB": div_gb,
        "SOS": sos,
        "rSOS": r_sos,
        "HOME": home_record,
        "ROAD": road_record,
        "CONF": conf_record,
        "DIV": div_record,
        ".500+": vs_over_500,
        "L10": last_10,
        "STRK": streak
    }


def get_stats(season_data):
    rg_basic = season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("BASIC", {})
    rg_adv = season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {})
    po_basic = season_data.get("STATS", {}).get("PLAYOFFS", {}).get("BASIC", {})
    po_adv = season_data.get("STATS", {}).get("PLAYOFFS", {}).get("ADV", {})

    return {
        # Stats
        "NRTG": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("NET_RATING", "-")),
        "ORTG": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("OFF_RATING", "-")),
        "DRTG": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("DEF_RATING", "-")),
        "Pace": "-" if (pace := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("PACE")) is None else f'{pace:.1f}',
        "FG%": "-" if (fg_pct := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("BASIC", {}).get("FG_PCT")) is None else f'{fg_pct * 100:.1f}%',
        "3P%": "-" if (fg3_pct := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("BASIC", {}).get("FG3_PCT")) is None else f'{fg3_pct * 100:.1f}%',
        "FT%": "-" if (ft_pct := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("BASIC", {}).get("FT_PCT")) is None else f'{ft_pct * 100:.1f}%',
        "eFG%": "-" if (efg_pct := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("EFG_PCT")) is None else f'{efg_pct * 100:.1f}%',
        "TS%": "-" if (ts_pct := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("TS_PCT")) is None else f'{ts_pct * 100:.1f}%',
        "Off Reb %": "-" if (oreb_pct := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("OREB_PCT")) is None else f'{oreb_pct * 100:.1f}%',
        "Turnover %": "-" if (tov_pct := season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("TM_TOV_PCT")) is None else f'{tov_pct * 100:.1f}%',
        # Stat Ranks
        "NRTG Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("NET_RATING_RANK", "-")),
        "ORTG Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("OFF_RATING_RANK", "-")),
        "DRTG Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("DEF_RATING_RANK", "-")),
        "Pace Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("PACE_RANK", "-")),
        "FG% Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("BASIC", {}).get("FG_PCT_RANK", "-")),
        "3P% Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("BASIC", {}).get("FG3_PCT_RANK", "-")),
        "FT% Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("BASIC", {}).get("FT_PCT_RANK", "-")),
        "eFG% Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("EFG_PCT_RANK", "-")),
        "TS% Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("TS_PCT_RANK", "-")),
        "Off Reb % Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("OREB_PCT_RANK", "-")),
        "Turnover % Rk": str(season_data.get("STATS", {}).get("REGULAR SEASON", {}).get("ADV", {}).get("TM_TOV_PCT_RANK", "-"))
    }


def get_seasons(team):
    return sorted(
        [
            {
                "year": season_key,
                "conference": season_data.get("STANDINGS", {}).get("Conference", None),
                "division": season_data.get("STANDINGS", {}).get("Division", None),
                "confRank": season_data.get("STANDINGS", {}).get("PlayoffRank", 0),
                "divRank": season_data.get("STANDINGS", {}).get("DivisionRank", 0),
                "wins": season_data.get("WINS", 0),
                "losses": season_data.get("LOSSES", 0),
                "ties": season_data.get("TIES", 0),
                "stats": get_stats(season_data),
                "standings": get_standings(season_data=season_data)
            }
            for season_key, season_data in team["seasons"].items()
        ],
        key=lambda x: x["year"],  # Sorting key is the year
        reverse=True
    )
