import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../utilities/constants.dart';

class TeamStatCard extends StatefulWidget {
  const TeamStatCard({
    super.key,
    required this.teamStats,
    required this.selectedSeason,
    required this.selectedSeasonType,
    required this.statGroup,
    required this.perMode,
  });

  final Map<String, dynamic> teamStats;
  final String selectedSeason;
  final String selectedSeasonType;
  final String statGroup;
  final String perMode;

  @override
  _TeamStatCardState createState() => _TeamStatCardState();
}

class _TeamStatCardState extends State<TeamStatCard> {
  bool _isExpanded = true;

  dynamic getValueFromMap(Map<String, dynamic> map, List<String> keys, String stat) {
    dynamic value = map;

    keys = [widget.selectedSeasonType] + keys;

    for (var key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return 0; // Return zero if any key is not found
      }
    }

    return value[stat] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final stats = kTeamStatLabelMap[widget.statGroup] ?? {};

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.fromLTRB(11.0, 0.0, 11.0, 11.0),
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ExpansionPanelList(
            expandedHeaderPadding: EdgeInsets.zero,
            elevation: 0,
            materialGapSize: 0.0,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _isExpanded = isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                canTapOnHeader: true,
                backgroundColor: Colors.transparent,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: Text(
                            widget.statGroup,
                            style: const TextStyle(
                              fontFamily: 'Anton',
                              fontSize: 18.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 15.0),
                  child: Column(
                    children: [
                      /*
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Name',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: 'Anton',
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Anton',
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Rank',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontFamily: 'Anton',
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            SizedBox(width: 5.0),
                          ],
                        ),
                      ),
                      // */
                      for (dynamic stat in stats.keys) ...[
                        if (stat.toString().contains('fill') &&
                            int.parse(widget.selectedSeason.substring(0, 4)) >=
                                int.parse(stats[stat]!['first_available']))
                          const SizedBox(height: 12.0),
                        if (!stat.toString().contains('fill') &&
                            int.parse(widget.selectedSeason.substring(0, 4)) >=
                                int.parse(stats[stat]!['first_available']))
                          const SizedBox(height: 8.0),
                        if (!stat.toString().contains('fill') &&
                            int.parse(widget.selectedSeason.substring(0, 4)) >=
                                int.parse(stats[stat]!['first_available']))
                          StatisticRow(
                            statValue: getValueFromMap(
                              widget.teamStats,
                              stats[stat]?['location'],
                              stats[stat]?[widget.perMode]['nba_name'],
                            ),
                            perMode: widget.perMode,
                            round: stats[stat]!['round']!,
                            convert: stats[stat]!['convert']!,
                            statName: stats[stat]!['splash_name']!,
                            statFullName: stats[stat]!['full_name']!,
                            definition: stats[stat]!['definition']!,
                            formula: stats[stat]!['formula']!,
                            statGroup: widget.statGroup,
                            rank: getValueFromMap(
                              widget.teamStats,
                              stats[stat]?['location'],
                              stats[stat]?[widget.perMode]['rank_nba_name'],
                            ),
                            numTeams: widget.teamStats[widget.selectedSeasonType]['BASIC']
                                ['LEAGUE_TEAMS'],
                          ),
                      ],
                    ],
                  ),
                ),
                isExpanded: _isExpanded,
              ),
            ],
          ),
        ],
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
  final int numTeams;

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
    required this.numTeams,
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
              DismissibleTooltip(
                statFullName: statFullName,
                definition: definition,
                formula: formula,
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
              value = convert == 'true' ? value * 100 : value;
              return Text(
                round == '0'
                    ? (perMode == 'PER_100' &&
                            statName != 'MIN' &&
                            statName != 'GP' &&
                            statName != 'POSS'
                        ? value.toStringAsFixed(1)
                        : value.toStringAsFixed(0))
                    : convert == 'true'
                        ? '${value.toStringAsFixed(int.parse(round))}%'
                        : value.toStringAsFixed(int.parse(round)),
                textAlign: TextAlign.right,
                style: kBebasNormal.copyWith(fontSize: 16.0),
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
            progressColor: getProgressColor(1 - ((rank - 1) / (numTeams - 1))),
            percent: 1 - ((rank - 1) / (numTeams - 1)) < 0
                ? 0
                : 1 - ((rank - 1) / (numTeams - 1)) > 1
                    ? 0
                    : 1 - ((rank - 1) / (numTeams - 1)),
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

class DismissibleTooltip extends StatefulWidget {
  final String statFullName;
  final String definition;
  final String formula;

  const DismissibleTooltip({
    Key? key,
    required this.statFullName,
    required this.definition,
    this.formula = '',
  }) : super(key: key);

  @override
  _DismissibleTooltipState createState() => _DismissibleTooltipState();
}

class _DismissibleTooltipState extends State<DismissibleTooltip> {
  final GlobalKey _tooltipKey = GlobalKey();
  bool _isTooltipVisible = false;

  void _toggleTooltip() {
    setState(() {
      _isTooltipVisible = !_isTooltipVisible;
    });
    if (_isTooltipVisible) {
      final dynamic tooltip = _tooltipKey.currentState;
      tooltip.ensureTooltipVisible();
    } else {
      final dynamic tooltip = _tooltipKey.currentState;
      tooltip.deactivate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTooltip,
      child: Tooltip(
        key: _tooltipKey,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10.0),
        ),
        triggerMode: TooltipTriggerMode.manual,
        showDuration: const Duration(minutes: 2),
        richMessage: TextSpan(
          children: [
            TextSpan(
              text: '${widget.statFullName}\n\n',
              style: const TextStyle(
                color: Colors.white,
                height: 0.9,
                fontSize: 14.0,
                fontFamily: 'Anton',
              ),
            ),
            TextSpan(
              text: widget.definition,
              style: const TextStyle(
                color: Color(0xFFBCBCBC),
                fontSize: 13.0,
                fontFamily: 'Anton',
              ),
            ),
            if (widget.formula.isNotEmpty)
              const TextSpan(
                text: '\n\nFormula: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                  fontFamily: 'Anton',
                ),
              ),
            if (widget.formula.isNotEmpty)
              TextSpan(
                text: widget.formula,
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
    );
  }
}
