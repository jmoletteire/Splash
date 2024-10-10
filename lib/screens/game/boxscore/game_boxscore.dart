import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:splash/screens/game/boxscore/box_player_stats.dart';
import 'package:splash/screens/game/boxscore/linescore.dart';
import 'package:splash/utilities/constants.dart';

import 'box_team_stats.dart';

class GameBoxScore extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  final bool inProgress;
  const GameBoxScore({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
    required this.inProgress,
  });

  @override
  State<GameBoxScore> createState() => _GameBoxScoreState();
}

class _GameBoxScoreState extends State<GameBoxScore> with TickerProviderStateMixin {
  late TabController _boxscoreTabController;
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  late Map<String, dynamic> gameBoxscore;
  late Map<String, dynamic> gameAdv;
  late List<dynamic> gameOtherStats;
  late LinkedScrollControllerGroup _awayControllers;
  late LinkedScrollControllerGroup _homeControllers;
  late ScrollController _awayStartersController;
  late ScrollController _awayBenchController;
  late ScrollController _homeStartersController;
  late ScrollController _homeBenchController;
  Color awayContainerColor = const Color(0xFF111111);
  Color homeContainerColor = const Color(0xFF111111);
  Color teamContainerColor = const Color(0xFF111111);

  @override
  void initState() {
    super.initState();
    gameBoxscore = widget.game['BOXSCORE'] ?? {};
    gameAdv = widget.game['ADV'] ?? {};
    gameOtherStats = widget.game['SUMMARY']?['OtherStats'] ?? [];

    _boxscoreTabController = TabController(length: 3, vsync: this);
    _boxscoreTabController.addListener(() {
      _selectedIndex.value = _boxscoreTabController.index;
      switch (_boxscoreTabController.index) {
        case 0:
          setState(() {
            awayContainerColor =
                kTeamColors[kTeamIdToName[widget.awayId][1]]!['primaryColor']!;
            homeContainerColor = const Color(0xFF1B1B1B);
            teamContainerColor = const Color(0xFF1B1B1B);
          });
        case 2:
          setState(() {
            awayContainerColor = const Color(0xFF1B1B1B);
            homeContainerColor =
                kTeamColors[kTeamIdToName[widget.homeId][1]]!['primaryColor']!;
            teamContainerColor = const Color(0xFF1B1B1B);
          });
        default:
          setState(() {
            awayContainerColor = const Color(0xFF1B1B1B);
            homeContainerColor = const Color(0xFF1B1B1B);
            teamContainerColor = const Color(0xFF1B1B1B);
          });
      }
    });
    _boxscoreTabController.index = 1;

    _awayControllers = LinkedScrollControllerGroup();
    _awayStartersController = _awayControllers.addAndGet();
    _awayBenchController = _awayControllers.addAndGet();

    _homeControllers = LinkedScrollControllerGroup();
    _homeStartersController = _homeControllers.addAndGet();
    _homeBenchController = _homeControllers.addAndGet();
  }

  @override
  void didUpdateWidget(covariant GameBoxScore oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the game data has changed
    if (oldWidget.game != widget.game) {
      setState(() {
        // Update the local state with the new game data
        gameBoxscore = widget.game['BOXSCORE'] ?? {};
        gameAdv = widget.game['ADV'] ?? {};
        gameOtherStats = widget.game['SUMMARY']?['OtherStats'] ?? [];
      });
    }
  }

