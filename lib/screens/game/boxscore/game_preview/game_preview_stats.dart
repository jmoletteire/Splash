import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/game/boxscore/game_preview/team_leaders.dart';
import 'package:splash/screens/game/boxscore/game_preview/team_players_helper.dart';
import 'package:splash/screens/game/boxscore/team_player_stats.dart';
import 'package:splash/screens/game/matchup/components/team_season_stats.dart';

import '../../../../utilities/constants.dart';

class GamePreviewStats extends StatefulWidget {
  final Map<String, dynamic> game;
  final Map<String, dynamic> homeTeam;
  final Map<String, dynamic> awayTeam;

  const GamePreviewStats({
    super.key,
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
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
  List homePlayers = [];
  List awayPlayers = [];
  Color awayContainerColor = const Color(0xFF111111);
  Color homeContainerColor = const Color(0xFF111111);
  Color teamContainerColor = const Color(0xFF111111);

  @override
  bool get wantKeepAlive => true;

  Future<List> getPlayers(String homeId, String awayId) async {
    List home = await TeamPlayers().getTeamPlayers(homeId);
    List away = await TeamPlayers().getTeamPlayers(awayId);

    return [home, away];
  }

  Future<void> setTeams() async {
    try {
      List fetchedPlayers = await getPlayers(
          widget.homeTeam['TEAM_ID'].toString(), widget.awayTeam['TEAM_ID'].toString());

      homeTeam = widget.homeTeam;
      awayTeam = widget.awayTeam;
      homePlayers = fetchedPlayers[0];
      awayPlayers = fetchedPlayers[1];
    } catch (e) {}
  }

  Future<void> initializeData() async {
    setState(() {
      _isLoading = true;
    });

    await setTeams();

    _tabController = TabController(length: 3, vsync: this);
    _homeController = ScrollController();
    _awayController = ScrollController();

    _tabController.addListener(() {
      _selectedIndex.value = _tabController.index;
      switch (_tabController.index) {
        case 0:
          setState(() {
            awayContainerColor = kTeamColors[
                kTeamIdToName[widget.awayTeam['TEAM_ID'].toString()][1]]!['primaryColor']!;
            homeContainerColor = const Color(0xFF1B1B1B);
            teamContainerColor = const Color(0xFF1B1B1B);
          });
        case 2:
          setState(() {
            awayContainerColor = const Color(0xFF1B1B1B);
            homeContainerColor = kTeamColors[
                kTeamIdToName[widget.homeTeam['TEAM_ID'].toString()][1]]!['primaryColor']!;
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SpinningIcon()
        : Column(
            children: [
              TabBar(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                controller: _tabController,
                indicator: CustomTabIndicator(
                  controller: _tabController,
                  homeTeam: kTeamIdToName[widget.homeTeam['TEAM_ID'].toString()][1],
                  awayTeam: kTeamIdToName[widget.awayTeam['TEAM_ID'].toString()][1],
                ),
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                labelStyle: kBebasNormal.copyWith(fontSize: 16.5.r),
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
                            text: widget.awayTeam['NICKNAME'],
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
                            text: widget.homeTeam['NICKNAME'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CustomScrollView(
                      slivers: [
                        TeamPlayerStats(players: awayPlayers, controller: _awayController),
                      ],
                    ),
                    CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.only(top: 10.0.r),
                          sliver: TeamLeaders(
                            season:
                                '${widget.game['season']}-${(int.parse(widget.game['season'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                            homeId: widget.homeTeam['TEAM_ID'].toString(),
                            awayId: widget.awayTeam['TEAM_ID'].toString(),
                            homePlayers: homePlayers,
                            awayPlayers: awayPlayers,
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 10.0.r),
                          sliver: SliverToBoxAdapter(
                            child: TeamSeasonStats(
                              season:
                                  '${widget.game['season']}-${(int.parse(widget.game['season'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                              homeId: widget.homeTeam['TEAM_ID'].toString(),
                              awayId: widget.awayTeam['TEAM_ID'].toString(),
                            ),
                          ),
                        ),
                        //PointsOfEmphasis(points: widget.game['SUMMARY']['PointsOfEmphasis']),
                      ],
                    ),
                    CustomScrollView(
                      slivers: [
                        TeamPlayerStats(players: homePlayers, controller: _homeController),
                      ],
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

  const CustomTabIndicator(
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
