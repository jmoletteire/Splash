import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/more/contracts/players/player_contracts.dart';
import 'package:splash/screens/more/contracts/players/upcoming_free_agents.dart';
import 'package:splash/screens/more/contracts/teams/team_cap_space.dart';

import '../../../components/custom_icon_button.dart';
import '../../../components/spinning_ball_loading.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../../utilities/team.dart';
import '../../search_screen.dart';
import '../../team/team_cache.dart';

class Contracts extends StatefulWidget {
  const Contracts({super.key});

  @override
  State<Contracts> createState() => _ContractsState();
}

class _ContractsState extends State<Contracts> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  Map<String, dynamic> teams = {};
  bool _isLoading = false;

  Future<void> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      setState(() {
        List contracts = teamCache.getTeam(teamId)!['CAP_SHEET']['contracts'];
        teams[teamId] = contracts;
        teams[teamId]['teamId'] = teamId;
        _isLoading = false;
      });
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      List contracts = fetchedTeam['CAP_SHEET']['contracts'];
      setState(() {
        teams[teamId] = contracts;
        teams[teamId]['teamId'] = teamId;
        _isLoading = false;
      });
      teamCache.addTeam(teamId, fetchedTeam);
    }
  }

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);

    for (String teamId in kTeamIdToName.keys) {
      if (teamId != '0') {
        getTeam(teamId);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _notifier.addController('team_contracts', _scrollController);
  }

  /// ******************************************************
  ///    Dispose of Controllers with page to conserve
  ///    memory & improve performance.
  /// ******************************************************

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController('team_contracts');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: _isLoading
          ? const Center(child: SpinningIcon())
          : ExtendedNestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.grey.shade900,
                    surfaceTintColor: Colors.grey.shade900,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.28,
                    title: Text(
                      'Contracts',
                      style: kBebasBold.copyWith(fontSize: 24.0.r),
                    ),
                    flexibleSpace: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          child: Image.asset(
                            'images/NBA_Logos/0.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient mask to fade out the image towards the bottom
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                kTeamColors['FA']!['primaryColor']!.withOpacity(
                                    kTeamColorOpacity['FA']![
                                        'opacity']!), // Transparent at the top
                                kTeamColors['FA']!['primaryColor']!
                                    .withOpacity(1.0), // Opaque at the bottom
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(minWidth: 110.0.r, maxWidth: 120.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/0.png',
                                        width: isLandscape
                                            ? MediaQuery.of(context).size.width * 0.1
                                            : MediaQuery.of(context).size.width * 0.125,
                                        height: isLandscape
                                            ? MediaQuery.of(context).size.width * 0.1
                                            : MediaQuery.of(context).size.height * 0.125,
                                      ),
                                    ),
                                    SizedBox(width: 20.0.r),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Salary Cap: \$${NumberFormat("###,###,###").format(kLeagueSalaryCap[kCurrentSeason.substring(0, 4)])}",
                                              style: kBebasNormal.copyWith(
                                                  fontSize: 18.0.r, color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "First Apron: \$${NumberFormat("###,###,###").format(kLeagueFirstApron[kCurrentSeason.substring(0, 4)])}",
                                              style: kBebasNormal.copyWith(
                                                  fontSize: 18.0.r, color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Second Apron: \$${NumberFormat("###,###,###").format(kLeagueSecondApron[kCurrentSeason.substring(0, 4)])}",
                                              style: kBebasNormal.copyWith(
                                                  fontSize: 18.0.r, color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottom: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Colors.deepOrange,
                        indicatorWeight: 3.0,
                        unselectedLabelColor: Colors.grey,
                        labelColor: Colors.white,
                        labelStyle: kBebasNormal.copyWith(fontSize: 19.0.r),
                        isScrollable: false,
                        //tabAlignment: TabAlignment.start,
                        tabs: const [
                          Tab(text: 'Teams'),
                          Tab(text: 'Players'),
                          Tab(text: 'Upcoming FA'),
                        ]),
                    actions: [
                      CustomIconButton(
                        icon: Icons.search,
                        size: 30.0.r,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ];
              },
              pinnedHeaderSliverHeightBuilder: () {
                return 104.0 + MediaQuery.of(context).padding.top; // 56 + 49 = 105
              },
              onlyOneScrollInBody: true,
              body: TabBarView(
                controller: _tabController,
                children: [
                  CustomScrollView(slivers: [TeamCapSpace(teams: teams)]),
                  CustomScrollView(slivers: [PlayerContracts(teams: teams)]),
                  CustomScrollView(slivers: [
                    UpcomingFreeAgents(
                      teams: teams,
                      season: kCurrentSeason,
                    )
                  ]),
                ],
              ),
            ),
    );
  }
}
