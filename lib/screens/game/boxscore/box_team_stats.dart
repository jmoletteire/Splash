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
  final bool _isLoading = false;
  dynamic homeTeam = {};
  dynamic awayTeam = {};
  Color homeTeamColor = Colors.transparent;
  Color awayTeamColor = Colors.transparent;
  int awayEstPoss = 0;
  int homeEstPoss = 0;
  int minutes = 0;
  late Widget efficiency;
  late Widget shooting;
  late Widget rebounding;
  late Widget passing;
  late Widget defense;

  @override
  void initState() {
    super.initState();
    setTeamValues(widget.homeId, widget.awayId);
    calculatePossessionsAndMinutes();

    // Set stats
    efficiency = buildStatsCard('Efficiency', buildEfficiencyRows());
    shooting = buildStatsCard('Shooting', buildShootingRows());
    rebounding = buildStatsCard('Rebounding', buildReboundingRows());
    passing = buildStatsCard('Passing', buildPassingRows());
    defense = buildStatsCard('Defense', buildDefenseRows());
  }

  @override
  void didUpdateWidget(covariant BoxTeamStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool existsUpdates = false;

    // Check if the game data has changed
    if (oldWidget.teams != widget.teams) {
      // Loop through both lists of teams and compare each field
      for (int i = 0; i < widget.teams.length; i++) {
        if (i >= oldWidget.teams.length) break;

        final newTeam = widget.teams[i];
        final oldTeam = oldWidget.teams[i];

        // Track which fields are different for this team
        Map<String, dynamic> changes = {};

        // Compare each key in the new team against the old team
        newTeam.forEach((key, newValue) {
          final oldValue = oldTeam[key];
          if (newValue != oldValue) {
            changes[key] = {'old': oldValue, 'new': newValue};
          }
        });

        // Output the differences for this team if any fields changed
        if (changes.isNotEmpty) {
          existsUpdates = true;
        }
      }

      if (existsUpdates) {
        // Re-calculate player and team stats
        setTeamValues(widget.homeId, widget.awayId);
        calculatePossessionsAndMinutes();

        // Set stats
        efficiency = buildStatsCard('Efficiency', buildEfficiencyRows());
        shooting = buildStatsCard('Shooting', buildShootingRows());
        rebounding = buildStatsCard('Rebounding', buildReboundingRows());
        passing = buildStatsCard('Passing', buildPassingRows());
        defense = buildStatsCard('Defense', buildDefenseRows());
      }
    }
  }

  void setTeamValues(String homeId, String awayId) {
    homeTeam = findTeam(homeId);
    awayTeam = findTeam(awayId);

    homeTeamColor = getTeamColor(homeTeam, homeId);
    awayTeamColor = getTeamColor(awayTeam, awayId);
  }

  dynamic findTeam(String teamId) {
    return widget.teams.firstWhere(
      (team) => team['teamId']?.toString() == teamId || team['TEAM_ID']?.toString() == teamId,
      orElse: () => {},
    );
  }

  Color getTeamColor(dynamic team, String teamId) {
    String abbreviation = kTeamIdToName[teamId]?[1] ?? 'FA';
    team['TEAM_ABBREVIATION'] = abbreviation;
    return kDarkPrimaryColors.contains(abbreviation)
        ? (kTeamColors[abbreviation]?['secondaryColor'] ?? Colors.transparent)
        : (kTeamColors[abbreviation]?['primaryColor'] ?? Colors.transparent);
  }

  void calculatePossessionsAndMinutes() {
    if (homeTeam['POSS'] == null || homeTeam['POSS'] == 0) {
      awayEstPoss = calculateEstimatedPossessions(awayTeam);
      homeEstPoss = calculateEstimatedPossessions(homeTeam);
      minutes = calculateMinutes(awayTeam);
    }
  }

  int calculateEstimatedPossessions(dynamic team) {
    return ((team['fieldGoalsAttempted'] ?? 0) +
            (team['turnovers'] ?? 0) +
            (0.44 * (team['freeThrowsAttempted'] ?? 0)) -
            (team['reboundsOffensive'] ?? 0))
        .ceil();
  }

  int calculateMinutes(dynamic team) {
    String minutesString = team['minutesCalculated'] ?? team['MIN'] ?? '0:00';
    return (int.parse(minutesString.substring(2, minutesString.length - 1)) / 5).floor();
  }

  double roundToDecimalPlaces(double value, int decimalPlaces) {
    num factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  @override
  Widget build(BuildContext context) {
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
                  efficiency,
                  shooting,
                  rebounding,
                  passing,
                  defense,
                  /*
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
                          if (awayTeam.containsKey('SQ_TOTAL') &&
                              homeTeam.containsKey('SQ_TOTAL'))
                            ComparisonRow(
                              statName: 'xPTS',
                              awayTeam: roundToDecimalPlaces(
                                      awayTeam['SQ_TOTAL'].toDouble() ?? 0.0, 1) +
                                  (awayTeam['freeThrowsMade'] ?? 0.0),
                              homeTeam: roundToDecimalPlaces(
                                      homeTeam['SQ_TOTAL'].toDouble() ?? 0.0, 1) +
                                  (homeTeam['freeThrowsMade'] ?? 0.0),
                              awayTeamColor: awayTeamColor,
                              homeTeamColor: homeTeamColor,
                            ),
                          if (awayTeam.containsKey('SQ_TOTAL') &&
                              homeTeam.containsKey('SQ_TOTAL'))
                            SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'PER POSS',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['points'] ?? awayTeam['PTS'] ?? 0) /
                                    ((awayTeam?['POSS'] ??
                                                (awayEstPoss == 0 ? 1 : awayEstPoss)) !=
                                            0
                                        ? (awayTeam?['POSS'] ??
                                            (awayEstPoss == 0 ? 1 : awayEstPoss))
                                        : (awayEstPoss == 0 ? 1 : awayEstPoss)),
                                2),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['points'] ?? homeTeam['PTS'] ?? 0) /
                                    ((homeTeam?['POSS'] ??
                                                (homeEstPoss == 0 ? 1 : homeEstPoss)) !=
                                            0
                                        ? (homeTeam?['POSS'] ??
                                            (homeEstPoss == 0 ? 1 : homeEstPoss))
                                        : (homeEstPoss == 0 ? 1 : homeEstPoss)),
                                2),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          SizedBox(height: 5.0.r),
                          ComparisonRow(
                            statName: 'PER SHOT',
                            awayTeam: roundToDecimalPlaces(
                                ((awayTeam['points'] ?? awayTeam['PTS'] ?? 0) -
                                            (awayTeam['freeThrowsMade'] ??
                                                awayTeam['FTM'] ??
                                                0)) /
                                        ((awayTeam['fieldGoalsAttempted'] ??
                                                    awayTeam['FGA']) ==
                                                0
                                            ? 1
                                            : awayTeam['fieldGoalsAttempted'] ??
                                                awayTeam['FGA']) ??
                                    0.0,
                                2),
                            homeTeam: roundToDecimalPlaces(
                                ((homeTeam['points'] ?? homeTeam['PTS'] ?? 0) -
                                            (homeTeam['freeThrowsMade'] ??
                                                homeTeam['FTM'] ??
                                                0)) /
                                        ((homeTeam['fieldGoalsAttempted'] ??
                                                    homeTeam['FGA']) ==
                                                0
                                            ? 1
                                            : homeTeam['fieldGoalsAttempted'] ??
                                                homeTeam['FGA']) ??
                                    0.0,
                                2),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          if (awayTeam.containsKey('SQ_TOTAL') &&
                              homeTeam.containsKey('SQ_TOTAL'))
                            SizedBox(height: 5.0.r),
                          if (awayTeam.containsKey('SQ_TOTAL') &&
                              homeTeam.containsKey('SQ_TOTAL'))
                            ComparisonRow(
                              statName: 'Shot Quality',
                              awayTeam: roundToDecimalPlaces(
                                  (awayTeam['SQ_TOTAL'].toDouble() ?? 0.0) / 100, 2),
                              homeTeam: roundToDecimalPlaces(
                                  (homeTeam['SQ_TOTAL'].toDouble() ?? 0.0) / 100, 2),
                              awayTeamColor: awayTeamColor,
                              homeTeamColor: homeTeamColor,
                            ),
                          SizedBox(height: 15.0.r),
                          ComparisonRow(
                            statName: 'POSSESSIONS',
                            awayTeam: awayTeam['POSS'] == null || awayTeam['POSS'] == 0
                                ? awayEstPoss
                                : awayTeam['POSS'] ?? 0.0,
                            homeTeam: homeTeam['POSS'] == null || homeTeam['POSS'] == 0
                                ? awayEstPoss
                                : homeTeam['POSS'] ?? 0.0,
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
                          SizedBox(height: 5.0.r),
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
                   */
                ],
              ),
      ),
    );
  }

  Widget buildNoStatsAvailable() {
    return Center(
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
            'No Stats Available',
            style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget buildStatsCard(String title, List<Widget> rows) {
    return Card(
      color: Colors.grey.shade900,
      margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
      child: Padding(
        padding: EdgeInsets.all(15.0.r),
        child: Column(
          children: [
            Center(child: Text(title, style: kBebasBold.copyWith(fontSize: 18.0.r))),
            SizedBox(height: 15.0.r),
            ...rows,
          ],
        ),
      ),
    );
  }

  List<Widget> buildEfficiencyRows() {
    return [
      buildComparisonRow('PTS', awayTeam['points'] ?? 0, homeTeam['points'] ?? 0),
      SizedBox(height: 5.0.r),
      if (awayTeam.containsKey('SQ_TOTAL') && homeTeam.containsKey('SQ_TOTAL'))
        ComparisonRow(
          statName: 'xPTS',
          awayTeam: roundToDecimalPlaces(
              (awayTeam['SQ_TOTAL'] + (awayTeam['freeThrowsMade'] ?? awayTeam['FTM'] ?? 0))
                      .toDouble() ??
                  0.0,
              1),
          homeTeam: roundToDecimalPlaces(
              (homeTeam['SQ_TOTAL'] + (homeTeam['freeThrowsMade'] ?? homeTeam['FTM'] ?? 0))
                      .toDouble() ??
                  0.0,
              1),
          awayTeamColor: awayTeamColor,
          homeTeamColor: homeTeamColor,
        ),
      if (awayTeam.containsKey('SQ_TOTAL') && homeTeam.containsKey('SQ_TOTAL'))
        SizedBox(height: 15.0.r),
      buildComparisonRow(
        'PER POSS',
        calculatePointsPerPossession(awayTeam, awayEstPoss),
        calculatePointsPerPossession(homeTeam, homeEstPoss),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'PER SHOT',
        calculatePointsPerShot(awayTeam),
        calculatePointsPerShot(homeTeam),
      ),
      if (awayTeam.containsKey('SQ_TOTAL') && homeTeam.containsKey('SQ_TOTAL'))
        SizedBox(height: 5.0.r),
      if (awayTeam.containsKey('SQ_TOTAL') && homeTeam.containsKey('SQ_TOTAL'))
        ComparisonRow(
          statName: 'Shot Quality',
          awayTeam: roundToDecimalPlaces((awayTeam['SQ_TOTAL'].toDouble() ?? 0.0) / 100, 2),
          homeTeam: roundToDecimalPlaces((homeTeam['SQ_TOTAL'].toDouble() ?? 0.0) / 100, 2),
          awayTeamColor: awayTeamColor,
          homeTeamColor: homeTeamColor,
        ),
      SizedBox(height: 15.0.r),
      ComparisonRow(
        statName: 'POSSESSIONS',
        awayTeam: awayTeam['POSS'] == null || awayTeam['POSS'] == 0
            ? awayEstPoss
            : awayTeam['POSS'] ?? 0.0,
        homeTeam: homeTeam['POSS'] == null || homeTeam['POSS'] == 0
            ? awayEstPoss
            : homeTeam['POSS'] ?? 0.0,
        awayTeamColor: awayTeamColor,
        homeTeamColor: homeTeamColor,
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow('PACE', awayTeam['PACE'] ?? calculatePace(awayTeam, awayEstPoss),
          homeTeam['PACE'] ?? calculatePace(homeTeam, homeEstPoss)),
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
                100 * awayTeam['turnovers'] / (awayEstPoss == 0 ? 1 : awayEstPoss) ??
                0.0,
            1),
        homeTeam: roundToDecimalPlaces(
            homeTeam['TM_TOV_PCT'] ??
                100 * homeTeam['turnovers'] / (homeEstPoss == 0 ? 1 : homeEstPoss) ??
                0.0,
            1),
        awayTeamColor: awayTeamColor,
        homeTeamColor: homeTeamColor,
      ),
    ];
  }

  double calculatePointsPerPossession(dynamic team, int estPoss) {
    int possessions = team['POSS'] ?? estPoss;
    return roundToDecimalPlaces(
        (team['points'] ?? 0) / (possessions == 0 ? 1 : possessions), 2);
  }

  double calculatePointsPerShot(dynamic team) {
    int fga = team['fieldGoalsAttempted'] ?? team['FGA'] ?? 1;
    return roundToDecimalPlaces((team['points'] ?? 0) / fga, 2);
  }

  double calculatePace(dynamic team, int estPoss) {
    int possessions = (awayEstPoss + homeEstPoss) ~/ 2;
    return roundToDecimalPlaces(48 * possessions / (minutes == 0 ? 1 : minutes), 1);
  }

  List<Widget> buildShootingRows() {
    return [
      NonComparisonRow(
        statName: 'FG',
        awayTeam:
            '${awayTeam['fieldGoalsMade'] ?? awayTeam['FGM'] ?? 0}-${awayTeam['fieldGoalsAttempted'] ?? awayTeam['FGA'] ?? 0}',
        homeTeam:
            '${homeTeam['fieldGoalsMade'] ?? homeTeam['FGM'] ?? 0}-${homeTeam['fieldGoalsAttempted'] ?? homeTeam['FGA'] ?? 0}',
      ),
      buildComparisonRow(
          'FG%',
          roundToDecimalPlaces(
              (awayTeam['fieldGoalsPercentage'] ?? awayTeam['FG_PCT'] ?? 0.0) * 100, 1),
          roundToDecimalPlaces(
              (homeTeam['fieldGoalsPercentage'] ?? homeTeam['FG_PCT'] ?? 0.0) * 100, 1)),
      SizedBox(height: 15.0.r),
      NonComparisonRow(
        statName: '3P',
        awayTeam:
            '${awayTeam['threePointersMade'] ?? awayTeam['FG3M'] ?? 0}-${awayTeam['threePointersAttempted'] ?? awayTeam['FG3A'] ?? 0}',
        homeTeam:
            '${homeTeam['threePointersMade'] ?? homeTeam['FG3M'] ?? 0}-${homeTeam['threePointersAttempted'] ?? homeTeam['FG3A'] ?? 0}',
      ),
      buildComparisonRow(
          '3P%',
          roundToDecimalPlaces(
              (awayTeam['threePointersPercentage'] ?? awayTeam['FG3_PCT'] ?? 0.0) * 100, 1),
          roundToDecimalPlaces(
              (homeTeam['threePointersPercentage'] ?? homeTeam['FG3_PCT'] ?? 0.0) * 100, 1)),
      SizedBox(height: 15.0.r),
      NonComparisonRow(
        statName: 'FT',
        awayTeam:
            '${awayTeam['freeThrowsMade'] ?? awayTeam['FTM'] ?? 0}-${awayTeam['freeThrowsAttempted'] ?? awayTeam['FTA'] ?? 0}',
        homeTeam:
            '${homeTeam['freeThrowsMade'] ?? homeTeam['FTM'] ?? 0}-${homeTeam['freeThrowsAttempted'] ?? homeTeam['FTA'] ?? 0}',
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
          'FT%',
          roundToDecimalPlaces(
              (awayTeam['freeThrowsPercentage'] ?? awayTeam['FT_PCT'] ?? 0.0) * 100, 1),
          roundToDecimalPlaces(
              (homeTeam['freeThrowsPercentage'] ?? homeTeam['FT_PCT'] ?? 0.0) * 100, 1)),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
          'FT/FGA',
          roundToDecimalPlaces(
              (awayTeam['freeThrowsMade'] ?? awayTeam['FTM']) /
                  ((awayTeam['fieldGoalsAttempted'] ?? awayTeam['FGA']) == 0
                      ? 1
                      : (awayTeam['fieldGoalsAttempted'] ?? awayTeam['FGA'])),
              2),
          roundToDecimalPlaces(
              (homeTeam['freeThrowsMade'] ?? homeTeam['FTM']) /
                  ((homeTeam['fieldGoalsAttempted'] ?? homeTeam['FGA']) == 0
                      ? 1
                      : (homeTeam['fieldGoalsAttempted'] ?? homeTeam['FGA'])),
              2)),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        'EFG%',
        roundToDecimalPlaces(
            (awayTeam['fieldGoalsEffectiveAdjusted'] ?? awayTeam['EFG_PCT'] ?? 0.0) * 100, 1),
        roundToDecimalPlaces(
            (homeTeam['fieldGoalsEffectiveAdjusted'] ?? homeTeam['EFG_PCT'] ?? 0.0) * 100, 1),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'TS%',
        roundToDecimalPlaces(
            (awayTeam['trueShootingPercentage'] ?? awayTeam['TS_PCT'] ?? 0.0) * 100, 1),
        roundToDecimalPlaces(
            (homeTeam['trueShootingPercentage'] ?? homeTeam['TS_PCT'] ?? 0.0) * 100, 1),
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        'PTS IN PAINT',
        awayTeam['pointsInThePaint'] ?? awayTeam['PTS_PAINT'] ?? 0.0,
        homeTeam['pointsInThePaint'] ?? homeTeam['PTS_PAINT'] ?? 0.0,
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'PTS OUTSIDE',
        (awayTeam['points'] ?? awayTeam['PTS'] ?? 0.0) -
            (awayTeam['freeThrowsMade'] ?? awayTeam['FTM'] ?? 0.0) -
            (awayTeam['pointsInThePaint'] ?? awayTeam['PTS_PAINT'] ?? 0.0),
        (homeTeam['points'] ?? homeTeam['PTS'] ?? 0.0) -
            (homeTeam['freeThrowsMade'] ?? homeTeam['FTM'] ?? 0.0) -
            (homeTeam['pointsInThePaint'] ?? homeTeam['PTS_PAINT'] ?? 0.0),
      )
    ];
  }

  List<Widget> buildReboundingRows() {
    return [
      buildComparisonRow(
          'REB', awayTeam['reboundsTotal'] ?? 0, homeTeam['reboundsTotal'] ?? 0),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
          'OREB', awayTeam['reboundsOffensive'] ?? 0, homeTeam['reboundsOffensive'] ?? 0),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
          'DREB', awayTeam['reboundsDefensive'] ?? 0, homeTeam['reboundsDefensive'] ?? 0),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        'OREB%',
        roundToDecimalPlaces(
            (awayTeam['OREB_PCT'] ??
                    (awayTeam['reboundsOffensive'] /
                        ((awayTeam['reboundsOffensive'] + homeTeam['reboundsDefensive']) == 0
                            ? 1
                            : (awayTeam['reboundsOffensive'] +
                                homeTeam['reboundsDefensive']))) ??
                    0.0) *
                100,
            1),
        roundToDecimalPlaces(
            (homeTeam['OREB_PCT'] ??
                    (homeTeam['reboundsOffensive'] /
                        ((homeTeam['reboundsOffensive'] + awayTeam['reboundsDefensive']) == 0
                            ? 1
                            : (homeTeam['reboundsOffensive'] +
                                awayTeam['reboundsDefensive']))) ??
                    0.0) *
                100,
            1),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'DREB%',
        roundToDecimalPlaces(
            (awayTeam['DREB_PCT'] ??
                    (awayTeam['reboundsDefensive'] /
                        ((homeTeam['reboundsOffensive'] + awayTeam['reboundsDefensive']) == 0
                            ? 1
                            : (homeTeam['reboundsOffensive'] +
                                awayTeam['reboundsDefensive']))) ??
                    0.0) *
                100,
            1),
        roundToDecimalPlaces(
            (homeTeam['DREB_PCT'] ??
                    (homeTeam['reboundsDefensive'] /
                        ((awayTeam['reboundsOffensive'] + homeTeam['reboundsDefensive']) == 0
                            ? 1
                            : (awayTeam['reboundsOffensive'] +
                                homeTeam['reboundsDefensive']))) ??
                    0.0) *
                100,
            1),
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        '2ND Chance PTS',
        awayTeam['pointsSecondChance'] ?? awayTeam['PTS_2ND_CHANCE'] ?? 0.0,
        homeTeam['pointsSecondChance'] ?? homeTeam['PTS_2ND_CHANCE'] ?? 0.0,
      ),
    ];
  }

  List<Widget> buildPassingRows() {
    return [
      buildComparisonRow('AST', awayTeam['assists'] ?? 0, homeTeam['assists'] ?? 0),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
          'AST%', calculateAssistPercentage(awayTeam), calculateAssistPercentage(homeTeam)),
      SizedBox(height: 5.0.r),
      buildComparisonRow('AST / TOV', awayTeam['AST_TOV'] ?? 0, homeTeam['AST_TOV'] ?? 0),
    ];
  }

  double calculateAssistPercentage(dynamic team) {
    int fgm = team['fieldGoalsMade'] ?? 1;
    return roundToDecimalPlaces((team['assists'] ?? 0) / fgm * 100, 1);
  }

  List<Widget> buildDefenseRows() {
    return [
      buildComparisonRow('STL', awayTeam['steals'] ?? 0, homeTeam['steals'] ?? 0),
      SizedBox(height: 5.0.r),
      buildComparisonRow('BLK', awayTeam['blocks'] ?? 0, homeTeam['blocks'] ?? 0),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'FOULS',
        awayTeam['foulsPersonal'] ?? 0,
        homeTeam['foulsPersonal'] ?? 0,
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
          'PTS OFF TOV',
          awayTeam['pointsFromTurnovers'] ?? awayTeam['PTS_OFF_TO'] ?? 0,
          homeTeam['pointsFromTurnovers'] ?? homeTeam['PTS_OFF_TO'] ?? 0),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
          'FASTBREAK PTS',
          awayTeam['pointsFastbreak'] ?? awayTeam['PTS_FB'] ?? 0,
          homeTeam['pointsFastbreak'] ?? homeTeam['PTS_FB'] ?? 0),
    ];
  }

  Widget buildComparisonRow(String statName, dynamic awayValue, dynamic homeValue) {
    return ComparisonRow(
      statName: statName,
      awayTeam: awayValue,
      homeTeam: homeValue,
      awayTeamColor: awayTeamColor,
      homeTeamColor: homeTeamColor,
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

class ComparisonRow extends StatefulWidget {
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
  State<ComparisonRow> createState() => _ComparisonRowState();
}

class _ComparisonRowState extends State<ComparisonRow> {
  bool oneIsBetter = false;
  bool twoIsBetter = false;

  @override
  void initState() {
    super.initState();
    oneIsBetter = (widget.statName.contains('DRTG') ||
            widget.statName == 'FOULS' ||
            widget.statName == 'TOV' ||
            widget.statName == 'TOV%')
        ? widget.awayTeam < widget.homeTeam
        : widget.awayTeam > widget.homeTeam;
    twoIsBetter = (widget.statName.contains('DRTG') ||
            widget.statName == 'FOULS' ||
            widget.statName == 'TOV' ||
            widget.statName == 'TOV%')
        ? widget.homeTeam < widget.awayTeam
        : widget.homeTeam > widget.awayTeam;
  }

  @override
  Widget build(BuildContext context) {
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
                value: widget.awayTeam,
                isHighlighted: oneIsBetter ? true : false,
                color: widget.awayTeamColor,
                isPercentage: widget.statName.contains('%'),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            widget.statName,
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
                value: widget.homeTeam,
                isHighlighted: twoIsBetter ? true : false,
                color: widget.homeTeamColor,
                isPercentage: widget.statName.contains('%'),
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

  StatValue({
    required this.value,
    this.isHighlighted = false,
    required this.color,
    required this.isPercentage,
  }) : super(key: ValueKey(value));

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

    return RepaintBoundary(
      child: Container(
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
      ),
    );
  }
}
