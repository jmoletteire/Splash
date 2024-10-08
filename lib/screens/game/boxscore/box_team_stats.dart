import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utilities/constants.dart';

class BoxTeamStats extends StatefulWidget {
  final List<dynamic> teams;
  final String homeId;
  final String awayId;
  final bool inProgress;
  const BoxTeamStats({
    super.key,
    required this.teams,
    required this.homeId,
    required this.awayId,
    required this.inProgress,
  });

  @override
  State<BoxTeamStats> createState() => _BoxTeamStatsState();
}

class _BoxTeamStatsState extends State<BoxTeamStats> {
  dynamic homeTeam = {};
  dynamic awayTeam = {};
  Color homeTeamColor = Colors.transparent;
  Color awayTeamColor = Colors.transparent;
  bool _isLoading = false;

  void setValues(String homeId, String awayId) {
    if (widget.teams[0].containsKey('teamId')) {
      // Use default order if no TEAM_ID key exists
      homeTeam = widget.teams.firstWhere((team) => team['teamId'].toString() == homeId);
      awayTeam = widget.teams.firstWhere((team) => team['teamId'].toString() == awayId);
    } else {
      // Assign based on the ID matching homeId
      homeTeam = widget.teams.firstWhere((team) => team['TEAM_ID'].toString() == homeId);
      awayTeam = widget.teams.firstWhere((team) => team['TEAM_ID'].toString() == awayId);
    }

    if (homeTeam.isNotEmpty) {
      homeTeam['TEAM_ABBREVIATION'] = kTeamIdToName[homeId][1];
      homeTeamColor = kDarkPrimaryColors.contains(homeTeam['TEAM_ABBREVIATION'])
          ? (kTeamColors[homeTeam['TEAM_ABBREVIATION']]!['secondaryColor']!)
          : (kTeamColors[homeTeam['TEAM_ABBREVIATION']]!['primaryColor']!);
    }

    if (awayTeam.isNotEmpty) {
      awayTeam['TEAM_ABBREVIATION'] = kTeamIdToName[awayId]?[1] ?? 'FA';
      awayTeamColor = kTeamColorOpacity.containsKey(awayTeam['TEAM_ABBREVIATION'])
          ? kDarkPrimaryColors.contains(awayTeam['TEAM_ABBREVIATION'])
              ? (kTeamColors[awayTeam['TEAM_ABBREVIATION']]!['secondaryColor']!)
              : (kTeamColors[awayTeam['TEAM_ABBREVIATION']]!['primaryColor']!)
          : kTeamColors['FA']!['primaryColor']!;
    }
  }

