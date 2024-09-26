import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utilities/constants.dart';

class H2H extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  final String homeAbbr;
  final String awayAbbr;

  const H2H({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
    required this.homeAbbr,
    required this.awayAbbr,
  });

  @override
  State<H2H> createState() => _H2HState();
}

class _H2HState extends State<H2H> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
        child: Column(
          children: [
            ComparisonBar(
              awayTeamWins: widget.game['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_LOSSES'],
              homeTeamWins: widget.game['SUMMARY']['SeasonSeries'][0]['HOME_TEAM_WINS'],
              awayId: widget.awayId,
              homeId: widget.homeId,
              awayTeam: widget.awayAbbr,
              homeTeam: widget.homeAbbr,
              awayTeamColor: kTeamColors[kTeamIdToName[widget.awayId][1]]!['primaryColor']!,
              homeTeamColor: kTeamColors[kTeamIdToName[widget.homeId][1]]!['primaryColor']!,
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
                Text(awayTeam, style: kBebasNormal.copyWith(fontSize: 18.0.r)),
                SizedBox(width: 5.0.r),
                Image.asset('images/NBA_Logos/${awayId}.png',
                    width: awayId == '0' ? 12.0.r : 18.0.r),
              ],
            ),
            Text('SERIES', style: kBebasBold.copyWith(fontSize: 15.0.r)),
            Row(
              children: [
                Image.asset('images/NBA_Logos/${homeId}.png', width: 18.0.r),
                SizedBox(width: 5.0.r),
                Text(homeTeam, style: kBebasNormal.copyWith(fontSize: 18.0.r)),
              ],
            ),
          ],
        ),
        SizedBox(height: 6.0.r),
        Stack(
          children: [
            Positioned(
              child: Row(
                children: [
                  Expanded(
                    flex: (awayTeamPercentage * 100).toInt(),
                    child: Container(
                      height: 20.0.r,
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
                          style: kBebasNormal.copyWith(fontSize: 13.0.r),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (homeTeamPercentage * 100).toInt(),
                    child: Container(
                      height: 20.0.r,
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
                          style: kBebasNormal.copyWith(fontSize: 13.0.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6.0.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                awayTeamWins == 1
                    ? '${awayTeamWins.toStringAsFixed(0)} WIN'
                    : '${awayTeamWins.toStringAsFixed(0)} WINS',
                style: kBebasNormal.copyWith(fontSize: 14.0.r)),
            Text(
                homeTeamWins == 1
                    ? '${homeTeamWins.toStringAsFixed(0)} WIN'
                    : '${homeTeamWins.toStringAsFixed(0)} WINS',
                style: kBebasNormal.copyWith(fontSize: 14.0.r)),
          ],
        ),
      ],
    );
  }
}
