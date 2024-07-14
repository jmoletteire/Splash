import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../utilities/constants.dart';

class PlayerStatCard extends StatelessWidget {
  const PlayerStatCard({
    super.key,
    required this.playerStats,
    required this.selectedSeason,
    required this.selectedSeasonType,
    required this.statGroup,
    required this.perMode,
  });

  final Map<String, dynamic> playerStats;
  final String selectedSeason;
  final String selectedSeasonType;
  final String statGroup;
  final String perMode;

  dynamic getValueFromMap(
      Map<String, dynamic> map, List<String> keys, String stat) {
    dynamic value = map;

    keys = [selectedSeasonType] + keys;

    for (var key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return 0; // Return null if any key is not found
      }
    }

    return value[stat] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final stats = kPlayerStatLabelMap[statGroup] ?? {};

    return Card(
      margin: const EdgeInsets.fromLTRB(11.0, 0.0, 11.0, 11.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 10,
                  child: Text(
                    statGroup,
                    style: const TextStyle(
                      fontFamily: 'Anton',
                      fontSize: 18.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Anton',
                      fontSize: 13.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            for (dynamic stat in stats.keys) ...[
              if (stat.toString().contains('fill') &&
                  int.parse(selectedSeason.substring(0, 4)) >=
                      int.parse(stats[stat]!['first_available']))
                const SizedBox(height: 12.0),
              if (!stat.toString().contains('fill') &&
                  int.parse(selectedSeason.substring(0, 4)) >=
                      int.parse(stats[stat]!['first_available']))
                const SizedBox(height: 8.0),
              if (!stat.toString().contains('fill') &&
                  int.parse(selectedSeason.substring(0, 4)) >=
                      int.parse(stats[stat]!['first_available']))
                StatisticRow(
                  statValue: stats[stat]?['convert'] == 'true'
                      ? getValueFromMap(
                            playerStats,
                            stats[stat]?['location'],
                            stats[stat]?[perMode]['nba_name'],
                          ) *
                          100
                      : getValueFromMap(
                          playerStats,
                          stats[stat]?['location'],
                          stats[stat]?[perMode]['nba_name'],
                        ),
                  perMode: perMode,
                  round: stats[stat]!['round']!,
                  convert: stats[stat]!['convert']!,
                  statName: stats[stat]!['splash_name']!,
                  statFullName: stats[stat]!['full_name']!,
                  definition: stats[stat]!['definition']!,
                  formula: stats[stat]!['formula']!,
                  statGroup: statGroup,
                  rank: getValueFromMap(
                    playerStats,
                    stats[stat]?['location'],
                    stats[stat]?[perMode]['rank_nba_name'],
                  ),
                  numPlayers: playerStats[selectedSeasonType]['BASIC']
                      ['NUM_PLAYERS'],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatisticRow extends StatelessWidget {
  final num statValue;
  final String perMode;
  final String round;
  final String convert;
  final String statName;
  final String statFullName;
  final String definition;
  final String formula;
  final String statGroup;
  final int rank;
  final int numPlayers;

  const StatisticRow({
    super.key,
    required this.statValue,
    required this.perMode,
    required this.round,
    required this.convert,
    required this.statName,
    required this.statFullName,
    required this.definition,
    required this.formula,
    required this.statGroup,
    required this.rank,
    required this.numPlayers,
  });

  Color getProgressColor(double percentile) {
    if (percentile < 1 / 3) {
      return const Color(0xDFFF3333);
    }
    if (percentile > 2 / 3) {
      return const Color(0xBB00FF6F);
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  statName,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 12.5,
                    letterSpacing: 0.0,
                    color: Color(0xFFCFCFCF),
                  ),
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              Tooltip(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10.0)),
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(minutes: 2),
                richMessage: TextSpan(
                  children: [
                    TextSpan(
                      text: '$statFullName\n\n',
                      style: const TextStyle(
                        color: Colors.white,
                        height: 0.9,
                        fontSize: 14.0,
                        fontFamily: 'Anton',
                      ),
                    ),
                    TextSpan(
                      text: definition,
                      style: const TextStyle(
                        color: Color(0xFFBCBCBC),
                        fontSize: 13.0,
                        fontFamily: 'Anton',
                      ),
                    ),
                    if (formula != '')
                      const TextSpan(
                        text: '\n\nFormula: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontFamily: 'Anton',
                        ),
                      ),
                    if (formula != '')
                      TextSpan(
                        text: formula,
                        style: const TextStyle(
                          color: Color(0xFFBCBCBC),
                          fontSize: 13.0,
                          fontFamily: 'Anton',
                        ),
                      ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 15.0,
                ),
              ),
            ],
          ),
        ),

        /// Value
        Expanded(
          flex: 2,
          child: TweenAnimationBuilder<num>(
            tween: Tween(
              begin: 0,
              end: statValue,
            ),
            duration: const Duration(milliseconds: 250),
            builder: (BuildContext context, num value, Widget? child) {
              return Text(
                round == '0'
                    ? (perMode == 'PER_75' &&
                            statName != 'MIN' &&
                            statName != 'GP' &&
                            statName != 'POSS'
                        ? value.toStringAsFixed(1)
                        : value.toStringAsFixed(0))
                    : convert == 'true'
                        ? '${value.toStringAsFixed(int.parse(round))}%'
                        : value.toStringAsFixed(int.parse(round)),
                textAlign: TextAlign.right,
                style: kBebasWhite.copyWith(fontSize: 16.0),
              );
            },
          ),
        ),
        const SizedBox(width: 5.0),

        /// Horizontal bar percentile (full == 100th, empty == 0th)
        Expanded(
          flex: 4,
          child: LinearPercentIndicator(
            lineHeight: 10.0,
            backgroundColor: const Color(0xFF444444),
            progressColor:
                getProgressColor(1 - ((rank - 1) / (numPlayers - 1))),
            percent: 1 - ((rank - 1) / (numPlayers - 1)) < 0
                ? 0
                : 1 - ((rank - 1) / (numPlayers - 1)),
            barRadius: const Radius.circular(10.0),
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 400,
          ),
        ),

        /// League rank
        Expanded(
          flex: 1,
          child: TweenAnimationBuilder<int>(
            tween: IntTween(
              begin: 0,
              end: rank,
            ),
            duration: const Duration(milliseconds: 250),
            builder: (BuildContext context, num value, Widget? child) {
              return Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: kBebasNormal.copyWith(fontSize: 16.0),
              );
            },
          ),
        ),
      ],
    );
  }
}
