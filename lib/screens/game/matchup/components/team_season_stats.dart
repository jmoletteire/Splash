import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utilities/constants.dart';
import '../../../../utilities/team.dart';
import '../../../team/team_cache.dart';

class TeamSeasonStats extends StatefulWidget {
  final String season;
  final String homeId;
  final String awayId;

  const TeamSeasonStats({
    super.key,
    required this.season,
    required this.homeId,
    required this.awayId,
  });

  @override
  State<TeamSeasonStats> createState() => _TeamSeasonStatsState();
}

class _TeamSeasonStatsState extends State<TeamSeasonStats> {
  List<Widget> statRows = [];
  Map<String, dynamic> homeTeam = {};
  Map<String, dynamic> awayTeam = {};
  Color homeTeamColor = Colors.transparent;
  Color awayTeamColor = Colors.transparent;
  late String season;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    season = widget.season;
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> teams = await Future.wait([
        getTeam(widget.homeId),
        getTeam(widget.awayId),
      ]);

      initializeTeamData(teams[0], teams[1]);
      updateSeasonIfNeeded();
    } catch (e) {
      handleErrorState();
    }
  }

  Future<Map<String, dynamic>> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    return teamCache.containsTeam(teamId)
        ? teamCache.getTeam(teamId)!
        : await fetchAndCacheTeam(teamCache, teamId);
  }

  Future<Map<String, dynamic>> fetchAndCacheTeam(TeamCache cache, String teamId) async {
    try {
      var teamData = await Team().getTeam(teamId);
      cache.addTeam(teamId, teamData);
      return teamData;
    } catch (e) {
      return {'error': 'not found'};
    }
  }

  void initializeTeamData(Map<String, dynamic> home, Map<String, dynamic> away) {
    setState(() {
      homeTeam = home;
      awayTeam = away;
      homeTeamColor = getTeamColor(home);
      awayTeamColor = getTeamColor(away);
      statRows = buildStatRows();
      _isLoading = false;
    });
  }

  void updateSeasonIfNeeded() {
    bool seasonNotStarted =
        (awayTeam['SEASONS']?[season]?['GP'] == 0 || homeTeam['SEASONS']?[season]?['GP'] == 0);

    if (!awayTeam['SEASONS'].containsKey(season) ||
        !homeTeam['SEASONS'].containsKey(season) ||
        seasonNotStarted) {
      setState(() {
        season = getPreviousSeason(season);
      });
    }
  }

  String getPreviousSeason(String currentSeason) {
    int startYear = int.parse(currentSeason.substring(0, 4)) - 1;
    int endYear = int.parse(currentSeason.substring(5)) - 1;
    return '$startYear-$endYear';
  }

  Color getTeamColor(Map<String, dynamic>? team) {
    String abbreviation = team?['ABBREVIATION'] ?? 'FA';
    return kDarkPrimaryColors.contains(abbreviation)
        ? (kTeamColors[abbreviation]?['secondaryColor'] ?? Colors.blue)
        : (kTeamColors[abbreviation]?['primaryColor'] ?? Colors.blue);
  }

  void handleErrorState() {
    setState(() {
      homeTeam = {};
      awayTeam = {};
      homeTeamColor = Colors.transparent;
      awayTeamColor = Colors.transparent;
      _isLoading = false;
    });
  }

  double roundToDecimalPlaces(double value, int decimalPlaces) {
    num factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  Widget buildHeaderRow() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
        ),
      ),
      child: Text(
        'Season Stats',
        style: kBebasBold.copyWith(fontSize: 16.0.r),
      ),
    );
  }

  List<Widget> buildStatRows() {
    return [
      buildHeaderRow(),
      SizedBox(height: 10.0.r),
      buildComparisonRow('NRTG'),
      SizedBox(height: 5.0.r),
      buildComparisonRow('ORTG'),
      SizedBox(height: 5.0.r),
      buildComparisonRow('DRTG'),
      SizedBox(height: 5.0.r),
      buildComparisonRow('PACE'),
      SizedBox(height: 15.0.r),
      buildComparisonRow('FG%', isPercentage: true),
      SizedBox(height: 5.0.r),
      buildComparisonRow('3P%', isPercentage: true),
      SizedBox(height: 5.0.r),
      buildComparisonRow('FT%', isPercentage: true),
      SizedBox(height: 15.0.r),
      buildComparisonRow('eFG%', isPercentage: true),
      SizedBox(height: 5.0.r),
      buildComparisonRow('TS%', isPercentage: true),
      SizedBox(height: 5.0.r),
      buildComparisonRow('OREB%', isPercentage: true),
      SizedBox(height: 5.0.r),
      buildComparisonRow('TOV%', isPercentage: true),
    ];
  }

  Widget buildComparisonRow(String statKey, {bool isPercentage = false}) {
    Map<String, dynamic> awaySeasonStats =
        awayTeam['SEASONS']?[season]?['STATS']?['REGULAR SEASON'] ?? {};
    Map<String, dynamic> homeSeasonStats =
        homeTeam['SEASONS']?[season]?['STATS']?['REGULAR SEASON'] ?? {};
    return ComparisonRow(
      statName: statKey,
      awayTeam: roundToDecimalPlaces(
          ((double.parse(awaySeasonStats[statKey]?['Totals']?['Value'].toString() ?? '0.0')) *
              (isPercentage ? 100 : 1)),
          1),
      homeTeam: roundToDecimalPlaces(
          ((double.parse(homeSeasonStats[statKey]?['Totals']?['Value'].toString() ?? '0.0')) *
              (isPercentage ? 100 : 1)),
          1),
      awayRank: int.parse(awaySeasonStats[statKey]?['Totals']?['Rank'].toString() ?? '0'),
      homeRank: int.parse(homeSeasonStats[statKey]?['Totals']?['Rank'] ?? '0'),
      awayTeamColor: awayTeamColor,
      homeTeamColor: homeTeamColor,
      isPercentage: isPercentage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: _isLoading,
      child: Card(
        margin: EdgeInsets.fromLTRB(11.0.r, 0.0.r, 11.0.r, 0.0.r),
        color: Colors.grey.shade900,
        child: Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Column(
            children: statRows,
          ),
        ),
      ),
    );
  }
}

