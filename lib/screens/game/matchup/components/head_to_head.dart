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
  late final BoxDecoration awayTeamDecoration;
  late final BoxDecoration homeTeamDecoration;
  late final TextStyle awayTeamTextStyle;
  late final TextStyle homeTeamTextStyle;
  late final TextStyle percentageTextStyle;
  late final TextStyle winTextStyle;
  late final Image awayLogo;
  late final Image homeLogo;
  late final int awayTeamWins;
  late final int homeTeamWins;
  late final double awayTeamWinPct;
  late final double homeTeamWinPct;

  @override
  void initState() {
    super.initState();

    // Initialize text styles
    awayTeamTextStyle = kBebasNormal.copyWith(fontSize: 18.0.r);
    homeTeamTextStyle = kBebasNormal.copyWith(fontSize: 18.0.r);
    percentageTextStyle = kBebasNormal.copyWith(fontSize: 13.0.r);
    winTextStyle = kBebasNormal.copyWith(fontSize: 14.0.r);

    awayTeamWins = widget.game['SUMMARY']?['SeasonSeries']?[0]?['HOME_TEAM_LOSSES'] ?? 0;
    homeTeamWins = widget.game['SUMMARY']?['SeasonSeries']?[0]?['HOME_TEAM_WINS'] ?? 0;

    int totalGames = awayTeamWins + homeTeamWins;
    awayTeamWinPct = totalGames == 0 ? 50 : (awayTeamWins / totalGames) * 100;
    homeTeamWinPct = totalGames == 0 ? 50 : (homeTeamWins / totalGames) * 100;

    Color homeColor =
        kTeamColors[kTeamIdToName[widget.homeId]?[1] ?? 'FA']?['primaryColor'] ?? Colors.blue;
    Color awayColor =
        kTeamColors[kTeamIdToName[widget.awayId]?[1] ?? 'FA']?['primaryColor'] ?? Colors.blue;

    // Initialize decorations
    awayTeamDecoration = BoxDecoration(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        bottomLeft: Radius.circular(20.0),
      ),
      color: awayTeamWins == 0 ? homeColor : awayColor,
    );

    homeTeamDecoration = BoxDecoration(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      color: homeTeamWins == 0 ? awayColor : homeColor,
    );

    awayLogo = Image.asset(
        'images/NBA_Logos/${kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0'}.png',
        width: (kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0') == '0'
            ? 12.0.r
            : 18.0.r);
    homeLogo = Image.asset('images/NBA_Logos/${widget.homeId}.png', width: 18.0.r);
  }

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
              awayTeamWins: awayTeamWins,
              homeTeamWins: homeTeamWins,
              awayTeamWinPct: awayTeamWinPct,
              homeTeamWinPct: homeTeamWinPct,
              awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
              homeId: widget.homeId,
              awayTeam: widget.awayAbbr,
              homeTeam: widget.homeAbbr,
              awayLogo: awayLogo,
              homeLogo: homeLogo,
              awayTeamDecoration: awayTeamDecoration,
              homeTeamDecoration: homeTeamDecoration,
              awayTeamTextStyle: awayTeamTextStyle,
              homeTeamTextStyle: homeTeamTextStyle,
              percentageTextStyle: percentageTextStyle,
              winTextStyle: winTextStyle,
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
  final double awayTeamWinPct;
  final double homeTeamWinPct;
  final String awayId;
  final String homeId;
  final String awayTeam;
  final String homeTeam;
  final Image awayLogo;
  final Image homeLogo;
  final BoxDecoration awayTeamDecoration;
  final BoxDecoration homeTeamDecoration;
  final TextStyle awayTeamTextStyle;
  final TextStyle homeTeamTextStyle;
  final TextStyle percentageTextStyle;
  final TextStyle winTextStyle;

  ComparisonBar({
    required this.awayTeamWins,
    required this.homeTeamWins,
    required this.awayTeamWinPct,
    required this.homeTeamWinPct,
    required this.awayId,
    required this.homeId,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayLogo,
    required this.homeLogo,
    required this.awayTeamDecoration,
    required this.homeTeamDecoration,
    required this.awayTeamTextStyle,
    required this.homeTeamTextStyle,
    required this.percentageTextStyle,
    required this.winTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Now you can use the precomputed decorations and text styles directly
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(awayTeam, style: awayTeamTextStyle),
                SizedBox(width: 5.0.r),
                awayLogo,
              ],
            ),
            Text('SERIES', style: kBebasBold.copyWith(fontSize: 15.0.r)),
            Row(
              children: [
                homeLogo,
                SizedBox(width: 5.0.r),
                Text(homeTeam, style: homeTeamTextStyle),
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
                    flex: awayTeamWinPct.toInt(),
                    child: Container(
                      height: 20.0.r,
                      decoration: awayTeamDecoration,
                      child: Center(
                        child: Text(
                          awayTeamWinPct == 0
                              ? '    '
                              : '${awayTeamWinPct.toStringAsFixed(1)}%',
                          style: percentageTextStyle,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: homeTeamWinPct.toInt(),
                    child: Container(
                      height: 20.0.r,
                      decoration: homeTeamDecoration,
                      child: Center(
                        child: Text(
                          homeTeamWinPct == 0
                              ? '    '
                              : '${homeTeamWinPct.toStringAsFixed(1)}%',
                          style: percentageTextStyle,
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
            Text(awayTeamWins == 1 ? '$awayTeamWins WIN' : '$awayTeamWins WINS',
                style: winTextStyle),
            Text(homeTeamWins == 1 ? '$homeTeamWins WIN' : '$homeTeamWins WINS',
                style: winTextStyle),
          ],
        ),
      ],
    );
  }
}
