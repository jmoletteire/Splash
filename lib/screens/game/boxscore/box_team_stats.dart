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
    homeTeam = widget.teams[0];
    awayTeam = widget.teams[1];

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
      buildComparisonRow(
          'PTS', int.parse(awayTeam['Points'] ?? '0'), int.parse(homeTeam['Points'] ?? '0')),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'PER POSS',
        double.parse(awayTeam['Per Poss'] ?? '0.00'),
        double.parse(homeTeam['Per Poss'] ?? '0.00'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'PER SHOT',
        double.parse(awayTeam['Per Shot'] ?? '0.00'),
        double.parse(homeTeam['Per Shot'] ?? '0.00'),
      ),
      SizedBox(height: 15.0.r),
      ComparisonRow(
        statName: 'POSSESSIONS',
        awayTeam: int.parse(awayTeam['Possessions'] ?? '0'),
        homeTeam: int.parse(homeTeam['Possessions'] ?? '0'),
        awayTeamColor: awayTeamColor,
        homeTeamColor: homeTeamColor,
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow('PACE', calculatePace(awayTeam), calculatePace(homeTeam)),
      SizedBox(height: 15.0.r),
      ComparisonRow(
        statName: 'TOV',
        awayTeam: int.parse(awayTeam['Turnovers'] ?? '0'),
        homeTeam: int.parse(homeTeam['Turnovers'] ?? '0'),
        awayTeamColor: awayTeamColor,
        homeTeamColor: homeTeamColor,
      ),
      SizedBox(height: 5.0.r),
      ComparisonRow(
        statName: 'TOV%',
        awayTeam: double.parse(awayTeam['Turnover %'].replaceAll('%', '') ?? '0.0'),
        homeTeam: double.parse(homeTeam['Turnover %'].replaceAll('%', '') ?? '0.0'),
        awayTeamColor: awayTeamColor,
        homeTeamColor: homeTeamColor,
      ),
    ];
  }

  double calculatePace(dynamic team) {
    int possessions = (int.parse(awayTeam['Possessions'] ?? '0') +
            int.parse(homeTeam['Possessions'] ?? '0')) ~/
        2;
    return roundToDecimalPlaces(48 * possessions / (minutes == 0 ? 1 : minutes), 1);
  }

  List<Widget> buildShootingRows() {
    return [
      NonComparisonRow(
        statName: 'FG',
        awayTeam: awayTeam['FG'] ?? '0-0',
        homeTeam: homeTeam['FG'] ?? '0-0',
      ),
      buildComparisonRow(
        'FG%',
        double.parse(awayTeam['FG%'].replaceAll('%', '') ?? '0.0'),
        double.parse(homeTeam['FG%'].replaceAll('%', '') ?? '0.0'),
      ),
      SizedBox(height: 15.0.r),
      NonComparisonRow(
        statName: '3P',
        awayTeam: awayTeam['3P'] ?? '0-0',
        homeTeam: homeTeam['3P'] ?? '0-0',
      ),
      buildComparisonRow(
        '3P%',
        double.parse(awayTeam['3P%'].replaceAll('%', '') ?? '0.0'),
        double.parse(homeTeam['3P%'].replaceAll('%', '') ?? '0.0'),
      ),
      SizedBox(height: 15.0.r),
      NonComparisonRow(
        statName: 'FT',
        awayTeam: awayTeam['FT'] ?? '0-0',
        homeTeam: homeTeam['FT'] ?? '0-0',
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'FT%',
        double.parse(awayTeam['FT%'].replaceAll('%', '') ?? '0.0'),
        double.parse(homeTeam['FT%'].replaceAll('%', '') ?? '0.0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'FT/FGA',
        roundToDecimalPlaces(
            int.parse(awayTeam['FTM'] ?? '0') / int.parse(awayTeam['FGA'] ?? '1'), 2),
        roundToDecimalPlaces(
            int.parse(homeTeam['FTM'] ?? '0') / int.parse(homeTeam['FGA'] ?? '1'), 2),
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        'eFG%',
        double.parse(awayTeam['eFG%'].replaceAll('%', '') ?? '0.0'),
        double.parse(homeTeam['eFG%'].replaceAll('%', '') ?? '0.0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'TS%',
        double.parse(awayTeam['TS%'].replaceAll('%', '') ?? '0.0'),
        double.parse(homeTeam['TS%'].replaceAll('%', '') ?? '0.0'),
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        'PTS IN PAINT',
        int.parse(awayTeam['Points in Paint'] ?? '0'),
        int.parse(homeTeam['Points in Paint'] ?? '0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'PTS OUTSIDE',
        int.parse(awayTeam['Points'] ?? '0') -
            int.parse(awayTeam['FTM'] ?? '0') -
            int.parse(awayTeam['Points in Paint'] ?? '0'),
        int.parse(homeTeam['Points'] ?? '0') -
            int.parse(homeTeam['FTM'] ?? '0') -
            int.parse(homeTeam['Points in Paint'] ?? '0'),
      )
    ];
  }

  List<Widget> buildReboundingRows() {
    return [
      buildComparisonRow(
        'REB',
        int.parse(awayTeam['Rebounds'] ?? '0'),
        int.parse(homeTeam['Rebounds'] ?? '0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'OREB',
        int.parse(awayTeam['Off Rebounds'] ?? '0'),
        int.parse(homeTeam['Off Rebounds'] ?? '0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'DREB',
        int.parse(awayTeam['Def Rebounds'] ?? '0'),
        int.parse(homeTeam['Def Rebounds'] ?? '0'),
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        'OREB%',
        roundToDecimalPlaces(
            int.parse(awayTeam['Off Rebounds'] ?? '0') /
                ((int.parse(awayTeam['Off Rebounds'] ?? '0') +
                            int.parse(homeTeam['Def Rebounds'] ?? '0')) ==
                        0
                    ? 1
                    : (int.parse(awayTeam['Off Rebounds'] ?? '0') +
                        int.parse(homeTeam['Def Rebounds'] ?? '0'))) *
                100,
            1),
        roundToDecimalPlaces(
            int.parse(homeTeam['Off Rebounds'] ?? '0') /
                ((int.parse(homeTeam['Off Rebounds'] ?? '0') +
                            int.parse(awayTeam['Def Rebounds'] ?? '0')) ==
                        0
                    ? 1
                    : (int.parse(homeTeam['Off Rebounds'] ?? '0') +
                        int.parse(awayTeam['Def Rebounds'] ?? '0'))) *
                100,
            1),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'DREB%',
        roundToDecimalPlaces(
            int.parse(awayTeam['Def Rebounds'] ?? '0') /
                ((int.parse(awayTeam['Def Rebounds'] ?? '0') +
                            int.parse(homeTeam['Off Rebounds'] ?? '0')) ==
                        0
                    ? 1
                    : (int.parse(awayTeam['Def Rebounds'] ?? '0') +
                        int.parse(homeTeam['Off Rebounds'] ?? '0'))) *
                100,
            1),
        roundToDecimalPlaces(
            int.parse(homeTeam['Def Rebounds'] ?? '0') /
                ((int.parse(homeTeam['Def Rebounds'] ?? '0') +
                            int.parse(awayTeam['Off Rebounds'] ?? '0')) ==
                        0
                    ? 1
                    : (int.parse(homeTeam['Def Rebounds'] ?? '0') +
                        int.parse(awayTeam['Off Rebounds'] ?? '0'))) *
                100,
            1),
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        '2ND Chance PTS',
        int.parse(awayTeam['2nd Chance Pts'] ?? '0'),
        int.parse(homeTeam['2nd Chance Pts'] ?? '0'),
      ),
    ];
  }

  List<Widget> buildPassingRows() {
    return [
      buildComparisonRow(
        'AST',
        int.parse(awayTeam['Assists'] ?? '0'),
        int.parse(homeTeam['Assists'] ?? '0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'AST%',
        double.parse(awayTeam['Assist %'].replaceAll('%', '') ?? '0.0'),
        double.parse(homeTeam['Assist %'].replaceAll('%', '') ?? '0.0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'AST / TOV',
        double.parse(awayTeam['Assist : Turnover'] ?? '0.0'),
        double.parse(homeTeam['Assist : Turnover'] ?? '0.0'),
      ),
    ];
  }

  List<Widget> buildDefenseRows() {
    return [
      buildComparisonRow(
        'STL',
        int.parse(awayTeam['Steals'] ?? '0'),
        int.parse(homeTeam['Steals'] ?? '0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'BLK',
        int.parse(awayTeam['Blocks'] ?? '0'),
        int.parse(homeTeam['Blocks'] ?? '0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'FOULS',
        int.parse(awayTeam['Fouls'] ?? '0'),
        int.parse(homeTeam['Fouls'] ?? '0'),
      ),
      SizedBox(height: 15.0.r),
      buildComparisonRow(
        'PTS OFF TOV',
        int.parse(awayTeam['Points off Turnovers'] ?? '0'),
        int.parse(homeTeam['Points off Turnovers'] ?? '0'),
      ),
      SizedBox(height: 5.0.r),
      buildComparisonRow(
        'FASTBREAK PTS',
        int.parse(awayTeam['Fast Break Points'] ?? '0'),
        int.parse(homeTeam['Fast Break Points'] ?? '0'),
      ),
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
