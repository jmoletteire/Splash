import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/utilities/constants.dart';
import 'package:timezone/timezone.dart';

import '../../utilities/global_variables.dart';
import '../../utilities/team.dart';
import '../team/team_cache.dart';
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
  Map<String, dynamic> home = {};
  Map<String, dynamic> away = {};
  late Image homeLogo;
  late Image awayLogo;
  late TeamRow homeRow;
  late TeamRow awayRow;

  @override
  void initState() {
    super.initState();
    statusCode = int.parse(widget.game['status'].toString());

    // Game Header
    broadcast = _getBroadcast(widget.game['broadcast']);
    title = _gameTitle();
    status = _getStatus();

    _setTeams();

    // Odds
    // spread = _parseOdds(widget.game, 'hcp', live: false, type: '168', fallbackType: '4');
    // overUnder = _parseOdds(widget.game, 'hcp', live: false, type: '18', fallbackType: '3');
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
      team: away,
      teamLogo: awayLogo,
      pts: widget.game['awayScore'],
      odds: spread,
      scoreColor: statusCode != 3
          ? Colors.white
          : _getScoreColor(widget.game['awayScore'], widget.game['homeScore']),
    );

    homeRow = TeamRow(
      team: home,
      teamLogo: homeLogo,
      pts: widget.game['homeScore'],
      odds: overUnder,
      scoreColor: statusCode != 3
          ? Colors.white
          : _getScoreColor(widget.game['homeScore'], widget.game['awayScore']),
    );
  }

  @override
  void didUpdateWidget(covariant GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool hasChanges = oldWidget.game != widget.game;

    if (hasChanges) {
      // Game Info & Box Score
      statusCode = int.parse(widget.game['status'].toString());
      status = _getStatus();

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

      // spread = _parseOdds(widget.game, 'hcp', live: false, type: '168', fallbackType: '4');
      // overUnder = _parseOdds(widget.game, 'hcp', live: false, type: '18', fallbackType: '3');

      // headerRow = _buildHeaderRow();
      //
      // awayRow = TeamRow(
      //   team: away,
      //   teamLogo: awayLogo,
      //   pts: widget.game['awayScore'],
      //   odds: spread,
      //   scoreColor: statusCode != 3
      //       ? Colors.white
      //       : _getScoreColor(widget.game['awayScore'], widget.game['homeScore']),
      // );
      //
      // homeRow = TeamRow(
      //   team: home,
      //   teamLogo: homeLogo,
      //   pts: widget.game['homeScore'],
      //   odds: overUnder,
      //   scoreColor: statusCode != 3
      //       ? Colors.white
      //       : _getScoreColor(widget.game['homeScore'], widget.game['awayScore']),
      // );
    }
  }

  void _setTeams() async {
    home = await getTeam(widget.homeTeam.toString());
    away = await getTeam(widget.awayTeam.toString());
  }

  Future<Map<String, dynamic>> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      return teamCache.getTeam(teamId)!;
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      var team = fetchedTeam;
      teamCache.addTeam(teamId, team);
      return team;
    }
  }

  Widget _getBroadcast(String? broadcast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (broadcast != 'ABC' && broadcast != 'ESPN' && broadcast != 'TNT')
          Text(
            broadcast ?? 'LP',
            style: kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300),
            textAlign: TextAlign.start,
          ),
        if (broadcast != null) ...[
          if (broadcast == 'NBA TV' || broadcast == 'ESPN2' || broadcast == 'ESPN/ESPN2')
            SizedBox(width: 3.0.r),
          if (broadcast == 'NBA TV')
            SvgPicture.asset(
              'images/NBA_TV.svg',
              width: 10.0.r,
              height: 10.0.r,
            ),
          if (broadcast == 'TNT')
            SvgPicture.asset(
              'images/TNT.svg',
              width: 16.0.r,
              height: 16.0.r,
            ),
          if (broadcast == 'ESPN')
            SvgPicture.asset(
              'images/ESPN.svg',
              width: 7.0.r,
              height: 7.0.r,
            ),
          if (broadcast == 'ESPN2' || broadcast == 'ESPN/ESPN2')
            SvgPicture.asset(
              'images/ESPN_E.svg',
              width: 9.0.r,
              height: 9.0.r,
            ),
          if (broadcast == 'ABC')
            SvgPicture.asset(
              'images/abc.svg',
              width: 16.0.r,
              height: 16.0.r,
            ),
        ],
      ],
    );
  }

  Widget _gameTitle() {
    if (widget.game.containsKey('title')) {
      return Text(
        'Emirates NBA Cup Final',
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

    String gameId = widget.game['gameId'];
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

  Widget _getStatus() {
    String gameTime = widget.game['gameClock'];
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

  // String _getGameTime(Map<String, dynamic> summary) {
  //   if (widget.game.containsKey('BOXSCORE')) {
  //     if (widget.game['BOXSCORE']['gameStatusText'] == 'pregame') {
  //       return 'Pregame';
  //     }
  //   }
  //   switch (summary['GAME_STATUS_ID']) {
  //     case 1:
  //       // Upcoming
  //       if (summary['GAME_STATUS_TEXT'] == 'Cancelled') {
  //         return summary['GAME_STATUS_TEXT'];
  //       }
  //       return _adjustTimezone(summary['GAME_DATE_EST'], summary['GAME_STATUS_TEXT']);
  //     case 2:
  //       // End Quarter
  //       if (summary['LIVE_PC_TIME'] == ":0.0" || summary['LIVE_PC_TIME'] == "     ") {
  //         switch (summary['LIVE_PERIOD']) {
  //           case 1:
  //             return 'End 1Q';
  //           case 2:
  //             return 'HALF';
  //           case 3:
  //             return 'End 3Q';
  //           case 4:
  //             return 'Final';
  //           case 5:
  //             return 'Final/OT';
  //           default:
  //             return 'Final/${summary['LIVE_PERIOD'] - 4}OT';
  //         }
  //       } else {
  //         // Game in-progress
  //         if (summary['LIVE_PERIOD'] <= 4) {
  //           return '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'].toString()}Q ';
  //         } else if (summary['LIVE_PERIOD'] == 5) {
  //           return '${summary['LIVE_PC_TIME'].toString()} OT';
  //         } else {
  //           return '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'] - 4}OT';
  //         }
  //       }
  //     case 3:
  //       // Game Final
  //       switch (summary['LIVE_PERIOD']) {
  //         case 4:
  //           return 'Final';
  //         case 5:
  //           return 'Final/OT';
  //         default:
  //           return 'Final/${summary['LIVE_PERIOD'] - 4}OT';
  //       }
  //     default:
  //       return '';
  //   }
  // }
  //
  // String _parseOdds(Map<String, dynamic> game, String field,
  //     {required bool live, required String type, required String fallbackType}) {
  //   try {
  //     final odds = live ? game['ODDS']['LIVE']['26338'] : game['ODDS']['BOOK']['18186'];
  //     double value =
  //         double.parse(odds['oddstypes']?[live ? type : fallbackType]?[field]?['value']);
  //     return value > 0 && type != '18' && fallbackType != '3'
  //         ? '+${value.toStringAsFixed(1)}'
  //         : value.toStringAsFixed(1);
  //   } catch (e) {
  //     return '';
  //   }
  // }

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
                gameId: widget.game['gameId'],
                homeId: widget.homeTeam.toString(),
                awayId: widget.awayTeam.toString(),
                gameDate: widget.game['date'],
                gameTime: widget.game[
                    'gameClock'] // _adjustTimezone(widget.game['date'], widget.game['gameClock']),
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey.shade800)),
        ),
        padding: EdgeInsets.all(15.0.r),
        child: Column(
          children: [
            _buildHeaderRow(),
            SizedBox(height: 5.0.r),
            TeamRow(
              team: away,
              teamLogo: awayLogo,
              pts: widget.game['awayScore'],
              odds: spread,
              scoreColor: statusCode != 3
                  ? Colors.white
                  : _getScoreColor(widget.game['awayScore'], widget.game['homeScore']),
            ),
            TeamRow(
              team: home,
              teamLogo: homeLogo,
              pts: widget.game['homeScore'],
              odds: overUnder,
              scoreColor: statusCode != 3
                  ? Colors.white
                  : _getScoreColor(widget.game['homeScore'], widget.game['awayScore']),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int teamScore, int opponentScore) {
    // Determine the color based on game status and score comparison
    return teamScore > opponentScore ? Colors.white : Colors.grey; // Example logic
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
  final Map<String, dynamic> team;
  final Image teamLogo;
  final int? pts;
  final String odds;
  final Color scoreColor;

  const TeamRow({
    super.key,
    required this.team,
    required this.teamLogo,
    required this.pts,
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
                team['NICKNAME'] ?? 'INT\'L',
                style: kGameCardTextStyle.copyWith(color: scoreColor, fontSize: 20.0.r),
              ),
              SizedBox(width: 4.0.r),
              // Text(lineScore['TEAM_WINS_LOSSES'] ?? '0-0',
              //     style: kGameCardTextStyle.copyWith(fontSize: 14.0.r)),
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
                  pts?.toString() ?? '',
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
