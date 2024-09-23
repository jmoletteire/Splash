import 'package:flutter/material.dart';

/// ******************************************************
///                     APP TITLE
/// ******************************************************

const kSplashText = Text(
  'Splash',
  style: TextStyle(color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 35.0),
);

const String kFlaskUrl = "54.159.103.129"; //"api.splashapp.org";

const kStandardWidth = 414.0;
const kStandardHeight = 896.0;

/// ******************************************************
///                    TEXT STYLES
/// ******************************************************

const kGameCardTextStyle = TextStyle(
  color: Colors.grey,
  fontFamily: 'Bebas_Neue',
  fontSize: 15.0,
  fontWeight: FontWeight.bold,
  textBaseline: TextBaseline.alphabetic,
);

const kBebasOffWhite = TextStyle(
  color: Color(0xFFF5F5F5),
  fontFamily: 'Bebas_Neue',
  fontSize: 16.0,
  textBaseline: TextBaseline.alphabetic,
);

const kBebasBold = TextStyle(
  color: Colors.white,
  fontFamily: 'Bebas_Neue',
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
  textBaseline: TextBaseline.alphabetic,
);

const kBebasNormal = TextStyle(
  color: Colors.white,
  fontFamily: 'Bebas_Neue',
  fontSize: 20.0,
  textBaseline: TextBaseline.alphabetic,
);

/// ******************************************************
///                       LISTS
/// ******************************************************

List<String> kEastConfTeamIds = [
  '1610612737', // ATL
  '1610612738', // BOS
  '1610612739', // CLE
  '1610612741', // CHI
  '1610612748', // MIA
  '1610612749', // MIL
  '1610612751', // BKN
  '1610612752', // NYK
  '1610612753', // ORL
  '1610612754', // IND
  '1610612755', // PHI
  '1610612761', // TOR
  '1610612764', // WAS
  '1610612765', // DET
  '1610612766', // CHA
];

List<String> kWestConfTeamIds = [
  '1610612740', // NOP
  '1610612742', // DAL
  '1610612743', // DEN
  '1610612744', // GSW
  '1610612745', // HOU
  '1610612746', // LAC
  '1610612747', // LAL
  '1610612750', // MIN
  '1610612756', // PHX
  '1610612757', // POR
  '1610612758', // SAC
  '1610612759', // SAS
  '1610612760', // OKC
  '1610612762', // UTA
  '1610612763', // MEM
];

List<String> kSeasons = [
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
  '1996-97',
  '1995-96',
  '1994-95',
  '1993-94',
  '1992-93',
  '1991-92',
  '1990-91',
  '1989-90',
  '1988-89',
  '1987-88',
  '1986-87',
  '1985-86',
  '1984-85',
  '1983-84',
  '1982-83',
  '1981-82',
  '1980-81',
];

/// ******************************************************
///               STRINGS/INTEGERS/DOUBLES
/// ******************************************************

const kCurrentSeason = '2023-24';
const kLeagueSalaryCap = {
  '1996': 24693000,
  '1997': 26900000,
  '1998': 30000000,
  '1999': 34000000,
  '2000': 35500000,
  '2001': 42500000,
  '2002': 40271000,
  '2003': 43840000,
  '2004': 43870000,
  '2005': 49500000,
  '2006': 53135000,
  '2007': 55630000,
  '2008': 58680000,
  '2009': 57700000,
  '2010': 58040000,
  '2011': 58044000,
  '2012': 58044000,
  '2013': 58679000,
  '2014': 63065000,
  '2015': 70000000,
  '2016': 94143000,
  '2017': 99093000,
  '2018': 101869000,
  '2019': 109140000,
  '2020': 109140000,
  '2021': 112414000,
  '2022': 123655000,
  '2023': 136021000,
  '2024': 140588000,
  '2025': 154647000,
  '2026': 170112000,
  '2027': 187123000,
  '2028': 205835000,
  '2029': 226418000,
};
const kLeagueFirstApron = {
  '2024': 178132000,
  '2025': 195946000,
  '2026': 215541000,
  '2027': 237096000,
  '2028': 260806000,
  '2029': 286887000,
};
const kLeagueSecondApron = {
  '2024': 188931000,
  '2025': 207825000,
  '2026': 228608000,
  '2027': 251469000,
  '2028': 276616000,
  '2029': 304277000,
};

/// ******************************************************
///                        MAPS
/// ******************************************************

Map<String, dynamic> kTeamNames = {
  '0': ['Free Agent', 'FA'],
  '1610612737': ['Hawks', 'ATL'],
  '1610612738': ['Celtics', 'BOS'],
  '1610612739': ['Cavaliers', 'CLE'],
  '1610612741': ['Bulls', 'CHI'],
  '1610612748': ['Heat', 'MIA'],
  '1610612749': ['Bucks', 'MIL'],
  '1610612751': ['Nets', 'BKN'],
  '1610612752': ['Knicks', 'NYK'],
  '1610612753': ['Magic', 'ORL'],
  '1610612754': ['Pacers', 'IND'],
  '1610612755': ['76ers', 'PHI'],
  '1610612761': ['Raptors', 'TOR'],
  '1610612764': ['Wizards', 'WAS'],
  '1610612765': ['Pistons', 'DET'],
  '1610612766': ['Hornets', 'CHA'],
  '1610612740': ['Pelicans', 'NOP'],
  '1610612742': ['Mavericks', 'DAL'],
  '1610612743': ['Nuggets', 'DEN'],
  '1610612744': ['Warriors', 'GSW'],
  '1610612745': ['Rockets', 'HOU'],
  '1610612746': ['Clippers', 'LAC'],
  '1610612747': ['Lakers', 'LAL'],
  '1610612750': ['Timberwolves', 'MIN'],
  '1610612756': ['Suns', 'PHX'],
  '1610612757': ['Trail Blazers', 'POR'],
  '1610612758': ['Kings', 'SAC'],
  '1610612759': ['Spurs', 'SAS'],
  '1610612760': ['Thunder', 'OKC'],
  '1610612762': ['Jazz', 'UTA'],
  '1610612763': ['Grizzlies', 'MEM']
};

Map<String, String> kTeamIds = {
  'FA': '0',
  'ATL': '1610612737',
  'BOS': '1610612738',
  'CLE': '1610612739',
  'CHI': '1610612741',
  'MIA': '1610612748',
  'MIL': '1610612749',
  'BKN': '1610612751',
  'NYK': '1610612752',
  'ORL': '1610612753',
  'IND': '1610612754',
  'PHI': '1610612755',
  'TOR': '1610612761',
  'WAS': '1610612764',
  'DET': '1610612765',
  'CHA': '1610612766',
  'NOP': '1610612740',
  'DAL': '1610612742',
  'DEN': '1610612743',
  'GSW': '1610612744',
  'HOU': '1610612745',
  'LAC': '1610612746',
  'LAL': '1610612747',
  'MIN': '1610612750',
  'PHX': '1610612756',
  'POR': '1610612757',
  'SAC': '1610612758',
  'SAS': '1610612759',
  'OKC': '1610612760',
  'UTA': '1610612762',
  'MEM': '1610612763'
};

