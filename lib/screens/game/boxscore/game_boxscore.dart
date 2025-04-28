import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:splash/screens/game/boxscore/box_player_stats.dart';
import 'package:splash/screens/game/boxscore/linescore.dart';
import 'package:splash/utilities/constants.dart';

import 'box_team_stats.dart';

class GameBoxScore extends StatefulWidget {
  final Map<String, dynamic> game;
  final Map<String, dynamic> homeTeam;
  final Map<String, dynamic> awayTeam;
  final bool inProgress;

  const GameBoxScore({
    super.key,
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
    required this.inProgress,
  });

  @override
  State<GameBoxScore> createState() => _GameBoxScoreState();
}

class _GameBoxScoreState extends State<GameBoxScore> with TickerProviderStateMixin {
  late TabController _boxscoreTabController;
  final ValueNotifier<int> selectedTabIndex = ValueNotifier<int>(1); // Start at index 1
  late Map<String, dynamic> gameBoxscore;
  late LinkedScrollControllerGroup _awayControllers;
  late LinkedScrollControllerGroup _homeControllers;
  late ScrollController _awayStartersController;
  late ScrollController _awayBenchController;
  late ScrollController _homeStartersController;
  late ScrollController _homeBenchController;
  Color awayContainerColor = const Color(0xFF111111);
  Color homeContainerColor = const Color(0xFF111111);
  Color teamContainerColor = const Color(0xFF111111);
  List boxPlayerStats = [];
  List<Map<String, dynamic>> advPlayerStats = [];
  List playerStats = [];
  List awayPlayerStats = [];
  List homePlayerStats = [];
  List teamStats = [];
  List<Map<String, dynamic>> boxTeamStats = [];
  List<Map<String, dynamic>> advTeamStats = [];
  String topScorer = '';
  String topRebounder = '';
  String topAssistant = '';
  int highestPTS = 0;
  int highestREB = 0;
  int highestAST = 0;

  // Function to safely cast and filter the list
  List<Map<String, dynamic>> castToListOfMap(List<dynamic> dynamicList) {
    return dynamicList
        .where((element) => element is Map<String, dynamic>)
        .map((element) => element as Map<String, dynamic>)
        .toList();
  }

  void _initializePlayerStats() {
    boxPlayerStats = homePlayerStats + awayPlayerStats;

    for (var player in boxPlayerStats) {
      if ((int.parse(player['statistics']?['PTS'] ?? '0')) > highestPTS) {
        highestPTS = int.parse(player['statistics']?['PTS'] ?? '0');
        topScorer = player['name'];
      }
      if ((int.parse(player['statistics']?['REB'] ?? '0')) > highestREB) {
        highestREB = int.parse(player['statistics']?['REB'] ?? '0');
        topRebounder = player['name'];
      }
      if ((int.parse(player['statistics']?['AST'] ?? '0')) > highestAST) {
        highestAST = int.parse(player['statistics']?['AST'] ?? '0');
        topAssistant = player['name'];
      }
    }
  }

  void _initializeTabController() {
    _boxscoreTabController = TabController(length: 3, vsync: this);
    _boxscoreTabController.index = 1;

    // Update the ValueNotifier instead of calling setState
    _boxscoreTabController.addListener(() {
      selectedTabIndex.value = _boxscoreTabController.index;
    });

    awayContainerColor = kTeamColors[kTeamIdToName[widget.awayTeam['TEAM_ID'].toString()][1]]
            ?['primaryColor'] ??
        const Color(0xFF00438C);
    homeContainerColor = kTeamColors[kTeamIdToName[widget.homeTeam['TEAM_ID'].toString()][1]]
            ?['primaryColor'] ??
        const Color(0xFF00438C);
    teamContainerColor = const Color(0xFF1B1B1B);
  }

