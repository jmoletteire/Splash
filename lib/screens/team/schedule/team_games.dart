import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

import '../../../utilities/constants.dart';
import '../../../utilities/global_variables.dart';
import '../../game/game_home.dart';
import '../team_cache.dart';

class TeamGames extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> schedule;
  final String selectedSeason;
  final String selectedSeasonType;
  final String selectedMonth;
  final int? opponent;

  const TeamGames({
    super.key,
    required this.team,
    required this.schedule,
    required this.selectedSeason,
    required this.selectedSeasonType,
    required this.selectedMonth,
    this.opponent,
  });

  @override
  State<TeamGames> createState() => _TeamGamesState();
}

class _TeamGamesState extends State<TeamGames> {
  late List<String> gamesList;
  late Map<String, dynamic> teamGames;
  double topPadding = 0.0;
  late String seasonType;

  Map<String, String> seasonTypes = {
    '*': 'All',
    '1': 'Pre-Season',
    '2': 'Regular Season',
    '4': 'Playoffs',
    '5': 'Play-In',
    '6': 'NBA Cup',
  };

  List<String> getTop10(String stat) {
    final teamCache = Provider.of<TeamCache>(context, listen: false);

    // Create a list to store the team IDs and their corresponding NET_RATING
    List<String> top10Teams = [];

    // Iterate through the cache and extract NET_RATING
    teamCache.cache.forEach((teamId, values) {
      int stat_rank = values['seasons']?[widget.selectedSeason]?['STATS']?['REGULAR SEASON']
              ?['ADV']?[stat] ??
          30;
      if (stat_rank <= 10) top10Teams.add(teamId);
    });

    return top10Teams;
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

  Map<String, dynamic> getGames(
      String season, String month, int? opponentId, String seasonType) {
    Map<String, int> monthsMap = {
      'October': 10,
      'November': 11,
      'December': 12,
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
    };

    // Function to filter games by month
    Map<String, dynamic> filterByMonth(Map<String, dynamic> schedule, int month) {
      // Create a new map to store filtered games
      Map<String, dynamic> filteredSchedule = {};

      // Iterate through the schedule map
      schedule.forEach((key, game) {
        // Parse the GAME_DATE field
        String gameDate = game['GAME_DATE'];
        DateTime date = DateTime.parse(gameDate);

        // Check if the month matches
        if (date.month == month) {
          filteredSchedule[key] = game;
        }
      });

      return filteredSchedule;
    }

    // Function to filter games by month
    Map<String, dynamic> filterByOpp(Map<String, dynamic> schedule, int opponentId) {
      // Create a new map to store filtered games
      Map<String, dynamic> filteredSchedule = {};

      if (opponentId < 4) {
        List<String> teamIds = [];
        if (opponentId == 1) teamIds = getTop10('NET_RATING_RANK');
        if (opponentId == 2) teamIds = getTop10('OFF_RATING_RANK');
        if (opponentId == 3) teamIds = getTop10('DEF_RATING_RANK');

        // Iterate through the schedule map
        schedule.forEach((key, game) {
          // Parse the GAME_DATE field
          int oppId = game['OPP'] ?? 0;

          // Check if the opponent matches
          if (teamIds.contains(oppId.toString())) {
            filteredSchedule[key] = game;
          }
        });
        return filteredSchedule;
      }

      // Iterate through the schedule map
      schedule.forEach((key, game) {
        // Parse the GAME_DATE field
        int oppId = game['OPP'];

        // Check if the opponent matches
        if (oppId == opponentId) {
          filteredSchedule[key] = game;
        }
      });
      return filteredSchedule;
    }

    // Function to filter games by month
    Map<String, dynamic> filterBySeasonType(
        Map<String, dynamic> schedule, String selectedSeasonType) {
      // Create a new map to store filtered games
      Map<String, dynamic> filteredSchedule = {};

      // Iterate through the schedule map
      schedule.forEach((key, game) {
        String seasonType = game['SEASON_ID'].toString().substring(0, 1);

        // Check if the season type matches
        if (seasonTypes[seasonType] == selectedSeasonType) {
          filteredSchedule[key] = game;
        }
      });
      return filteredSchedule;
    }

    // Month filter only
    if ((opponentId == null || opponentId == 0) && month != 'All' && seasonType == 'All') {
      //print('Filtering by Month only');
      return filterByMonth(widget.schedule, monthsMap[month]!);
    }
// Opp filter only
    else if (opponentId != null && opponentId != 0 && month == 'All' && seasonType == 'All') {
      //print('Filtering by Opp only');
      return filterByOpp(widget.schedule, opponentId);
    }
// Season Type filter only
    else if ((opponentId == null || opponentId == 0) &&
        month == 'All' &&
        seasonType != 'All') {
      //print('Filtering by Season Type only');
      return filterBySeasonType(widget.schedule, seasonType);
    }
// Month & Opp filters
    else if (opponentId != 0 && month != 'All' && seasonType == 'All') {
      //print('Filtering by Month & Opp');
      return filterByOpp(filterByMonth(widget.schedule, monthsMap[month]!), opponentId!);
    }
// Month & Season Type filters
    else if ((opponentId == null || opponentId == 0) &&
        month != 'All' &&
        seasonType != 'All') {
      //print('Filtering by Month & Season Type');
      return filterByMonth(filterBySeasonType(widget.schedule, seasonType), monthsMap[month]!);
    }
// Season Type & Opp filters
    else if (opponentId != 0 && month == 'All' && seasonType != 'All') {
      //print('Filtering by Season Type & Opp');
      return filterByOpp(filterBySeasonType(widget.schedule, seasonType), opponentId!);
    }
// All filters
    else if (opponentId != 0 && month != 'All' && seasonType != 'All') {
      //print('Filtering by all filters');
      return filterByOpp(
          filterByMonth(filterBySeasonType(widget.schedule, seasonType), monthsMap[month]!),
          opponentId!);
    }
// No filters
    else {
      return widget.schedule;
    }
  }

  List<String> sortGames() {
    // Convert the map to a list of entries
    var entries = teamGames.entries.toList();

    // Sort the entries by the GAME_DATE value
    entries.sort((a, b) => a.value['GAME_DATE'].compareTo(b.value['GAME_DATE']));

    // Extract the sorted keys
    var gameIndex = entries.map((e) => e.key).toList();

    return gameIndex;
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
    if (widget.opponent == null || widget.opponent == 0 && widget.selectedMonth != 'All') {
      teamGames = getGames(
        widget.selectedSeason,
        widget.selectedMonth,
        null,
        widget.selectedSeasonType,
      );
    } else {
      teamGames = getGames(widget.selectedSeason, widget.selectedMonth, widget.opponent,
          widget.selectedSeasonType);
    }
    gamesList = sortGames();

    return teamGames.isEmpty
        ? Center(
            heightFactor: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_basketball,
                  color: Colors.white38,
                  size: 38.0.r,
                ),
                SizedBox(height: 15.0.r),
                Text(
                  'No Games Available',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
                ),
              ],
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(
                  bottom: 2 * kBottomNavigationBarHeight,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Get the current game date
                      List<String> gameDate =
                          formatDate(teamGames[gamesList[index]]['GAME_DATE']);

                      // List to hold the widgets to be returned
                      List<Widget> widgets = [];

                      // Check if we need to add the season separator
                      if (index == 0 ||
                          teamGames[gamesList[index]]['SEASON_ID'] !=
                              teamGames[gamesList[index - 1]]['SEASON_ID']) {
                        widgets.add(
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              seasonTypes[teamGames[gamesList[index]]['SEASON_ID']
                                  .toString()
                                  .substring(0, 1)]!,
                              style: kBebasNormal.copyWith(fontSize: 13.0.r),
                            ),
                          ),
                        );
                      }

