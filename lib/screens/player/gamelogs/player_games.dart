import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splash/screens/player/gamelogs/game_by_game_stats.dart';

import '../../../utilities/constants.dart';

class PlayerGames extends StatefulWidget {
  final Map<String, dynamic> player;
  final Map<String, dynamic> schedule;
  final String selectedSeason;
  final String selectedSeasonType;
  final String selectedMonth;
  final int? opponent;

  const PlayerGames({
    super.key,
    required this.player,
    required this.schedule,
    required this.selectedSeason,
    required this.selectedSeasonType,
    required this.selectedMonth,
    this.opponent,
  });

  @override
  State<PlayerGames> createState() => _PlayerGamesState();
}

class _PlayerGamesState extends State<PlayerGames> {
  late List<String> gamesList;
  late Map<String, dynamic> playerGames;
  double topPadding = 0.0;
  bool _includesPlayoffs = false;
  bool _includesRegSeason = false;

  Map<String, String> seasonTypes = {
    '*': 'ALL',
    '1': 'PRE-SEASON',
    '2': 'REGULAR SEASON',
    '4': 'PLAYOFFS',
    '5': 'PLAY-IN',
    '6': 'NBA CUP',
  };

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

      // Iterate through the schedule map
      schedule.forEach((key, game) {
        // Parse the GAME_DATE field
        String matchup = game['MATCHUP'].toString();
        int oppId = int.parse(kTeamIds[matchup.substring(matchup.length - 3)]!);

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
        String seasonType = game['GAME_ID'].toString().substring(2, 3);

        // Check if the season type matches
        if (seasonTypes[seasonType] == selectedSeasonType) {
          filteredSchedule[key] = game;
        }
      });
      return filteredSchedule;
    }

    // Month filter only
    if ((opponentId == null || opponentId == 0) && month != 'All' && seasonType == 'ALL') {
      //print('Filtering by Month only');
      return filterByMonth(widget.schedule, monthsMap[month]!);
    }
    // Opp filter only
    else if (opponentId != null && opponentId != 0 && month == 'All' && seasonType == 'ALL') {
      //print('Filtering by Opp only');
      return filterByOpp(widget.schedule, opponentId);
    }
    // Season Type filter only
    else if ((opponentId == null || opponentId == 0) &&
        month == 'All' &&
        seasonType != 'ALL') {
      //print('Filtering by Season Type only');
      return filterBySeasonType(widget.schedule, seasonType);
    }
    // Month & Opp filters
    else if (opponentId != 0 && month != 'All' && seasonType == 'ALL') {
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
    else if (opponentId != 0 && month == 'All' && seasonType != 'ALL') {
      //print('Filtering by Season Type & Opp');
      return filterByOpp(filterBySeasonType(widget.schedule, seasonType), opponentId!);
    }
    // All filters
    else if (opponentId != 0 && month != 'All' && seasonType != 'ALL') {
      //print('Filtering by all filters');
      return filterByOpp(
          filterByMonth(filterBySeasonType(widget.schedule, seasonType), monthsMap[month]!),
          opponentId!);
    }
    // No filters
    else {
      //print('No filters');
      return widget.schedule;
    }
  }

  List<String> sortGames() {
    // Convert the map to a list of entries
    var entries = playerGames.entries.toList();

    // Sort the entries by the GAME_DATE value
    entries.sort((a, b) => b.value['GAME_DATE'].compareTo(a.value['GAME_DATE']));

    // Extract the sorted keys
    var gameIndex = entries.map((e) => e.key).toList();

    return gameIndex;
  }

  @override
  void initState() {
    super.initState();
    _includesPlayoffs =
        widget.selectedSeasonType == 'ALL' || widget.selectedSeasonType == 'PLAYOFFS';
    _includesRegSeason =
        widget.selectedSeasonType == 'ALL' || widget.selectedSeasonType == 'REGULAR SEASON';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.opponent == null || widget.opponent == 0 && widget.selectedMonth != 'All') {
      playerGames = getGames(
        widget.selectedSeason,
        widget.selectedMonth,
        null,
        widget.selectedSeasonType,
      );
    } else {
      playerGames = getGames(widget.selectedSeason, widget.selectedMonth, widget.opponent,
          widget.selectedSeasonType);
    }
    gamesList = sortGames();

    _includesPlayoffs =
        widget.selectedSeasonType == 'ALL' || widget.selectedSeasonType == 'PLAYOFFS';
    _includesRegSeason =
        widget.selectedSeasonType == 'ALL' || widget.selectedSeasonType == 'REGULAR SEASON';

    return playerGames.isEmpty
        ? CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
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
              ),
            ],
          )
        : CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100.0),
                sliver: GameByGameStats(
                  player: widget.player,
                  gameIds: gamesList,
                  schedule: playerGames,
                ),
              ),
            ],
          );
  }
}
