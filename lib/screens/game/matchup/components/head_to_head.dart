import 'package:flutter/material.dart';

import '../../../../utilities/constants.dart';

class H2H extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const H2H({super.key, required this.game, required this.homeId, required this.awayId});

  @override
  State<H2H> createState() => _H2HState();
}

class _H2HState extends State<H2H> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Column(
          children: [
            ComparisonBar(
              awayTeamWins: widget.game['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_LOSSES'],
              homeTeamWins: widget.game['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_WINS'],
              awayId: widget.awayId,
              homeId: widget.homeId,
              awayTeam: kTeamNames[widget.awayId][1],
              homeTeam: kTeamNames[widget.homeId][1],
              awayTeamColor: kTeamColors[kTeamNames[widget.awayId][1]]!['primaryColor']!,
              homeTeamColor: kTeamColors[kTeamNames[widget.homeId][1]]!['primaryColor']!,
            ),
          ],
        ),
      ),
    );
  }
}

class ComparisonBar extends StatelessWidget {
  final int awayTeamWins;
  final int homeTeamWins;
  final String awayId;
  final String homeId;
  final String awayTeam;
  final String homeTeam;
  final Color awayTeamColor;
  final Color homeTeamColor;

  ComparisonBar({
    required this.awayTeamWins,
    required this.homeTeamWins,
    required this.awayId,
    required this.homeId,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayTeamColor,
    required this.homeTeamColor,
  });

  @override
  Widget build(BuildContext context) {
    final int totalValue = awayTeamWins + homeTeamWins;
    final double awayTeamPercentage = awayTeamWins / totalValue;
    final double homeTeamPercentage = homeTeamWins / totalValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(awayTeam, style: kBebasNormal),
                const SizedBox(width: 5.0),
                Image.asset('images/NBA_Logos/${awayId}.png', width: 18.0),
              ],
            ),
            Text('SERIES', style: kBebasBold.copyWith(fontSize: 17.0)),
            Row(
              children: [
                Image.asset('images/NBA_Logos/${homeId}.png', width: 18.0),
                const SizedBox(width: 5.0),
                Text(homeTeam, style: kBebasNormal),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Stack(
          children: [
            Positioned(
              child: Row(
                children: [
                  Expanded(
                    flex: (awayTeamPercentage * 100).toInt(),
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        ),
                        color: awayTeamPercentage > 0 ? awayTeamColor : homeTeamColor,
                      ),
                      child: Center(
                        child: Text(
                          awayTeamPercentage > 0
                              ? '${(awayTeamPercentage * 100).toStringAsFixed(1)}%'
                              : '    ',
                          style: kBebasNormal.copyWith(fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (homeTeamPercentage * 100).toInt(),
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                        color: homeTeamPercentage > 0 ? homeTeamColor : awayTeamColor,
                      ),
                      child: Center(
                        child: Text(
                          homeTeamPercentage > 0
                              ? '${(homeTeamPercentage * 100).toStringAsFixed(1)}%'
                              : '    ',
                          style: kBebasNormal.copyWith(fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                awayTeamWins == 1
                    ? '${awayTeamWins.toStringAsFixed(0)} WIN'
                    : '${awayTeamWins.toStringAsFixed(0)} WINS',
                style: kBebasNormal.copyWith(fontSize: 16.0)),
            Text(
                homeTeamWins == 1
                    ? '${homeTeamWins.toStringAsFixed(0)} WIN'
                    : '${homeTeamWins.toStringAsFixed(0)} WINS',
                style: kBebasNormal.copyWith(fontSize: 16.0)),
          ],
        ),
      ],
    );
  }
}
