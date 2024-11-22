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
  GameCardState createState() => GameCardState();
}

class GameCardState extends State<GameCard> {
  int statusCode = 0;
  String spread = '';
  String overUnder = '';
  late Widget broadcast;
  late Widget title;
  late Widget status;
  late Widget headerRow;
  late Map<String, dynamic> homeLineScore;
  late Map<String, dynamic> awayLineScore;
  late Image homeLogo;
  late Image awayLogo;
  late TeamRow homeRow;
  late TeamRow awayRow;

  @override
  void initState() {
    super.initState();
    final summary = widget.game['SUMMARY']['GameSummary'][0];
    final lineScore = widget.game['SUMMARY']['LineScore'];
    statusCode = summary['GAME_STATUS_ID'];
    homeLineScore = lineScore[0]['TEAM_ID'] == widget.homeTeam ? lineScore[0] : lineScore[1];
    awayLineScore = lineScore[1]['TEAM_ID'] == widget.homeTeam ? lineScore[0] : lineScore[1];

    // Game Header
    broadcast = _getBroadcast(summary);
    title = _gameTitle(summary);
    status = _getStatus(summary);

    // Odds
    spread = _parseOdds(widget.game, 'hcp', live: false, type: '168', fallbackType: '4');
    overUnder = _parseOdds(widget.game, 'hcp', live: false, type: '18', fallbackType: '3');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final logicalSize = 24.0.r; // The width at which the image will be displayed
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio; // Typically 2.0 or 3.0
    awayLogo = Image.asset(
      'images/NBA_Logos/${widget.awayTeam}.png',
      width: logicalSize,
      height: logicalSize,
      cacheWidth: (logicalSize * devicePixelRatio).toInt(),
    );

    homeLogo = Image.asset(
      'images/NBA_Logos/${widget.homeTeam}.png',
      width: logicalSize,
      height: logicalSize,
      cacheWidth: (logicalSize * devicePixelRatio).toInt(),
    );

    headerRow = _buildHeaderRow();
    awayRow = TeamRow(
      teamId: widget.awayTeam,
      teamLogo: awayLogo,
      lineScore: awayLineScore,
      odds: spread,
      scoreColor:
          statusCode != 3 ? Colors.white : _getScoreColor(awayLineScore, homeLineScore),
    );

    homeRow = TeamRow(
      teamId: widget.homeTeam,
      teamLogo: homeLogo,
      lineScore: homeLineScore,
      odds: overUnder,
      scoreColor:
          statusCode != 3 ? Colors.white : _getScoreColor(homeLineScore, awayLineScore),
    );
  }

