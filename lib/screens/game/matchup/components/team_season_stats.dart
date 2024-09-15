import 'dart:math';

import 'package:flutter/material.dart';
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
  Map<String, dynamic> homeTeam = {};
  Map<String, dynamic> awayTeam = {};
  Color homeTeamColor = Colors.transparent;
  Color awayTeamColor = Colors.transparent;
  late String season;
  bool _isLoading = false;

  Future<Map<String, dynamic>> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      return teamCache.getTeam(teamId)!;
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      teamCache.addTeam(teamId, fetchedTeam);
      return fetchedTeam;
    }
  }

  Future<void> setValues(String homeId, String awayId) async {
    setState(() {
      _isLoading = true;
    });
    List teams = await Future.wait([
      getTeam(homeId),
      getTeam(awayId),
    ]);
    setState(() {
      homeTeam = teams[0];
      awayTeam = teams[1];

      if (awayTeam.isNotEmpty) {
        awayTeamColor = kDarkPrimaryColors.contains(awayTeam['ABBREVIATION'])
            ? (kTeamColors[awayTeam['ABBREVIATION']]!['secondaryColor']!)
            : (kTeamColors[awayTeam['ABBREVIATION']]!['primaryColor']!);
      }

      if (homeTeam.isNotEmpty) {
        homeTeamColor = kDarkPrimaryColors.contains(homeTeam['ABBREVIATION'])
            ? (kTeamColors[homeTeam['ABBREVIATION']]!['secondaryColor']!)
            : (kTeamColors[homeTeam['ABBREVIATION']]!['primaryColor']!);
      }

      _isLoading = false;
    });

    if (!awayTeam['seasons'].keys.toList().contains(widget.season) ||
        !homeTeam['seasons'].keys.toList().contains(widget.season)) {
      season =
          '${(int.parse(widget.season.substring(0, 4)) - 1).toString()}-${(int.parse(widget.season.substring(5)) - 1).toString()}';
    }
  }

  double roundToDecimalPlaces(double value, int decimalPlaces) {
    num factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  @override
  void initState() {
    super.initState();
    season = widget.season;
    setValues(widget.homeId, widget.awayId);
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: _isLoading,
      child: Card(
        margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 0.0),
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                  ),
                ),
                child: const Text(
                  'Season Stats',
                  style: kBebasBold,
                ),
              ),
              const SizedBox(height: 10.0),
              ComparisonRow(
                statName: 'ORTG',
                awayTeam: roundToDecimalPlaces(
                    awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                            ?['OFF_RATING'] ??
                        0.0,
                    1),
                homeTeam: roundToDecimalPlaces(
                    homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                            ?['OFF_RATING'] ??
                        0.0,
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: 'DRTG',
                awayTeam: roundToDecimalPlaces(
                    awayTeam['seasons']?[season]?['STATS']['REGULAR SEASON']?['ADV']
                            ['DEF_RATING'] ??
                        0.0,
                    1),
                homeTeam: roundToDecimalPlaces(
                    homeTeam['seasons']?[season]?['STATS']['REGULAR SEASON']?['ADV']
                            ['DEF_RATING'] ??
                        0.0,
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: 'NRTG',
                awayTeam: roundToDecimalPlaces(
                    awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                            ['NET_RATING'] ??
                        0.0,
                    1),
                homeTeam: roundToDecimalPlaces(
                    homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                            ['NET_RATING'] ??
                        0.0,
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: 'PACE',
                awayTeam: roundToDecimalPlaces(
                    awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                            ['PACE'] ??
                        0.0,
                    1),
                homeTeam: roundToDecimalPlaces(
                    homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                            ['PACE'] ??
                        0.0,
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 15.0),
              ComparisonRow(
                statName: 'FG%',
                awayTeam: roundToDecimalPlaces(
                    ((awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['BASIC']
                                ?['FG_PCT'] ??
                            0.0) *
                        100),
                    1),
                homeTeam: roundToDecimalPlaces(
                    ((homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['BASIC']
                                ?['FG_PCT'] ??
                            0.0) *
                        100),
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: '3P%',
                awayTeam: roundToDecimalPlaces(
                    ((awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['BASIC']
                                ?['FG3_PCT'] ??
                            0.0) *
                        100),
                    1),
                homeTeam: roundToDecimalPlaces(
                    ((homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['BASIC']
                                ?['FG3_PCT'] ??
                            0.0) *
                        100),
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: 'FT%',
                awayTeam: roundToDecimalPlaces(
                    ((awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['BASIC']
                                ?['FT_PCT'] ??
                            0.0) *
                        100),
                    1),
                homeTeam: roundToDecimalPlaces(
                    ((homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['BASIC']
                                ?['FT_PCT'] ??
                            0.0) *
                        100),
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 15.0),
              ComparisonRow(
                statName: 'EFG%',
                awayTeam: roundToDecimalPlaces(
                    ((awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['EFG_PCT'] ??
                            0.0) *
                        100),
                    1),
                homeTeam: roundToDecimalPlaces(
                    ((homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['EFG_PCT'] ??
                            0.0) *
                        100),
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: 'TS%',
                awayTeam: roundToDecimalPlaces(
                    ((awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['TS_PCT'] ??
                            0.0) *
                        100),
                    1),
                homeTeam: roundToDecimalPlaces(
                    ((homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['TS_PCT'] ??
                            0.0) *
                        100),
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: 'OREB%',
                awayTeam: roundToDecimalPlaces(
                    (awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['OREB_PCT'] ??
                            0.0) *
                        100,
                    1),
                homeTeam: roundToDecimalPlaces(
                    (homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['OREB_PCT'] ??
                            0.0) *
                        100,
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
              const SizedBox(height: 5.0),
              ComparisonRow(
                statName: 'TOV%',
                awayTeam: roundToDecimalPlaces(
                    (awayTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['TM_TOV_PCT'] ??
                            0.0) *
                        100,
                    1),
                homeTeam: roundToDecimalPlaces(
                    (homeTeam['seasons']?[season]?['STATS']?['REGULAR SEASON']?['ADV']
                                ?['TM_TOV_PCT'] ??
                            0.0) *
                        100,
                    1),
                awayTeamColor: awayTeamColor,
                homeTeamColor: homeTeamColor,
              ),
            ],
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
    bool oneIsBetter = (statName.contains('DRTG') || statName == 'FOULS PER 75')
        ? awayTeam < homeTeam
        : awayTeam > homeTeam;
    bool twoIsBetter = (statName.contains('DRTG') || statName == 'FOULS PER 75')
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
      const Color(0xFFFFFFFF): Color(0xFF000000),
      const Color(0xFFFEC524): Color(0xFF0E2240),
      const Color(0xFFFDBB30): Color(0xFF002D62),
      const Color(0xFFED184D): Color(0xFF0B2240),
      const Color(0xFF78BE20): Color(0xFF0B233F),
      const Color(0xFF85714D): Color(0xFF0C2340),
      const Color(0xFFE56020): Color(0xFF1D1160),
      const Color(0xFFC4CED4): Color(0xFF000000),
      const Color(0xFFFCA200): Color(0xFF002B5C),
      const Color(0xFFE31837): Color(0xFF002B5C),
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
            ? kBebasNormal.copyWith(color: lightColors[color])
            : kBebasNormal,
      ),
    );
  }
}
