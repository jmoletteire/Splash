import 'package:flutter/material.dart';

import '../../../utilities/constants.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';

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
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  Color awayContainerColor = const Color(0xFF111111);
  Color homeContainerColor = const Color(0xFF111111);
  Color teamContainerColor = const Color(0xFF111111);
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();

    _tabController.addListener(() {
      _selectedIndex.value = _tabController.index;
      switch (_tabController.index) {
        case 0:
          setState(() {
            awayContainerColor = kTeamColors[kTeamNames[widget.awayId][1]]!['primaryColor']!;
            homeContainerColor = const Color(0xFF1B1B1B);
            teamContainerColor = const Color(0xFF1B1B1B);
          });
        case 2:
          setState(() {
            awayContainerColor = const Color(0xFF1B1B1B);
            homeContainerColor = kTeamColors[kTeamNames[widget.homeId][1]]!['primaryColor']!;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController(_scrollController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController(_scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 0.0),
          controller: _tabController,
          indicator: CustomTabIndicator(
            controller: _tabController,
            homeTeam: kTeamNames[widget.homeId][1],
            awayTeam: kTeamNames[widget.awayId][1],
          ),
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
                        colors: [const Color(0xFF1B1B1B), awayContainerColor],
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
                    margin: const EdgeInsets.only(bottom: 3.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B1B1B), homeContainerColor],
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