  double roundToDecimalPlaces(double value, int decimalPlaces) {
    num factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  @override
  void initState() {
    super.initState();
    setValues(widget.homeId, widget.awayId);
  }

  @override
  Widget build(BuildContext context) {
    int awayEstPoss = 0;
    int homeEstPoss = 0;
    int minutes = 0;

    if (homeTeam['POSS'] == null) {
      awayEstPoss = ((awayTeam['fieldGoalsAttempted'] ?? 0) +
              (awayTeam['turnovers'] ?? 0) +
              (0.44 * (awayTeam['freeThrowsAttempted'] ?? 0)) -
              (awayTeam['reboundsOffensive'] ?? 0))
          .ceil();
      homeEstPoss = ((homeTeam['fieldGoalsAttempted'] ?? 0) +
              (homeTeam['turnovers'] ?? 0) +
              (0.44 * (homeTeam['freeThrowsAttempted'] ?? 0)) -
              (homeTeam['reboundsOffensive'] ?? 0))
          .ceil();

      minutes = (int.parse(awayTeam['minutesCalculated']
                  .substring(2, awayTeam['minutesCalculated'].length - 1)) /
              5)
          .floor();
    }

    return SliverToBoxAdapter(
      child: Skeletonizer(
        enabled: _isLoading,
        child: homeTeam == null || awayTeam == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_basketball,
                      color: Colors.white38,
                      size: 40.0.r,
                    ),
                    SizedBox(height: 15.0.r),
                    Text(
                      'No Games Available',
                      style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Card(
                    color: Colors.grey.shade900,
                    margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                    child: Padding(
                      padding: EdgeInsets.all(15.0.r),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Efficiency', style: kBebasBold.copyWith(fontSize: 18.0.r))
                            ],
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'PTS',
                            awayTeam: awayTeam['points'] ?? awayTeam['PTS'] ?? 0.0,
                            homeTeam: homeTeam['points'] ?? homeTeam['PTS'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'PER 100',
                            awayTeam: roundToDecimalPlaces(
                                awayTeam['OFF_RATING'] ??
                                    awayTeam['points'] /
                                        (awayEstPoss == 0 ? 1 : awayEstPoss) *
                                        100 ??
                                    0.0,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                homeTeam['OFF_RATING'] ??
                                    homeTeam['points'] /
                                        (homeEstPoss == 0 ? 1 : homeEstPoss) *
                                        100 ??
                                    0.0,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'POSSESSIONS',
                            awayTeam: awayTeam['POSS'] ?? awayEstPoss ?? 0.0,
                            homeTeam: homeTeam['POSS'] ?? homeEstPoss ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'PACE',
                            awayTeam: roundToDecimalPlaces(
                                awayTeam['PACE'] ??
                                    48 *
                                        ((awayEstPoss + homeEstPoss) / 2) /
                                        (minutes == 0 ? 1 : minutes) ??
                                    0.0,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                homeTeam['PACE'] ??
                                    48 *
                                        ((awayEstPoss + homeEstPoss) / 2) /
                                        (minutes == 0 ? 1 : minutes) ??
                                    0.0,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'TOV',
                            awayTeam: awayTeam['turnoversTotal'] ?? awayTeam['TO'] ?? 0,
                            homeTeam: homeTeam['turnoversTotal'] ?? homeTeam['TO'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'TOV%',
                            awayTeam: roundToDecimalPlaces(
                                awayTeam['TM_TOV_PCT'] ??
                                    100 *
                                        awayTeam['turnovers'] /
                                        (awayEstPoss == 0 ? 1 : awayEstPoss) ??
                                    0.0,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                homeTeam['TM_TOV_PCT'] ??
                                    100 *
                                        homeTeam['turnovers'] /
                                        (homeEstPoss == 0 ? 1 : homeEstPoss) ??
                                    0.0,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey.shade900,
                    margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                    child: Padding(
                      padding: EdgeInsets.all(15.0.r),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Shooting', style: kBebasBold.copyWith(fontSize: 18.0.r))
                            ],
                          ),
                          SizedBox(height: 15.0.r),
                          NonComparisonRow(
                            statName: 'FG',
                            awayTeam:
                                '${awayTeam['fieldGoalsMade'] ?? awayTeam['FGM'] ?? 0}-${awayTeam['fieldGoalsAttempted'] ?? awayTeam['FGA'] ?? 0}',
                            homeTeam:
                                '${homeTeam['fieldGoalsMade'] ?? homeTeam['FGM'] ?? 0}-${homeTeam['fieldGoalsAttempted'] ?? homeTeam['FGA'] ?? 0}',
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'FG%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['fieldGoalsPercentage'] ??
                                        awayTeam['FG_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['fieldGoalsPercentage'] ??
                                        homeTeam['FG_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          NonComparisonRow(
                            statName: '3P',
                            awayTeam:
                                '${awayTeam['threePointersMade'] ?? awayTeam['FG3M'] ?? 0}-${awayTeam['threePointersAttempted'] ?? awayTeam['FG3A'] ?? 0}',
                            homeTeam:
                                '${homeTeam['threePointersMade'] ?? homeTeam['FG3M'] ?? 0}-${homeTeam['threePointersAttempted'] ?? homeTeam['FG3A'] ?? 0}',
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: '3P%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['threePointersPercentage'] ??
                                        awayTeam['FG3_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['threePointersPercentage'] ??
                                        homeTeam['FG3_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          NonComparisonRow(
                            statName: 'FT',
                            awayTeam:
                                '${awayTeam['freeThrowsMade'] ?? awayTeam['FTM'] ?? 0}-${awayTeam['freeThrowsAttempted'] ?? awayTeam['FTA'] ?? 0}',
                            homeTeam:
                                '${homeTeam['freeThrowsMade'] ?? homeTeam['FTM'] ?? 0}-${homeTeam['freeThrowsAttempted'] ?? homeTeam['FTA'] ?? 0}',
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'FT%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['freeThrowsPercentage'] ??
                                        awayTeam['FT_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['freeThrowsPercentage'] ??
                                        homeTeam['FT_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'FT/FGA',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['freeThrowsMade'] ?? awayTeam['FTM']) /
                                    ((awayTeam['fieldGoalsAttempted'] ?? awayTeam['FGA']) == 0
                                        ? 1
                                        : (awayTeam['fieldGoalsAttempted'] ??
                                            awayTeam['FGA'])),
                                2),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['freeThrowsMade'] ?? homeTeam['FTM']) /
                                    ((homeTeam['fieldGoalsAttempted'] ?? homeTeam['FGA']) == 0
                                        ? 1
                                        : (homeTeam['fieldGoalsAttempted'] ??
                                            homeTeam['FGA'])),
                                2),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'EFG%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['fieldGoalsEffectiveAdjusted'] ??
                                        awayTeam['EFG_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['fieldGoalsEffectiveAdjusted'] ??
                                        homeTeam['EFG_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'TS%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['trueShootingPercentage'] ??
                                        awayTeam['TS_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['trueShootingPercentage'] ??
                                        homeTeam['TS_PCT'] ??
                                        0.0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'PTS IN PAINT',
                            awayTeam:
                                awayTeam['pointsInThePaint'] ?? awayTeam['PTS_PAINT'] ?? 0.0,
                            homeTeam:
                                homeTeam['pointsInThePaint'] ?? homeTeam['PTS_PAINT'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'PTS OUTSIDE',
                            awayTeam: (awayTeam['points'] ?? awayTeam['PTS'] ?? 0.0) -
                                (awayTeam['freeThrowsMade'] ?? awayTeam['FTM'] ?? 0.0) -
                                (awayTeam['pointsInThePaint'] ?? awayTeam['PTS_PAINT'] ?? 0.0),
                            homeTeam: (homeTeam['points'] ?? homeTeam['PTS'] ?? 0.0) -
                                (homeTeam['freeThrowsMade'] ?? homeTeam['FTM'] ?? 0.0) -
                                (homeTeam['pointsInThePaint'] ?? homeTeam['PTS_PAINT'] ?? 0.0),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey.shade900,
                    margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                    child: Padding(
                      padding: EdgeInsets.all(15.0.r),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Rebounding', style: kBebasBold.copyWith(fontSize: 18.0.r))
                            ],
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'REB',
                            awayTeam: awayTeam['reboundsTotal'] ?? awayTeam['REB'] ?? 0,
                            homeTeam: homeTeam['reboundsTotal'] ?? homeTeam['REB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'OREB',
                            awayTeam: awayTeam['reboundsOffensive'] ?? awayTeam['OREB'] ?? 0,
                            homeTeam: homeTeam['reboundsOffensive'] ?? homeTeam['OREB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'DREB',
                            awayTeam: awayTeam['reboundsDefensive'] ?? awayTeam['DREB'] ?? 0,
                            homeTeam: homeTeam['reboundsDefensive'] ?? homeTeam['DREB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'OREB%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['OREB_PCT'] ??
                                        awayTeam['reboundsOffensive'] /
                                            ((awayTeam['fieldGoalsAttempted'] -
                                                        awayTeam['fieldGoalsMade']) ==
                                                    0
                                                ? 1
                                                : (awayTeam['fieldGoalsAttempted'] -
                                                    awayTeam['fieldGoalsMade'])) ??
                                        0.0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['OREB_PCT'] ??
                                        homeTeam['reboundsOffensive'] /
                                            ((homeTeam['fieldGoalsAttempted'] -
                                                        homeTeam['fieldGoalsMade']) ==
                                                    0
                                                ? 1
                                                : (homeTeam['fieldGoalsAttempted'] -
                                                    homeTeam['fieldGoalsMade'])) ??
                                        0.0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'DREB%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['DREB_PCT'] ??
                                        awayTeam['reboundsDefensive'] /
                                            ((awayTeam['fieldGoalsAttempted'] -
                                                        awayTeam['fieldGoalsMade']) ==
                                                    0
                                                ? 1
                                                : (awayTeam['fieldGoalsAttempted'] -
                                                    awayTeam['fieldGoalsMade'])) ??
                                        0.0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['DREB_PCT'] ??
                                        homeTeam['reboundsDefensive'] /
                                            ((homeTeam['fieldGoalsAttempted'] -
                                                        homeTeam['fieldGoalsMade']) ==
                                                    0
                                                ? 1
                                                : (homeTeam['fieldGoalsAttempted'] -
                                                    homeTeam['fieldGoalsMade'])) ??
                                        0.0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: '2ND Chance PTS',
                            awayTeam: awayTeam['pointsSecondChance'] ??
                                awayTeam['PTS_2ND_CHANCE'] ??
                                0.0,
                            homeTeam: homeTeam['pointsSecondChance'] ??
                                homeTeam['PTS_2ND_CHANCE'] ??
                                0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey.shade900,
                    margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                    child: Padding(
                      padding: EdgeInsets.all(15.0.r),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Passing', style: kBebasBold.copyWith(fontSize: 18.0.r))
                            ],
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'AST',
                            awayTeam: awayTeam['assists'] ?? awayTeam['AST'] ?? 0,
                            homeTeam: homeTeam['assists'] ?? homeTeam['AST'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'AST%',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['AST_PCT'] ??
                                        (awayTeam['assists'] /
                                            (awayTeam['fieldGoalsMade'] == 0
                                                ? 1
                                                : awayTeam['fieldGoalsMade'])) ??
                                        0) *
                                    100,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['AST_PCT'] ??
                                        (homeTeam['assists'] /
                                            (homeTeam['fieldGoalsMade'] == 0
                                                ? 1
                                                : homeTeam['fieldGoalsMade'])) ??
                                        0) *
                                    100,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'AST / TOV',
                            awayTeam: roundToDecimalPlaces(
                                awayTeam['assistsTurnoverRatio'] ?? awayTeam['AST_TOV'] ?? 0,
                                1),
                            homeTeam: roundToDecimalPlaces(
                                homeTeam['assistsTurnoverRatio'] ?? homeTeam['AST_TOV'] ?? 0,
                                1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey.shade900,
                    margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                    child: Padding(
                      padding: EdgeInsets.all(15.0.r),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Defense', style: kBebasBold.copyWith(fontSize: 18.0.r))
                            ],
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'STL',
                            awayTeam: awayTeam['steals'] ?? awayTeam['STL'] ?? 0,
                            homeTeam: homeTeam['steals'] ?? homeTeam['STL'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'BLK',
                            awayTeam: awayTeam['blocks'] ?? awayTeam['BLK'] ?? 0,
                            homeTeam: homeTeam['blocks'] ?? homeTeam['BLK'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'FOULS',
                            awayTeam: awayTeam['foulsPersonal'] ?? awayTeam['PF'] ?? 0,
                            homeTeam: homeTeam['foulsPersonal'] ?? homeTeam['PF'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'PTS OFF TOV',
                            awayTeam:
                                awayTeam['pointsFromTurnovers'] ?? awayTeam['PTS_OFF_TO'] ?? 0,
                            homeTeam:
                                homeTeam['pointsFromTurnovers'] ?? homeTeam['PTS_OFF_TO'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'FASTBREAK PTS',
                            awayTeam: awayTeam['pointsFastbreak'] ?? awayTeam['PTS_FB'] ?? 0,
                            homeTeam: homeTeam['pointsFastbreak'] ?? homeTeam['PTS_FB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0.r),
                ],
              ),
      ),
    );
  }
}

class NonComparisonRow extends StatelessWidget {
  const NonComparisonRow({
    super.key,
    required this.statName,
    required this.awayTeam,
    required this.homeTeam,
  });

  final String statName;
  final dynamic awayTeam;
  final dynamic homeTeam;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0.r),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              awayTeam,
              textAlign: TextAlign.start,
              style: kBebasNormal.copyWith(fontSize: 15.0.r, color: Colors.grey.shade300),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 14.0.r),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0.r),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              homeTeam,
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 15.0.r, color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}

class ComparisonRow extends StatelessWidget {
  const ComparisonRow({
    super.key,
    required this.statName,
    required this.awayTeam,
    required this.homeTeam,
    this.awayTeamColor = Colors.transparent,
    this.homeTeamColor = Colors.transparent,
  });

  final String statName;
  final dynamic awayTeam;
  final dynamic homeTeam;
  final Color awayTeamColor;
  final Color homeTeamColor;

  @override
  Widget build(BuildContext context) {
    bool oneIsBetter = (statName.contains('DRTG') ||
            statName == 'FOULS' ||
            statName == 'TOV' ||
            statName == 'TOV%')
        ? awayTeam < homeTeam
        : awayTeam > homeTeam;
    bool twoIsBetter = (statName.contains('DRTG') ||
            statName == 'FOULS' ||
            statName == 'TOV' ||
            statName == 'TOV%')
        ? homeTeam < awayTeam
        : homeTeam > awayTeam;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StatValue(
                value: awayTeam,
                isHighlighted: oneIsBetter ? true : false,
                color: awayTeamColor,
                isPercentage: statName.contains('%'),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 14.0.r),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StatValue(
                value: homeTeam,
                isHighlighted: twoIsBetter ? true : false,
                color: homeTeamColor,
                isPercentage: statName.contains('%'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatValue extends StatelessWidget {
  final dynamic value;
  final bool isHighlighted;
  final Color color;
  final bool isPercentage;

  StatValue(
      {required this.value,
      this.isHighlighted = false,
      required this.color,
      required this.isPercentage});

  @override
  Widget build(BuildContext context) {
    Map<Color, Color> lightColors = {
      const Color(0xFFFFFFFF): const Color(0xFF000000),
      const Color(0xFFFEC524): const Color(0xFF0E2240),
      const Color(0xFFFDBB30): const Color(0xFF002D62),
      const Color(0xFFED184D): const Color(0xFF0B2240),
      const Color(0xFF78BE20): const Color(0xFF0B233F),
      const Color(0xFF85714D): const Color(0xFF0C2340),
      const Color(0xFFE56020): const Color(0xFF1D1160),
      const Color(0xFFC4CED4): const Color(0xFF000000),
      const Color(0xFFFCA200): const Color(0xFF002B5C),
      const Color(0xFFE31837): const Color(0xFF002B5C),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0.r),
      decoration: BoxDecoration(
        color: isHighlighted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        isPercentage ? '$value%' : '$value',
        style: isHighlighted && lightColors.containsKey(color)
            ? kBebasNormal.copyWith(fontSize: 16.0.r, color: lightColors[color])
            : kBebasNormal.copyWith(fontSize: 16.0.r),
      ),
    );
  }
}