const Map<String, dynamic> kTeamStatLabelMap = {
  'EFFICIENCY': {
    'ORTG': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'OFF_RATING',
        'rank_nba_name': 'OFF_RATING_RANK',
      },
      'PER_100': {
        'nba_name': 'OFF_RATING',
        'rank_nba_name': 'OFF_RATING_RANK',
      },
      'splash_name': 'OFF RTG',
      'full_name': 'Offensive Rating',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition': 'A team\'s points scored per 100 possessions.',
      'formula': '100 * (Points Scored / Possessions)'
    },
    'DRTG': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'DEF_RATING',
        'rank_nba_name': 'DEF_RATING_RANK',
      },
      'PER_100': {
        'nba_name': 'DEF_RATING',
        'rank_nba_name': 'DEF_RATING_RANK',
      },
      'splash_name': 'DEF RTG',
      'full_name': 'Defensive Rating',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition': 'A team\'s points allowed per 100 possessions.',
      'formula': '100 * (Points Allowed / Possessions)'
    },
    'NRTG': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'NET_RATING',
        'rank_nba_name': 'NET_RATING_RANK',
      },
      'PER_100': {
        'nba_name': 'NET_RATING',
        'rank_nba_name': 'NET_RATING_RANK',
      },
      'splash_name': 'NET RTG',
      'full_name': 'Net Rating',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition': 'A team\'s point differential per 100 possessions.',
      'formula': 'ORTG - DRTG'
    },
    'PACE': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'PACE',
        'rank_nba_name': 'PACE_RANK',
      },
      'PER_100': {
        'nba_name': 'PACE',
        'rank_nba_name': 'PACE_RANK',
      },
      'splash_name': 'PACE',
      'full_name': 'Pace',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition': 'A team\'s number of possessions per 48 minutes.',
      'formula': ''
    },
    'TOV%': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'TM_TOV_PCT',
        'rank_nba_name': 'TM_TOV_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'TM_TOV_PCT',
        'rank_nba_name': 'TM_TOV_PCT_RANK',
      },
      'splash_name': 'TOV%',
      'full_name': 'Turnover Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of plays that end in a team\'s turnover.',
      'formula': ''
    },
  },
  'SCORING': {
    'PTS': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'PTS',
        'rank_nba_name': 'PTS_RANK',
      },
      'PER_100': {
        'nba_name': 'PTS_PER_100',
        'rank_nba_name': 'PTS_PER_100_RANK',
      },
      'splash_name': 'PTS',
      'full_name': 'Points Scored',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of points scored by a team.',
      'formula': ''
    },
    'eFG%': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'splash_name': 'eFG%',
      'full_name': 'Effective Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'Measures field goal percentage adjusting for made 3-point field goals being 1.5 times more valuable than made 2-point field goals.',
      'formula': '((FGM + (0.5 * 3PM)) / FGA'
    },
    'TS%': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'TS_PCT',
        'rank_nba_name': 'TS_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'TS_PCT',
        'rank_nba_name': 'TS_PCT_RANK',
      },
      'splash_name': 'TS%',
      'full_name': 'True Shooting Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'A shooting percentage that factors in the value of 3-point field goals and free throws in addition to conventional 2-point field goals (assuming 44% of FTAs end possessions).',
      'formula': 'PTS / [2 * (FGA + (0.44 * FTA))]'
    },
    'fill': {'first_available': '1996'},
    'FGM': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FGM',
        'rank_nba_name': 'FGM_RANK',
      },
      'PER_100': {
        'nba_name': 'FGM_PER_100',
        'rank_nba_name': 'FGM_PER_100_RANK',
      },
      'splash_name': 'FGM',
      'full_name': 'Field Goals Made',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of field goal attempts (shots) that a team makes.',
      'formula': ''
    },
    'FGA': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FGA',
        'rank_nba_name': 'FGA_RANK',
      },
      'PER_100': {
        'nba_name': 'FGA_PER_100',
        'rank_nba_name': 'FGA_PER_100_RANK',
      },
      'splash_name': 'FGA',
      'full_name': 'Field Goal Attempts',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of field goals (shots) that a team attempted.',
      'formula': ''
    },
    'FG%': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'FG%',
      'full_name': 'Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of field goal attempts that a team makes.',
      'formula': 'FGM / FGA'
    },
    'fill2': {'first_available': '1996'},
    '3PM': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FG3M',
        'rank_nba_name': 'FG3M_RANK',
      },
      'PER_100': {
        'nba_name': 'FG3M_PER_100',
        'rank_nba_name': 'FG3M_PER_100_RANK',
      },
      'splash_name': '3PM',
      'full_name': 'Three-Point Field Goals Made',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of 3-point field goal attempts that a team makes.',
      'formula': ''
    },
    '3PA': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FG3A',
        'rank_nba_name': 'FG3A_RANK',
      },
      'PER_100': {
        'nba_name': 'FG3A_PER_100',
        'rank_nba_name': 'FG3A_PER_100_RANK',
      },
      'splash_name': '3PA',
      'full_name': 'Three-Point Field Goal Attempts',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of 3-point field goals that a team attempted.',
      'formula': ''
    },
    '3P%': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': '3P%',
      'full_name': 'Three-Point Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of 3-point field goal attempts that a team makes.',
      'formula': '3PM / 3PA'
    },
    '3PAr': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': '3PAr',
        'rank_nba_name': '3PAr_RANK',
      },
      'PER_100': {
        'nba_name': '3PAr',
        'rank_nba_name': '3PAr_RANK',
      },
      'splash_name': '3PAr',
      'full_name': 'Three-Point Attempt Rate',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The number of 3-point field goal attempts a team shoots compared to the number of total field goal attempts they shoot.',
      'formula': '3PA / FGA'
    },
    'fill3': {'first_available': '1996'},
    'FTM': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FTM',
        'rank_nba_name': 'FTM_RANK',
      },
      'PER_100': {
        'nba_name': 'FTM_PER_100',
        'rank_nba_name': 'FTM_PER_100_RANK',
      },
      'splash_name': 'FTM',
      'full_name': 'Free Throws Made',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of free throw attempts that a team makes.',
      'formula': ''
    },
    'FTA': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FTA',
        'rank_nba_name': 'FTA_RANK',
      },
      'PER_100': {
        'nba_name': 'FTA_PER_100',
        'rank_nba_name': 'FTA_PER_100_RANK',
      },
      'splash_name': 'FTA',
      'full_name': 'Free Throw Attempts',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of free throws that a team attempted.',
      'formula': ''
    },
    'FT%': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FT_PCT',
        'rank_nba_name': 'FT_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'FT_PCT',
        'rank_nba_name': 'FT_PCT_RANK',
      },
      'splash_name': 'FT%',
      'full_name': 'Free Throw Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of free throw attempts that a team makes.',
      'formula': 'FTM / FTA'
    },
    'FT/FGA': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'FT_PER_FGA',
        'rank_nba_name': 'FT_PER_FGA_RANK',
      },
      'PER_100': {
        'nba_name': 'FT_PER_FGA',
        'rank_nba_name': 'FT_PER_FGA_RANK',
      },
      'splash_name': 'FT/FGA',
      'full_name': 'Free Throws per Field Goal Attempt',
      'first_available': '1996',
      'convert': 'false',
      'round': '2',
      'definition':
          'The number of free throws a team makes compared to the number of field goal attempts they shoot.',
      'formula': 'FTM / FGA'
    },
  },
  'DEFENSE': {
    'DRTG': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'DEF_RATING',
        'rank_nba_name': 'DEF_RATING_RANK',
      },
      'PER_100': {
        'nba_name': 'DEF_RATING',
        'rank_nba_name': 'DEF_RATING_RANK',
      },
      'splash_name': 'DRTG',
      'full_name': 'Defensive Rating',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition': 'Team\'s points allowed per 100 possessions.',
      'formula': '100 * (Points Allowed / Possessions)'
    },
    'fill': {'first_available': '2016'},
    'STL': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'STL',
        'rank_nba_name': 'STL_RANK',
      },
      'PER_100': {
        'nba_name': 'STL_PER_100',
        'rank_nba_name': 'STL_PER_100_RANK',
      },
      'splash_name': 'STL',
      'full_name': 'Steals',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition':
          'Number of times a defensive player or team takes the ball from a player on offense, causing a turnover.',
      'formula': ''
    },
    'DEFLECTS': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'DEFLECTIONS',
        'rank_nba_name': 'DEFLECTIONS_RANK',
      },
      'PER_100': {
        'nba_name': 'DEFLECTIONS_PER_100',
        'rank_nba_name': 'DEFLECTIONS_PER_100_RANK',
      },
      'splash_name': 'DEFLECTIONS',
      'full_name': 'Deflections',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a defensive player or team gets their hand on the ball on a non-shot attempt.',
      'formula': ''
    },
    'fill2': {'first_available': '2016'},
    'BLK': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'BLK',
        'rank_nba_name': 'BLK_RANK',
      },
      'PER_100': {
        'nba_name': 'BLK_PER_100',
        'rank_nba_name': 'BLK_PER_100_RANK',
      },
      'splash_name': 'BLK',
      'full_name': 'Blocks',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition':
          'A block occurs when an offensive player attempts a shot, and the defensive player tips the ball, blocking their chance to score.',
      'formula': ''
    },
    'CONTESTS': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'CONTESTED_SHOTS',
        'rank_nba_name': 'CONTESTED_SHOTS_RANK',
      },
      'PER_100': {
        'nba_name': 'CONTESTED_SHOTS_PER_100',
        'rank_nba_name': 'CONTESTED_SHOTS_PER_100_RANK',
      },
      'splash_name': 'CONTESTED SHOTS',
      'full_name': 'Contested Shots',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a defensive player or team closes out and raises a hand to contest a shot prior to its release.',
      'formula': ''
    },
  },
  'REBOUNDING': {
    'REB': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'REB',
        'rank_nba_name': 'REB_RANK',
      },
      'PER_100': {
        'nba_name': 'REB_PER_100',
        'rank_nba_name': 'REB_PER_100_RANK',
      },
      'splash_name': 'REB',
      'full_name': 'Total Rebounds',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of total rebounds a team obtained.',
      'formula': 'OREB + DREB'
    },
    'OREB': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'OREB',
        'rank_nba_name': 'OREB_RANK',
      },
      'PER_100': {
        'nba_name': 'OREB_PER_100',
        'rank_nba_name': 'OREB_PER_100_RANK',
      },
      'splash_name': 'OREB',
      'full_name': 'Offensive Rebounds',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of offensive rebounds a team obtained.',
      'formula': ''
    },
    'DREB': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'DREB',
        'rank_nba_name': 'DREB_RANK',
      },
      'PER_100': {
        'nba_name': 'DREB_PER_100',
        'rank_nba_name': 'DREB_PER_100_RANK',
      },
      'splash_name': 'DREB',
      'full_name': 'Defensive Rebounds',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of defensive rebounds a team obtained.',
      'formula': ''
    },
    'fill': {'first_available': '1996'},
    'OREB%': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'OREB_PCT',
        'rank_nba_name': 'OREB_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'OREB_PCT',
        'rank_nba_name': 'OREB_PCT_RANK',
      },
      'splash_name': 'OREB%',
      'full_name': 'Offensive Rebound Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of available offensive rebounds a team obtained.',
      'formula': ''
    },
    'DREB%': {
      'location': ['ADV'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'DREB_PCT',
        'rank_nba_name': 'DREB_PCT_RANK',
      },
      'PER_100': {
        'nba_name': 'DREB_PCT',
        'rank_nba_name': 'DREB_PCT_RANK',
      },
      'splash_name': 'DREB%',
      'full_name': 'Defensive Rebound Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of available defensive rebounds a team obtained.',
      'formula': ''
    },
    'fill2': {'first_available': '2016'},
    'BOX_OUTS': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'BOX_OUTS',
        'rank_nba_name': 'BOX_OUTS_RANK',
      },
      'PER_100': {
        'nba_name': 'BOX_OUTS_PER_100',
        'rank_nba_name': 'BOX_OUTS_PER_100_RANK',
      },
      'splash_name': 'BOX OUTS',
      'full_name': 'Box Outs',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a player made physical contact with an opponent who was actively pursuing a rebound, showed visible progress or strong effort in disadvantaging the opponent, and successfully prevented that opponent from securing the rebound.',
      'formula': ''
    },
    'OFF_BOX_OUTS': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'OFF_BOXOUTS',
        'rank_nba_name': 'OFF_BOXOUTS_RANK',
      },
      'PER_100': {
        'nba_name': 'OFF_BOXOUTS_PER_100',
        'rank_nba_name': 'OFF_BOXOUTS_PER_100_RANK',
      },
      'splash_name': 'OFF BOX OUTS',
      'full_name': 'Offensive Box Outs',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times an offensive player made physical contact with an opponent who was actively pursuing a rebound, showed visible progress or strong effort in disadvantaging the opponent, and successfully prevented that opponent from securing the rebound.',
      'formula': ''
    },
    'DEF_BOX_OUTS': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'DEF_BOXOUTS',
        'rank_nba_name': 'DEF_BOXOUTS_RANK',
      },
      'PER_100': {
        'nba_name': 'DEF_BOXOUTS_PER_100',
        'rank_nba_name': 'DEF_BOXOUTS_PER_100_RANK',
      },
      'splash_name': 'DEF BOX OUTS',
      'full_name': 'Defensive Box Outs',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a defensive player made physical contact with an opponent who was actively pursuing a rebound, showed visible progress or strong effort in disadvantaging the opponent, and successfully prevented that opponent from securing the rebound.',
      'formula': ''
    },
  },
  'HUSTLE': {
    'SCREEN_ASSISTS': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'SCREEN_ASSISTS',
        'rank_nba_name': 'SCREEN_ASSISTS_RANK',
      },
      'PER_100': {
        'nba_name': 'SCREEN_ASSISTS_PER_100',
        'rank_nba_name': 'SCREEN_ASSISTS_PER_100_RANK',
      },
      'splash_name': 'SCREEN ASSISTS',
      'full_name': 'Screen Assists',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times an offensive player sets a screen for a teammate that directly leads to a made field goal by that teammate.',
      'formula': ''
    },
    'SCREEN_AST_PTS': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'SCREEN_AST_PTS',
        'rank_nba_name': 'SCREEN_AST_PTS_RANK',
      },
      'PER_100': {
        'nba_name': 'SCREEN_AST_PTS_PER_100',
        'rank_nba_name': 'SCREEN_AST_PTS_PER_100_RANK',
      },
      'splash_name': 'SCREEN AST PTS',
      'full_name': 'Screen Assist Points',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition': 'Points created by a team through their screen assists.',
      'formula': ''
    },
    'fill': {'first_available': '2016'},
    'LOOSE_BALLS_RECOVERED': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'LOOSE_BALLS_RECOVERED',
        'rank_nba_name': 'LOOSE_BALLS_RECOVERED_RANK',
      },
      'PER_100': {
        'nba_name': 'LOOSE_BALLS_RECOVERED_PER_100',
        'rank_nba_name': 'LOOSE_BALLS_RECOVERED_PER_100_RANK',
      },
      'splash_name': 'LOOSE BALLS',
      'full_name': 'Loose Balls Recovered',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a team gains sole possession of a live ball that is not in the control of either team.',
      'formula': ''
    },
    'fill2': {'first_available': '2016'},
    'PF': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'PF',
        'rank_nba_name': 'PF_RANK',
      },
      'PER_100': {
        'nba_name': 'PF_PER_100',
        'rank_nba_name': 'PF_PER_100_RANK',
      },
      'splash_name': 'FOULS',
      'full_name': 'Personal Fouls',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of personal fouls a team committed.',
      'formula': ''
    },
    'PFD': {
      'location': ['BASIC'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'PFD',
        'rank_nba_name': 'PFD_RANK',
      },
      'PER_100': {
        'nba_name': 'PFD_PER_100',
        'rank_nba_name': 'PFD_PER_100_RANK',
      },
      'splash_name': 'FOULS DRAWN',
      'full_name': 'Personal Fouls Drawn',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of personal fouls drawn by a team.',
      'formula': ''
    },
    'CHARGES_DRAWN': {
      'location': ['HUSTLE'],
      'secondaryLocation': '',
      'TOTAL': {
        'nba_name': 'CHARGES_DRAWN',
        'rank_nba_name': 'CHARGES_DRAWN_RANK',
      },
      'PER_100': {
        'nba_name': 'CHARGES_DRAWN',
        'rank_nba_name': 'CHARGES_DRAWN_RANK',
      },
      'splash_name': 'CHARGES DRAWN',
      'full_name': 'Charges Drawn',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of charging fouls drawn by a team.',
      'formula': ''
    },
  },
};

