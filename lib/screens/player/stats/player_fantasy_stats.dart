import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/player/stats/player_rotowire_news.dart';
import 'package:splash/utilities/constants.dart';

import '../../game/game_home.dart';
import '../../team/team_cache.dart';

class PlayerFantasyStats extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerFantasyStats({super.key, required this.team, required this.player});

  @override
  State<PlayerFantasyStats> createState() => _PlayerFantasyStatsState();
}

class _PlayerFantasyStatsState extends State<PlayerFantasyStats> {
  List gamelogs = [];
  List nextFiveGames = [];
  Map<int, dynamic> prevGamesMap = {};
  Map<int, bool> _isExpandedMap = {};
  late TeamCache teamCache;

  Map<String, dynamic> getGames() {
    Map<String, dynamic> seasons = widget.player['STATS'] ?? {};
    for (var season in seasons.entries) {
      Map<String, dynamic> seasonTypes = season.value['GAMELOGS'] ?? {};

      for (var seasonType in seasonTypes.entries) {
        for (var game in seasonType.value.entries) {
          gamelogs.add(game.value);
        }
      }
      // Sort the entries by the GAME_DATE value
      gamelogs.sort((a, b) => b['GAME_DATE'].compareTo(a['GAME_DATE']));
    }
    return {};
  }

