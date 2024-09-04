import 'package:flutter/material.dart';
import 'package:splash/screens/standings/nba_cup/wildcard_standings.dart';

import '../../../utilities/constants.dart';
import 'group_standings.dart';

class NbaCup extends StatefulWidget {
  final Map<String, dynamic> cupData;
  final String selectedSeason;
  const NbaCup({super.key, required this.cupData, required this.selectedSeason});

  @override
  State<NbaCup> createState() => _NbaCupState();
}

class _NbaCupState extends State<NbaCup> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  late Map<String, dynamic> groups;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    setGroups();
  }

  void setGroups() {
    setState(() {
      groups = {};

      for (var group in widget.cupData['GROUP']['East'].entries) {
        if (!groups.containsKey(group.key)) {
          groups[group.key] = group.value;
        }
      }

      for (var group in widget.cupData['GROUP']['West'].entries) {
        if (!groups.containsKey(group.key)) {
          groups[group.key] = group.value;
        }
      }

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        toolbarHeight: 0.0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.deepOrange,
          indicatorWeight: 3.0,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle: kBebasNormal.copyWith(fontSize: 18.0),
          tabs: const [
            Tab(text: 'Groups'),
            Tab(text: 'Wild Card'),
            Tab(text: 'Knockout'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: groups.keys.map((groupName) {
                return GroupStandings(
                  columnNames: [groupName, 'W', 'L', 'PCT', 'GB', 'DIFF', 'PTS', 'OPP'],
                  standings: groups[groupName]!,
                  season: widget.selectedSeason,
                );
              }).toList(),
            ),
          ),
          ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                WildcardStandings(
                    columnNames: ['EAST', 'W', 'L', 'PCT', 'GB', 'DIFF', 'PTS', 'OPP'],
                    standings: widget.cupData['WILD CARD']['East']!,
                    season: widget.selectedSeason),
                WildcardStandings(
                    columnNames: ['WEST', 'W', 'L', 'PCT', 'GB', 'DIFF', 'PTS', 'OPP'],
                    standings: widget.cupData['WILD CARD']['West']!,
                    season: widget.selectedSeason),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
