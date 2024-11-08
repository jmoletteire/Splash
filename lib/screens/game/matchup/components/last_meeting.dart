import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utilities/constants.dart';
import '../../../../utilities/game.dart';
import '../../game_cache.dart';
import '../../game_home.dart';

class LastMeeting extends StatefulWidget {
  final Map<String, dynamic> lastMeeting;
  final String homeId;
  final String awayId;
  const LastMeeting(
      {super.key, required this.lastMeeting, required this.homeId, required this.awayId});

  @override
  State<LastMeeting> createState() => _LastMeetingState();
}

class _LastMeetingState extends State<LastMeeting> {
  late List<String> gameDate;
  late Map<String, dynamic> game;
  bool _isLoading = false;

  List<String> formatDate(String date) {
    // Parse the string to a DateTime object
    DateTime dateTime = DateTime.parse(date);

    // Create a DateFormat for the abbreviated day of the week
    DateFormat dayOfWeekFormat = DateFormat('E');
    String dayOfWeek = dayOfWeekFormat.format(dateTime);

    // Create a DateFormat for the month and date
    DateFormat monthDateFormat = DateFormat('M/d');
    String monthDate = monthDateFormat.format(dateTime);

    return [dayOfWeek, monthDate];
  }

  Future<void> getGame(String gameId, String gameDate) async {
    final gameCache = Provider.of<GameCache>(context, listen: false);
    if (gameCache.containsGame(gameId)) {
      setState(() {
        game = gameCache.getGame(gameId)!;
      });
    } else {
      var fetchedGame = await Game().getGame(gameId, gameDate);
      setState(() {
        game = fetchedGame;
      });
      gameCache.addGame(gameId, game);
    }
  }

  Future<void> setValues(String gameId, String gameDate) async {
    setState(() {
      _isLoading = true;
    });
    await getGame(gameId, gameDate);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    gameDate = formatDate(widget.lastMeeting['LAST_GAME_DATE_EST']);
    setValues(widget.lastMeeting['LAST_GAME_ID'],
        widget.lastMeeting['LAST_GAME_DATE_EST'].substring(0, 10));
  }

  @override
  Widget build(BuildContext context) {
    String lastHomeId = '';
    String lastAwayId = '';
    if (!_isLoading) {
      if (game.isNotEmpty && game.containsKey('SUMMARY')) {
        lastHomeId = game['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'].toString();
        lastAwayId = game['SUMMARY']['GameSummary'][0]['VISITOR_TEAM_ID'].toString();
        if (!kTeamIdToName.containsKey(lastAwayId)) {
          lastAwayId = '0';
        }
      } else {
        return Container();
      }
    }
    return Skeletonizer(
      enabled: _isLoading,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameHome(
                gameData: game,
                gameId: widget.lastMeeting['LAST_GAME_ID'],
                homeId: lastHomeId,
                awayId: lastAwayId,
                gameDate: widget.lastMeeting['LAST_GAME_DATE_EST'].substring(0, 10),
              ),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
          color: Colors.grey.shade900,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
                        ),
                      ),
                      child: Text(
                        'Previous Meeting',
                        style: kBebasBold.copyWith(fontSize: 16.0.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0.r),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameDate[0],
                            style:
                                kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.white70),
                          ),
                          Text(
                            gameDate[1],
                            style: kBebasNormal.copyWith(fontSize: 11.0.r),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(width: 15.0.r),
                          SizedBox(
                            width: 24.0.r,
                            height: 24.0.r,
                            child: lastAwayId == ''
                                ? const Text('')
                                : Image.asset(
                                    'images/NBA_Logos/$lastAwayId.png',
                                    fit: BoxFit.contain,
                                    width: 16.0.r,
                                    height: 16.0.r,
                                  ),
                          ),
                          Text(
                            widget.lastMeeting['LAST_GAME_HOME_TEAM_ID'].toString() ==
                                    lastAwayId
                                ? widget.lastMeeting['LAST_GAME_HOME_TEAM_POINTS']
                                    .toStringAsFixed(0)
                                : widget.lastMeeting['LAST_GAME_VISITOR_TEAM_POINTS']
                                    .toStringAsFixed(0),
                            style: kBebasBold.copyWith(
                              color: widget.lastMeeting['LAST_GAME_HOME_TEAM_ID'].toString() ==
                                      lastAwayId
                                  ? widget.lastMeeting['LAST_GAME_HOME_TEAM_POINTS'] >
                                          widget.lastMeeting['LAST_GAME_VISITOR_TEAM_POINTS']
                                      ? Colors.white
                                      : Colors.grey
                                  : widget.lastMeeting['LAST_GAME_VISITOR_TEAM_POINTS'] >
                                          widget.lastMeeting['LAST_GAME_HOME_TEAM_POINTS']
                                      ? Colors.white
                                      : Colors.grey,
                            ),
                          ),
                          Text(
                            '@',
                            style: kBebasBold.copyWith(fontSize: 12.0.r),
                          ),
                          Text(
                            widget.lastMeeting['LAST_GAME_HOME_TEAM_ID'].toString() ==
                                    lastHomeId
                                ? widget.lastMeeting['LAST_GAME_HOME_TEAM_POINTS']
                                    .toStringAsFixed(0)
                                : widget.lastMeeting['LAST_GAME_VISITOR_TEAM_POINTS']
                                    .toStringAsFixed(0),
                            style: kBebasBold.copyWith(
                              color: widget.lastMeeting['LAST_GAME_HOME_TEAM_ID'].toString() ==
                                      lastHomeId
                                  ? widget.lastMeeting['LAST_GAME_HOME_TEAM_POINTS'] >
                                          widget.lastMeeting['LAST_GAME_VISITOR_TEAM_POINTS']
                                      ? Colors.white
                                      : Colors.grey
                                  : widget.lastMeeting['LAST_GAME_VISITOR_TEAM_POINTS'] >
                                          widget.lastMeeting['LAST_GAME_HOME_TEAM_POINTS']
                                      ? Colors.white
                                      : Colors.grey,
                            ),
                          ),
                          SizedBox(
                            width: 24.0.r,
                            height: 24.0.r,
                            child: lastHomeId == ''
                                ? const Text('')
                                : Image.asset(
                                    'images/NBA_Logos/$lastHomeId.png',
                                    fit: BoxFit.contain,
                                    width: 16.0.r,
                                    height: 16.0.r,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.0.r,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
