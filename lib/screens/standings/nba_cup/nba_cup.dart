import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/standings/nba_cup/knockout_bracket.dart';
import 'package:splash/screens/standings/nba_cup/wildcard_standings.dart';

import '../../../utilities/constants.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import 'group_standings.dart';

class NbaCup extends StatefulWidget {
  final Map<String, dynamic> cupData;
  final String selectedSeason;
  const NbaCup({super.key, required this.cupData, required this.selectedSeason});

  @override
  State<NbaCup> createState() => _NbaCupState();
}

class _NbaCupState extends State<NbaCup>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController = TabController(length: 3, vsync: this);
  late Map<String, dynamic> groups;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    setGroups();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController('nba_cup', _scrollController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController('nba_cup');
    _scrollController.dispose();
    super.dispose();
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
          labelStyle: kBebasNormal.copyWith(fontSize: 16.0.r),
          tabs: [
            Tab(text: 'Groups'),
            Tab(text: 'Wild Card'),
            if (widget.cupData.containsKey('KNOCKOUT')) Tab(text: 'Knockout'),
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
                  columnNames: [
                    groupName,
                    'W',
                    'L',
                    'PCT',
                    'GB',
                    'DIFF',
                    'PTS',
                    'OPP',
                    'GAME 1',
                    'GAME 2',
                    'GAME 3',
                    'GAME 4',
                  ],
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
                    columnNames: const [
                      'EAST',
                      'W',
                      'L',
                      'PCT',
                      'GB',
                      'DIFF',
                      'PTS',
                      'OPP',
                      'GAME 1',
                      'GAME 2',
                      'GAME 3',
                      'GAME 4',
                    ],
                    standings: widget.cupData['WILD CARD']['East']!,
                    season: widget.selectedSeason),
                WildcardStandings(
                    columnNames: const [
                      'WEST',
                      'W',
                      'L',
                      'PCT',
                      'GB',
                      'DIFF',
                      'PTS',
                      'OPP',
                      'GAME 1',
                      'GAME 2',
                      'GAME 3',
                      'GAME 4',
                    ],
                    standings: widget.cupData['WILD CARD']['West']!,
                    season: widget.selectedSeason),
              ],
            ),
          ),
          if (widget.cupData.containsKey('KNOCKOUT'))
            KnockoutBracket(knockoutData: widget.cupData['KNOCKOUT'])
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
