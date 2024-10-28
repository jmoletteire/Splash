import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';
import 'package:timezone/timezone.dart';

import '../../utilities/global_variables.dart';
import 'game_home.dart';

class GameCard extends StatefulWidget {
  final Map<String, dynamic> game;
  final int homeTeam;
  final int awayTeam;

  const GameCard({
    super.key,
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
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
    Map<String, dynamic> odds = {};
    bool _isLive = false;

    try {
      if (summary['GAME_STATUS_ID'] != 1 &&
          widget.game['ODDS']?['LIVE'].containsKey('26338')) {
        odds = widget.game['ODDS']?['LIVE']?['26338'];
        _isLive = true;
      } else {
        odds = widget.game['ODDS']?['BOOK']?['18186'];
      }
    } catch (e) {
      odds = {};
    }

    String spread = '';
    String overUnder = '';

    try {
      double raw = double.parse(odds['oddstypes'][_isLive ? '168' : '4']['hcp']['value']);
      if (raw > 0) {
        spread = '+${raw.toStringAsFixed(1)}';
      } else {
        spread = raw.toStringAsFixed(1);
      }
    } catch (e) {
      spread = '';
    }

    try {
      double raw = double.parse(odds['oddstypes'][_isLive ? '18' : '3']['hcp']['value']);
      overUnder = raw.toStringAsFixed(1);
    } catch (e) {
      overUnder = '';
    }

    String broadcast = summary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LP';

    String getGameTime() {
      if (widget.game.containsKey('BOXSCORE')) {
        if (widget.game['BOXSCORE']['gameStatusText'] == 'pregame') {
          return 'Pregame';
        }
      }
      switch (summary['GAME_STATUS_ID']) {
        case 1:
          // Upcoming
          if (summary['GAME_STATUS_TEXT'] == 'Cancelled') {
            return summary['GAME_STATUS_TEXT'];
          }
          return adjustTimezone(summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT']);
        case 2:
          // End Quarter
          if (summary['LIVE_PC_TIME'] == ":0.0" || summary['LIVE_PC_TIME'] == "     ") {
            switch (summary['LIVE_PERIOD']) {
              case 1:
                return 'End 1Q';
              case 2:
                return 'HALF';
              case 3:
                return 'End 3Q';
              case 4:
                return 'Final';
              case 5:
                return 'Final/OT';
              default:
                return 'Final/${summary['LIVE_PERIOD'] - 4}OT';
            }
          } else {
            // Game in-progress
            if (summary['LIVE_PERIOD'] <= 4) {
              return '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'].toString()}Q ';
            } else if (summary['LIVE_PERIOD'] == 5) {
              return '${summary['LIVE_PC_TIME'].toString()} OT';
            } else {
              return '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'] - 4}OT';
            }
          }
        case 3:
          // Game Final
          switch (summary['LIVE_PERIOD']) {
            case 4:
              return 'Final';
            case 5:
              return 'Final/OT';
            default:
              return 'Final/${summary['LIVE_PERIOD'] - 4}OT';
          }
        default:
          return '';
      }
    }

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'] == widget.homeTeam ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[1]['TEAM_ID'] == widget.homeTeam ? linescore[0] : linescore[1];

    String status = getGameTime();

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameHome(
              gameData: widget.game,
              gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
              homeId: widget.homeTeam.toString(),
              awayId: widget.awayTeam.toString(),
              gameDate:
                  widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'].substring(0, 10),
              gameTime:
                  summary['GAME_STATUS_ID'] == 1 && summary['GAME_STATUS_TEXT'] != 'Cancelled'
                      ? adjustTimezone(summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT'])
                      : summary['GAME_STATUS_TEXT'] == 'Cancelled'
                          ? 'Cancelled'
                          : null,
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
                            broadcast,
                            style: kBebasBold.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade300),
                            textAlign: TextAlign.start,
                          ),
                        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != null) ...[
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV' ||
                              summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN2' ||
                              summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN/ESPN2')
                            SizedBox(width: 3.0.r),
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
                              width: 7.0.r,
                              height: 7.0.r,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN2' ||
                              summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN/ESPN2')
                            SvgPicture.asset(
                              'images/ESPN_E.svg',
                              width: 9.0.r,
                              height: 9.0.r,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if ((summary['GAME_STATUS_ID'] == 1 && status == 'Pregame') ||
                            summary['GAME_STATUS_ID'] == 2)
                          Container(
                            width: 4.0.r, // Size of the dot
                            height: 4.0.r,
                            decoration: BoxDecoration(
                              color: status == 'Pregame'
                                  ? Colors.orangeAccent
                                  : const Color(0xFF55F86F),
                              shape: BoxShape.circle, // Circular shape
                            ),
                          ),
                        if ((summary['GAME_STATUS_ID'] == 1 && status == 'Pregame') ||
                            summary['GAME_STATUS_ID'] == 2)
                          SizedBox(width: 3.0.r),
                        Text(
                          status,
                          style: kBebasNormal.copyWith(
                              fontSize: 14.0.r,
                              color: summary['GAME_STATUS_ID'] != 2 // Game NOT in-progress
                                  ? Colors.grey.shade300
                                  : Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 5.0.r),

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
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/${widget.awayTeam}.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/0.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    ),
                              SizedBox(width: 10.0.r),
                              Text(
                                kTeamIdToName[widget.awayTeam.toString()]?[0] ??
                                    awayLinescore['TEAM_NICKNAME'] ??
                                    awayLinescore['TEAM_NAME'] ??
                                    'INT\'L',
                                style: kGameCardTextStyle.copyWith(
                                  color: summary['GAME_STATUS_ID'] != 3
                                      ? Colors.white // Game upcoming or in-progress
                                      : (awayLinescore['PTS'] ?? 0) >
                                                  (homeLinescore['PTS'] ?? 0) &&
                                              summary['GAME_STATUS_ID'] == 3
                                          ? Colors.white // Away team won
                                          : Colors.grey, // Away team lost
                                  fontSize: 20.0.r,
                                ),
                              ),
                              SizedBox(width: 4.0.r),
                              Text(
                                awayLinescore['TEAM_WINS_LOSSES'] ?? '0-0',
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
                                  awayLinescore['PTS'] == null || homeLinescore['PTS'] == null
                                      ? ''
                                      : awayLinescore['PTS'].toString(),
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(
                                    color: summary['GAME_STATUS_ID'] != 3
                                        ? Colors.white // Game upcoming or in-progress
                                        : (awayLinescore['PTS'] ?? 0) >
                                                    (homeLinescore['PTS'] ?? 0) &&
                                                summary['GAME_STATUS_ID'] == 3
                                            ? Colors.white // Away team won
                                            : Colors.grey, // Away team lost
                                    fontSize: 20.0.r,
                                  ),
                                ),
                              ),
                              if (odds.isNotEmpty) SizedBox(width: 15.0.r),
                              Expanded(
                                flex: odds.isEmpty ? 0 : 1,
                                child: Text(
                                  spread,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Bebas_Neue',
                                    fontSize: 14.0.r,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
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
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/${widget.homeTeam}.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/0.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    ),
                              SizedBox(width: 10.0.r),
                              Text(
                                kTeamIdToName[widget.homeTeam.toString()][0] ??
                                    homeLinescore['TEAM_NICKNAME'] ??
                                    homeLinescore['TEAM_NAME'] ??
                                    'INT\'L',
                                style: kGameCardTextStyle.copyWith(
                                  color: summary['GAME_STATUS_ID'] != 3
                                      ? Colors.white // Game upcoming or in-progress
                                      : (homeLinescore['PTS'] ?? 0) >
                                                  (awayLinescore['PTS'] ?? 0) &&
                                              summary['GAME_STATUS_ID'] == 3
                                          ? Colors.white // Home team won
                                          : Colors.grey, // Home team lost
                                  fontSize: 20.0.r,
                                ),
                              ),
                              SizedBox(width: 4.0.r),
                              Text(
                                homeLinescore['TEAM_WINS_LOSSES'] ?? '0-0',
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
                                  homeLinescore['PTS'] == null || awayLinescore['PTS'] == null
                                      ? ''
                                      : homeLinescore['PTS'].toString(),
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(
                                    color: summary['GAME_STATUS_ID'] != 3
                                        ? Colors.white // Game upcoming or in-progress
                                        : (homeLinescore['PTS'] ?? 0) >
                                                    (awayLinescore['PTS'] ?? 0) &&
                                                summary['GAME_STATUS_ID'] == 3
                                            ? Colors.white // Home team won
                                            : Colors.grey, // Home team lost
                                    fontSize: 20.0.r,
                                  ),
                                ),
                              ),
                              if (odds.isNotEmpty) SizedBox(width: 15.0.r),
                              Expanded(
                                flex: odds.isEmpty ? 0 : 1,
                                child: Text(
                                  overUnder,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Bebas_Neue',
                                    fontSize: 14.0.r,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
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