  @override
  void initState() {
    super.initState();

    // Box Score
    gameBoxscore = widget.game['stats'] ?? {};
    homePlayerStats = gameBoxscore['home']?['players'] ?? [];
    awayPlayerStats = gameBoxscore['away']?['players'] ?? [];
    teamStats = [gameBoxscore['home']?['team'] ?? {}, gameBoxscore['away']?['team'] ?? {}];

    // Tab Controller + Listeners
    _initializeTabController();

    // Player Stats
    _initializePlayerStats();

    // Linked Controllers for linked scrolling between Starters and Bench
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
        gameBoxscore = widget.game['stats'] ?? {};
        homePlayerStats = gameBoxscore['home']?['players'] ?? [];
        awayPlayerStats = gameBoxscore['away']?['players'] ?? [];
        teamStats = [gameBoxscore['home']?['team'] ?? {}, gameBoxscore['away']?['team'] ?? {}];
      });

      // Only update if `widget.game` has changed
      if (!mapEquals(oldWidget.game, widget.game)) {
        // Re-calculate player and team stats
        _initializePlayerStats();
      }
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
          homeTeam: widget.homeTeam['TEAM_ID'].toString(),
          awayTeam: kTeamIdToName.containsKey(widget.awayTeam['TEAM_ID'].toString())
              ? widget.awayTeam['TEAM_ID'].toString()
              : '0',
          homeAbbr: widget.homeTeam['ABBREVIATION'],
          awayAbbr: widget.awayTeam['ABBREVIATION'],
          homeScores: [
            int.parse(gameBoxscore['linescore']?['1']?['home'] ?? '0'),
            int.parse(gameBoxscore['linescore']?['2']?['home'] ?? '0'),
            int.parse(gameBoxscore['linescore']?['3']?['home'] ?? '0'),
            int.parse(gameBoxscore['linescore']?['4']?['home'] ?? '0'),
            for (int i = 1; i < 11; i++)
              if (int.parse(gameBoxscore['linescore']?[i]?['home'] ?? '0') > 0)
                int.parse(gameBoxscore['linescore']?[i]?['home'] ?? '0')
          ],
          awayScores: [
            int.parse(gameBoxscore['linescore']?['1']?['away'] ?? '0'),
            int.parse(gameBoxscore['linescore']?['2']?['away'] ?? '0'),
            int.parse(gameBoxscore['linescore']?['3']?['away'] ?? '0'),
            int.parse(gameBoxscore['linescore']?['4']?['away'] ?? '0'),
            for (int i = 1; i < 11; i++)
              if (int.parse(gameBoxscore['linescore']?[i]?['away'] ?? '0') > 0)
                int.parse(gameBoxscore['linescore']?[i]?['away'] ?? '0')
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
          padding: EdgeInsets.symmetric(horizontal: 0.0.r),
          labelPadding: EdgeInsets.symmetric(horizontal: 0.0.r),
          controller: _boxscoreTabController,
          indicator: CustomTabIndicator(
              controller: _boxscoreTabController,
              homeTeam: kTeamColorOpacity.containsKey(widget.homeTeam['ABBREVIATION'])
                  ? widget.homeTeam['ABBREVIATION']
                  : 'FA',
              awayTeam: kTeamColorOpacity.containsKey(widget.awayTeam['ABBREVIATION'])
                  ? widget.awayTeam['ABBREVIATION']
                  : 'FA'),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle: kBebasNormal.copyWith(fontSize: 16.5.r),
          tabs: <Widget>[
            ValueListenableBuilder<int>(
                valueListenable: selectedTabIndex,
                builder: (context, index, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46.0.r,
                          margin: EdgeInsets.only(bottom: 1.0.r),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1B1B1B),
                                index == 0 ? awayContainerColor : const Color(0xFF1B1B1B)
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                          ),
                          child: Tab(
                            text: widget.awayTeam['NICKNAME'] ?? 'Away',
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            ValueListenableBuilder<int>(
                valueListenable: selectedTabIndex,
                builder: (context, index, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46.0.r,
                          margin: EdgeInsets.only(bottom: 1.0.r),
                          color: const Color(0xFF1B1B1B),
                          child: const Tab(
                            text: "TEAM",
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            ValueListenableBuilder<int>(
                valueListenable: selectedTabIndex,
                builder: (context, index, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46.0.r,
                          margin: EdgeInsets.only(bottom: 1.0.r),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1B1B1B),
                                index == 2 ? homeContainerColor : const Color(0xFF1B1B1B)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Tab(
                            text: widget.homeTeam['NICKNAME'] ?? 'Home',
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _boxscoreTabController,
            children: [
              RepaintBoundary(
                child: CustomScrollView(
                  slivers: [
                    BoxPlayerStats(
                      players: reorderStarters(awayPlayerStats.sublist(0, 5)),
                      playerGroup: 'STARTERS',
                      team: teamStats[1],
                      inProgress: widget.game['status'] == 2,
                      controller: _awayStartersController,
                    ),
                    BoxPlayerStats(
                      players: awayPlayerStats.sublist(5),
                      playerGroup: 'BENCH',
                      team: teamStats[1],
                      inProgress: widget.game['status'] == 2,
                      controller: _awayBenchController,
                    ),
                  ],
                ),
              ),
              RepaintBoundary(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(top: 10.0.r),
                      sliver: BoxTeamStats(
                        teams: teamStats,
                        homeId: widget.homeTeam['TEAM_ID'].toString(),
                        awayId: widget.awayTeam['TEAM_ID'].toString(),
                        inProgress: widget.game['status'] == 2,
                      ),
                    )
                  ],
                ),
              ),
              RepaintBoundary(
                child: CustomScrollView(
                  slivers: [
                    BoxPlayerStats(
                      players: reorderStarters(homePlayerStats.sublist(0, 5)),
                      playerGroup: 'STARTERS',
                      team: teamStats[0],
                      inProgress: widget.game['status'] == 2,
                      controller: _homeStartersController,
                    ),
                    BoxPlayerStats(
                      players: homePlayerStats.sublist(5),
                      playerGroup: 'BENCH',
                      team: teamStats[0],
                      inProgress: widget.game['status'] == 2,
                      controller: _homeBenchController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
      paint.color = kTeamColors[awayTeam]?['secondaryColor'] ?? Colors.white;
    } else if (controller.index == 1) {
      paint.color = Colors.deepOrange;
    } else if (controller.index == 2) {
      paint.color = kTeamColors[homeTeam]?['secondaryColor'] ?? Colors.white;
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
