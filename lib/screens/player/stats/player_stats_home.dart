import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/player/stats/player_fantasy_stats.dart';
import 'package:splash/screens/player/stats/player_stats.dart';

import '../../../utilities/constants.dart';

class PlayerStatsHome extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerStatsHome({super.key, required this.team, required this.player});

  @override
  State<PlayerStatsHome> createState() => _PlayerStatsHomeState();
}

class _PlayerStatsHomeState extends State<PlayerStatsHome>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar.secondary(
            controller: _tabController,
            indicatorColor: kDarkSecondaryColors
                    .contains(kTeamIdToName[widget.team['TEAM_ID'].toString()][1])
                ? kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!
                : kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!,
            indicatorWeight: 2.0,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            labelStyle: kBebasNormal.copyWith(fontSize: 16.0.r),
            labelPadding: EdgeInsets.symmetric(horizontal: 16.0.r, vertical: 0.0.r),
            tabs: const [
              Tab(text: 'Stats'),
              Tab(text: 'Fantasy'),
            ]),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              PlayerStats(team: widget.team, player: widget.player),
              PlayerFantasyStats(team: widget.team, player: widget.player),
            ],
          ),
        ),
      ],
    );
  }
}
