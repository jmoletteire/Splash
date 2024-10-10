import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utilities/constants.dart';
import '../../../../utilities/team.dart';
import '../../../team/team_cache.dart';
import '../../game_home.dart';

class LastFiveGames extends StatefulWidget {
  final String gameDate;
  final String homeId;
  final String awayId;

  const LastFiveGames({
    super.key,
    required this.gameDate,
    required this.homeId,
    required this.awayId,
  });

  @override
  State<LastFiveGames> createState() => _LastFiveGamesState();
}

class _LastFiveGamesState extends State<LastFiveGames> {
  Map<String, dynamic> homeTeam = {};
  Map<String, dynamic> awayTeam = {};
  List homeLastFive = [];
  List awayLastFive = [];
  Color homeTeamColor = Colors.transparent;
  Color awayTeamColor = Colors.transparent;
  bool _isLoading = false;

  List getLastFiveGames(Map<String, dynamic> team) {
    List gamesToAdd = [];

    while (gamesToAdd.length < 5) {
      for (String season in kSeasons) {
        Map<String, dynamic> schedule = team['seasons']?[season]?['GAMES'] ?? {};

        if (schedule.isEmpty) {
          break;
        }

        // Convert the map to a list of entries
        var entries = schedule.entries.toList();

        // Sort the entries by the GAME_DATE value
        entries.sort((a, b) => b.value['GAME_DATE'].compareTo(a.value['GAME_DATE']));

        // Extract the sorted keys
        var games = entries.map((e) => e.key).toList();

        final lastGame = DateTime.parse(schedule[games.last]['GAME_DATE']);
        final today = DateTime.parse(widget.gameDate);

        // Strip the time part by only keeping year, month, and day
        final lastGameDate = DateTime(lastGame.year, lastGame.month, lastGame.day);
        final todayDate = DateTime(today.year, today.month, today.day);

        // If season has started
        if (lastGameDate.compareTo(todayDate) < 0) {
          // Find last game
          for (var game in games) {
            if (DateTime.parse(schedule[game]['GAME_DATE']).compareTo(todayDate) < 0) {
              schedule[game]['GAME_ID'] = game;
              gamesToAdd.add(schedule[game]);
            }
          }
        }
      }
    }
    return gamesToAdd;
  }

