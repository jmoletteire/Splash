import 'package:flutter/material.dart';
import 'package:splash/screens/game/boxscore/box_player_stats.dart';
import 'package:splash/utilities/constants.dart';

import 'box_team_stats.dart';

class GameBoxScore extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const GameBoxScore(
      {super.key, required this.game, required this.homeId, required this.awayId});

  @override
  State<GameBoxScore> createState() => _GameBoxScoreState();
}

class _GameBoxScoreState extends State<GameBoxScore> with TickerProviderStateMixin {
  late TabController _boxscoreTabController;
  ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  late Map<String, dynamic> gameBoxscore;
  late Map<String, dynamic> gameAdv;

  @override
  void initState() {
    super.initState();
    gameBoxscore = widget.game['BOXSCORE'];
    gameAdv = widget.game['ADV'];
    _boxscoreTabController = TabController(length: 3, vsync: this);
    _boxscoreTabController.addListener(() {
      _selectedIndex.value = _boxscoreTabController.index;
    });
  }

  @override
  void dispose() {
    _boxscoreTabController.dispose();
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
      teamStats.add({...boxTeamStats[i], ...advTeamStats[i]});
    }

    return Column(
      children: [
        TabBar.secondary(
          controller: _boxscoreTabController,
          //indicatorSize: TabBarIndicatorSize.tab,
          //indicatorColor: Colors.deepOrange,
          //indicatorWeight: 3.0,
          indicator: CustomTabIndicator(
              controller: _boxscoreTabController,
              homeTeam: homePlayerStats[0]['TEAM_ABBREVIATION'],
              awayTeam: awayPlayerStats[0]['TEAM_ABBREVIATION']),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle: kBebasNormal,
          tabs: <Widget>[
            Tab(
              text: kTeamNames[widget.awayId][0],
            ),
            const Tab(
              text: "TEAM",
            ),
            Tab(
              text: kTeamNames[widget.homeId][0],
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _boxscoreTabController,
            children: [
              CustomScrollView(slivers: [BoxPlayerStats(players: awayPlayerStats)]),
              CustomScrollView(slivers: [BoxTeamStats(teams: teamStats)]),
              CustomScrollView(slivers: [BoxPlayerStats(players: homePlayerStats)]),
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