  @override
  void dispose() {
    _boxscoreTabController.dispose();

    _homeStartersController.dispose();
    _awayStartersController.dispose();
    _homeBenchController.dispose();
    _awayBenchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int season = int.parse(widget.game['SUMMARY']['GameSummary'][0]['SEASON']);

    List reorderStarters(List starters) {
      // Create a new list with the desired order of elements
      List reorderedSublist = [
        starters[4], // index 4
        starters[3], // index 3
        starters[0], // index 0
        starters[1], // index 1
        starters[2], // index 2
      ];

      // Return the reordered sublist
      return reorderedSublist;
    }

    // Function to safely cast and filter the list
    List<Map<String, dynamic>> castToListOfMap(List<dynamic> dynamicList) {
      return dynamicList
          .where((element) => element is Map<String, dynamic>)
          .map((element) => element as Map<String, dynamic>)
          .toList();
    }

    // PLAYER STATS
    List boxPlayerStats = season < 2021
        ? castToListOfMap(gameBoxscore['PlayerStats'])
        : gameBoxscore['homeTeam']['players'] + gameBoxscore['awayTeam']['players'];
    List<Map<String, dynamic>> advPlayerStats =
        gameAdv['PlayerStats'] != null ? castToListOfMap(gameAdv['PlayerStats']) : [];

    List<dynamic> playerStats = [];
    List<dynamic> homePlayerStats = gameBoxscore['homeTeam']?['players'] ?? [];
    List<dynamic> awayPlayerStats = gameBoxscore['awayTeam']?['players'] ?? [];

    String topScorer = '';
    String topRebounder = '';
    String topAssistant = '';

    int highestPTS = 0;
    int highestREB = 0;
    int highestAST = 0;

    // PRE-2021 DATA USES DIFFERENT FORMAT
    if (season < 2021) {
      for (int i = 0; i < boxPlayerStats.length; i++) {
        playerStats.add({...boxPlayerStats[i], ...advPlayerStats[i]});
      }
      for (var player in playerStats) {
        if (player['TEAM_ID'].toString() == widget.homeId) {
          homePlayerStats.add(player);
        } else {
          awayPlayerStats.add(player);
        }
        if ((player['PTS'] ?? 0) > highestPTS) {
          highestPTS = player['PTS'];
          topScorer = player['PLAYER_NAME'].toString();
          int firstSpaceIndex = topScorer.indexOf(' ');
          topScorer = '${topScorer[0]}. ${topScorer.substring(firstSpaceIndex + 1)}';
        }
        if ((player['REB'] ?? 0) > highestREB) {
          highestREB = player['REB'];
          topRebounder = player['PLAYER_NAME'].toString();
          int firstSpaceIndex = topRebounder.indexOf(' ');
          topRebounder = '${topRebounder[0]}. ${topRebounder.substring(firstSpaceIndex + 1)}';
        }
        if ((player['AST'] ?? 0) > highestAST) {
          highestAST = player['AST'];
          topAssistant = player['PLAYER_NAME'].toString();
          int firstSpaceIndex = topAssistant.indexOf(' ');
          topAssistant = '${topAssistant[0]}. ${topAssistant.substring(firstSpaceIndex + 1)}';
        }
      }
    } else {
      // GAME IS FINAL (ADV STATS AVAILABLE)
      if (advPlayerStats.isNotEmpty) {
        // Combine stats for away players
        for (int i = 0; i < awayPlayerStats.length; i++) {
          String playerId = awayPlayerStats[i]['personId']
              .toString(); // Use a unique identifier to match players

          // Find matching boxPlayerStats and advPlayerStats by playerId
          var boxStats = boxPlayerStats.firstWhere(
              (player) => player['personId'].toString() == playerId,
              orElse: () => {});

          var advStats = advPlayerStats.isNotEmpty
              ? advPlayerStats.firstWhere(
                  (player) => player['PLAYER_ID'].toString() == playerId,
                  orElse: () => {})
              : {};

          awayPlayerStats[i]['statistics'] = {
            ...boxStats['statistics'], // This gets the box score stats for the away player
            ...advStats // This adds the adv stats if available
          };
        }

        // Combine stats for home players
        for (int i = 0; i < homePlayerStats.length; i++) {
          String playerId = homePlayerStats[i]['personId']
              .toString(); // Use a unique identifier to match players

          // Find matching boxPlayerStats and advPlayerStats by playerId
          var boxStats = boxPlayerStats.firstWhere(
              (player) => player['personId'].toString() == playerId,
              orElse: () => {});

          var advStats = advPlayerStats.isNotEmpty
              ? advPlayerStats.firstWhere(
                  (player) => player['PLAYER_ID'].toString() == playerId,
                  orElse: () => {})
              : {};

          homePlayerStats[i]['statistics'] = {
            ...boxStats['statistics'], // This gets the box score stats for the home player
            ...advStats // This adds the adv stats if available
          };
        }
      }
    }

    for (var player in boxPlayerStats) {
      if ((player['statistics']?['points'] ?? player['PTS'] ?? 0) > highestPTS) {
        highestPTS = player['statistics']['points'];
        topScorer = player['nameI'];
      }
      if ((player['statistics']?['reboundsTotal'] ?? player['REB'] ?? 0) > highestREB) {
        highestREB = player['statistics']['reboundsTotal'];
        topRebounder = player['nameI'];
      }
      if ((player['statistics']?['assists'] ?? player['AST'] ?? 0) > highestAST) {
        highestAST = player['statistics']['assists'];
        topAssistant = player['nameI'];
      }
    }

    // TEAM STATS
    List<Map<String, dynamic>> boxTeamStats = season < 2021
        ? castToListOfMap(gameBoxscore['TeamStats'])
        : [gameBoxscore['homeTeam']['statistics'], gameBoxscore['awayTeam']['statistics']];
    List<Map<String, dynamic>> advTeamStats =
        gameAdv.isEmpty ? [] : castToListOfMap(gameAdv['TeamStats']);

    boxTeamStats[0]['teamId'] = widget.homeId;
    boxTeamStats[1]['teamId'] = widget.awayId;

    // Adv Stats NOT available, just use basic stats
    List<dynamic> teamStats = gameAdv.isEmpty
        ? [gameBoxscore['homeTeam']['statistics'], gameBoxscore['awayTeam']['statistics']]
        : [];

    if (season < 2021) {
      for (int i = 0; i < boxTeamStats.length; i++) {
        int otherStatsIndex =
            gameOtherStats.indexWhere((stat) => stat['TEAM_ID'] == boxTeamStats[i]['TEAM_ID']);
        teamStats
            .add({...boxTeamStats[i], ...advTeamStats[i], ...gameOtherStats[otherStatsIndex]});
      }
    } else {
      if (advTeamStats.isNotEmpty) {
        Map<String, dynamic> findAndCombineStats(String teamId,
            List<Map<String, dynamic>> boxTeamStats, List<Map<String, dynamic>> advTeamStats) {
          var boxStats =
              boxTeamStats.firstWhere((stat) => stat['teamId'] == teamId, orElse: () => {});
          var advStats =
              advTeamStats.firstWhere((stat) => stat['TEAM_ID'] == teamId, orElse: () => {});
          return {...boxStats, ...advStats};
        }

        teamStats.add(findAndCombineStats(widget.homeId, boxTeamStats, advTeamStats));
        teamStats.add(findAndCombineStats(widget.awayId, boxTeamStats, advTeamStats));
      }
    }

    // LINE SCORE
    var linescore = widget.game['SUMMARY']['LineScore'];

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'].toString() == widget.homeId ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[1]['TEAM_ID'].toString() == widget.homeId ? linescore[0] : linescore[1];

    return Column(
      children: [
        Container(
          height: (kToolbarHeight - 15.0.r) / 4.5.r,
          decoration: const BoxDecoration(
            color: Color(0xFF1B1B1B),
            border: Border(
              top: BorderSide(color: Color(0xFF333333)),
              bottom: BorderSide(color: Color(0xFF2A2A2A)),
            ),
          ),
        ),
        LineScore(
          homeTeam: widget.homeId,
          awayTeam: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
          homeAbbr: homeLinescore['TEAM_ABBREVIATION'],
          awayAbbr: awayLinescore['TEAM_ABBREVIATION'],
          homeScores: [
            homeLinescore['PTS_QTR1'],
            homeLinescore['PTS_QTR2'],
            homeLinescore['PTS_QTR3'],
            homeLinescore['PTS_QTR4'],
            for (int i = 1; i < 11; i++)
              if (homeLinescore['PTS_OT$i'] > 0) homeLinescore['PTS_OT$i']
          ],
          awayScores: [
            awayLinescore['PTS_QTR1'],
            awayLinescore['PTS_QTR2'],
            awayLinescore['PTS_QTR3'],
            awayLinescore['PTS_QTR4'],
            for (int i = 1; i < 11; i++)
              if (awayLinescore['PTS_OT$i'] > 0) awayLinescore['PTS_OT$i']
          ],
        ),
        Container(
          height: kToolbarHeight - 15.0.r,
          decoration: const BoxDecoration(
            color: Color(0xFF1B1B1B),
            border: Border(
              top: BorderSide(color: Colors.white12),
              bottom: BorderSide(color: Color(0xFF333333)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  highestPTS == 0 ? '' : topScorer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey.shade300),
                ),
              ),
              Text(
                highestPTS == 0 ? '' : '  - $highestPTS  PTS',
                style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey.shade300),
              ),
              SizedBox(width: 25.0.r),
              Flexible(
                child: Text(
                  highestREB == 0 ? '' : topRebounder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey.shade300),
                ),
              ),
              Text(
                highestREB == 0 ? '' : '  - $highestREB  REB',
                style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey.shade300),
              ),
              SizedBox(width: 25.0.r),
              Flexible(
                child: Text(
                  highestAST == 0 ? '' : topAssistant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey.shade300),
                ),
              ),
              Text(
                highestAST == 0 ? '' : '  - $highestAST  AST',
                style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey.shade300),
              ),
            ],
          ),
        ),
        TabBar.secondary(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0.0),
          controller: _boxscoreTabController,
          indicator: CustomTabIndicator(
              controller: _boxscoreTabController,
              homeTeam: kTeamColorOpacity.containsKey(homeLinescore['TEAM_ABBREVIATION'])
                  ? homeLinescore['TEAM_ABBREVIATION']
                  : 'FA',
              awayTeam: kTeamColorOpacity.containsKey(awayLinescore['TEAM_ABBREVIATION'])
                  ? awayLinescore['TEAM_ABBREVIATION']
                  : 'FA'),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle: kBebasNormal.copyWith(fontSize: 18.0.r),
          tabs: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46.0.r,
                    margin: const EdgeInsets.only(bottom: 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B1B1B), awayContainerColor],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                    child: Tab(
                      text: awayLinescore['TEAM_NAME'] ?? awayLinescore['TEAM_NICKNAME'],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 1.0),
                    color: const Color(0xFF1B1B1B),
                    child: const Tab(
                      text: "TEAM",
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46.0.r,
                    margin: const EdgeInsets.only(bottom: 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B1B1B), homeContainerColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Tab(
                      text: homeLinescore['TEAM_NAME'] ?? homeLinescore['TEAM_NICKNAME'],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _boxscoreTabController,
            children: [
              CustomScrollView(
                slivers: [
                  BoxPlayerStats(
                    players: reorderStarters(awayPlayerStats.sublist(0, 5)),
                    playerGroup: 'STARTERS',
                    inProgress:
                        widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
                    controller: _awayStartersController,
                  ),
                  BoxPlayerStats(
                    players: awayPlayerStats.sublist(5),
                    playerGroup: 'BENCH',
                    inProgress:
                        widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
                    controller: _awayBenchController,
                  ),
                ],
              ),
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(top: 10.0.r),
                    sliver: BoxTeamStats(
                      teams: teamStats,
                      homeId: widget.homeId,
                      awayId: widget.awayId,
                      inProgress:
                          widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
                    ),
                  )
                ],
              ),
              CustomScrollView(
                slivers: [
                  BoxPlayerStats(
                    players: reorderStarters(homePlayerStats.sublist(0, 5)),
                    playerGroup: 'STARTERS',
                    inProgress:
                        widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
                    controller: _homeStartersController,
                  ),
                  BoxPlayerStats(
                    players: homePlayerStats.sublist(5),
                    playerGroup: 'BENCH',
                    inProgress:
                        widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
                    controller: _homeBenchController,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails axisDirection) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return CustomScrollPhysics();
  }
}

