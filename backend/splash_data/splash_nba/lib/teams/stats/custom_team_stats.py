import logging
from splash_nba.imports import get_mongo_collection


def three_and_ft_rate(seasons: list = None, season_types: list = None):
    # Connect to MongoDB
    try:
        logging.basicConfig(level=logging.INFO)  # Configure logging
        teams_collection = get_mongo_collection('nba_teams')
    except Exception as e:
        logging.error(f"(Team 3PAr & FTr) Failed to connect to MongoDB: {e}", exc_info=True)
        return

    if seasons is None:
        # List of all available seasons
        seasons = [
            '2024-25',
            '2023-24',
            '2022-23',
            '2021-22',
            '2020-21',
            '2019-20',
            '2018-19',
            '2017-18',
            '2016-17',
            '2015-16',
            '2014-15',
            '2013-14',
            '2012-13',
            '2011-12',
            '2010-11',
            '2009-10',
            '2008-09',
            '2007-08',
            '2006-07',
            '2005-06',
            '2004-05',
            '2003-04',
            '2002-03',
            '2001-02',
            '2000-01',
            '1999-00',
            '1998-99',
            '1997-98',
            '1996-97'
        ]
    if season_types is None:
        # List of all season types
        season_types = ['REGULAR SEASON', 'PLAYOFFS']

    # Update each document in the collection
    query = {"TEAM_ID": {"$ne": 0}}
    proj = {"TEAM_ID": 1, "SEASONS": 1, "_id": 0}
    for team in teams_collection.find(query, proj):
        team_id = team.get('TEAM_ID', 0)
        if team_id != 0:
            team_seasons = team.get('SEASONS', None)
            if team_seasons is None:
                continue

            logging.info(f'(Team 3PAr & FTr) Processing team {team_id}...')
            for season in seasons:
                stats = team_seasons.get(season, {}).get('STATS', None)  # Get season stats, if not exists return None
                if stats is None:
                    continue  # If team has no data for this season skip to next season

                for season_type in season_types:
                    season_stats = stats.get(season_type, None)  # Get stats for season type, if not exists return None
                    if season_stats is None or season_stats == {}:
                        continue  # If team has no data for this season type skip to next season type

                    try:
                        # Extract the values needed for calculation
                        fg3a = season_stats.get('3PA', {}).get('Totals', {}).get('Value', 0)
                        fta = season_stats.get('FTA', {}).get('Totals', {}).get('Value', 0)
                        ftm = season_stats.get('FTM', {}).get('Totals', {}).get('Value', 0)
                        fga = season_stats.get('FGA', {}).get('Totals', {}).get('Value', 1)

                        # Calculate 3PAr, FTAr, FT/FGA
                        three_pt_rate = {"Value": f"{100 * (int(fg3a) / int(fga)):.1f}%", "Rank": "0", "Pct": "0.000"}
                        fta_rate = {"Value": f"{(int(fta) / int(fga)):.3f}", "Rank": "0", "Pct": "0.000"}
                        ft_rate = {"Value": f"{(int(ftm) / int(fga)):.3f}", "Rank": "0", "Pct": "0.000"}

                        # Update the document with the new field
                        teams_collection.update_one(
                            {'TEAM_ID': team['TEAM_ID']},
                            {'$set': {f'SEASONS.{season}.STATS.{season_type}.3PAr.Totals': three_pt_rate,
                                      f'SEASONS.{season}.STATS.{season_type}.FTAr.Totals': fta_rate,
                                      f'SEASONS.{season}.STATS.{season_type}.FTr.Totals': ft_rate}
                             }
                        )

                        # logging.info(f'\tAdded stats for {season}')

                    except Exception as e:
                        logging.error(f"(Team 3PAr & FTr) Error for team {team['TEAM_ID']}: {e}", exc_info=True)


if __name__ == "__main__":
    three_and_ft_rate()
