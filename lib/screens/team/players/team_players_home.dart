import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/team/players/depth_chart.dart';
import 'package:splash/screens/team/players/rotation.dart';
import 'package:splash/screens/team/players/team_injuries.dart';
import 'package:splash/screens/team/players/team_roster.dart';

import '../../../utilities/constants.dart';

class TeamPlayersHome extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamPlayersHome({super.key, required this.team});

  @override
  State<TeamPlayersHome> createState() => _TeamPlayersHomeState();
}

class _TeamPlayersHomeState extends State<TeamPlayersHome>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        TabBar.secondary(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: kDarkSecondaryColors
                    .contains(kTeamIdToName[widget.team['TEAM_ID'].toString()][1])
                ? kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!
                : kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!,
            indicatorWeight: 3.0,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            labelStyle: kBebasNormal.copyWith(fontSize: 15.0.r),
            labelPadding: EdgeInsets.symmetric(horizontal: 16.0.r, vertical: 0.0.r),
            tabs: const [
              Tab(text: 'Roster'),
              Tab(text: 'Depth Chart'),
              Tab(text: 'Rotation'),
              Tab(text: 'Injuries'),
            ]),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              TeamRoster(team: widget.team),
              DepthChart(team: widget.team),
              TeamRotation(team: widget.team),
              TeamInjuries(team: widget.team),
            ],
          ),
        ),
      ],
    );
  }
}