const Map<String, dynamic> kPlayerStatLabelMap = {
  'EFFICIENCY': {
    'GP': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'GP',
        'rank_nba_name': 'GP_RANK',
      },
      'PER_75': {
        'nba_name': 'GP',
        'rank_nba_name': 'GP_RANK',
      },
      'splash_name': 'GP',
      'full_name': 'Games Played',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of games a player participated in.',
      'formula': ''
    },
    'MIN': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'MIN',
        'rank_nba_name': 'MIN_RANK',
      },
      'PER_75': {
        'nba_name': 'MIN',
        'rank_nba_name': 'MIN_RANK',
      },
      'splash_name': 'MIN',
      'full_name': 'Minutes Played',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of game minutes a player was on the court.',
      'formula': ''
    },
    'MPG': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'MIN',
        'rank_nba_name': 'MIN_RANK',
      },
      'PER_75': {
        'nba_name': 'MIN',
        'rank_nba_name': 'MIN_RANK',
      },
      'splash_name': 'MPG',
      'full_name': 'Minutes Per Game',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition': 'The number of game minutes a player was on the court per game.',
      'formula': ''
    },
    'POSS': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'POSS',
        'rank_nba_name': 'POSS_RANK',
      },
      'PER_75': {
        'nba_name': 'POSS',
        'rank_nba_name': 'POSS_RANK',
      },
      'splash_name': 'POSS',
      'full_name': 'Possessions Played',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of team possessions a player was on the court.',
      'formula': ''
    },
    'POSS PER GM': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'POSS_PER_GM',
        'rank_nba_name': 'POSS_PER_GM_RANK',
      },
      'PER_75': {
        'nba_name': 'POSS_PER_GM',
        'rank_nba_name': 'POSS_PER_GM_RANK',
      },
      'splash_name': 'POSS PER G',
      'full_name': 'Possessions Played per Game',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition': 'The number of team possessions a player was on the court per game.',
      'formula': ''
    },
    'fill': {'first_available': '1996'},
    'PACE': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'PACE',
        'rank_nba_name': 'PACE_RANK',
      },
      'PER_75': {
        'nba_name': 'PACE',
        'rank_nba_name': 'PACE_RANK',
      },
      'splash_name': 'PACE',
      'full_name': 'Pace',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition':
          'A team\'s number of possessions per 48 minutes when this player is on the court.',
      'formula': ''
    },
    'ORTG': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'OFF_RATING_ON_OFF',
        'rank_nba_name': 'OFF_RATING_ON_OFF_RANK',
      },
      'PER_75': {
        'nba_name': 'OFF_RATING_ON_OFF',
        'rank_nba_name': 'OFF_RATING_ON_OFF_RANK',
      },
      'splash_name': 'ORTG - ON/OFF',
      'full_name': 'Offensive Rating - On/Off',
      'first_available': '2007',
      'convert': 'false',
      'round': '1',
      'definition':
          'Difference in team\'s points scored per 100 possessions when player is on court vs. when player is off court.',
      'formula': 'ORTG (On) - ORTG (Off)'
    },
    'DRTG': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'DEF_RATING_ON_OFF',
        'rank_nba_name': 'DEF_RATING_ON_OFF_RANK',
      },
      'PER_75': {
        'nba_name': 'DEF_RATING_ON_OFF',
        'rank_nba_name': 'DEF_RATING_ON_OFF_RANK',
      },
      'splash_name': 'DRTG - ON/OFF',
      'full_name': 'Defensive Rating - On/Off',
      'first_available': '2007',
      'convert': 'false',
      'round': '1',
      'definition':
          'Difference in team\'s points allowed per 100 possessions when player is on court vs. when player is off court.',
      'formula': 'DRTG (On) - DRTG (Off)'
    },
    'NRTG': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'NET_RATING_ON_OFF',
        'rank_nba_name': 'NET_RATING_ON_OFF_RANK',
      },
      'PER_75': {
        'nba_name': 'NET_RATING_ON_OFF',
        'rank_nba_name': 'NET_RATING_ON_OFF_RANK',
      },
      'splash_name': 'NRTG - ON/OFF',
      'full_name': 'Net Rating - On/Off',
      'first_available': '2007',
      'convert': 'false',
      'round': '1',
      'definition':
          'Difference in team\'s point differential per 100 possessions when player is on court vs. when player is off court.',
      'formula': 'NRTG (On) - NRTG (Off)'
    },
    '+/-': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'PLUS_MINUS',
        'rank_nba_name': 'PLUS_MINUS_RANK',
      },
      'PER_75': {
        'nba_name': 'PLUS_MINUS_PER_75',
        'rank_nba_name': 'PLUS_MINUS_PER_75_RANK',
      },
      'splash_name': 'P/M',
      'full_name': 'Plus/Minus',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'Team\'s point differential when player is on court.',
      'formula': ''
    },
    'fill2': {'first_available': '1996'},
    'USAGE': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'USG_PCT',
        'rank_nba_name': 'USG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'USG_PCT',
        'rank_nba_name': 'USG_PCT_RANK',
      },
      'splash_name': 'USG%',
      'full_name': 'Usage Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of team plays used by a player when they are on the floor.',
      'formula': '(FGA + Possession Ending FTA + TO) / Plays'
    },
    'OFF LOAD': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'OFFENSIVE_LOAD',
        'rank_nba_name': 'OFFENSIVE_LOAD_RANK',
      },
      'PER_75': {
        'nba_name': 'OFFENSIVE_LOAD',
        'rank_nba_name': 'OFFENSIVE_LOAD_RANK',
      },
      'splash_name': 'LOAD%',
      'full_name': 'Offensive Load',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition':
          'Estimates percentage of team plays a player contributes to when they are on the floor. Unlike Usage, Offensive Load incorporates passing and creation.',
      'formula':
          '((AST - (0.38 * BOX CREATION) * 0.75) + (FTA * 0.44) + FGA + BOX CREATION + TOV'
    },
    'TOV': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'TOV',
        'rank_nba_name': 'TOV_RANK',
      },
      'PER_75': {
        'nba_name': 'TOV_PER_75',
        'rank_nba_name': 'TOV_PER_75_RANK',
      },
      'splash_name': 'TOV',
      'full_name': 'Turnovers',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition':
          'A turnover occurs when the player or team on offense loses the ball to the defense.',
      'formula': ''
    },
    'C-TOV%': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'ADJ_TOV_PCT',
        'rank_nba_name': 'ADJ_TOV_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'ADJ_TOV_PCT',
        'rank_nba_name': 'ADJ_TOV_PCT_RANK',
      },
      'splash_name': 'cTOV%',
      'full_name': 'Creation-Based (Adjusted) Turnover %',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'Turnover percentage based on possessions the player was involved rather than possessions the player ended.',
      'formula': 'TOV / (LOAD% * 100)'
    },
    'fill3': {'first_available': '2013'},
    'TOUCHES': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'TOUCHES',
        'rank_nba_name': 'TOUCHES_RANK',
      },
      'PER_75': {
        'nba_name': 'TOUCHES_PER_75',
        'rank_nba_name': 'TOUCHES_PER_75_RANK',
      },
      'splash_name': 'TOUCHES',
      'full_name': 'Touches',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of times a player possessed the ball.',
      'formula': ''
    },
    'TIME OF POSS': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'TIME_OF_POSS',
        'rank_nba_name': 'TIME_OF_POSS_RANK',
      },
      'PER_75': {
        'nba_name': 'TIME_OF_POSS_PER_75',
        'rank_nba_name': 'TIME_OF_POSS_PER_75_RANK',
      },
      'splash_name': 'TIME OF POSS',
      'full_name': 'Time of Possession',
      'first_available': '2013',
      'convert': 'false',
      'round': '1',
      'definition': 'The number of minutes a player possessed the ball.',
      'formula': ''
    },
    'SECONDS PER TOUCH': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'AVG_SEC_PER_TOUCH',
        'rank_nba_name': 'AVG_SEC_PER_TOUCH_RANK',
      },
      'PER_75': {
        'nba_name': 'AVG_SEC_PER_TOUCH',
        'rank_nba_name': 'AVG_SEC_PER_TOUCH_RANK',
      },
      'splash_name': 'SEC PER TOUCH',
      'full_name': 'Seconds Per Touch',
      'first_available': '2013',
      'convert': 'false',
      'round': '1',
      'definition': 'The number of times a player dribbles the ball per touch.',
      'formula': ''
    },
    'DRIBBLES PER TOUCH': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'AVG_DRIB_PER_TOUCH',
        'rank_nba_name': 'AVG_DRIB_PER_TOUCH_RANK',
      },
      'PER_75': {
        'nba_name': 'AVG_DRIB_PER_TOUCH',
        'rank_nba_name': 'AVG_DRIB_PER_TOUCH_RANK',
      },
      'splash_name': 'DRIB PER TOUCH',
      'full_name': 'Dribbles Per Touch',
      'first_available': '2013',
      'convert': 'false',
      'round': '1',
      'definition': 'The number of times a player dribbles the ball per touch.',
      'formula': ''
    },
    'fill4': {'first_available': '2013'},
    '% SHOOT': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'FGA_PER_TOUCH',
        'rank_nba_name': 'FGA_PER_TOUCH_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_PER_TOUCH',
        'rank_nba_name': 'FGA_PER_TOUCH_RANK',
      },
      'splash_name': '% SHOOT',
      'full_name': '% Shoot',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of touches a player shot the ball.',
      'formula': ''
    },
    '% PASS': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'PASSES_PER_TOUCH',
        'rank_nba_name': 'PASSES_PER_TOUCH_RANK',
      },
      'PER_75': {
        'nba_name': 'PASSES_PER_TOUCH',
        'rank_nba_name': 'PASSES_PER_TOUCH_RANK',
      },
      'splash_name': '% PASS',
      'full_name': '% Pass',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of touches a player passed the ball to a teammate.',
      'formula': ''
    },
    '% TOV': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'TOV_PER_TOUCH',
        'rank_nba_name': 'TOV_PER_TOUCH_RANK',
      },
      'PER_75': {
        'nba_name': 'TOV_PER_TOUCH',
        'rank_nba_name': 'TOV_PER_TOUCH_RANK',
      },
      'splash_name': '% TOV',
      'full_name': '% Turnover',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of touches a player turned the ball over.',
      'formula': ''
    },
    '% FOULED': {
      'location': ['ADV', 'TOUCHES'],
      'TOTAL': {
        'nba_name': 'PFD_PER_TOUCH',
        'rank_nba_name': 'PFD_PER_TOUCH_RANK',
      },
      'PER_75': {
        'nba_name': 'PFD_PER_TOUCH',
        'rank_nba_name': 'PFD_PER_TOUCH_RANK',
      },
      'splash_name': '% FOULED',
      'full_name': '% Fouled',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of touches a player was fouled.',
      'formula': ''
    },
  },
  'SCORING': {
    'PTS': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'PTS',
        'rank_nba_name': 'PTS_RANK',
      },
      'PER_75': {
        'nba_name': 'PTS_PER_75',
        'rank_nba_name': 'PTS_PER_75_RANK',
      },
      'splash_name': 'PTS',
      'full_name': 'Points Scored',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of points scored by a player.',
      'formula': ''
    },
    'eFG%': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'splash_name': 'eFG%',
      'full_name': 'Effective Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'Measures field goal percentage adjusting for made 3-point field goals being 1.5 times more valuable than made 2-point field goals.',
      'formula': '((FGM + (0.5 * 3PM)) / FGA'
    },
    'TS%': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'TS_PCT',
        'rank_nba_name': 'TS_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'TS_PCT',
        'rank_nba_name': 'TS_PCT_RANK',
      },
      'splash_name': 'TS%',
      'full_name': 'True Shooting Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'A shooting percentage that factors in the value of 3-point field goals and free throws in addition to conventional 2-point field goals (assuming 44% of FTAs end possessions).',
      'formula': 'PTS / [2 * (FGA + (0.44 * FTA))]'
    },
    '% UAST': {
      'location': ['ADV', 'SCORING_BREAKDOWN'],
      'TOTAL': {
        'nba_name': 'PCT_UAST_FGM',
        'rank_nba_name': 'PCT_UAST_FGM_RANK',
      },
      'PER_75': {
        'nba_name': 'PCT_UAST_FGM',
        'rank_nba_name': 'PCT_UAST_FGM_RANK',
      },
      'splash_name': '% UAST',
      'full_name': 'Percent Unassisted',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of this player\'s FGM that were not assisted by a teammate.',
      'formula': ''
    },
    'fill': {'first_available': '1996'},
    'FGM': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FGM',
        'rank_nba_name': 'FGM_RANK',
      },
      'PER_75': {
        'nba_name': 'FGM_PER_75',
        'rank_nba_name': 'FGM_PER_75_RANK',
      },
      'splash_name': 'FGM',
      'full_name': 'Field Goals Made',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of field goal attempts (shots) that a player makes.',
      'formula': ''
    },
    'FGA': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FGA',
        'rank_nba_name': 'FGA_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_PER_75',
        'rank_nba_name': 'FGA_PER_75_RANK',
      },
      'splash_name': 'FGA',
      'full_name': 'Field Goal Attempts',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of field goals (shots) that a player attempted.',
      'formula': ''
    },
    'FG%': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'FG%',
      'full_name': 'Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of field goal attempts that a player makes.',
      'formula': 'FGM / FGA'
    },
    'fill2': {'first_available': '1996'},
    '3PM': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FG3M',
        'rank_nba_name': 'FG3M_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3M_PER_75',
        'rank_nba_name': 'FG3M_PER_75_RANK',
      },
      'splash_name': '3PM',
      'full_name': 'Three-Point Field Goals Made',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of 3-point field goal attempts that a player makes.',
      'formula': ''
    },
    '3PA': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FG3A',
        'rank_nba_name': 'FG3A_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3A_PER_75',
        'rank_nba_name': 'FG3A_PER_75_RANK',
      },
      'splash_name': '3PA',
      'full_name': 'Three-Point Field Goal Attempts',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of 3-point field goals that a player attempted.',
      'formula': ''
    },
    '3P%': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': '3P%',
      'full_name': 'Three-Point Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of 3-point field goal attempts that a player makes.',
      'formula': '3PM / 3PA'
    },
    '3PA RATE': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': '3PAr',
        'rank_nba_name': '3PAr_RANK',
      },
      'PER_75': {
        'nba_name': '3PAr',
        'rank_nba_name': '3PAr_RANK',
      },
      'splash_name': '3PAr',
      'full_name': 'Three-Point Attempt Rate',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The number of 3-point field goal attempts a player shoots compared to the number of total field goal attempts they shoot.',
      'formula': '3PA / FGA'
    },
    '% 3P UAST': {
      'location': ['ADV', 'SCORING_BREAKDOWN'],
      'TOTAL': {
        'nba_name': 'PCT_UAST_3PM',
        'rank_nba_name': 'PCT_UAST_3PM_RANK',
      },
      'PER_75': {
        'nba_name': 'PCT_UAST_3PM',
        'rank_nba_name': 'PCT_UAST_3PM_RANK',
      },
      'splash_name': '% 3P UAST',
      'full_name': 'Percent 3-Point Field Goals Unassisted',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of this player\'s 3PM that were not assisted by a teammate.',
      'formula': ''
    },
    'fill4': {'first_available': '1996'},
    'FTM': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FTM',
        'rank_nba_name': 'FTM_RANK',
      },
      'PER_75': {
        'nba_name': 'FTM_PER_75',
        'rank_nba_name': 'FTM_PER_75_RANK',
      },
      'splash_name': 'FTM',
      'full_name': 'Free Throws Made',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of free throw attempts that a player makes.',
      'formula': ''
    },
    'FTA': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FTA',
        'rank_nba_name': 'FTA_RANK',
      },
      'PER_75': {
        'nba_name': 'FTA_PER_75',
        'rank_nba_name': 'FTA_PER_75_RANK',
      },
      'splash_name': 'FTA',
      'full_name': 'Free Throw Attempts',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of free throws that a player attempted.',
      'formula': ''
    },
    'FT%': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FT_PCT',
        'rank_nba_name': 'FT_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FT_PCT',
        'rank_nba_name': 'FT_PCT_RANK',
      },
      'splash_name': 'FT%',
      'full_name': 'Free Throw Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of free throw attempts that a player makes.',
      'formula': 'FTM / FTA'
    },
    'FT/FGA': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'FT_PER_FGA',
        'rank_nba_name': 'FT_PER_FGA_RANK',
      },
      'PER_75': {
        'nba_name': 'FT_PER_FGA',
        'rank_nba_name': 'FT_PER_FGA_RANK',
      },
      'splash_name': 'FT/FGA',
      'full_name': 'Free Throws per Field Goal Attempt',
      'first_available': '1996',
      'convert': 'false',
      'round': '2',
      'definition':
          'The number of free throws a player makes compared to the number of field goal attempts they shoot.',
      'formula': 'FTM / FGA'
    },
  },
  'SHOT TYPE': {
    'C&S FREQ': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Catch and Shoot'],
      'TOTAL': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'splash_name': 'C&S FREQ',
      'full_name': 'Catch & Shoot - Frequency',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'The number of Catch & Shoot field goal attempts taken by a player compared to the total field goal attempts by the player.\n\n"Catch & Shoot" is a shot in which a player catches a pass and shoots the ball without dribbling or waiting.',
      'formula': ''
    },
    'PULL UP FREQ': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Pull Ups'],
      'TOTAL': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'splash_name': 'PULL-UP FREQ',
      'full_name': 'Pull-Up Frequency',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'The number of Pull-Up field goal attempts taken by a player compared to the total field goal attempts by the player.\n\nA pull-up shot is one in which a player shoots the ball directly off of a dribble.',
      'formula': ''
    },
    '< 10FT FREQ': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Less than 10 ft'],
      'TOTAL': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'splash_name': '< 10FT FREQ',
      'full_name': 'Less Than 10 Feet - Frequency',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'The number of field goal attempts within 10 feet of the basket taken by a player compared to the total field goal attempts by the player.',
      'formula': ''
    },
    'fill': {'first_available': '2013'},
    'C&S FG%': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Catch and Shoot'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'C&S FG%',
      'full_name': 'Catch & Shoot - Field Goal Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of Catch & Shoot field goal attempts that a player makes.\n\n"Catch & Shoot" is a shot in which a player catches a pass and shoots the ball without dribbling or waiting.',
      'formula': 'FGM / FGA'
    },
    'PULL UP FG%': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Pull Ups'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'PULL UP FG%',
      'full_name': 'Pull-Up - Field Goal Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of Pull-Up field goal attempts that a player makes.\n\nA pull-up shot is one in which a player shoots the ball directly off of a dribble.',
      'formula': 'FGM / FGA'
    },
    '< 10FT FG%': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Less than 10 ft'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': '< 10FT FG%',
      'full_name': 'Less Than 10 Feet - Field Goal Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of field goal attempts within 10 feet of the basket that a player makes.',
      'formula': 'FGM / FGA'
    },
    'fill2': {'first_available': '2013'},
    'C&S 3P%': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Catch and Shoot'],
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': 'C&S 3P%',
      'full_name': 'Catch & Shoot - Three-Point Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of Catch & Shoot 3-point field goal attempts that a player makes.\n\n"Catch & Shoot" is a shot in which a player catches a pass and shoots the ball without dribbling or waiting.',
      'formula': '3PM / 3PA'
    },
    'PULL UP 3P%': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Pull Ups'],
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': 'PULL UP 3P%',
      'full_name': 'Pull-Up - Three-Point Field Goal Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of Pull-Up 3-point field goal attempts that a player makes.\n\nA pull-up shot is one in which a player shoots the ball directly off of a dribble.',
      'formula': '3PM / 3PA'
    },
    'fill3': {'first_available': '2013'},
    'C&S eFG%': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Catch and Shoot'],
      'TOTAL': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'splash_name': 'C&S eFG%',
      'full_name': 'Catch & Shoot - Effective Field Goal Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Measures field goal percentage adjusting for made 3-point field goals being 1.5 times more valuable than made 2-point field goals.\n\n"Catch & Shoot" is a shot in which a player catches a pass and shoots the ball without dribbling or waiting.',
      'formula': '((FGM + (0.5 * 3PM)) / FGA'
    },
    'PULL UP eFG%': {
      'location': ['ADV', 'SHOOTING', 'SHOT_TYPE', 'Pull Ups'],
      'TOTAL': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'EFG_PCT',
        'rank_nba_name': 'EFG_PCT_RANK',
      },
      'splash_name': 'PULL UP eFG%',
      'full_name': 'Pull-Up - Effective Field Goal Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Measures field goal percentage adjusting for made 3-point field goals being 1.5 times more valuable than made 2-point field goals.\n\nA pull-up shot is one in which a player shoots the ball directly off of a dribble.',
      'formula': '((FGM + (0.5 * 3PM)) / FGA'
    },
  },
  'CLOSEST DEFENDER': {
    'VERY TIGHT FREQ': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '0-2 Feet - Very Tight'],
      'TOTAL': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'splash_name': 'VERY TIGHT - FREQ',
      'full_name': 'Frequency (Very Tight)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Very Tight - Closest defender is within 2 feet of the player.\n\nFrequency - The number of field goal attempts of this type taken by a player compared to the total field goal attempts by the player.',
      'formula': ''
    },
    'TIGHT FREQ': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '2-4 Feet - Tight'],
      'TOTAL': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'splash_name': 'TIGHT - FREQ',
      'full_name': 'Frequency (Tight)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Tight - Closest defender is 2-4 feet from the player.\n\nFrequency - The number of field goal attempts of this type taken by a player compared to the total field goal attempts by the player.',
      'formula': ''
    },
    'OPEN FREQ': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '4-6 Feet - Open'],
      'TOTAL': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'splash_name': 'OPEN - FREQ',
      'full_name': 'Frequency (Open)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Open - Closest defender is 4-6 feet from the player.\n\nFrequency - The number of field goal attempts of this type taken by a player compared to the total field goal attempts by the player.',
      'formula': ''
    },
    'WIDE OPEN FREQ': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '6+ Feet - Wide Open'],
      'TOTAL': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'PER_75': {
        'nba_name': 'FGA_FREQUENCY',
        'rank_nba_name': 'FGA_FREQUENCY_RANK',
      },
      'splash_name': 'WIDE OPEN - FREQ',
      'full_name': 'Frequency (Wide Open)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Wide Open - No defender within 6+ feet of the player.\n\nFrequency - The number of field goal attempts of this type taken by a player compared to the total field goal attempts by the player.',
      'formula': ''
    },
    'fill': {'first_available': '2013'},
    'VERY TIGHT FG%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '0-2 Feet - Very Tight'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'VERY TIGHT - FG%',
      'full_name': 'Field Goal Percentage (Very Tight)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Very Tight - Closest defender is within 2 feet of the player.\n\nFG% - The percentage of field goal attempts that a player makes.',
      'formula': 'FGM / FGA'
    },
    'TIGHT FG%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '2-4 Feet - Tight'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'TIGHT - FG%',
      'full_name': 'Field Goal Percentage (Tight)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Tight - Closest defender is 2-4 feet from the player.\n\nFG% - The percentage of field goal attempts that a player makes.',
      'formula': 'FGM / FGA'
    },
    'OPEN FG%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '4-6 Feet - Open'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'OPEN - FG%',
      'full_name': 'Field Goal Percentage (Open)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Open - Closest defender is 4-6 feet from the player.\n\nFG% - The percentage of field goal attempts that a player makes.',
      'formula': 'FGM / FGA'
    },
    'WIDE OPEN FG%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '6+ Feet - Wide Open'],
      'TOTAL': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG_PCT',
        'rank_nba_name': 'FG_PCT_RANK',
      },
      'splash_name': 'WIDE OPEN - FG%',
      'full_name': 'Field Goal Percentage (Wide Open)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Wide Open - No defender within 6+ feet of the player.\n\nFG% - The percentage of field goal attempts that a player makes.',
      'formula': 'FGM / FGA'
    },
    'fill2': {'first_available': '2013'},
    'VERY TIGHT 3P%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '0-2 Feet - Very Tight'],
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': 'VERY TIGHT - 3P%',
      'full_name': 'Three-Point Field Goal Percentage (Very Tight)',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'Very Tight - Closest defender is within 2 feet of the player.\n\n3P% - The percentage of 3-point field goal attempts that a player makes.',
      'formula': '3PM / 3PA'
    },
    'TIGHT 3P%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '2-4 Feet - Tight'],
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': 'TIGHT - 3P%',
      'full_name': 'Three-Point Field Goal Percentage (Tight)',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'Open - Closest defender is 2-4 feet from the player.\n\n3P% - The percentage of 3-point field goal attempts that a player makes.',
      'formula': '3PM / 3PA'
    },
    'OPEN 3P%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '4-6 Feet - Open'],
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': 'OPEN - 3P%',
      'full_name': 'Three-Point Field Goal Percentage (Open)',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'Open - Closest defender is 4-6 feet from the player.\n\n3P% - The percentage of 3-point field goal attempts that a player makes.',
      'formula': '3PM / 3PA'
    },
    'WIDE OPEN 3P%': {
      'location': ['ADV', 'SHOOTING', 'CLOSEST_DEFENDER', '6+ Feet - Wide Open'],
      'TOTAL': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'FG3_PCT',
        'rank_nba_name': 'FG3_PCT_RANK',
      },
      'splash_name': 'WIDE OPEN - 3P%',
      'full_name': 'Three-Point Field Goal Percentage (Wide Open)',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'Wide Open - No defender within 6+ feet of the player.\n\n3P% - The percentage of 3-point field goal attempts that a player makes.',
      'formula': '3PM / 3PA'
    },
  },
  'DRIVES': {
    'DRIVES': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVES',
        'rank_nba_name': 'DRIVES_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVES_PER_75',
        'rank_nba_name': 'DRIVES_PER_75_RANK',
      },
      'splash_name': 'DRIVES',
      'full_name': 'Drives',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'When a player attacks the basket off the dribble in the halfcourt offense. Does not include situations where the player starts close to the basket, catches on the move, or immediately gets cut off on the perimeter.',
      'formula': ''
    },
    '% DRIVE': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVES_PER_TOUCH',
        'rank_nba_name': 'DRIVES_PER_TOUCH_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVES_PER_TOUCH',
        'rank_nba_name': 'DRIVES_PER_TOUCH_RANK',
      },
      'splash_name': '% DRIVE',
      'full_name': 'Drive Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of touches on which a player drives to the rim.',
      'formula': ''
    },
    'fill': {'first_available': '2013'},
    'DRIVE PTS': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_PTS',
        'rank_nba_name': 'DRIVE_PTS_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_PTS_PER_75',
        'rank_nba_name': 'DRIVE_PTS_PER_75_RANK',
      },
      'splash_name': 'PTS',
      'full_name': 'Points Scored (Drives)',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of points scored by a player on drives to the basket.',
      'formula': ''
    },
    'PTS PER DRIVE': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_PTS_PCT',
        'rank_nba_name': 'DRIVE_PTS_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_PTS_PCT',
        'rank_nba_name': 'DRIVE_PTS_PCT_RANK',
      },
      'splash_name': 'PTS PER DRIVE',
      'full_name': 'Points per Drive',
      'first_available': '2013',
      'convert': 'false',
      'round': '2',
      'definition': 'The number of points scored by a player per drive to the basket.',
      'formula': ''
    },
    'fill2': {'first_available': '2013'},
    'DRIVE FGM': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_FGM',
        'rank_nba_name': 'DRIVE_FGM_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_FGM_PER_75',
        'rank_nba_name': 'DRIVE_FGM_PER_75_RANK',
      },
      'splash_name': 'DRIVE FGM',
      'full_name': 'Field Goals Made (Drives)',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of field goals made by a player on drives to the basket.',
      'formula': ''
    },
    'DRIVE FGA': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_FGA',
        'rank_nba_name': 'DRIVE_FGA_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_FGA_PER_75',
        'rank_nba_name': 'DRIVE_FGA_PER_75_RANK',
      },
      'splash_name': 'DRIVE FGA',
      'full_name': 'Field Goal Attempts (Drives)',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of field goals attempted by a player on drives to the basket.',
      'formula': ''
    },
    'DRIVE FG%': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_FG_PCT',
        'rank_nba_name': 'DRIVE_FG_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_FG_PCT',
        'rank_nba_name': 'DRIVE_FG_PCT_RANK',
      },
      'splash_name': 'DRIVE FG%',
      'full_name': 'Field Goal Percentage (Drives)',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Player\'s field goal percentage on drives to the basket.',
      'formula': ''
    },
    'fill3': {'first_available': '2013'},
    'DRIVE TS%': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_TS_PCT',
        'rank_nba_name': 'DRIVE_TS_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_TS_PCT',
        'rank_nba_name': 'DRIVE_TS_PCT_RANK',
      },
      'splash_name': 'DRIVE TS%',
      'full_name': 'Drive - True Shooting %',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Player\'s True Shooting% on drives to the basket.',
      'formula': ''
    },
    'DRIVE FT/FGA': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_FT_PER_FGA',
        'rank_nba_name': 'DRIVE_FT_PER_FGA_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_FT_PER_FGA',
        'rank_nba_name': 'DRIVE_FT_PER_FGA_RANK',
      },
      'splash_name': 'DRIVE FT/FGA',
      'full_name': 'Drive - Free Throws per Field Goal Attempt',
      'first_available': '2013',
      'convert': 'false',
      'round': '2',
      'definition':
          'The number of field throws made by a player from drives to the basket per driving field goal attempt.',
      'formula': ''
    },
    'fill4': {'first_available': '2013'},
    'DRIVE PASSES': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_PASSES',
        'rank_nba_name': 'DRIVE_PASSES_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_PASSES_PER_75',
        'rank_nba_name': 'DRIVE_PASSES_PER_75_RANK',
      },
      'splash_name': 'PASSES MADE',
      'full_name': 'Drive Passes',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of passes made by a player on drives to the basket.',
      'formula': ''
    },
    'DRIVE PASS %': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_PASSES_PCT',
        'rank_nba_name': 'DRIVE_PASSES_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_PASSES_PCT',
        'rank_nba_name': 'DRIVE_PASSES_PCT_RANK',
      },
      'splash_name': 'PASS %',
      'full_name': 'Drive Pass %',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of drives where a player passes the ball to a teammate.',
      'formula': ''
    },
    'DRIVE AST': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_AST',
        'rank_nba_name': 'DRIVE_AST_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_AST_PER_75',
        'rank_nba_name': 'DRIVE_AST_PER_75_RANK',
      },
      'splash_name': 'AST',
      'full_name': 'Drive Assists',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of assists by a player on drives to the basket.',
      'formula': ''
    },
    'DRIVE AST %': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_AST_PCT',
        'rank_nba_name': 'DRIVE_AST_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_AST_PCT',
        'rank_nba_name': 'DRIVE_AST_PCT_RANK',
      },
      'splash_name': 'ASSIST %',
      'full_name': 'Assists per Drive',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of drives where the player recorded an assist.',
      'formula': ''
    },
    'fill5': {'first_available': '2013'},
    'DRIVE TOV': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_TOV',
        'rank_nba_name': 'DRIVE_TOV_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_TOV_PER_75',
        'rank_nba_name': 'DRIVE_TOV_PER_75_RANK',
      },
      'splash_name': 'TOV',
      'full_name': 'Turnovers (Drives)',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of turnovers by a player on drives to the basket.',
      'formula': ''
    },
    'DRIVE TOV %': {
      'location': ['ADV', 'DRIVES'],
      'TOTAL': {
        'nba_name': 'DRIVE_TOV_PCT',
        'rank_nba_name': 'DRIVE_TOV_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DRIVE_TOV_PCT',
        'rank_nba_name': 'DRIVE_TOV_PCT_RANK',
      },
      'splash_name': 'TURNOVER %',
      'full_name': 'Turnovers per Drive',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of drives where the player turned the ball over.',
      'formula': 'Drive TOV / DRIVES'
    },
  },
  'REBOUNDING': {
    'REB': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'REB',
        'rank_nba_name': 'REB_RANK',
      },
      'PER_75': {
        'nba_name': 'REB_PER_75',
        'rank_nba_name': 'REB_PER_75_RANK',
      },
      'splash_name': 'REB',
      'full_name': 'Total Rebounds',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of total rebounds a player obtains while on the floor.',
      'formula': 'OREB + DREB'
    },
    'OREB': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'OREB',
        'rank_nba_name': 'OREB_RANK',
      },
      'PER_75': {
        'nba_name': 'OREB_PER_75',
        'rank_nba_name': 'OREB_PER_75_RANK',
      },
      'splash_name': 'OREB',
      'full_name': 'Offensive Rebounds',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of offensive rebounds a player obtains while on the floor.',
      'formula': ''
    },
    'DREB': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'DREB',
        'rank_nba_name': 'DREB_RANK',
      },
      'PER_75': {
        'nba_name': 'DREB_PER_75',
        'rank_nba_name': 'DREB_PER_75_RANK',
      },
      'splash_name': 'DREB',
      'full_name': 'Defensive Rebounds',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of defensive rebounds a player obtains while on the floor.',
      'formula': ''
    },
    'fill': {'first_available': '1996'},
    'OREB%': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'OREB_PCT',
        'rank_nba_name': 'OREB_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'OREB_PCT',
        'rank_nba_name': 'OREB_PCT_RANK',
      },
      'splash_name': 'OREB%',
      'full_name': 'Offensive Rebound Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of available offensive rebounds a player obtains while on the floor.',
      'formula': ''
    },
    'DREB%': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'DREB_PCT',
        'rank_nba_name': 'DREB_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DREB_PCT',
        'rank_nba_name': 'DREB_PCT_RANK',
      },
      'splash_name': 'DREB%',
      'full_name': 'Defensive Rebound Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of available defensive rebounds a player obtains while on the floor.',
      'formula': ''
    },
    'fill2': {'first_available': '2013'},
    'OREB CHANCES': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'OREB_CHANCES',
        'rank_nba_name': 'OREB_CHANCES_RANK',
      },
      'PER_75': {
        'nba_name': 'OREB_CHANCES_PER_75',
        'rank_nba_name': 'OREB_CHANCES_PER_75_RANK',
      },
      'splash_name': 'OREB CHANCES',
      'full_name': 'Offensive Rebound Chances',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'A player has a rebound chance if they are the closest player to the ball at any point in time between when the ball has crossed below the rim to when it is fully rebounded.',
      'formula': ''
    },
    'DREB CHANCES': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'DREB_CHANCES',
        'rank_nba_name': 'DREB_CHANCES_RANK',
      },
      'PER_75': {
        'nba_name': 'DREB_CHANCES_PER_75',
        'rank_nba_name': 'DREB_CHANCES_PER_75_RANK',
      },
      'splash_name': 'DREB CHANCES',
      'full_name': 'Defensive Rebound Chances',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'A player has a rebound chance if they are the closest player to the ball at any point in time between when the ball has crossed below the rim to when it is fully rebounded.',
      'formula': ''
    },
    'OREB DEFER': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'OREB_CHANCE_DEFER',
        'rank_nba_name': 'OREB_CHANCE_DEFER_RANK',
      },
      'PER_75': {
        'nba_name': 'OREB_CHANCE_DEFER_PER_75',
        'rank_nba_name': 'OREB_CHANCE_DEFER_PER_75_RANK',
      },
      'splash_name': 'OREB DEFER',
      'full_name': 'Offensive Rebound Chances Deferred',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times that a player has an offensive rebound chance, but defers the rebound to a teammate',
      'formula': ''
    },
    'DREB DEFER': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'DREB_CHANCE_DEFER',
        'rank_nba_name': 'DREB_CHANCE_DEFER_RANK',
      },
      'PER_75': {
        'nba_name': 'DREB_CHANCE_DEFER_PER_75',
        'rank_nba_name': 'DREB_CHANCE_DEFER_PER_75_RANK',
      },
      'splash_name': 'DREB DEFER',
      'full_name': 'Defensive Rebound Chances Deferred',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times that a player has a defensive rebound chance, but defers the rebound to a teammate',
      'formula': ''
    },
    'fill3': {'first_available': '2013'},
    'OREB CHANCE %': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'OREB_CHANCE_PCT',
        'rank_nba_name': 'OREB_CHANCE_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'OREB_CHANCE_PCT',
        'rank_nba_name': 'OREB_CHANCE_PCT_RANK',
      },
      'splash_name': 'OREB CHANCE %',
      'full_name': 'Offensive Rebound Chance Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of rebounds gathered when given a rebound chance on offense.',
      'formula': 'OREB / OREB Chances'
    },
    'DREB CHANCE %': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'DREB_CHANCE_PCT',
        'rank_nba_name': 'DREB_CHANCE_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'DREB_CHANCE_PCT',
        'rank_nba_name': 'DREB_CHANCE_PCT_RANK',
      },
      'splash_name': 'DREB CHANCE %',
      'full_name': 'Defensive Rebound Chance Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'Percentage of rebounds gathered when given a rebound chance on defense.',
      'formula': 'DREB / DREB Chances'
    },
    'ADJ OREB CHANCE %': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'OREB_CHANCE_PCT_ADJ',
        'rank_nba_name': 'OREB_CHANCE_PCT_ADJ_RANK',
      },
      'PER_75': {
        'nba_name': 'OREB_CHANCE_PCT_ADJ',
        'rank_nba_name': 'OREB_CHANCE_PCT_ADJ_RANK',
      },
      'splash_name': 'ADJ OREB CHANCE %',
      'full_name': 'Adjusted Offensive Rebound Chance Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Percentage of rebounds gathered when given a rebound chance on offense; excludes all deferred rebounds.',
      'formula': '(OREB)/(OREB Chances - Deferred OREB Chances)'
    },
    'ADJ DREB CHANCE %': {
      'location': ['ADV', 'REBOUNDING'],
      'TOTAL': {
        'nba_name': 'DREB_CHANCE_PCT_ADJ',
        'rank_nba_name': 'DREB_CHANCE_PCT_ADJ_RANK',
      },
      'PER_75': {
        'nba_name': 'DREB_CHANCE_PCT_ADJ',
        'rank_nba_name': 'DREB_CHANCE_PCT_ADJ_RANK',
      },
      'splash_name': 'ADJ DREB CHANCE %',
      'full_name': 'Adjusted Defensive Rebound Chance Percentage',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'Percentage of rebounds gathered when given a rebound chance on defense; excludes all deferred rebounds.',
      'formula': '(DREB)/(DREB Chances - Deferred DREB Chances)'
    },
    'fill4': {'first_available': '2016'},
    'BOX OUTS': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'BOX_OUTS',
        'rank_nba_name': 'BOX_OUTS_RANK',
      },
      'PER_75': {
        'nba_name': 'BOX_OUTS_PER_75',
        'rank_nba_name': 'BOX_OUTS_PER_75_RANK',
      },
      'splash_name': 'BOX OUTS',
      'full_name': 'Box Outs',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a player made physical contact with an opponent who was actively pursuing a rebound, showed visible progress or strong effort in disadvantaging the opponent, and successfully prevented that opponent from securing the rebound.',
      'formula': ''
    },
    'OFF BOX OUTS': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'OFF_BOXOUTS',
        'rank_nba_name': 'OFF_BOXOUTS_RANK',
      },
      'PER_75': {
        'nba_name': 'OFF_BOXOUTS_PER_75',
        'rank_nba_name': 'OFF_BOXOUTS_PER_75_RANK',
      },
      'splash_name': 'OFF BOX OUTS',
      'full_name': 'Offensive Box Outs',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times an offensive player made physical contact with an opponent who was actively pursuing a rebound, showed visible progress or strong effort in disadvantaging the opponent, and successfully prevented that opponent from securing the rebound.',
      'formula': ''
    },
    'DEF BOX OUTS': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'DEF_BOXOUTS',
        'rank_nba_name': 'DEF_BOXOUTS_RANK',
      },
      'PER_75': {
        'nba_name': 'DEF_BOXOUTS_PER_75',
        'rank_nba_name': 'DEF_BOXOUTS_PER_75_RANK',
      },
      'splash_name': 'DEF BOX OUTS',
      'full_name': 'Defensive Box Outs',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a defensive player made physical contact with an opponent who was actively pursuing a rebound, showed visible progress or strong effort in disadvantaging the opponent, and successfully prevented that opponent from securing the rebound.',
      'formula': ''
    },
  },
  'PLAYMAKING': {
    'PASSES': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'PASSES_MADE',
        'rank_nba_name': 'PASSES_MADE_RANK',
      },
      'PER_75': {
        'nba_name': 'PASSES_MADE_PER_75',
        'rank_nba_name': 'PASSES_MADE_PER_75_RANK',
      },
      'splash_name': 'PASSES',
      'full_name': 'Passes Made',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of passes made by a player.',
      'formula': ''
    },
    'fill': {'first_available': '2013'},
    'AST': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'AST',
        'rank_nba_name': 'AST_RANK',
      },
      'PER_75': {
        'nba_name': 'AST_PER_75',
        'rank_nba_name': 'AST_PER_75_RANK',
      },
      'splash_name': 'AST',
      'full_name': 'Assist',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of passes made by a player that lead directly to a made basket',
      'formula': ''
    },
    '2ND AST': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'SECONDARY_AST',
        'rank_nba_name': 'SECONDARY_AST_RANK',
      },
      'PER_75': {
        'nba_name': 'SECONDARY_AST_PER_75',
        'rank_nba_name': 'SECONDARY_AST_PER_75_RANK',
      },
      'splash_name': 'SECONDARY AST',
      'full_name': 'Secondary Assist',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'A player is awarded a secondary assist if they passed the ball to a player who recorded an assist within 1 second and without dribbling.',
      'formula': ''
    },
    'FT AST': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'FT_AST',
        'rank_nba_name': 'FT_AST_RANK',
      },
      'PER_75': {
        'nba_name': 'FT_AST_PER_75',
        'rank_nba_name': 'FT_AST_PER_75_RANK',
      },
      'splash_name': 'FT AST',
      'full_name': 'Free Throw Assist',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'A player is awarded a free throw assist if they passed the ball to a player who drew a shooting foul within one dribble of receiving the pass.',
      'formula': ''
    },
    'ADJ AST': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'AST_ADJ',
        'rank_nba_name': 'AST_ADJ_RANK',
      },
      'PER_75': {
        'nba_name': 'AST_ADJ_PER_75',
        'rank_nba_name': 'AST_ADJ_PER_75_RANK',
      },
      'splash_name': 'ADJ AST',
      'full_name': 'Adjusted Assists',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'The total sum of a player\'s assists, free throw assists, and secondary assists.',
      'formula': 'AST + FT AST + Secondary AST'
    },
    'fill2': {'first_available': '2013'},
    'BOX CREATION': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'BOX_CREATION',
        'rank_nba_name': 'BOX_CREATION_RANK',
      },
      'PER_75': {
        'nba_name': 'BOX_CREATION',
        'rank_nba_name': 'BOX_CREATION_RANK',
      },
      'splash_name': 'BOX CREATION',
      'full_name': 'Box Creation',
      'first_available': '1996',
      'convert': 'false',
      'round': '1',
      'definition':
          'Estimates number of scoring opportunities created for teammates per 75 possessions. Goes beyond Potential Assists by factoring in the passer\'s usage, shooting proficiency, and more.',
      'formula': ''
    },
    'POT. AST': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'POTENTIAL_AST',
        'rank_nba_name': 'POTENTIAL_AST_RANK',
      },
      'PER_75': {
        'nba_name': 'POTENTIAL_AST_PER_75',
        'rank_nba_name': 'POTENTIAL_AST_PER_75_RANK',
      },
      'splash_name': 'POTENTIAL AST',
      'full_name': 'Potential Assist',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition':
          'Any pass to a teammate who shoots within 1 dribble of receiving the ball.',
      'formula': ''
    },
    'AST PTS CREATED': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'AST_PTS_CREATED',
        'rank_nba_name': 'AST_PTS_CREATED_RANK',
      },
      'PER_75': {
        'nba_name': 'AST_PTS_CREATED_PER_75',
        'rank_nba_name': 'AST_PTS_CREATED_PER_75_RANK',
      },
      'splash_name': 'AST PTS CREATED',
      'full_name': 'Assist Points Created',
      'first_available': '2013',
      'convert': 'false',
      'round': '0',
      'definition': 'Points created by a player through their assists.',
      'formula': ''
    },
    'fill3': {'first_available': '2013'},
    'AST%': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'AST_PCT',
        'rank_nba_name': 'AST_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'AST_PCT',
        'rank_nba_name': 'AST_PCT_RANK',
      },
      'splash_name': 'AST %',
      'full_name': 'Assist Percentage',
      'first_available': '1996',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of teammate field goals a player assisted on while they were on the floor.',
      'formula': 'AST / (TmFGM - FGM)'
    },
    'AST-PASS %': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'AST_TO_PASS_PCT',
        'rank_nba_name': 'AST_TO_PASS_PCT_RANK',
      },
      'PER_75': {
        'nba_name': 'AST_TO_PASS_PCT',
        'rank_nba_name': 'AST_TO_PASS_PCT_RANK',
      },
      'splash_name': 'AST - Pass %',
      'full_name': 'Assist to Pass Ratio',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition': 'The percentage of passes by a player that are assists.',
      'formula': 'AST / Passes'
    },
    'ADJ AST-PASS %': {
      'location': ['ADV', 'PASSING'],
      'TOTAL': {
        'nba_name': 'AST_TO_PASS_PCT_ADJ',
        'rank_nba_name': 'AST_TO_PASS_PCT_ADJ_RANK',
      },
      'PER_75': {
        'nba_name': 'AST_TO_PASS_PCT_ADJ',
        'rank_nba_name': 'AST_TO_PASS_PCT_ADJ_RANK',
      },
      'splash_name': 'Adj AST - Pass %',
      'full_name': 'Adj Assist to Pass Ratio',
      'first_available': '2013',
      'convert': 'true',
      'round': '1',
      'definition':
          'The percentage of passes by a player that are assists, free throw assists, or secondary assists.',
      'formula': 'ADJ AST / Passes'
    },
  },
  'DEFENSE': {
    'DRTG - ON': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'DEF_RATING',
        'rank_nba_name': 'DEF_RATING_RANK',
      },
      'PER_75': {
        'nba_name': 'DEF_RATING',
        'rank_nba_name': 'DEF_RATING_RANK',
      },
      'splash_name': 'DRTG - ON',
      'full_name': 'Defensive Rating - On',
      'first_available': '2007',
      'convert': 'false',
      'round': '1',
      'definition': 'Team\'s points allowed per 100 possessions when player is on court.',
      'formula': ''
    },
    'VERSATILITY': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'VERSATILITY_SCORE',
        'rank_nba_name': 'VERSATILITY_SCORE_RANK',
      },
      'PER_75': {
        'nba_name': 'VERSATILITY_SCORE',
        'rank_nba_name': 'VERSATILITY_SCORE_RANK',
      },
      'splash_name': 'VERSATILITY',
      'full_name': 'VERSATILITY SCORE',
      'first_available': '2017',
      'convert': 'true',
      'round': '0',
      'definition':
          'A measure of the time spent guarding different positions (G, F, C) on a 0-100 scale. A player who guarded all 3 positions equally ( ⅓ of the time each) will have a score of 100, while a player who only guarded one position will have a score of 0.',
      'formula':
          '1 - ( | Gₜ - ⅓ | + | Fₜ - ⅓ | + | Cₜ - ⅓ | )\n\n*Where Gₜ, Fₜ, Cₜ represent % of time spent guarding each position.'
    },
    'MATCHUP DIFFICULTY': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'MATCHUP_DIFFICULTY',
        'rank_nba_name': 'MATCHUP_DIFFICULTY_RANK',
      },
      'PER_75': {
        'nba_name': 'MATCHUP_DIFFICULTY',
        'rank_nba_name': 'MATCHUP_DIFFICULTY_RANK',
      },
      'splash_name': 'MATCHUP DIFFICULTY',
      'full_name': 'Matchup Difficulty',
      'first_available': '2017',
      'convert': 'false',
      'round': '1',
      'definition':
          'The season-average Offensive Load of this player\'s defensive matchups. Players with high Matchup Difficulty guarded players who were heavily involved in their team\'s offense.',
      'formula': ''
    },
    'DEF IMPACT EST': {
      'location': ['ADV'],
      'TOTAL': {
        'nba_name': 'DEF_IMPACT_EST',
        'rank_nba_name': 'DEF_IMPACT_EST_RANK',
      },
      'PER_75': {
        'nba_name': 'DEF_IMPACT_EST',
        'rank_nba_name': 'DEF_IMPACT_EST_RANK',
      },
      'splash_name': 'DEF IMPACT',
      'full_name': 'Defensive Impact Estimate',
      'first_available': '2017',
      'convert': 'false',
      'round': '1',
      'definition':
          'Difference in opponent ORTG vs. expected, based on whom this player guarded. For example, if player A\'s team normally has a 110.0 ORTG when he is on the court, but it drops to 108.0 when player B is guarding him, then player B\'s DIE is 2.0.\n\nOver a full season, this tells us how many points a player may have "saved" per 100 possessions on defense.',
      'formula': ''
    },
    'fill': {'first_available': '2016'},
    'STL': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'STL',
        'rank_nba_name': 'STL_RANK',
      },
      'PER_75': {
        'nba_name': 'STL_PER_75',
        'rank_nba_name': 'STL_PER_75_RANK',
      },
      'splash_name': 'STL',
      'full_name': 'Steals',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition':
          'Number of times a defensive player or team takes the ball from a player on offense, causing a turnover.',
      'formula': ''
    },
    'DEFLECTS': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'DEFLECTIONS',
        'rank_nba_name': 'DEFLECTIONS_RANK',
      },
      'PER_75': {
        'nba_name': 'DEFLECTIONS_PER_75',
        'rank_nba_name': 'DEFLECTIONS_PER_75_RANK',
      },
      'splash_name': 'DEFLECTIONS',
      'full_name': 'Deflections',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a defensive player or team gets their hand on the ball on a non-shot attempt.',
      'formula': ''
    },
    'fill2': {'first_available': '2016'},
    'BLK': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'BLK',
        'rank_nba_name': 'BLK_RANK',
      },
      'PER_75': {
        'nba_name': 'BLK_PER_75',
        'rank_nba_name': 'BLK_PER_75_RANK',
      },
      'splash_name': 'BLK',
      'full_name': 'Blocks',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition':
          'A block occurs when an offensive player attempts a shot, and the defense player tips the ball, blocking their chance to score.',
      'formula': ''
    },
    'CONTESTS': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'CONTESTED_SHOTS',
        'rank_nba_name': 'CONTESTED_SHOTS_RANK',
      },
      'PER_75': {
        'nba_name': 'CONTESTED_SHOTS_PER_75',
        'rank_nba_name': 'CONTESTED_SHOTS_PER_75_RANK',
      },
      'splash_name': 'CONTESTED SHOTS',
      'full_name': 'Contested Shots',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a defensive player or team closes out and raises a hand to contest a shot prior to its release.',
      'formula': ''
    },
  },
  'HUSTLE': {
    'SCREEN AST': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'SCREEN_ASSISTS',
        'rank_nba_name': 'SCREEN_ASSISTS_RANK',
      },
      'PER_75': {
        'nba_name': 'SCREEN_ASSISTS_PER_75',
        'rank_nba_name': 'SCREEN_ASSISTS_PER_75_RANK',
      },
      'splash_name': 'SCREEN ASSISTS',
      'full_name': 'Screen Assists',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times an offensive player sets a screen for a teammate that directly leads to a made field goal by that teammate.',
      'formula': ''
    },
    'SCREEN AST PTS': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'SCREEN_AST_PTS',
        'rank_nba_name': 'SCREEN_AST_PTS_RANK',
      },
      'PER_75': {
        'nba_name': 'SCREEN_AST_PTS_PER_75',
        'rank_nba_name': 'SCREEN_AST_PTS_PER_75_RANK',
      },
      'splash_name': 'SCREEN AST PTS',
      'full_name': 'Screen Assist Points',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition': 'Points created by a player through their screen assists.',
      'formula': ''
    },
    'fill': {'first_available': '2016'},
    'LOOSE BALLS': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'LOOSE_BALLS_RECOVERED',
        'rank_nba_name': 'LOOSE_BALLS_RECOVERED_RANK',
      },
      'PER_75': {
        'nba_name': 'LOOSE_BALLS_RECOVERED_PER_75',
        'rank_nba_name': 'LOOSE_BALLS_RECOVERED_PER_75_RANK',
      },
      'splash_name': 'LOOSE BALLS',
      'full_name': 'Loose Balls Recovered',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition':
          'The number of times a player gains sole possession of a live ball that is not in the control of either team.',
      'formula': ''
    },
    'fill2': {'first_available': '2016'},
    'FOULS': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'PF',
        'rank_nba_name': 'PF_RANK',
      },
      'PER_75': {
        'nba_name': 'PF_PER_75',
        'rank_nba_name': 'PF_PER_75_RANK',
      },
      'splash_name': 'FOULS',
      'full_name': 'Personal Fouls',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of personal fouls a player committed.',
      'formula': ''
    },
    'FOULS DRAWN': {
      'location': ['BASIC'],
      'TOTAL': {
        'nba_name': 'PFD',
        'rank_nba_name': 'PFD_RANK',
      },
      'PER_75': {
        'nba_name': 'PFD_PER_75',
        'rank_nba_name': 'PFD_PER_75_RANK',
      },
      'splash_name': 'FOULS DRAWN',
      'full_name': 'Personal Fouls Drawn',
      'first_available': '1996',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of personal fouls drawn by a player.',
      'formula': ''
    },
    'CHARGES DRAWN': {
      'location': ['HUSTLE'],
      'TOTAL': {
        'nba_name': 'CHARGES_DRAWN',
        'rank_nba_name': 'CHARGES_DRAWN_RANK',
      },
      'PER_75': {
        'nba_name': 'CHARGES_DRAWN_PER_75',
        'rank_nba_name': 'CHARGES_DRAWN_PER_75_RANK',
      },
      'splash_name': 'CHARGES DRAWN',
      'full_name': 'Charges Drawn',
      'first_available': '2016',
      'convert': 'false',
      'round': '0',
      'definition': 'The number of charging fouls drawn by a player.',
      'formula': ''
    },
  },
};