class CustomScrollPhysics extends ClampingScrollPhysics {
  CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }
}

class CustomTabIndicator extends Decoration {
  final TabController controller;
  final String homeTeam;
  final String awayTeam;

  CustomTabIndicator(
      {required this.controller, required this.homeTeam, required this.awayTeam});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(controller: controller, homeTeam: homeTeam, awayTeam: awayTeam);
  }
}

class _CustomPainter extends BoxPainter {
  final TabController controller;
  final String homeTeam;
  final String awayTeam;

  _CustomPainter({required this.controller, required this.homeTeam, required this.awayTeam});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Paint paint = Paint();
    if (controller.index == 0) {
      paint.color = kDarkSecondaryColors.contains(awayTeam)
          ? (kTeamColors[awayTeam]!['primaryColor']!)
          : (kTeamColors[awayTeam]!['secondaryColor']!);
      ;
    } else if (controller.index == 1) {
      paint.color = Colors.deepOrange;
    } else if (controller.index == 2) {
      paint.color = kDarkSecondaryColors.contains(homeTeam)
          ? (kTeamColors[homeTeam]!['primaryColor']!)
          : (kTeamColors[homeTeam]!['secondaryColor']!);
      ;
    } else {
      paint.color = Colors.transparent;
    }

    const double indicatorHeight = 2.0;
    final Offset start = offset + Offset(0, configuration.size!.height - indicatorHeight);
    final Offset end = offset +
        Offset(configuration.size!.width, configuration.size!.height - indicatorHeight);
    canvas.drawLine(start, end, paint);
    canvas.drawLine(start, end, paint..strokeWidth = indicatorHeight);
  }
}
