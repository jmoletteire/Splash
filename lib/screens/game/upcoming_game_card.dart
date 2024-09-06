import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';
import 'package:timezone/timezone.dart';

import 'game_home.dart';

class UpcomingGameCard extends StatefulWidget {
  final Map<String, dynamic> game;
  final int homeTeam;
  final int awayTeam;
  final Location userTZ;

  const UpcomingGameCard(
      {super.key,
      required this.game,
      required this.homeTeam,
      required this.awayTeam,
      required this.userTZ});

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
          style: kBebasNormal.copyWith(fontSize: 15.0, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      case 'Play-In':
        return Text(
          'Play-In Tourney',
          style: kBebasNormal.copyWith(fontSize: 15.0, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      case 'In-Season Tournament':
        return Text(
          'Emirates NBA Cup Final',
          style: kBebasNormal.copyWith(fontSize: 15.0, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      default:
        return const Text(
          '',
          textAlign: TextAlign.center,
        );
    }
  }

  String convertToDate(String dateString, String timeString) {
    bool isDaylightSavingsTime(DateTime dateTime) {
      // Get the current timezone offset
      Duration currentOffset = dateTime.timeZoneOffset;

      // Get the timezone offset for a known date during standard time (e.g., January 1st)
      DateTime standardTime = DateTime(dateTime.year, 1, 1);
      Duration standardOffset = standardTime.timeZoneOffset;

      // If the current offset is different from the standard offset, it's DST
      return currentOffset != standardOffset;
    }

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

    Duration timeZoneOffset = const Duration(hours: 0);

    // Adjust for daylight savings
    if (isDaylightSavingsTime(baseDate)) {
      timeZoneOffset = const Duration(hours: 1);
    }

    // Combine the base date and new time
    DateTime finalDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    ).subtract(timeZoneOffset);

    // Convert to local time zone using the 'timezone' package
    final TZDateTime localDateTime = TZDateTime.from(finalDateTime, widget.userTZ);

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
              gameTime: convertToDate(summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT']),
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
          padding: const EdgeInsets.all(15.0),
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
                        Text(
                          summary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LP',
                          style:
                              kBebasBold.copyWith(fontSize: 14.0, color: Colors.grey.shade300),
                          textAlign: TextAlign.start,
                        ),
                        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != null) ...[
                          const SizedBox(width: 5),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'NBA TV')
                            Icon(
                              Icons.tv_sharp, // TV icon
                              color: Colors.grey.shade300,
                              size: 11.0,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV')
                            SvgPicture.asset(
                              'images/NBA_TV.svg',
                              width: 12.0,
                              height: 12.0,
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
                              ? convertToDate(
                                  summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT'])
                              : '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'].toString()}Q ',
                      style: kBebasNormal.copyWith(
                          fontSize: 15.0,
                          color: summary['GAME_STATUS_TEXT'] == 'Final' ||
                                  summary['LIVE_PERIOD'] == 0
                              ? Colors.grey.shade300
                              : Colors.white),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5.0),

              /// AWAY TEAM ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 0.0),
                      child: kTeamNames.containsKey(widget.awayTeam.toString())
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 26.0),
                              child: Image.asset(
                                'images/NBA_Logos/${widget.awayTeam}.png',
                                fit: BoxFit.contain,
                                width: 26.0,
                                height: 26.0,
                              ),
                            )
                          : const Text(''),
                    ),
                  ),
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
                              Text(
                                kTeamNames[widget.awayTeam.toString()]?[0] ??
                                    awayLinescore['TEAM_NAME'],
                                style: kGameCardTextStyle.copyWith(
                                  color: Colors.white, // Away team lost
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                awayLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle,
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
                                  style: kGameCardTextStyle.copyWith(fontSize: 22.0),
                                ),
                              ),
                              const SizedBox(width: 17.0),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '206.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle,
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
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 0.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 26.0),
                        child: Image.asset(
                          'images/NBA_Logos/${widget.homeTeam}.png',
                          fit: BoxFit.contain,
                          width: 26.0,
                          height: 26.0,
                        ),
                      ),
                    ),
                  ),
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
                              Text(
                                kTeamNames[widget.homeTeam.toString()][0],
                                style: kGameCardTextStyle.copyWith(
                                  color: Colors.white, // Home team lost
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                homeLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle,
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
                                  style: kGameCardTextStyle.copyWith(fontSize: 22.0),
                                ),
                              ),
                              const SizedBox(width: 17.0),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-6.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle,
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
