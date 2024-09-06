import 'package:flutter/material.dart';
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

  Future<void> getGame(String gameId) async {
    final gameCache = Provider.of<GameCache>(context, listen: false);
    if (gameCache.containsGame(gameId)) {
      setState(() {
        game = gameCache.getGame(gameId)!;
      });
    } else {
      var fetchedGame = await Game().getGame(gameId);
      setState(() {
        game = fetchedGame;
      });
      gameCache.addGame(gameId, game);
    }
  }

  Future<void> setValues(String gameId) async {
    setState(() {
      _isLoading = true;
    });
    await getGame(gameId);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    gameDate = formatDate(widget.lastMeeting['LAST_GAME_DATE_EST']);
    setValues(widget.lastMeeting['LAST_GAME_ID']);
  }

  @override
  Widget build(BuildContext context) {
    String lastHomeId = '';
    String lastAwayId = '';
    if (!_isLoading) {
      lastHomeId = game['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'].toString();
      lastAwayId = game['SUMMARY']['GameSummary'][0]['VISITOR_TEAM_ID'].toString();
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
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 0.0),
          color: Colors.grey.shade900,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                        ),
                      ),
                      child: Text(
                        'Previous Meeting',
                        style: kBebasBold.copyWith(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
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
                                kBebasNormal.copyWith(fontSize: 13.0, color: Colors.white70),
                          ),
                          Text(
                            gameDate[1],
                            style: kBebasNormal.copyWith(fontSize: 13.0),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 15.0),
                          SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: lastAwayId == ''
                                ? const Text('')
                                : Image.asset(
                                    'images/NBA_Logos/$lastAwayId.png',
                                    fit: BoxFit.contain,
                                    width: 16.0,
                                    height: 16.0,
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
                            style: kBebasBold.copyWith(fontSize: 14.0),
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
                            width: 24.0,
                            height: 24.0,
                            child: lastHomeId == ''
                                ? const Text('')
                                : Image.asset(
                                    'images/NBA_Logos/$lastHomeId.png',
                                    fit: BoxFit.contain,
                                    width: 16.0,
                                    height: 16.0,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.0,
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