const kTeamColors = {
  "FA": {"primaryColor": Color(0xFF00438C), "secondaryColor": Color(0xFFDA1A32)},
  "ATL": {
    "primaryColor": Color(0xFFE03A3E),
    "secondaryColor": Color(0xFFC1D32F)
  }, // Atlanta Hawks
  "BOS": {
    "primaryColor": Color(0xFF007047),
    "secondaryColor": Color(0xFFFFFFFF)
  }, // Boston Celtics
  "BKN": {
    "primaryColor": Color(0xFF000000),
    "secondaryColor": Color(0xFFFFFFFF)
  }, // Brooklyn Nets
  "CHA": {
    "primaryColor": Color(0xFF00788C),
    "secondaryColor": Color(0xFF1D1160)
  }, // Charlotte Hornets
  "CHI": {
    "primaryColor": Color(0xFFCE1141),
    "secondaryColor": Color(0xFF000000)
  }, // Chicago Bulls
  "CLE": {
    "primaryColor": Color(0xFF860038),
    "secondaryColor": Color(0xFFFFB81A)
  }, // Cleveland Cavaliers
  "DAL": {
    "primaryColor": Color(0xFF00538C),
    "secondaryColor": Color(0xFFB8C4CA)
  }, // Dallas Mavericks
  "DEN": {
    "primaryColor": Color(0xFF0E2240),
    "secondaryColor": Color(0xFFFEC524)
  }, // Denver Nuggets
  "DET": {
    "primaryColor": Color(0xFFDD0031),
    "secondaryColor": Color(0xFF003EA6)
  }, // Detroit Pistons
  "GSW": {
    "primaryColor": Color(0xFF016BB6),
    "secondaryColor": Color(0xFFFBB927)
  }, // Golden State Warriors
  "HOU": {
    "primaryColor": Color(0xFFCD1041),
    "secondaryColor": Color(0xFF919798),
  }, // Houston Rockets
  "IND": {
    "primaryColor": Color(0xFF002D62),
    "secondaryColor": Color(0xFFFDBB30)
  }, // Indiana Pacers
  "LAC": {
    "primaryColor": Color(0xFF0B2240),
    "secondaryColor": Color(0xFFED184D)
  }, // LA Clippers
  "LAL": {
    "primaryColor": Color(0xFF562584),
    "secondaryColor": Color(0xFFFDB927)
  }, // Los Angeles Lakers
  "MEM": {
    "primaryColor": Color(0xFF5D76A9),
    "secondaryColor": Color(0xFFFCB827)
  }, // Memphis Grizzlies
  "MIA": {
    "primaryColor": Color(0xFF98002E),
    "secondaryColor": Color(0xFFF9A01B)
  }, // Miami Heat
  "MIL": {
    "primaryColor": Color(0xFF264F36),
    "secondaryColor": Color(0xFFEEE1C6)
  }, // Milwaukee Bucks
  "MIN": {
    "primaryColor": Color(0xFF0B233F),
    "secondaryColor": Color(0xFF78BE20)
  }, // Minnesota Timberwolves
  "NOP": {
    "primaryColor": Color(0xFF0C2340),
    "secondaryColor": Color(0xFF85714D)
  }, // New Orleans Pelicans
  "NYK": {
    "primaryColor": Color(0xFF016BB6),
    "secondaryColor": Color(0xFFF58426)
  }, // New York Knicks
  "OKC": {
    "primaryColor": Color(0xFF007AC2),
    "secondaryColor": Color(0xFFEF3B24)
  }, // Oklahoma City Thunder
  "ORL": {
    "primaryColor": Color(0xFF0077C0),
    "secondaryColor": Color(0xFFC4CED4)
  }, // Orlando Magic
  "PHI": {
    "primaryColor": Color(0xFF006BB6),
    "secondaryColor": Color(0xFFED174C)
  }, // Philadelphia 76ers
  "PHX": {
    "primaryColor": Color(0xFF1D1160),
    "secondaryColor": Color(0xFFE56020)
  }, // Phoenix Suns
  "POR": {
    "primaryColor": Color(0xFFE03A3E),
    "secondaryColor": Color(0xFF000000)
  }, // Portland Trail Blazers
  "SAC": {
    "primaryColor": Color(0xFF5A2D81),
    "secondaryColor": Color(0xFF63727A)
  }, // Sacramento Kings
  "SAS": {
    "primaryColor": Color(0xFF000000),
    "secondaryColor": Color(0xFFC4CED4)
  }, // San Antonio Spurs
  "TOR": {
    "primaryColor": Color(0xFFCE1141),
    "secondaryColor": Color(0xFF000000)
  }, // Toronto Raptors
  "UTA": {"primaryColor": Color(0xFF2F0370), "secondaryColor": Color(0xFF57A0CB)}, // Utah Jazz
  "WAS": {
    "primaryColor": Color(0xFF002B5C),
    "secondaryColor": Color(0xFFE31837)
  }, // Washington Wizards
};

