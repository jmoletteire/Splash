import time
import logging
from collections import defaultdict
from nba_api.stats.endpoints import shotchartdetail, videodetailsasset, shotchartleaguewide
from splash_nba.imports import get_mongo_collection, PROXY, HEADERS


def get_shot_chart_data(player, team, season, season_type, keep_lg_avg):
    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    player_shots_collection = get_mongo_collection('nba_player_shot_data')

    shot_data = shotchartdetail.ShotChartDetail(proxy=PROXY, headers=HEADERS, player_id=player, team_id=team, season_nullable=season,
                                                season_type_all_star=season_type,
                                                context_measure_simple='FGA').get_normalized_dict()
    video_data = videodetailsasset.VideoDetailsAsset(proxy=PROXY, headers=HEADERS, player_id=player, team_id=team, season=season,
                                                season_type_all_star=season_type,
                                                context_measure_detailed='FGA').get_normalized_dict()

    filtered_data = [
        {
            "LOC_X": shot['LOC_X'],
            "LOC_Y": shot['LOC_Y'],
            "SHOT_ATTEMPTED_FLAG": shot['SHOT_ATTEMPTED_FLAG'],
            "SHOT_MADE_FLAG": shot['SHOT_MADE_FLAG'],
            "SHOT_TYPE": shot['ACTION_TYPE'],
            "DISTANCE": shot['SHOT_DISTANCE'],
            "GAME_DATE": shot['GAME_DATE'],
            "HTM": shot['HTM'],
            "VTM": shot['VTM'],
            "PERIOD": shot['PERIOD'],
            "MIN": shot['MINUTES_REMAINING'],
            "SEC": shot['SECONDS_REMAINING'],
            "VIDEO": video_data['Meta']['videoUrls'][i]['murl'],
            'THUMBNAIL': video_data['Meta']['videoUrls'][i]['mth'],
        }
        for i, shot in enumerate(shot_data['Shot_Chart_Detail'])
    ]

    player_shots_collection.update_one(
        {'PLAYER_ID': player},
        {'$set': {
            'PLAYER_ID': player,
            f'SEASON.{season}.{season_type}': filtered_data
        }},
        upsert=True
    )

    if keep_lg_avg:
        lg_avg = {}

        for item in shot_data['LeagueAverages']:
            zone = item['SHOT_ZONE_AREA']
            range_ = item['SHOT_ZONE_RANGE']
            if zone not in lg_avg:
                lg_avg[zone] = {}
            lg_avg[zone][range_] = item['FG_PCT']

        player_shots_collection.update_one(
            {'PLAYER_ID': 0},
            {'$set': {
                'PLAYER_ID': 0,
                f'SEASON.{season}.{season_type}': lg_avg
            }},
            upsert=True
        )

        league_avg = shotchartleaguewide.ShotChartLeagueWide(proxy=PROXY, headers=HEADERS, season=season).get_normalized_dict()

        # Mapping from SHOT_ZONE_AREA and SHOT_ZONE_BASIC to your Dart zone names
        zone_mapping = {
            ('Above the Break 3', 'Left Side Center(LC)'): 'AB3 (L)',
            ('Above the Break 3', 'Left Side(L)'): 'AB3 (L)',
            ('Above the Break 3', 'Right Side Center(RC)'): 'AB3 (R)',
            ('Above the Break 3', 'Right Side(R)'): 'AB3 (R)',
            ('Above the Break 3', 'Center(C)'): 'AB3 (C)',
            ('Left Corner 3', 'Left Side(L)'): 'C3 (L)',
            ('Right Corner 3', 'Right Side(R)'): 'C3 (R)',
            ('Mid-Range', 'Left Side Center(LC)'): 'LONG MID RANGE (L)',
            ('Mid-Range', 'Left Side(L)'): 'LONG MID RANGE (L)',
            ('Mid-Range', 'Right Side Center(RC)'): 'LONG MID RANGE (R)',
            ('Mid-Range', 'Right Side(R)'): 'LONG MID RANGE (R)',
            ('Mid-Range', 'Center(C)'): 'LONG MID RANGE (C)',
            ('In The Paint (Non-RA)', 'Left Side(L)'): 'SHORT MID RANGE',
            ('In The Paint (Non-RA)', 'Right Side(R)'): 'SHORT MID RANGE',
            ('In The Paint (Non-RA)', 'Center(C)'): 'SHORT MID RANGE',
            ('Restricted Area', 'Center(C)'): 'RESTRICTED AREA',
            ('Backcourt', 'Back Court(BC)'): 'Backcourt'
        }

        # Initialize a default dict to accumulate FGA, FGM
        zone_aggregates = defaultdict(lambda: {'FGA': 0, 'FGM': 0})

        # Aggregating data based on zone_mapping
        for entry in league_avg['League_Wide']:
            key = (entry['SHOT_ZONE_BASIC'], entry['SHOT_ZONE_AREA'])
            if key in zone_mapping:
                zone = zone_mapping[key]
                zone_aggregates[zone]['FGA'] += entry['FGA']
                zone_aggregates[zone]['FGM'] += entry['FGM']

        # Calculate FG_PCT for each zone
        for zone, stats in zone_aggregates.items():
            stats['FG_PCT'] = stats['FGM'] / stats['FGA'] if stats['FGA'] > 0 else 0

        # Convert to dictionary of dictionaries with Zone Names as keys and FG_PCT values as the values
        final_zone_data = {zone: {'FG_PCT': stats['FG_PCT']} for zone, stats in zone_aggregates.items()}

        player_shots_collection.update_one(
            {'PLAYER_ID': 0},
            {'$set': {
                'PLAYER_ID': 0,
                f'SEASON.{season}.{season_type}.Zone': final_zone_data
            }},
            upsert=True
        )