                      // Define the main container to return
                      Widget gameContainer = GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameHome(
                                gameId: gamesList[index].toString(),
                                homeId: teamGames[gamesList[index]]['HOME_AWAY'] == 'vs'
                                    ? widget.team['TEAM_ID'].toString()
                                    : teamGames[gamesList[index]]['OPP'].toString(),
                                awayId: teamGames[gamesList[index]]['HOME_AWAY'] == '@'
                                    ? widget.team['TEAM_ID'].toString()
                                    : teamGames[gamesList[index]]['OPP'].toString(),
                                gameTime: teamGames[gamesList[index]]['RESULT'] != 'W' &&
                                        teamGames[gamesList[index]]['RESULT'] != 'L'
                                    ? adjustTimezone(
                                        teamGames[gamesList[index]]['GAME_DATE'],
                                        teamGames[gamesList[index]]['RESULT'],
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0.r, vertical: 8.0.r),
                          height: MediaQuery.sizeOf(context).height * 0.065,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            border: const Border(
                                bottom: BorderSide(color: Colors.white70, width: 0.125)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gameDate[0],
                                      style: kBebasNormal.copyWith(
                                          fontSize: 12.0.r, color: Colors.white70),
                                    ),
                                    Text(
                                      gameDate[1],
                                      style: kBebasNormal.copyWith(fontSize: 12.0.r),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 30.0.r,
                                      child: Text(
                                        teamGames[gamesList[index]]['HOME_AWAY'],
                                        style: kBebasBold.copyWith(fontSize: 14.0.r),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24.0.r,
                                      height: 24.0.r,
                                      child: kTeamIdToName[teamGames[gamesList[index]]['OPP']
                                                  .toString()] ==
                                              null
                                          ? const Text('')
                                          : Image.asset(
                                              'images/NBA_Logos/${teamGames[gamesList[index]]['OPP']}.png',
                                              fit: BoxFit.contain,
                                              width: 18.0.r,
                                              height: 18.0.r,
                                            ),
                                    ),
                                    SizedBox(width: 15.0.r),
                                    Text(
                                      kTeamIdToName[teamGames[gamesList[index]]['OPP']
                                                  .toString()] !=
                                              null
                                          ? kTeamIdToName[
                                              teamGames[gamesList[index]]['OPP'].toString()][0]
                                          : 'INT\'L',
                                      style: kBebasBold.copyWith(fontSize: 16.0.r),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (teamGames[gamesList[index]]['RESULT'] == 'W' ||
                                        teamGames[gamesList[index]]['RESULT'] == 'L')
                                      Text(
                                        'Final',
                                        textAlign: TextAlign.end,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 11.0.r, color: Colors.grey),
                                      ),
                                    if (teamGames[gamesList[index]]['RESULT'] != 'W' &&
                                        teamGames[gamesList[index]]['RESULT'] != 'L' &&
                                        teamGames[gamesList[index]]['BROADCAST'] != null)
                                      Text(
                                        teamGames[gamesList[index]]['BROADCAST'],
                                        textAlign: TextAlign.end,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 12.0.r, color: Colors.grey),
                                      ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          teamGames[gamesList[index]]['RESULT'] != 'W' &&
                                                  teamGames[gamesList[index]]['RESULT'] !=
                                                      'L' &&
                                                  teamGames[gamesList[index]]['RESULT'] !=
                                                      'Cancelled'
                                              ? adjustTimezone(
                                                  teamGames[gamesList[index]]['GAME_DATE'],
                                                  teamGames[gamesList[index]]['RESULT'])
                                              : teamGames[gamesList[index]]['RESULT'],
                                          style: kBebasNormal.copyWith(
                                            fontSize: 13.0.r,
                                            color: teamGames[gamesList[index]]['RESULT'] == 'W'
                                                ? Colors.green
                                                : teamGames[gamesList[index]]['RESULT'] == 'L'
                                                    ? Colors.red
                                                    : Colors.white,
                                          ),
                                        ),
                                        if (teamGames[gamesList[index]]['RESULT'] == 'W' ||
                                            teamGames[gamesList[index]]['RESULT'] == 'L')
                                          Row(
                                            children: [
                                              SizedBox(width: 5.0.r),
                                              Text(
                                                teamGames[gamesList[index]]['TEAM_PTS']
                                                    .toString(),
                                                style: kBebasNormal.copyWith(fontSize: 13.0.r),
                                              ),
                                              SizedBox(
                                                width: 10.0.r,
                                                child: Text(
                                                  '-',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      kBebasNormal.copyWith(fontSize: 13.0.r),
                                                ),
                                              ),
                                              Text(
                                                teamGames[gamesList[index]]['OPP_PTS']
                                                    .toString(),
                                                style: kBebasNormal.copyWith(fontSize: 13.0.r),
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      widgets.add(gameContainer);

                      return Column(
                        children: widgets,
                      );
                    },
                    childCount: gamesList.length,
                  ),
                ),
              ),
            ],
          );
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String seasonType;

  const MySliverPersistentHeaderDelegate({required this.seasonType});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
      alignment: Alignment.centerLeft,
      child: Text(
        seasonType,
        style: kBebasNormal.copyWith(fontSize: 12.0.r),
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