const kTeamColorOpacity = {
  "FA": {"opacity": 0.90}, // Free Agent
  "ATL": {"opacity": 0.90}, // Atlanta Hawks
  "BOS": {"opacity": 0.94}, // Boston Celtics
  "BKN": {"opacity": 0.88}, // Brooklyn Nets
  "CHA": {"opacity": 0.94}, // Charlotte Hornets
  "CHI": {"opacity": 0.88}, // Chicago Bulls
  "CLE": {"opacity": 0.92}, // Cleveland Cavaliers
  "DAL": {"opacity": 0.94}, // Dallas Mavericks
  "DEN": {"opacity": 0.94}, // Denver Nuggets
  "DET": {"opacity": 0.86}, // Detroit Pistons
  "GSW": {"opacity": 0.80}, // Golden State Warriors
  "HOU": {"opacity": 0.90}, // Houston Rockets
  "IND": {"opacity": 0.90}, // Indiana Pacers
  "LAC": {"opacity": 0.94}, // LA Clippers
  "LAL": {"opacity": 0.94}, // Los Angeles Lakers
  "MEM": {"opacity": 0.90}, // Memphis Grizzlies
  "MIA": {"opacity": 0.92}, // Miami Heat
  "MIL": {"opacity": 0.94}, // Milwaukee Bucks
  "MIN": {"opacity": 0.94}, // Minnesota Timberwolves
  "NOP": {"opacity": 0.94}, // New Orleans Pelicans
  "NYK": {"opacity": 0.86}, // New York Knicks
  "OKC": {"opacity": 0.94}, // Oklahoma City Thunder
  "ORL": {"opacity": 0.94}, // Orlando Magic
  "PHI": {"opacity": 0.90}, // Philadelphia 76ers
  "PHX": {"opacity": 0.90}, // Phoenix Suns
  "POR": {"opacity": 0.94}, // Portland Trail Blazers
  "SAC": {"opacity": 0.94}, // Sacramento Kings
  "SAS": {"opacity": 0.88}, // San Antonio Spurs
  "TOR": {"opacity": 0.84}, // Toronto Raptors
  "UTA": {"opacity": 0.94}, // Utah Jazz
  "WAS": {"opacity": 0.94}, // Washington Wizards
};

