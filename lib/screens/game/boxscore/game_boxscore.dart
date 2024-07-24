import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:splash/screens/game/boxscore/box_player_stats.dart';
import 'package:splash/utilities/constants.dart';

import 'box_team_stats.dart';

class GameBoxScore extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const GameBoxScore({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
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

  ScrollController awayTableViewController = ScrollController();

  @override
  void initState() {
    super.initState();
    gameBoxscore = widget.game['BOXSCORE'];
    gameAdv = widget.game['ADV'];
    gameOtherStats = widget.game['SUMMARY']['OtherStats'];

    _boxscoreTabController = TabController(length: 3, vsync: this);
    _boxscoreTabController.addListener(() {
      _selectedIndex.value = _boxscoreTabController.index;
      switch (_boxscoreTabController.index) {
        case 0:
          setState(() {
            awayContainerColor = kTeamColors[kTeamNames[widget.awayId][1]]!['primaryColor']!;
            homeContainerColor = Colors.grey.shade900;
            teamContainerColor = const Color(0xFF111111);
          });
        case 2:
          setState(() {
            awayContainerColor = Colors.grey.shade900;
            homeContainerColor = kTeamColors[kTeamNames[widget.homeId][1]]!['primaryColor']!;
            teamContainerColor = const Color(0xFF111111);
          });
        default:
          setState(() {
            awayContainerColor = Colors.grey.shade900;
            homeContainerColor = Colors.grey.shade900;
            teamContainerColor = Colors.grey.shade900;
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
    // Function to safely cast and filter the list
    List<Map<String, dynamic>> castToListOfMap(List<dynamic> dynamicList) {
      return dynamicList
          .where((element) => element is Map<String, dynamic>)
          .map((element) => element as Map<String, dynamic>)
          .toList();
    }

    List<Map<String, dynamic>> boxPlayerStats = castToListOfMap(gameBoxscore['PlayerStats']);
    List<Map<String, dynamic>> advPlayerStats = castToListOfMap(gameAdv['PlayerStats']);
    List<dynamic> playerStats = [];
    List<dynamic> homePlayerStats = [];
    List<dynamic> awayPlayerStats = [];

    for (int i = 0; i < boxPlayerStats.length; i++) {
      playerStats.add({...boxPlayerStats[i], ...advPlayerStats[i]});
    }

    for (var player in playerStats) {
      if (player['TEAM_ID'].toString() == widget.homeId) {
        homePlayerStats.add(player);
      } else {
        awayPlayerStats.add(player);
      }
    }

    List<Map<String, dynamic>> boxTeamStats = castToListOfMap(gameBoxscore['TeamStats']);
    List<Map<String, dynamic>> advTeamStats = castToListOfMap(gameAdv['TeamStats']);
    List<dynamic> teamStats = [];

    for (int i = 0; i < boxTeamStats.length; i++) {
      teamStats.add({...boxTeamStats[i], ...advTeamStats[i], ...gameOtherStats[i]});
    }

    return Column(
      children: [
        TabBar.secondary(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0.0),
          controller: _boxscoreTabController,
          indicator: CustomTabIndicator(
              controller: _boxscoreTabController,
              homeTeam: homePlayerStats[0]['TEAM_ABBREVIATION'],
              awayTeam: awayPlayerStats[0]['TEAM_ABBREVIATION']),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle: kBebasNormal,
          tabs: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: awayContainerColor,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF111111), awayContainerColor],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 3.0),
                    child: Tab(
                      text: kTeamNames[widget.awayId][0],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 3.0),
                    color: const Color(0xFF111111),
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
                    margin: const EdgeInsets.only(bottom: 3.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF111111), homeContainerColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Tab(
                      text: kTeamNames[widget.homeId][0],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: TabBarView(
              controller: _boxscoreTabController,
              children: [
                CustomScrollView(
                  slivers: [
                    BoxPlayerStats(
                      players: awayPlayerStats.sublist(0, 5),
                      playerGroup: 'STARTERS',
                      controller: _awayStartersController,
                    ),
                    BoxPlayerStats(
                      players: awayPlayerStats.sublist(5),
                      playerGroup: 'BENCH',
                      controller: _awayBenchController,
                    ),
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    BoxTeamStats(
                      teams: teamStats,
                      homeId: widget.homeId,
                      awayId: widget.awayId,
                    )
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    BoxPlayerStats(
                      players: homePlayerStats.sublist(0, 5),
                      playerGroup: 'STARTERS',
                      controller: _homeStartersController,
                    ),
                    BoxPlayerStats(
                      players: homePlayerStats.sublist(5),
                      playerGroup: 'BENCH',
                      controller: _homeBenchController,
                    ),
                  ],
                ),
              ],
            ),
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

    final double indicatorHeight = 3.0;
    final Offset start = offset + Offset(0, configuration.size!.height - indicatorHeight);
    final Offset end = offset +
        Offset(configuration.size!.width, configuration.size!.height - indicatorHeight);
    canvas.drawLine(start, end, paint);
    canvas.drawLine(start, end, paint..strokeWidth = indicatorHeight);
  }
}
