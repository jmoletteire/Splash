import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/global_variables.dart';
import 'package:timezone/timezone.dart';

import 'game_home.dart';

class UpcomingGameCard extends StatefulWidget {
  final Map<String, dynamic> game;
  final int homeTeam;
  final int awayTeam;

  const UpcomingGameCard({
    super.key,
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  _UpcomingGameCardState createState() => _UpcomingGameCardState();
}

class _UpcomingGameCardState extends State<UpcomingGameCard> {
  Widget gameTitle(String gameId) {
    String seasonTypeCode = gameId[2];

    Map<String, String> seasonTypes = {
      '1': 'Pre-Season',
      '2': 'Regular Season',
      '4': 'Playoffs',
      '5': 'Play-In',
      '6': 'In-Season Tournament',
    };

    switch (seasonTypes[seasonTypeCode]) {
      case 'Playoffs':
        String gameNum = gameId[9];
        String conf;
        String roundId = gameId[7];

        switch (roundId) {
          case '1':
            conf = int.parse(gameId[8]) < 4 ? 'East' : 'West';
          case '2':
            conf = int.parse(gameId[8]) < 2 ? 'East' : 'West';
          case '3':
            conf = gameId[8] == '0' ? 'East' : 'West';
          default:
            conf = '';
        }

        Map<String, String> poRounds = {
          '1': '1st Round',
          '2': 'Semis',
          '3': 'Conf Finals',
          '4': 'NBA Finals',
        };

        return Text(
          'Game $gameNum - $conf ${poRounds[roundId]}',
          style: kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      case 'Play-In':
        return Text(
          'Play-In Tourney',
          style: kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      case 'In-Season Tournament':
        return Text(
          'Emirates NBA Cup Final',
          style: kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      default:
        return const Text(
          '',
          textAlign: TextAlign.center,
        );
    }
  }

  String adjustTimezone(String dateString, String timeString) {
    // Parse the base date
    DateTime baseDate = DateTime.parse(dateString);

    // Convert 12-hour format to 24-hour format
    bool isPm = timeString.contains("pm");
    List<String> timeParts = timeString.split(" ")[0].split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (isPm && hour != 12) {
      hour += 12;
    } else if (!isPm && hour == 12) {
      hour = 0;
    }

    // Load the EST timezone location
    final Location est = getLocation('America/New_York'); // NBA data uses EST

    // Combine the base date and time in the EST timezone
    final TZDateTime estDateTime =
        TZDateTime(est, baseDate.year, baseDate.month, baseDate.day, hour, minute);

    // Convert to the user's local timezone
    final TZDateTime localDateTime = TZDateTime.from(estDateTime, GlobalTimeZone.location);

    // Format the time in "h:mm a" format
    String formattedTime = DateFormat.jm().format(localDateTime);

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    var summary = widget.game['SUMMARY']['GameSummary'][0];
    var linescore = widget.game['SUMMARY']['LineScore'];

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'] == widget.homeTeam ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[0]['TEAM_ID'] == widget.awayTeam ? linescore[0] : linescore[1];

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameHome(
              gameData: widget.game,
              gameId: summary['GAME_ID'],
              homeId: widget.homeTeam.toString(),
              awayId: widget.awayTeam.toString(),
              gameTime: adjustTimezone(summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT']),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.grey.shade800),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ABC' &&
                            summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ESPN' &&
                            summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'TNT')
                          Text(
                            summary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LP',
                            style: kBebasBold.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade300),
                            textAlign: TextAlign.start,
                          ),
                        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != null) ...[
                          SizedBox(width: 5.0.r),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV')
                            SvgPicture.asset(
                              'images/NBA_TV.svg',
                              width: 10.0.r,
                              height: 10.0.r,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'TNT')
                            SvgPicture.asset(
                              'images/TNT.svg',
                              width: 16.0.r,
                              height: 16.0.r,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN')
                            SvgPicture.asset(
                              'images/ESPN.svg',
                              width: 5.0.r,
                              height: 5.0.r,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ABC')
                            SvgPicture.asset(
                              'images/abc.svg',
                              width: 16.0.r,
                              height: 16.0.r,
                            ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(flex: 3, child: gameTitle(summary['GAME_ID'])),
                  Expanded(
                    child: Text(
                      summary['GAME_STATUS_TEXT'] == 'Final'
                          ? summary['GAME_STATUS_TEXT']
                          : summary['LIVE_PERIOD'] == 0
                              ? adjustTimezone(
                                  summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT'])
                              : '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'].toString()}Q ',
                      style: kBebasNormal.copyWith(
                          fontSize: 14.0.r,
                          color: summary['GAME_STATUS_TEXT'] == 'Final' ||
                                  summary['LIVE_PERIOD'] == 0
                              ? Colors.grey.shade300
                              : Colors.white),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
              SizedBox(height: 3.0.r),

              /// AWAY TEAM ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              kTeamIdToName.containsKey(widget.awayTeam.toString())
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 26.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/${widget.awayTeam}.png',
                                        fit: BoxFit.contain,
                                        width: 26.0.r,
                                        height: 26.0.r,
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 26.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/0.png',
                                        fit: BoxFit.contain,
                                        width: 26.0.r,
                                        height: 26.0.r,
                                      ),
                                    ),
                              SizedBox(width: 10.0.r),
                              Text(
                                kTeamIdToName[widget.awayTeam.toString()]?[0] ??
                                    awayLinescore['TEAM_NAME'],
                                style: kGameCardTextStyle.copyWith(
                                  color: Colors.white, // Away team lost
                                  fontSize: 20.0.r,
                                ),
                              ),
                              SizedBox(width: 4.0.r),
                              Text(
                                awayLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle.copyWith(fontSize: 14.0.r),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(fontSize: 20.0.r),
                                ),
                              ),
                              SizedBox(width: 17.0.r),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '206.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(fontSize: 14.0.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// HOME TEAM ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              kTeamIdToName.containsKey(widget.homeTeam.toString())
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 26.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/${widget.homeTeam}.png',
                                        fit: BoxFit.contain,
                                        width: 26.0.r,
                                        height: 26.0.r,
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 26.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/0.png',
                                        fit: BoxFit.contain,
                                        width: 26.0.r,
                                        height: 26.0.r,
                                      ),
                                    ),
                              SizedBox(width: 10.0.r),
                              Text(
                                kTeamIdToName[widget.homeTeam.toString()][0],
                                style: kGameCardTextStyle.copyWith(
                                  color: Colors.white, // Home team lost
                                  fontSize: 20.0.r,
                                ),
                              ),
                              SizedBox(width: 4.0.r),
                              Text(
                                homeLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle.copyWith(fontSize: 14.0.r),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(fontSize: 20.0.r),
                                ),
                              ),
                              SizedBox(width: 17.0.r),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-6.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(fontSize: 14.0.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
