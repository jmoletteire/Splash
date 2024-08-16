import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../utilities/constants.dart';
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
  bool _showStickyHeader = false;
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
      int stat_rank =
          values['seasons'][widget.selectedSeason]['STATS']['REGULAR SEASON']['ADV'][stat];
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
          int oppId = game['OPP'];

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
        ? SliverToBoxAdapter(
            child: Center(
              heightFactor: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sports_basketball,
                    color: Colors.white38,
                    size: 40.0,
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    'No Games Available',
                    style: kBebasNormal.copyWith(fontSize: 20.0, color: Colors.white54),
                  ),
                ],
              ),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              seasonTypes[teamGames[gamesList[index]]['SEASON_ID']
                                  .toString()
                                  .substring(0, 1)]!,
                              style: kBebasNormal.copyWith(fontSize: 14.0),
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
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
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
                                          fontSize: 13.0, color: Colors.white70),
                                    ),
                                    Text(
                                      gameDate[1],
                                      style: kBebasNormal.copyWith(fontSize: 13.0),
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
                                      width: 30.0,
                                      child: Text(
                                        teamGames[gamesList[index]]['HOME_AWAY'],
                                        style: kBebasBold.copyWith(fontSize: 14.0),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: kTeamNames[teamGames[gamesList[index]]['OPP']
                                                  .toString()] ==
                                              null
                                          ? const Text('')
                                          : Image.asset(
                                              'images/NBA_Logos/${teamGames[gamesList[index]]['OPP']}.png',
                                              fit: BoxFit.contain,
                                              width: 16.0,
                                              height: 16.0,
                                            ),
                                    ),
                                    const SizedBox(width: 15.0),
                                    Text(
                                      kTeamNames[teamGames[gamesList[index]]['OPP']
                                                  .toString()] !=
                                              null
                                          ? kTeamNames[
                                              teamGames[gamesList[index]]['OPP'].toString()][0]
                                          : 'INT\'L',
                                      style: kBebasBold.copyWith(fontSize: 18.0),
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
                                    Text(
                                      'Final',
                                      textAlign: TextAlign.end,
                                      style: kBebasNormal.copyWith(
                                          fontSize: 12.0, color: Colors.grey),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          teamGames[gamesList[index]]['RESULT'],
                                          style: kBebasNormal.copyWith(
                                            fontSize: 14.0,
                                            color: teamGames[gamesList[index]]['RESULT'] == 'W'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          teamGames[gamesList[index]]['TEAM_PTS'].toString(),
                                          style: kBebasNormal.copyWith(fontSize: 14.0),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                          child: Text(
                                            '-',
                                            textAlign: TextAlign.center,
                                            style: kBebasNormal.copyWith(fontSize: 14.0),
                                          ),
                                        ),
                                        Text(
                                          teamGames[gamesList[index]]['OPP_PTS'].toString(),
                                          style: kBebasNormal.copyWith(fontSize: 14.0),
                                        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: Text(
        seasonType,
        style: kBebasNormal.copyWith(fontSize: 14.0),
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