if __name__ == "__main__":
    season_types = ['Regular Season', 'Playoffs']

    # Configure logging
    logging.basicConfig(level=logging.INFO)

    # Replace with your MongoDB connection string
    players_collection = get_mongo_collection('nba_players')
    player_shots_collection = get_mongo_collection('nba_player_shot_data')
    logging.info("Connected to MongoDB")

    league_averages = player_shots_collection.find_one(
        {'PLAYER_ID': 0},
        {'_id': 0, 'SEASON': 1},
    )

    # Set batch size to process documents
    batch_size = 10
    total_documents = players_collection.count_documents({})
    processed_count = 0
    i = 0

    while processed_count < total_documents:
        with players_collection.find({}, {'PERSON_ID': 1, 'STATS': 1, '_id': 0}).skip(processed_count).limit(
                batch_size).batch_size(batch_size) as cursor:
            documents = list(cursor)
            if not documents:
                break
            processed_count += len(documents)

            for player in documents:
                i += 1
                logging.info(f'\nProcessing {i} of {total_documents} (ID: {player["PERSON_ID"]})')

                stats = player.get('STATS', None)
                if not stats:
                    continue

                for season in stats.keys():
                    try:
                        keep_league_avg = season not in league_averages['SEASON']
                        get_shot_chart_data(player['PERSON_ID'], stats[season]['REGULAR SEASON']['BASIC']['TEAM_ID'],
                                            season, 'Regular Season', keep_league_avg)
                        if 'PLAYOFFS' in stats[season]:
                            keep_league_avg = 'Playoffs' not in league_averages['SEASON'][season]
                            get_shot_chart_data(player['PERSON_ID'], stats[season]['PLAYOFFS']['BASIC']['TEAM_ID'],
                                                season, 'Playoffs', keep_league_avg)
                    except Exception as e:
                        logging.error(f'Could not process shot chart for Player {player["PERSON_ID"]}: {e}')
                        continue
                    # Pause for a random time between 0.5 and 1 second
                    time.sleep(3)

            time.sleep(30)
