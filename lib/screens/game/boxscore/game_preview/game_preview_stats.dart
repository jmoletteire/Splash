import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/game/boxscore/game_preview/team_leaders.dart';
import 'package:splash/screens/game/boxscore/team_player_stats.dart';

import '../../../../utilities/constants.dart';
import '../../../../utilities/team.dart';
import '../../../team/team_cache.dart';

class GamePreviewStats extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const GamePreviewStats({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
  });

  @override
  State<GamePreviewStats> createState() => _GamePreviewStatsState();
}

class _GamePreviewStatsState extends State<GamePreviewStats>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late ScrollController _homeController;
  late ScrollController _awayController;
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  bool _isLoading = false;
  late Map<String, dynamic> homeTeam;
  late Map<String, dynamic> awayTeam;
  Color awayContainerColor = const Color(0xFF111111);
  Color homeContainerColor = const Color(0xFF111111);
  Color teamContainerColor = const Color(0xFF111111);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _homeController = ScrollController();
    _awayController = ScrollController();

    _tabController.addListener(() {
      _selectedIndex.value = _tabController.index;
      switch (_tabController.index) {
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
    _tabController.index = 1;
  }

  Future<List<Map<String, dynamic>>> getTeams(List<String> teamIds) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    List<Future<Map<String, dynamic>>> teamFutures = teamIds.map((teamId) async {
      try {
        if (teamCache.containsTeam(teamId)) {
          return teamCache.getTeam(teamId)!;
        } else {
          var fetchedTeam = await Team().getTeam(teamId);
          teamCache.addTeam(teamId, fetchedTeam);
          return fetchedTeam;
        }
      } catch (e) {
        return {'error': 'not found'}; // Return an empty map in case of an error
      }
    }).toList();

    return await Future.wait(teamFutures);
  }

  void setTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedTeams = await getTeams(kEastConfTeamIds);

      setState(() {
        homeTeam = fetchedTeams[0];
        awayTeam = fetchedTeams[1];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var linescore = widget.game['SUMMARY']['LineScore'];

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'].toString() == widget.homeId ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[0]['TEAM_ID'].toString() == widget.homeId ? linescore[1] : linescore[0];

    return Column(
      children: [
        TabBar(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0.0),
          controller: _tabController,
          indicator: CustomTabIndicator(
            controller: _tabController,
            homeTeam: kTeamIdToName[widget.homeId][1],
            awayTeam: kTeamIdToName[widget.awayId][1],
          ),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle: kBebasNormal.copyWith(fontSize: 18.0.r),
          tabs: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: awayContainerColor,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B1B1B), awayContainerColor],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 1.0),
                    child: Tab(
                      text: awayLinescore['TEAM_NAME'],
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
                    margin: const EdgeInsets.only(bottom: 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B1B1B), homeContainerColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Tab(
                      text: homeLinescore['TEAM_NAME'],
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
              controller: _tabController,
              children: [
                CustomScrollView(
                  slivers: [
                    TeamPlayerStats(players: [], controller: _homeController),
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 10.0),
                      sliver: TeamLeaders(
                        season:
                            '${widget.game['SUMMARY']['GameSummary'][0]['SEASON']}-${(int.parse(widget.game['SUMMARY']['GameSummary'][0]['SEASON'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                        homeId: widget.homeId,
                        awayId: widget.awayId,
                      ),
                    )
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    TeamPlayerStats(players: [], controller: _awayController),
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
      paint.color = kTeamColors[awayTeam]?['secondaryColor'] ?? Colors.white;
      ;
    } else if (controller.index == 1) {
      paint.color = Colors.deepOrange;
    } else if (controller.index == 2) {
      paint.color = kTeamColors[homeTeam]?['secondaryColor'] ?? Colors.white;
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