class ComparisonRow extends StatelessWidget {
  const ComparisonRow({
    super.key,
    required this.statName,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayRank,
    required this.homeRank,
    required this.isPercentage,
    this.awayTeamColor = Colors.transparent,
    this.homeTeamColor = Colors.transparent,
  });

  final String statName;
  final dynamic awayTeam;
  final dynamic homeTeam;
  final dynamic awayRank;
  final dynamic homeRank;
  final bool isPercentage;
  final Color awayTeamColor;
  final Color homeTeamColor;

  @override
  Widget build(BuildContext context) {
    bool oneIsBetter =
        (statName.contains('DRTG') || statName == 'FOULS PER 75' || statName.contains('TOV'))
            ? awayTeam < homeTeam
            : awayTeam > homeTeam;
    bool twoIsBetter =
        (statName.contains('DRTG') || statName == 'FOULS PER 75' || statName.contains('TOV'))
            ? homeTeam < awayTeam
            : homeTeam > awayTeam;

    String getRank(int teamRank) {
      switch (teamRank) {
        case 0:
          return '';
        case 1:
          return '${teamRank}st';
        case 2:
          return '${teamRank}nd';
        case 3:
          return '${teamRank}rd';
        case 21:
          return '${teamRank}st';
        case 22:
          return '${teamRank}nd';
        case 23:
          return '${teamRank}rd';
        default:
          return '${teamRank}th';
      }
    }

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
                isPercentage: isPercentage,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  getRank(awayRank),
                  textAlign: TextAlign.end,
                  style: kBebasNormal.copyWith(
                    fontSize: 12.5.r,
                    color: awayRank < 11
                        ? Colors.green
                        : awayRank < 21
                            ? Colors.orangeAccent
                            : Colors.redAccent,
                  ),
                ),
              ),
              SizedBox(width: 15.0.r),
              Expanded(
                child: Text(
                  statName,
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(fontSize: 14.0.r),
                ),
              ),
              SizedBox(width: 15.0.r),
              Expanded(
                child: Text(
                  getRank(homeRank),
                  style: kBebasNormal.copyWith(
                    fontSize: 12.5.r,
                    color: homeRank < 11
                        ? Colors.green
                        : homeRank < 21
                            ? Colors.orangeAccent
                            : Colors.redAccent,
                  ),
                ),
              ),
            ],
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
                isPercentage: isPercentage,
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