  @override
  void didUpdateWidget(covariant GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool hasChanges = oldWidget.game['SUMMARY']['GameSummary'][0] !=
            widget.game['SUMMARY']['GameSummary'][0] ||
        oldWidget.game['SUMMARY']['LineScore'] != widget.game['SUMMARY']['LineScore'];

    if (hasChanges) {
      // Game Info & Box Score
      final summary = widget.game['SUMMARY']['GameSummary'][0];
      final lineScore = widget.game['SUMMARY']['LineScore'];
      statusCode = summary['GAME_STATUS_ID'];
      status = _getStatus(summary);
      homeLineScore = lineScore[0]['TEAM_ID'] == widget.homeTeam ? lineScore[0] : lineScore[1];
      awayLineScore = lineScore[1]['TEAM_ID'] == widget.homeTeam ? lineScore[0] : lineScore[1];

      final logicalSize = 24.0.r;
      //final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      awayLogo = Image.asset(
        'images/NBA_Logos/${widget.awayTeam}.png',
        width: logicalSize,
        height: logicalSize,
      );

      homeLogo = Image.asset(
        'images/NBA_Logos/${widget.homeTeam}.png',
        width: logicalSize,
        height: logicalSize,
      );

      spread = _parseOdds(widget.game, 'hcp', live: false, type: '168', fallbackType: '4');
      overUnder = _parseOdds(widget.game, 'hcp', live: false, type: '18', fallbackType: '3');

      headerRow = _buildHeaderRow();

      awayRow = TeamRow(
        teamId: widget.awayTeam,
        teamLogo: awayLogo,
        lineScore: awayLineScore,
        odds: spread,
        scoreColor:
            statusCode != 3 ? Colors.white : _getScoreColor(awayLineScore, homeLineScore),
      );

      homeRow = TeamRow(
        teamId: widget.homeTeam,
        teamLogo: homeLogo,
        lineScore: homeLineScore,
        odds: overUnder,
        scoreColor:
            statusCode != 3 ? Colors.white : _getScoreColor(homeLineScore, awayLineScore),
      );
    }
  }

  Widget _getBroadcast(Map<String, dynamic> summary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ABC' &&
            summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ESPN' &&
            summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'TNT')
          Text(
            summary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LP',
            style: kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300),
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
    );
  }

  Widget _gameTitle(Map<String, dynamic> summary) {
    if (summary.containsKey('NBA_CUP')) {
      return Text(
        summary['NBA_CUP'],
        style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.white70),
        textAlign: TextAlign.center,
      );
    }

    Map<String, String> seasonTypes = {
      '1': 'Pre-Season',
      '2': 'Regular Season',
      '4': 'Playoffs',
      '5': 'Play-In',
      '6': 'In-Season Tournament',
    };

    String gameId = summary['GAME_ID'].toString();
    String seasonType = seasonTypes[gameId.substring(2, 3)] ?? 'Regular Season';

    switch (seasonType) {
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

  Widget _getStatus(Map<String, dynamic> summary) {
    String gameTime = _getGameTime(summary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if ((statusCode == 1 && gameTime == 'Pregame') || statusCode == 2)
          Container(
            width: 4.0.r, // Size of the dot
            height: 4.0.r,
            decoration: BoxDecoration(
              color: gameTime == 'Pregame' ? Colors.orangeAccent : const Color(0xFF55F86F),
              shape: BoxShape.circle, // Circular shape
            ),
          ),
        if ((statusCode == 1 && gameTime == 'Pregame') || statusCode == 2)
          SizedBox(width: 3.0.r),
        Text(
          gameTime,
          style: kBebasNormal.copyWith(
              fontSize: 14.0.r,
              color: statusCode != 2 // Game NOT in-progress
                  ? Colors.grey.shade300
                  : Colors.white),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  String _getGameTime(Map<String, dynamic> summary) {
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
        return _adjustTimezone(summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT']);
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

  String _parseOdds(Map<String, dynamic> game, String field,
      {required bool live, required String type, required String fallbackType}) {
    try {
      final odds = live ? game['ODDS']['LIVE']['26338'] : game['ODDS']['BOOK']['18186'];
      double value =
          double.parse(odds['oddstypes']?[live ? type : fallbackType]?[field]?['value']);
      return value > 0 && type != '18' && fallbackType != '3'
          ? '+${value.toStringAsFixed(1)}'
          : value.toStringAsFixed(1);
    } catch (e) {
      return '';
    }
  }

  String _adjustTimezone(String dateString, String timeString) {
    if (timeString == 'Final') {
      return timeString;
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
              gameTime: _adjustTimezone(
                widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'],
                widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_TEXT'],
              ),
            ),
          ),
        );
      },
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey.shade800)),
          ),
          padding: EdgeInsets.all(15.0.r),
          child: Column(
            children: [
              headerRow,
              SizedBox(height: 5.0.r),
              awayRow,
              homeRow,
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(Map<String, dynamic> teamScore, Map<String, dynamic> opponentScore) {
    // Determine the color based on game status and score comparison
    return teamScore['PTS'] > opponentScore['PTS']
        ? Colors.white
        : Colors.grey; // Example logic
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: broadcast),
        Expanded(flex: 3, child: title),
        Expanded(child: status)
      ],
    );
  }
}

class TeamRow extends StatelessWidget {
  final int teamId;
  final Image teamLogo;
  final Map<String, dynamic> lineScore;
  final String odds;
  final Color scoreColor;

  const TeamRow({
    super.key,
    required this.teamId,
    required this.teamLogo,
    required this.lineScore,
    required this.odds,
    required this.scoreColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          flex: 8,
          child: Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              teamLogo,
              SizedBox(width: 10.0.r),
              Text(
                lineScore['TEAM_NICKNAME'] ?? lineScore['TEAM_NAME'] ?? 'INT\'L',
                style: kGameCardTextStyle.copyWith(color: scoreColor, fontSize: 20.0.r),
              ),
              SizedBox(width: 4.0.r),
              Text(lineScore['TEAM_WINS_LOSSES'] ?? '0-0',
                  style: kGameCardTextStyle.copyWith(fontSize: 14.0.r)),
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
                child: Text(
                  lineScore['PTS']?.toString() ?? '',
                  style: kGameCardTextStyle.copyWith(color: scoreColor, fontSize: 20.0.r),
                  textAlign: TextAlign.right,
                ),
              ),
              if (odds != '') SizedBox(width: 15.0.r),
              if (odds != '')
                Expanded(
                  child: Text(
                    odds,
                    style: TextStyle(
                        color: Colors.grey, fontFamily: 'Bebas_Neue', fontSize: 14.0.r),
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