const List<String> kDarkPrimaryColors = [
  'BKN',
  'DEN',
  'IND',
  'LAC',
  'MIN',
  'NOP',
  'PHX',
  'UTA',
  'SAS',
  'WAS'
];

const List<String> kDarkSecondaryColors = ['CHA', 'CHI', 'DET', 'POR', 'TOR'];

const Map<String, String> kCountryCodes = {
  "Andorra": "AD",
  "United Arab Emirates": "AE",
  "Afghanistan": "AF",
  "Antigua and Barbuda": "AG",
  "Anguilla": "AI",
  "Albania": "AL",
  "Armenia": "AM",
  "Angola": "AO",
  "Antarctica": "AQ",
  "Argentina": "AR",
  "American Samoa": "AS",
  "Austria": "AT",
  "Australia": "AU",
  "Aruba": "AW",
  "Åland Islands": "AX",
  "Azerbaijan": "AZ",
  "Bosnia and Herzegovina": "BA",
  "Barbados": "BB",
  "Bangladesh": "BD",
  "Belgium": "BE",
  "Burkina Faso": "BF",
  "Bulgaria": "BG",
  "Bahrain": "BH",
  "Burundi": "BI",
  "Benin": "BJ",
  "Saint Barthélemy": "BL",
  "Bermuda": "BM",
  "Brunei Darussalam": "BN",
  "Bolivia, Plurinational State of": "BO",
  "Caribbean Netherlands": "BQ",
  "Brazil": "BR",
  "Bahamas": "BS",
  "Bhutan": "BT",
  "Bouvet Island": "BV",
  "Botswana": "BW",
  "Belarus": "BY",
  "Belize": "BZ",
  "Canada": "CA",
  "Cocos (Keeling) Islands": "CC",
  "Congo, the Democratic Republic of the": "CD",
  "Central African Republic": "CF",
  "Republic of the Congo": "CG",
  "Switzerland": "CH",
  "Côte d'Ivoire": "CI",
  "Cook Islands": "CK",
  "Chile": "CL",
  "Cameroon": "CM",
  "China (People's Republic of China)": "CN",
  "Colombia": "CO",
  "Costa Rica": "CR",
  "Cuba": "CU",
  "Cape Verde": "CV",
  "Curaçao": "CW",
  "Christmas Island": "CX",
  "Cyprus": "CY",
  "Czech Republic": "CZ",
  "Germany": "DE",
  "Djibouti": "DJ",
  "Denmark": "DK",
  "Dominica": "DM",
  "Dominican Republic": "DO",
  "Algeria": "DZ",
  "Ecuador": "EC",
  "Estonia": "EE",
  "Egypt": "EG",
  "Western Sahara": "EH",
  "Eritrea": "ER",
  "Spain": "ES",
  "Ethiopia": "ET",
  "Europe": "EU",
  "Finland": "FI",
  "Fiji": "FJ",
  "Falkland Islands (Malvinas)": "FK",
  "Micronesia, Federated States of": "FM",
  "Faroe Islands": "FO",
  "France": "FR",
  "Gabon": "GA",
  "England": "GB-ENG",
  "Northern Ireland": "GB-NIR",
  "Scotland": "GB-SCT",
  "Wales": "GB-WLS",
  "United Kingdom": "GB",
  "Grenada": "GD",
  "Georgia": "GE",
  "French Guiana": "GF",
  "Guernsey": "GG",
  "Ghana": "GH",
  "Gibraltar": "GI",
  "Greenland": "GL",
  "Gambia": "GM",
  "Guinea": "GN",
  "Guadeloupe": "GP",
  "Equatorial Guinea": "GQ",
  "Greece": "GR",
  "South Georgia and the South Sandwich Islands": "GS",
  "Guatemala": "GT",
  "Guam": "GU",
  "Guinea-Bissau": "GW",
  "Guyana": "GY",
  "Hong Kong": "HK",
  "Heard Island and McDonald Islands": "HM",
  "Honduras": "HN",
  "Croatia": "HR",
  "Haiti": "HT",
  "Hungary": "HU",
  "Indonesia": "ID",
  "Ireland": "IE",
  "Israel": "IL",
  "Isle of Man": "IM",
  "India": "IN",
  "British Indian Ocean Territory": "IO",
  "Iraq": "IQ",
  "Iran, Islamic Republic of": "IR",
  "Iceland": "IS",
  "Italy": "IT",
  "Jersey": "JE",
  "Jamaica": "JM",
  "Jordan": "JO",
  "Japan": "JP",
  "Kenya": "KE",
  "Kyrgyzstan": "KG",
  "Cambodia": "KH",
  "Kiribati": "KI",
  "Comoros": "KM",
  "Saint Kitts and Nevis": "KN",
  "Korea, Democratic People's Republic of": "KP",
  "Korea, Republic of": "KR",
  "Kuwait": "KW",
  "Cayman Islands": "KY",
  "Kazakhstan": "KZ",
  "Laos (Lao People's Democratic Republic)": "LA",
  "Lebanon": "LB",
  "Saint Lucia": "LC",
  "Liechtenstein": "LI",
  "Sri Lanka": "LK",
  "Liberia": "LR",
  "Lesotho": "LS",
  "Lithuania": "LT",
  "Luxembourg": "LU",
  "Latvia": "LV",
  "Libya": "LY",
  "Morocco": "MA",
  "Monaco": "MC",
  "Moldova, Republic of": "MD",
  "Montenegro": "ME",
  "Saint Martin": "MF",
  "Madagascar": "MG",
  "Marshall Islands": "MH",
  "North Macedonia": "MK",
  "Mali": "ML",
  "Myanmar": "MM",
  "Mongolia": "MN",
  "Macao": "MO",
  "Northern Mariana Islands": "MP",
  "Martinique": "MQ",
  "Mauritania": "MR",
  "Montserrat": "MS",
  "Malta": "MT",
  "Mauritius": "MU",
  "Maldives": "MV",
  "Malawi": "MW",
  "Mexico": "MX",
  "Malaysia": "MY",
  "Mozambique": "MZ",
  "Namibia": "NA",
  "New Caledonia": "NC",
  "Niger": "NE",
  "Norfolk Island": "NF",
  "Nigeria": "NG",
  "Nicaragua": "NI",
  "Netherlands": "NL",
  "Norway": "NO",
  "Nepal": "NP",
  "Nauru": "NR",
  "Niue": "NU",
  "New Zealand": "NZ",
  "Oman": "OM",
  "Panama": "PA",
  "Peru": "PE",
  "French Polynesia": "PF",
  "Papua New Guinea": "PG",
  "Philippines": "PH",
  "Pakistan": "PK",
  "Poland": "PL",
  "Saint Pierre and Miquelon": "PM",
  "Pitcairn": "PN",
  "Puerto Rico": "PR",
  "Palestine": "PS",
  "Portugal": "PT",
  "Palau": "PW",
  "Paraguay": "PY",
  "Qatar": "QA",
  "Réunion": "RE",
  "Romania": "RO",
  "Serbia": "RS",
  "Russian Federation": "RU",
  "Rwanda": "RW",
  "Saudi Arabia": "SA",
  "Solomon Islands": "SB",
  "Seychelles": "SC",
  "Sudan": "SD",
  "Sweden": "SE",
  "Singapore": "SG",
  "Saint Helena, Ascension and Tristan da Cunha": "SH",
  "Slovenia": "SI",
  "Svalbard and Jan Mayen Islands": "SJ",
  "Slovakia": "SK",
  "Sierra Leone": "SL",
  "San Marino": "SM",
  "Senegal": "SN",
  "Somalia": "SO",
  "Suriname": "SR",
  "South Sudan": "SS",
  "Sao Tome and Principe": "ST",
  "El Salvador": "SV",
  "Sint Maarten (Dutch part)": "SX",
  "Syrian Arab Republic": "SY",
  "Swaziland": "SZ",
  "Turks and Caicos Islands": "TC",
  "Chad": "TD",
  "French Southern Territories": "TF",
  "Togo": "TG",
  "Thailand": "TH",
  "Tajikistan": "TJ",
  "Tokelau": "TK",
  "Timor-Leste": "TL",
  "Turkmenistan": "TM",
  "Tunisia": "TN",
  "Tonga": "TO",
  "Turkey": "TR",
  "Trinidad and Tobago": "TT",
  "Tuvalu": "TV",
  "Taiwan (Republic of China)": "TW",
  "Tanzania, United Republic of": "TZ",
  "Ukraine": "UA",
  "Uganda": "UG",
  "US Minor Outlying Islands": "UM",
  "USA": "US",
  "Uruguay": "UY",
  "Uzbekistan": "UZ",
  "Holy See (Vatican City State)": "VA",
  "Saint Vincent and the Grenadines": "VC",
  "Venezuela, Bolivarian Republic of": "VE",
  "Virgin Islands, British": "VG",
  "Virgin Islands, U.S.": "VI",
  "Vietnam": "VN",
  "Vanuatu": "VU",
  "Wallis and Futuna Islands": "WF",
  "Samoa": "WS",
  "Kosovo": "XK",
  "Yemen": "YE",
  "Mayotte": "YT",
  "South Africa": "ZA",
  "Zambia": "ZM",
  "Zimbabwe": "ZW"
};