  void getNextGames() {
    Map<String, dynamic> schedule = widget.team['seasons'][kCurrentSeason]['GAMES'] ?? {};

    if (schedule.isNotEmpty) {
      // Convert the map to a list of entries
      var entries = schedule.entries.toList();

      // Sort the entries by the GAME_DATE value
      entries.sort((a, b) => a.value['GAME_DATE'].compareTo(b.value['GAME_DATE']));

      // Extract the sorted keys
      var games = entries.map((e) => e.key).toList();

      final nextGame = DateTime.parse(schedule[games.last]['GAME_DATE']);
      final today = DateTime.now();

      // Strip the time part by only keeping year, month, and day
      final nextGameDate = DateTime(nextGame.year, nextGame.month, nextGame.day);
      final todayDate = DateTime(today.year, today.month, today.day);

      // If season has not ended
      if (nextGameDate.compareTo(todayDate) >= 0) {
        // Find next game
        for (var game in games) {
          if (nextFiveGames.length == 5) {
            break;
          }
          if (DateTime.parse(schedule[game]['GAME_DATE']).compareTo(todayDate) >= 0 &&
              schedule[game]['RESULT'] != 'Cancelled') {
            nextFiveGames.add(schedule[game]);
            _isExpandedMap[schedule[game]['OPP']] = false;
            prevGamesMap[schedule[game]['OPP']] = gamelogs
                .where((e) =>
                    kTeamAbbrToId[e['MATCHUP'].substring(e['MATCHUP'].length - 3)] ==
                    schedule[game]['OPP'].toString())
                .toList();
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    teamCache = Provider.of<TeamCache>(context, listen: false);
    getGames();
    if (widget.player['ROSTERSTATUS'] == 'Active') getNextGames();
  }

  @override
  Widget build(BuildContext context) {
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

    String getStanding(int rank) {
      switch (rank) {
        case 1:
          return '${rank}st';
        case 2:
          return '${rank}nd';
        case 3:
          return '${rank}rd';
        case 21:
          return '${rank}st';
        case 22:
          return '${rank}nd';
        case 23:
          return '${rank}rd';
        default:
          return '${rank}th';
      }
    }

    Widget upcomingGameRow(Map<String, dynamic> game) {
      List<String> gameDate = formatDate(game['GAME_DATE']);
      Map<String, dynamic>? opp = teamCache.getTeam(game['OPP'].toString());
      Map<String, dynamic> oppStats = {};

      if (opp != null) {
        if (opp['seasons'].containsKey(kCurrentSeason)) {
          oppStats['DRTG'] = [
            opp['seasons'][kCurrentSeason]['STATS']['REGULAR SEASON']['ADV']['DEF_RATING'],
            opp['seasons'][kCurrentSeason]['STATS']['REGULAR SEASON']['ADV']['DEF_RATING_RANK']
          ];
          oppStats['PACE'] = [
            opp['seasons'][kCurrentSeason]['STATS']['REGULAR SEASON']['ADV']['PACE'],
            opp['seasons'][kCurrentSeason]['STATS']['REGULAR SEASON']['ADV']['PACE_RANK']
          ];
        }
      }

      return Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameDate[0],
                  style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.white70),
                ),
                Text(
                  gameDate[1],
                  style: kBebasNormal.copyWith(fontSize: 11.0.r),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game['HOME_AWAY'] == '@' ? '@ ' : ' ',
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
                Text(
                  kTeamIdToName[game['OPP'].toString()][1],
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
                SizedBox(width: 8.0.r),
                SizedBox(
                  width: 25.0.r,
                  height: 20.0.r,
                  child: Image.asset('images/NBA_Logos/${game['OPP']}.png'),
                )
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Text(
                      '${oppStats['DRTG'][0]} ',
                      style: kBebasNormal.copyWith(
                          fontSize: 16.0.r,
                          color: oppStats['DRTG'][1] <= 5
                              ? const Color(0xDFFF3333)
                              : oppStats['DRTG'][1] <= 10
                                  ? Colors.redAccent
                                  : oppStats['DRTG'][1] <= 20
                                      ? Colors.orangeAccent
                                      : oppStats['DRTG'][1] <= 25
                                          ? const Color(0xFF32CE78)
                                          : const Color(0xFF03A208)),
                    ),
                    Text(
                      '  ${getStanding(oppStats['DRTG'][1])}',
                      style: kBebasNormal.copyWith(
                          fontSize: 12.0.r,
                          color: oppStats['DRTG'][1] <= 5
                              ? const Color(0xDFFF3333)
                              : oppStats['DRTG'][1] <= 10
                                  ? Colors.redAccent
                                  : oppStats['DRTG'][1] <= 20
                                      ? Colors.orangeAccent
                                      : oppStats['DRTG'][1] <= 25
                                          ? const Color(0xFF32CE78)
                                          : const Color(0xFF03A208)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${oppStats['PACE'][0].toStringAsFixed(1)} ',
                      style: kBebasNormal.copyWith(
                          fontSize: 16.0.r,
                          color: oppStats['PACE'][1] > 25
                              ? const Color(0xDFFF3333)
                              : oppStats['PACE'][1] > 20
                                  ? Colors.redAccent
                                  : oppStats['PACE'][1] > 10
                                      ? Colors.orangeAccent
                                      : oppStats['PACE'][1] > 5
                                          ? const Color(0xFF32CE78)
                                          : const Color(0xFF03A208)),
                    ),
                    Text(
                      '  ${getStanding(oppStats['PACE'][1])}',
                      style: kBebasNormal.copyWith(
                          fontSize: 12.0.r,
                          color: oppStats['PACE'][1] > 25
                              ? const Color(0xDFFF3333)
                              : oppStats['PACE'][1] > 20
                                  ? Colors.redAccent
                                  : oppStats['PACE'][1] > 10
                                      ? Colors.orangeAccent
                                      : oppStats['PACE'][1] > 5
                                          ? const Color(0xFF32CE78)
                                          : const Color(0xFF03A208)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return !widget.player.keys.contains('STATS') || !widget.player['STATS'].isNotEmpty
        ? Center(
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
                  'No Stats Available',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                // Other content can go here
                SizedBox(height: 20.0.r),
                Text(
                  'Performance',
                  style: kBebasBold.copyWith(fontSize: 18.0.r),
                ),
                SizedBox(height: 10.0.r),
                Stack(
                  children: [
                    Positioned(
                      bottom: 50.0.r,
                      child: Opacity(
                        opacity: 0.2,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0, // Red channel
                            0.2126, 0.7152, 0.0722, 0, 0, // Green channel
                            0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
                            0, 0, 0, 1, 0, // Alpha channel
                          ]),
                          child: Image.network(
                            'https://cdn.nba.com/silos/nba/latest/440x700/${widget.player['PERSON_ID']}.png',
                            width: MediaQuery.of(context).size.width,
                            height: 300.0.r,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300.0.r,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        itemCount: gamelogs.length,
                        itemBuilder: (context, index) {
                          String matchup = gamelogs[index]['MATCHUP'].toString();
                          String oppId =
                              kTeamAbbrToId[matchup.substring(matchup.length - 3)] ?? '0';
                          String currentGameDate = gamelogs[index]['GAME_DATE'];
                          String currentMonth =
                              DateFormat('MMM').format(DateTime.parse(currentGameDate));
                          String currentYear =
                              DateFormat('yy').format(DateTime.parse(currentGameDate));

                          // Check if this is the first item or if the month has changed
                          bool isNewMonth = false;
                          try {
                            isNewMonth = DateFormat('MMM').format(
                                    DateTime.parse(gamelogs[index + 1]['GAME_DATE'])) !=
                                currentMonth;
                          } catch (e) {
                            isNewMonth = false;
                          }

                          return Row(
                            children: [
                              if (isNewMonth)
                                Column(
                                  children: [
                                    Text(
                                      '$currentMonth \'$currentYear',
                                      style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                    ),
                                    SizedBox(height: 5.0.r),
                                    Container(
                                      width: 2.0,
                                      height: 215.0.r,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                        width: 8.0.r), // Spacing between the line and the bar
                                  ],
                                ),
                              Bar(
                                game: gamelogs[index],
                                playerName: widget.player['DISPLAY_FIRST_LAST'] ?? '',
                                date: formatDate(gamelogs[index]['GAME_DATE']),
                                opp: oppId, // Use your oppId here
                                homeAway: gamelogs[index]['MATCHUP'][4] != '@' ? 'vs' : '@',
                                value: gamelogs[index]?['NBA_FANTASY_PTS'] ?? 0,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // More content below the bar chart
                SizedBox(height: 25.0.r),
                Text(
                  'Upcoming Games',
                  style: kBebasBold.copyWith(fontSize: 18.0.r),
                ),
                SizedBox(height: 5.0.r),
                Card(
                  color: Colors.grey.shade900,
                  margin: EdgeInsets.fromLTRB(11.0.r, 0.0, 11.0.r, 11.0.r),
                  child: Padding(
                    padding: EdgeInsets.all(11.0.r),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Date',
                                textAlign: TextAlign.center,
                                style: kBebasNormal.copyWith(fontSize: 14.0.r),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Opp',
                                textAlign: TextAlign.center,
                                style: kBebasNormal.copyWith(fontSize: 14.0.r),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'DRTG',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    'PACE',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        for (var game in nextFiveGames)
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border(bottom: BorderSide(color: Colors.grey.shade700))),
                            child: Theme(
                              data:
                                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: upcomingGameRow(game),
                                trailing: Icon(
                                  _isExpandedMap[game['OPP']]!
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.white70,
                                ),
                                onExpansionChanged: (bool expanded) {
                                  setState(() {
                                    _isExpandedMap[game['OPP']] = expanded;
                                  });
                                },
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(bottom: 20.0.r),
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: prevGamesMap[game['OPP']]!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      int year = int.parse(prevGamesMap[game['OPP']]![index]
                                              ['GAME_ID']
                                          .toString()
                                          .substring(3, 5));
                                      String season = '20$year-${year + 1}';
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (index == 0 ||
                                              (index > 0 &&
                                                  prevGamesMap[game['OPP']]![index]['GAME_ID']
                                                          .toString()
                                                          .substring(3, 5) !=
                                                      prevGamesMap[game['OPP']]![index - 1]
                                                              ['GAME_ID']
                                                          .toString()
                                                          .substring(3, 5)))
                                            Column(
                                              children: [
                                                SizedBox(height: 10.0.r),
                                                Text(season,
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 14.0.r)),
                                                SizedBox(height: 5.0.r),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'DATE',
                                                              style: kBebasNormal.copyWith(
                                                                  fontSize: 12.0.r),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              'OPP',
                                                              style: kBebasNormal.copyWith(
                                                                  fontSize: 12.0.r),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'FP',
                                                              textAlign: TextAlign.center,
                                                              style: kBebasNormal.copyWith(
                                                                  fontSize: 12.0.r),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              'MIN',
                                                              textAlign: TextAlign.center,
                                                              style: kBebasNormal.copyWith(
                                                                  fontSize: 12.0.r),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              'POSS',
                                                              textAlign: TextAlign.center,
                                                              style: kBebasNormal.copyWith(
                                                                  fontSize: 12.0.r),
                                                            ),
                                                          ),
                                                          SizedBox(width: 5.0.r),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'PTS',
                                                        textAlign: TextAlign.center,
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 12.0.r),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'REB',
                                                        textAlign: TextAlign.center,
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 12.0.r),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'AST',
                                                        textAlign: TextAlign.center,
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 12.0.r),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'STL',
                                                        textAlign: TextAlign.center,
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 12.0.r),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'BLK',
                                                        textAlign: TextAlign.center,
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 12.0.r),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'TOV',
                                                        textAlign: TextAlign.center,
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 12.0.r),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        formatDate(
                                                            prevGamesMap[game['OPP']]![index]
                                                                ['GAME_DATE'])[1],
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 12.0.r),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        prevGamesMap[game['OPP']]![index]
                                                                    ['MATCHUP'][4] ==
                                                                '@'
                                                            ? prevGamesMap[game['OPP']]![index]
                                                                    ['MATCHUP']
                                                                .substring(4)
                                                            : prevGamesMap[game['OPP']]![index]
                                                                    ['MATCHUP']
                                                                .substring(8),
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 13.0.r),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Row(children: [
                                                  Expanded(
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      margin: const EdgeInsets.all(0.5),
                                                      decoration: BoxDecoration(
                                                        color: (prevGamesMap[game['OPP']]![
                                                                            index]
                                                                        ['NBA_FANTASY_PTS'] ??
                                                                    0) >=
                                                                40.0
                                                            ? Colors.greenAccent
                                                            : (prevGamesMap[game['OPP']]![
                                                                                index][
                                                                            'NBA_FANTASY_PTS'] ??
                                                                        0) >=
                                                                    20.0
                                                                ? const Color(0xFFFAE16E)
                                                                : const Color(0xFFF38989),
                                                        borderRadius:
                                                            BorderRadius.circular(3.0),
                                                      ),
                                                      child: Text(
                                                        (prevGamesMap[game['OPP']]![index]
                                                                    ['NBA_FANTASY_PTS'] ??
                                                                0)
                                                            .toStringAsFixed(1),
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 14.0.r,
                                                            color: Colors.grey.shade800),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      margin: const EdgeInsets.all(0.5),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            (prevGamesMap[game['OPP']]![index]
                                                                            ['MIN'] ??
                                                                        0) >=
                                                                    29.5
                                                                ? Colors.greenAccent
                                                                : (prevGamesMap[game['OPP']]![
                                                                                    index]
                                                                                ['MIN'] ??
                                                                            0) >
                                                                        24.5
                                                                    ? const Color(0xFFFAE16E)
                                                                    : const Color(0xFFF38989),
                                                        borderRadius:
                                                            BorderRadius.circular(3.0),
                                                      ),
                                                      child: Text(
                                                        (prevGamesMap[game['OPP']]![index]
                                                                    ['MIN'] ??
                                                                0)
                                                            .toStringAsFixed(0),
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 14.0.r,
                                                            color: Colors.grey.shade800),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      alignment: Alignment.center,
                                                      margin: const EdgeInsets.all(0.5),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            (prevGamesMap[game['OPP']]![index]
                                                                            ['POSS'] ??
                                                                        0) >=
                                                                    50
                                                                ? Colors.greenAccent
                                                                : (prevGamesMap[game['OPP']]![
                                                                                    index]
                                                                                ['POSS'] ??
                                                                            0) >
                                                                        38
                                                                    ? const Color(0xFFFAE16E)
                                                                    : const Color(0xFFF38989),
                                                        borderRadius:
                                                            BorderRadius.circular(3.0),
                                                      ),
                                                      child: Text(
                                                        (prevGamesMap[game['OPP']]![index]
                                                                    ['POSS'] ??
                                                                0)
                                                            .toStringAsFixed(0),
                                                        style: kBebasNormal.copyWith(
                                                            fontSize: 14.0.r,
                                                            color: Colors.grey.shade800),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.0.r),
                                                ]),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.all(0.5),
                                                  decoration: BoxDecoration(
                                                    color: (prevGamesMap[game['OPP']]![index]
                                                                    ['PTS'] ??
                                                                0) >=
                                                            20
                                                        ? Colors.greenAccent
                                                        : (prevGamesMap[game['OPP']]![index]
                                                                        ['PTS'] ??
                                                                    0) >=
                                                                10
                                                            ? const Color(0xFFFAE16E)
                                                            : const Color(0xFFF38989),
                                                    borderRadius: BorderRadius.circular(3.0),
                                                  ),
                                                  child: Text(
                                                    (prevGamesMap[game['OPP']]![index]
                                                                ['PTS'] ??
                                                            0)
                                                        .toStringAsFixed(0),
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 14.0.r,
                                                        color: Colors.grey.shade800),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.all(0.5),
                                                  decoration: BoxDecoration(
                                                    color: (prevGamesMap[game['OPP']]![index]
                                                                    ['REB'] ??
                                                                0) >=
                                                            8
                                                        ? Colors.greenAccent
                                                        : (prevGamesMap[game['OPP']]![index]
                                                                        ['REB'] ??
                                                                    0) >=
                                                                5
                                                            ? const Color(0xFFFAE16E)
                                                            : const Color(0xFFF38989),
                                                    borderRadius: BorderRadius.circular(3.0),
                                                  ),
                                                  child: Text(
                                                    (prevGamesMap[game['OPP']]![index]
                                                                ['REB'] ??
                                                            0)
                                                        .toStringAsFixed(0),
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 14.0.r,
                                                        color: Colors.grey.shade800),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.all(0.5),
                                                  decoration: BoxDecoration(
                                                    color: (prevGamesMap[game['OPP']]![index]
                                                                    ['AST'] ??
                                                                0) >=
                                                            5
                                                        ? Colors.greenAccent
                                                        : (prevGamesMap[game['OPP']]![index]
                                                                        ['AST'] ??
                                                                    0) >=
                                                                3
                                                            ? const Color(0xFFFAE16E)
                                                            : const Color(0xFFF38989),
                                                    borderRadius: BorderRadius.circular(3.0),
                                                  ),
                                                  child: Text(
                                                    (prevGamesMap[game['OPP']]![index]
                                                                ['AST'] ??
                                                            0)
                                                        .toStringAsFixed(0),
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 14.0.r,
                                                        color: Colors.grey.shade800),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.all(0.5),
                                                  decoration: BoxDecoration(
                                                    color: (prevGamesMap[game['OPP']]![index]
                                                                    ['STL'] ??
                                                                0) >=
                                                            2
                                                        ? Colors.greenAccent
                                                        : (prevGamesMap[game['OPP']]![index]
                                                                        ['STL'] ??
                                                                    0) ==
                                                                1
                                                            ? const Color(0xFFFAE16E)
                                                            : const Color(0xFFF38989),
                                                    borderRadius: BorderRadius.circular(3.0),
                                                  ),
                                                  child: Text(
                                                    (prevGamesMap[game['OPP']]![index]
                                                                ['STL'] ??
                                                            0)
                                                        .toStringAsFixed(0),
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 14.0.r,
                                                        color: Colors.grey.shade800),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.all(0.5),
                                                  decoration: BoxDecoration(
                                                    color: (prevGamesMap[game['OPP']]![index]
                                                                    ['BLK'] ??
                                                                0) >=
                                                            2
                                                        ? Colors.greenAccent
                                                        : (prevGamesMap[game['OPP']]![index]
                                                                        ['BLK'] ??
                                                                    0) ==
                                                                1
                                                            ? const Color(0xFFFAE16E)
                                                            : const Color(0xFFF38989),
                                                    borderRadius: BorderRadius.circular(3.0),
                                                  ),
                                                  child: Text(
                                                    (prevGamesMap[game['OPP']]![index]
                                                                ['BLK'] ??
                                                            0)
                                                        .toStringAsFixed(0),
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 14.0.r,
                                                        color: Colors.grey.shade800),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.all(0.5),
                                                  decoration: BoxDecoration(
                                                    color: (prevGamesMap[game['OPP']]![index]
                                                                    ['TOV'] ??
                                                                0) <
                                                            2
                                                        ? Colors.greenAccent
                                                        : (prevGamesMap[game['OPP']]![index]
                                                                        ['TOV'] ??
                                                                    0) ==
                                                                2
                                                            ? const Color(0xFFFAE16E)
                                                            : const Color(0xFFF38989),
                                                    borderRadius: BorderRadius.circular(3.0),
                                                  ),
                                                  child: Text(
                                                    (prevGamesMap[game['OPP']]![index]
                                                                ['TOV'] ??
                                                            0)
                                                        .toStringAsFixed(0),
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 14.0.r,
                                                        color: Colors.grey.shade800),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5.0.r),
                Text(
                  'Recent News',
                  style: kBebasBold.copyWith(fontSize: 18.0.r),
                ),
                SizedBox(height: 5.0.r),
                if (widget.player.containsKey('PlayerRotowires'))
                  for (var newsItem in widget.player['PlayerRotowires'])
                    PlayerRotowireNews(
                      playerNews: newsItem,
                      teamAbbr: widget.player['TEAM_ABBREVIATION'],
                    ),
                SizedBox(height: 5.0.r),
              ],
            ),
          );
  }
}

class Bar extends StatelessWidget {
  final Map<String, dynamic> game;
  final String playerName;
  final List<String> date;
  final String opp;
  final String homeAway;
  final double value;

  const Bar({
    Key? key,
    required this.game,
    required this.playerName,
    required this.date,
    required this.opp,
    required this.homeAway,
    required this.value,
  }) : super(key: key);

  void showGameDetails(BuildContext context, Map<String, dynamic> gameData) {
    Color getColor(double value) {
      if (value > 35 && value <= 45) {
        return const Color(0xFF70DAC7);
      } else if (value > 25 && value <= 35) {
        return const Color(0xFFC2DB2F);
      } else if (value > 15 && value <= 25) {
        return const Color(0xFFF0CE1D);
      } else if (value > 5 && value <= 15) {
        return const Color(0xFFF7AA37);
      } else if (value <= 5) {
        return const Color(0xFFFF999B);
      } else {
        return const Color(0xFF32CE78);
      }
    }

    Widget fantasyStatRow(String statName, String abbr, int amount, double fpValue) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$statName: ",
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            ),
          ),
          Expanded(
            child: Text(
              "${(gameData[abbr] ?? '-') == 0 ? '-' : (gameData[abbr] ?? '-')}",
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 16.0.r),
            ),
          ),
          Expanded(
            child: Text(
              fpValue.toString(),
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              "${(gameData[abbr] * fpValue ?? '-') == 0 ? '-' : (gameData[abbr] * fpValue ?? '-').toStringAsFixed(1)}",
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 16.0.r),
            ),
          ),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0.r),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8.0.r, vertical: 4.0.r),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('M/d/yy').format(DateTime.parse(game['GAME_DATE'])),
                style: kBebasNormal.copyWith(fontSize: 19.0.r),
              ),
              SizedBox(width: 25.0.r),
              Row(
                children: [
                  Text(
                    homeAway,
                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                  ),
                  SizedBox(width: 3.0.r),
                  Text(
                    kTeamIdToName[opp][1],
                    style: kBebasNormal,
                  ),
                  SizedBox(width: 3.0.r),
                  SizedBox(
                      width: 20.0.r,
                      height: 20.0.r,
                      child: Image.asset('images/NBA_Logos/$opp.png')),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.0.r),
              Card(
                color: Colors.white10,
                child: Padding(
                  padding: EdgeInsets.all(8.0.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text("Total: ",
                                  style: kBebasBold.copyWith(fontSize: 20.0.r))),
                          Expanded(
                            child: Text(
                              "${gameData['NBA_FANTASY_PTS'] ?? '-'}",
                              textAlign: TextAlign.end,
                              style: kBebasBold.copyWith(
                                  fontSize: 20.0.r,
                                  color: getColor(gameData['NBA_FANTASY_PTS'])),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0.r),
                      fantasyStatRow('Points', 'PTS', gameData['PTS'] ?? 0, 1),
                      fantasyStatRow('Rebounds', 'REB', gameData['REB'] ?? 0, 1.2),
                      fantasyStatRow('Assists', 'AST', gameData['AST'] ?? 0, 1.5),
                      fantasyStatRow('Steals', 'STL', gameData['STL'] ?? 0, 3),
                      fantasyStatRow('Blocks', 'BLK', gameData['BLK'] ?? 0, 3),
                      fantasyStatRow('Turnovers', 'TOV', gameData['TOV'] ?? 0, -1),
                      SizedBox(height: 10.0.r),
                      Row(
                        children: [
                          Text(
                            'Minutes:  ',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade300),
                          ),
                          Text(
                            gameData['MIN_SEC'],
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Possessions:  ',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade300),
                          ),
                          Text(
                            gameData['POSS'].toString(),
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: kBebasNormal.copyWith(fontSize: 15.0.r, color: Colors.deepOrange),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Normalize the bar height based on a maximum value, e.g., 120
    double normalizedHeight = (value * 3).clamp(30.0.r, 215.0.r);
    double valueContainerHeight = 30.0.r; // Height of the rounded container for the value

    Color getColor(double value) {
      if (value > 35 && value <= 45) {
        return const Color(0xFF70DAC7);
      } else if (value > 25 && value <= 35) {
        return const Color(0xFFC2DB2F);
      } else if (value > 15 && value <= 25) {
        return const Color(0xFFF0CE1D);
      } else if (value > 5 && value <= 15) {
        return const Color(0xFFF7AA37);
      } else if (value <= 5) {
        return const Color(0xFFFF999B);
      } else {
        return const Color(0xFF32CE78);
      }
    }

    // Choose colors based on the value, with lighter color for the value container
    Color barColor = getColor(value);
    Color valueContainerColor = barColor.withOpacity(0.8);

    return Container(
      width: 35.0.r, // Width of each bar
      margin: EdgeInsets.symmetric(horizontal: 8.0.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Main part of the bar with gradient
                InkWell(
                  onTap: () => showGameDetails(context, game),
                  child: Container(
                    height: normalizedHeight,
                    width: 40.0.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          barColor, // Lighter at the top
                          Colors.grey.shade800, // Darker at the bottom
                        ],
                      ),
                    ),
                  ),
                ),
                // Value container with rounded edges
                Positioned(
                  top: 252.5.r - normalizedHeight - valueContainerHeight,
                  child: InkWell(
                    onTap: () => showGameDetails(context, game),
                    child: Container(
                      height: valueContainerHeight,
                      width: 40.0.r,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: valueContainerColor,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        value.toStringAsFixed(0),
                        style: kBebasNormal.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.0.r),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameHome(
                      gameId: game['GAME_ID'].toString(),
                      homeId: homeAway == '@' ? opp : game['TEAM_ID'].toString(),
                      awayId: homeAway == '@' ? game['TEAM_ID'].toString() : opp,
                      gameDate: game['GAME_DATE'].substring(0, 10),
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        homeAway,
                        style: kBebasBold.copyWith(fontSize: 10.0.r),
                      ),
                      SizedBox(width: 0.0.r),
                      SizedBox(
                        width: 18.0.r,
                        height: 18.0.r,
                        child: Image.asset(
                          'images/NBA_Logos/$opp.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          width: 18.0.r,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0.r),
                  Text(
                    date[0],
                    style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.white70),
                  ),
                  Text(
                    date[1],
                    style: kBebasNormal.copyWith(fontSize: 12.0.r),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
