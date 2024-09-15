import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utilities/constants.dart';

class BoxTeamStats extends StatefulWidget {
  final List<dynamic> teams;
  final String homeId;
  final String awayId;
  const BoxTeamStats({
    super.key,
    required this.teams,
    required this.homeId,
    required this.awayId,
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
    setState(() {
      homeTeam = widget.teams[0]['TEAM_ID'].toString() == widget.homeId
          ? widget.teams[0]
          : widget.teams[1];
      awayTeam = widget.teams[0]['TEAM_ID'].toString() == widget.homeId
          ? widget.teams[1]
          : widget.teams[0];

      if (awayTeam.isNotEmpty) {
        awayTeamColor = kTeamColorOpacity.containsKey(awayTeam['TEAM_ABBREVIATION'])
            ? kDarkPrimaryColors.contains(awayTeam['TEAM_ABBREVIATION'])
                ? (kTeamColors[awayTeam['TEAM_ABBREVIATION']]!['secondaryColor']!)
                : (kTeamColors[awayTeam['TEAM_ABBREVIATION']]!['primaryColor']!)
            : kTeamColors['FA']!['primaryColor']!;
      }

      if (homeTeam.isNotEmpty) {
        homeTeamColor = kDarkPrimaryColors.contains(homeTeam['TEAM_ABBREVIATION'])
            ? (kTeamColors[homeTeam['TEAM_ABBREVIATION']]!['secondaryColor']!)
            : (kTeamColors[homeTeam['TEAM_ABBREVIATION']]!['primaryColor']!);
      }
    });
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
    return SliverToBoxAdapter(
      child: Skeletonizer(
        enabled: _isLoading,
        child: homeTeam == null || awayTeam == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sports_basketball,
                      color: Colors.white38,
                      size: 40.0,
                    ),
                    const SizedBox(height: 15.0),
                    Text(
                      'No Games Available',
                      style: kBebasNormal.copyWith(fontSize: 20.0, color: Colors.white54),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Efficiency', style: kBebasBold.copyWith(fontSize: 20.0))
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'PTS',
                            awayTeam: awayTeam['PTS'] ?? 0.0,
                            homeTeam: homeTeam['PTS'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'PER 100',
                            awayTeam: awayTeam['OFF_RATING'] ?? 0.0,
                            homeTeam: homeTeam['OFF_RATING'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'POSSESSIONS',
                            awayTeam: awayTeam['POSS'] ?? 0.0,
                            homeTeam: homeTeam['POSS'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'PACE',
                            awayTeam: awayTeam['PACE'] ?? 0.0,
                            homeTeam: homeTeam['PACE'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'TOV',
                            awayTeam: awayTeam['TO'] ?? 0,
                            homeTeam: homeTeam['TO'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'TOV%',
                            awayTeam: roundToDecimalPlaces(awayTeam['TM_TOV_PCT'] ?? 0.0, 1),
                            homeTeam: roundToDecimalPlaces(homeTeam['TM_TOV_PCT'] ?? 0.0, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Shooting', style: kBebasBold.copyWith(fontSize: 20.0))
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          NonComparisonRow(
                            statName: 'FG',
                            awayTeam: '${awayTeam['FGM'] ?? 0}-${awayTeam['FGA'] ?? 0}',
                            homeTeam: '${homeTeam['FGM'] ?? 0}-${homeTeam['FGA'] ?? 0}',
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'FG%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['FG_PCT'] ?? 0.0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['FG_PCT'] ?? 0.0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          NonComparisonRow(
                            statName: '3P',
                            awayTeam: '${awayTeam['FG3M'] ?? 0}-${awayTeam['FG3A'] ?? 0}',
                            homeTeam: '${homeTeam['FG3M'] ?? 0}-${homeTeam['FG3A'] ?? 0}',
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: '3P%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['FG3_PCT'] ?? 0.0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['FG3_PCT'] ?? 0.0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          NonComparisonRow(
                            statName: 'FT',
                            awayTeam: '${awayTeam['FTM'] ?? 0}-${awayTeam['FTA'] ?? 0}',
                            homeTeam: '${homeTeam['FTM'] ?? 0}-${homeTeam['FTA'] ?? 0}',
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'FT%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['FT_PCT'] ?? 0.0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['FT_PCT'] ?? 0.0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'FT/FGA',
                            awayTeam: roundToDecimalPlaces(
                                (awayTeam['FTM'] / awayTeam['FGA']) ?? 0.0, 2),
                            homeTeam: roundToDecimalPlaces(
                                (homeTeam['FTM'] / homeTeam['FGA']) ?? 0.0, 2),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'EFG%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['EFG_PCT'] ?? 0.0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['EFG_PCT'] ?? 0.0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'TS%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['TS_PCT'] ?? 0.0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['TS_PCT'] ?? 0.0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'PTS IN PAINT',
                            awayTeam: awayTeam['PTS_PAINT'] ?? 0.0,
                            homeTeam: homeTeam['PTS_PAINT'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'PTS OUTSIDE',
                            awayTeam:
                                (awayTeam['PTS'] - awayTeam['FTM'] - awayTeam['PTS_PAINT']) ??
                                    0.0,
                            homeTeam:
                                (homeTeam['PTS'] - homeTeam['FTM'] - homeTeam['PTS_PAINT']) ??
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
                    margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Rebounding', style: kBebasBold.copyWith(fontSize: 20.0))
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'REB',
                            awayTeam: awayTeam['REB'] ?? 0,
                            homeTeam: homeTeam['REB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'OREB',
                            awayTeam: awayTeam['OREB'] ?? 0,
                            homeTeam: homeTeam['OREB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'DREB',
                            awayTeam: awayTeam['DREB'] ?? 0,
                            homeTeam: homeTeam['DREB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'OREB%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['OREB_PCT'] ?? 0.0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['OREB_PCT'] ?? 0.0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'DREB%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['DREB_PCT'] ?? 0.0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['DREB_PCT'] ?? 0.0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: '2ND Chance PTS',
                            awayTeam: awayTeam['PTS_2ND_CHANCE'] ?? 0.0,
                            homeTeam: homeTeam['PTS_2ND_CHANCE'] ?? 0.0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Passing', style: kBebasBold.copyWith(fontSize: 20.0))
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'AST',
                            awayTeam: awayTeam['AST'] ?? 0,
                            homeTeam: homeTeam['AST'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'AST%',
                            awayTeam:
                                roundToDecimalPlaces((awayTeam['AST_PCT'] ?? 0) * 100, 1),
                            homeTeam:
                                roundToDecimalPlaces((homeTeam['AST_PCT'] ?? 0) * 100, 1),
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'AST / TOV',
                            awayTeam: awayTeam['AST_TOV'] ?? 0,
                            homeTeam: homeTeam['AST_TOV'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'AST Ratio',
                            awayTeam: awayTeam['AST_RATIO'] ?? 0,
                            homeTeam: homeTeam['AST_RATIO'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Defense', style: kBebasBold.copyWith(fontSize: 20.0))
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'STL',
                            awayTeam: awayTeam['STL'] ?? 0,
                            homeTeam: homeTeam['STL'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'BLK',
                            awayTeam: awayTeam['BLK'] ?? 0,
                            homeTeam: homeTeam['BLK'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'FOULS',
                            awayTeam: awayTeam['PF'] ?? 0,
                            homeTeam: homeTeam['PF'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 15.0),
                          ComparisonRow(
                            statName: 'PTS OFF TOV',
                            awayTeam: awayTeam['PTS_OFF_TO'] ?? 0,
                            homeTeam: homeTeam['PTS_OFF_TO'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                          const SizedBox(height: 5.0),
                          ComparisonRow(
                            statName: 'FASTBREAK PTS',
                            awayTeam: awayTeam['PTS_FB'] ?? 0,
                            homeTeam: homeTeam['PTS_FB'] ?? 0,
                            awayTeamColor: awayTeamColor,
                            homeTeamColor: homeTeamColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0)
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              awayTeam,
              textAlign: TextAlign.start,
              style: kBebasNormal.copyWith(fontSize: 17.0, color: Colors.grey.shade300),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 16.0),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              homeTeam,
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 17.0, color: Colors.grey.shade300),
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
            style: kBebasNormal.copyWith(fontSize: 16.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: isHighlighted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        isPercentage ? '$value%' : '$value',
        style: isHighlighted && lightColors.containsKey(color)
            ? kBebasNormal.copyWith(fontSize: 18.0, color: lightColors[color])
            : kBebasNormal.copyWith(fontSize: 18.0),
      ),
    );
  }
}
