import 'package:flutter/material.dart';
import 'package:splash/screens/team/players/rotation.dart';
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar.secondary(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor:
                kDarkSecondaryColors.contains(kTeamNames[widget.team['TEAM_ID'].toString()][1])
                    ? kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!
                    : kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!,
            indicatorWeight: 3.0,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            labelStyle: kBebasNormal.copyWith(fontSize: 18.0),
            tabs: const [
              Tab(text: 'Roster'),
              Tab(text: 'Depth Chart'),
              Tab(text: 'Rotation'),
            ]),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              TeamRoster(team: widget.team),
              TeamRoster(team: widget.team),
              TeamRotation(team: widget.team),
            ],
          ),
        ),
      ],
    );
  }
}