  Future<Map<String, dynamic>> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      return teamCache.getTeam(teamId)!;
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      teamCache.addTeam(teamId, fetchedTeam);
      return fetchedTeam;
    }
  }

  Future<void> setValues(String homeId, String awayId) async {
    setState(() {
      _isLoading = true;
    });
    List teams = await Future.wait([
      getTeam(homeId),
      getTeam(awayId),
    ]);
    setState(() {
      homeTeam = teams[0];
      awayTeam = teams[1];

      if (awayTeam.isNotEmpty) {
        awayTeamColor = kDarkPrimaryColors.contains(awayTeam['ABBREVIATION'])
            ? (kTeamColors[awayTeam['ABBREVIATION']]!['secondaryColor']!)
            : (kTeamColors[awayTeam['ABBREVIATION']]!['primaryColor']!);
      }

      if (homeTeam.isNotEmpty) {
        homeTeamColor = kDarkPrimaryColors.contains(homeTeam['ABBREVIATION'])
            ? (kTeamColors[homeTeam['ABBREVIATION']]!['secondaryColor']!)
            : (kTeamColors[homeTeam['ABBREVIATION']]!['primaryColor']!);
      }

      if (homeTeam.isNotEmpty) {
        homeLastFive = getLastFiveGames(homeTeam);
      }
      if (awayTeam.isNotEmpty && awayTeam['ABBREVIATION'] != 'FA') {
        awayLastFive = getLastFiveGames(awayTeam);
      }

      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setValues(widget.homeId, widget.awayId);
  }

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

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: _isLoading,
      child: Card(
        margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
        color: Colors.grey.shade900,
        child: Padding(
          padding: EdgeInsets.all(15.0.r),
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
                      'Last 5 Games',
                      style: kBebasBold.copyWith(fontSize: 16.0.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (awayLastFive.isNotEmpty) awayGameRow(0),
                  SizedBox(width: 15.0.r),
                  if (homeLastFive.isNotEmpty) homeGameRow(0)
                ],
              ),
              SizedBox(height: 10.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (awayLastFive.isNotEmpty) awayGameRow(1),
                  SizedBox(width: 15.0.r),
                  if (homeLastFive.isNotEmpty) homeGameRow(1)
                ],
              ),
              SizedBox(height: 10.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (awayLastFive.isNotEmpty) awayGameRow(2),
                  SizedBox(width: 15.0.r),
                  if (homeLastFive.isNotEmpty) homeGameRow(2)
                ],
              ),
              SizedBox(height: 10.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (awayLastFive.isNotEmpty) awayGameRow(3),
                  SizedBox(width: 15.0.r),
                  if (homeLastFive.isNotEmpty) homeGameRow(3)
                ],
              ),
              SizedBox(height: 10.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (awayLastFive.isNotEmpty) awayGameRow(4),
                  SizedBox(width: 15.0.r),
                  if (homeLastFive.isNotEmpty) homeGameRow(4)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded homeGameRow(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameHome(
                gameId: homeLastFive[index]['GAME_ID'],
                homeId: homeLastFive[index]['HOME_AWAY'] == 'vs'
                    ? widget.homeId
                    : homeLastFive[index]['OPP'].toString(),
                awayId: homeLastFive[index]['HOME_AWAY'] == '@'
                    ? widget.homeId
                    : homeLastFive[index]['OPP'].toString(),
              ),
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0.r),
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                decoration: BoxDecoration(
                  color: homeLastFive[index]['RESULT'] == 'W'
                      ? Colors.green
                      : homeLastFive[index]['RESULT'] == 'L'
                          ? const Color(0xFFEC3126)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      homeLastFive[index]['TEAM_PTS'].toString(),
                      style: kBebasNormal.copyWith(
                        fontSize: 16.0.r,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' - ',
                      textAlign: TextAlign.center,
                      style:
                          kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300),
                    ),
                    Text(
                      homeLastFive[index]['OPP_PTS'].toString(),
                      style: kBebasNormal.copyWith(
                        fontSize: 16.0.r,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Text(
                      homeLastFive[index]['HOME_AWAY'],
                      style: kBebasNormal.copyWith(fontSize: 12.0.r),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 20.0.r, maxHeight: 20.0.r),
                      child: Image.asset('images/NBA_Logos/${homeLastFive[index]['OPP']}.png'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatDate(homeLastFive[index]['GAME_DATE'])[0],
                    style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.white70),
                  ),
                  Text(
                    formatDate(homeLastFive[index]['GAME_DATE'])[1],
                    style: kBebasNormal.copyWith(fontSize: 11.0.r),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded awayGameRow(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameHome(
                gameId: awayLastFive[index]['GAME_ID'],
                homeId: awayLastFive[index]['HOME_AWAY'] == 'vs'
                    ? widget.awayId
                    : awayLastFive[index]['OPP'].toString(),
                awayId: awayLastFive[index]['HOME_AWAY'] == '@'
                    ? widget.awayId
                    : awayLastFive[index]['OPP'].toString(),
              ),
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDate(awayLastFive[index]['GAME_DATE'])[0],
                    style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.white70),
                  ),
                  Text(
                    formatDate(awayLastFive[index]['GAME_DATE'])[1],
                    style: kBebasNormal.copyWith(fontSize: 11.0.r),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Text(
                      awayLastFive[index]['HOME_AWAY'],
                      style: kBebasNormal.copyWith(fontSize: 12.0.r),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 20.0.r, maxHeight: 20.0.r),
                      child: Image.asset(
                          'images/NBA_Logos/${kTeamIdToName.containsKey(awayLastFive[index]['OPP'].toString()) ? awayLastFive[index]['OPP'].toString() : '0'}.png'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0.r),
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                decoration: BoxDecoration(
                  color: awayLastFive[index]['RESULT'] == 'W'
                      ? Colors.green
                      : awayLastFive[index]['RESULT'] == 'L'
                          ? const Color(0xFFEC3126)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      awayLastFive[index]['TEAM_PTS'].toString(),
                      style: kBebasNormal.copyWith(
                        fontSize: 16.0.r,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' - ',
                      textAlign: TextAlign.center,
                      style:
                          kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300),
                    ),
                    Text(
                      awayLastFive[index]['OPP_PTS'].toString(),
                      style: kBebasNormal.copyWith(
                        fontSize: 16.0.r,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
