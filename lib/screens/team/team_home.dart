import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/team/overview/team_overview.dart';
import 'package:splash/screens/team/players/team_players_home.dart';
import 'package:splash/screens/team/schedule/team_schedule.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/screens/team/team_history.dart';
import 'package:splash/screens/team/team_stats.dart';
import 'package:splash/utilities/constants.dart';

import '../../utilities/scroll/scroll_controller_notifier.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../../utilities/team.dart';
import '../search_screen.dart';
import 'cap_sheet/team_cap_sheet.dart';
import 'comparison/team_comparison.dart';

class TeamHome extends StatefulWidget {
  static const String id = 'team_home';
  final String teamId;

  const TeamHome({super.key, required this.teamId});

  @override
  State<TeamHome> createState() => _TeamHomeState();
}

class _TeamHomeState extends State<TeamHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  late Map<String, dynamic> team;
  bool _title = false;
  bool _isLoading = true;

  Map<int, double> _scrollPositions = {};

  Future<void> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      setState(() {
        team = teamCache.getTeam(teamId)!;
        _isLoading = false;
      });
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      setState(() {
        team = fetchedTeam;
        _isLoading = false;
      });
      teamCache.addTeam(teamId, team);
    }
  }

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  @override
  void initState() {
    super.initState();
    getTeam(widget.teamId);
    _tabController = TabController(length: _teamPages.length, vsync: this);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _title = _isSliverAppBarExpanded;
        });

        // Save the scroll position of the current tab
        _scrollPositions[_tabController.index] = _scrollController.offset;
      });

    _tabController.addListener(() {
      // If app bar expanded
      if (_scrollController.offset < (201 - kToolbarHeight)) {
        // Remain at current offset
        _scrollController.jumpTo(_scrollController.offset);
      }
      // Else, app bar collapsed and no collapsed position saved
      else {
        // Go to top collapsed position
        _scrollController.jumpTo(201 - kToolbarHeight);
      }
    });
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _title = _isSliverAppBarExpanded;
        });
      });
    _notifier.addController(_scrollController);
  }

  /// ******************************************************
  ///    Dispose of Tab Controller with page to conserve
  ///    memory & improve performance.
  /// ******************************************************

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController(_scrollController);
    _scrollController.dispose();
    super.dispose();
  }

  /// ******************************************************
  ///      Initialize each tab via anonymous function.
  /// ******************************************************

  final List<Widget Function({required Map<String, dynamic> team})> _teamPages = [
    ({required Map<String, dynamic> team}) => TeamOverview(team: team),
    ({required Map<String, dynamic> team}) => TeamSchedule(team: team),
    ({required Map<String, dynamic> team}) => TeamStats(team: team),
    ({required Map<String, dynamic> team}) => TeamPlayersHome(team: team),
    ({required Map<String, dynamic> team}) => TeamCapSheet(team: team),
    ({required Map<String, dynamic> team}) => TeamHistory(team: team),
  ];

  /// ******************************************************
  ///                   Build the page.
  /// ******************************************************

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SpinningIcon(
            color: Colors.deepOrange,
          )
        : Scaffold(
            body: ExtendedNestedScrollView(
              controller: _scrollController,
              floatHeaderSlivers: false,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: kTeamColors[team['ABBREVIATION']]!['primaryColor']!,
                    title: _title
                        ? SvgPicture.asset(
                            'images/NBA_Logos/${team['TEAM_ID']}.svg',
                            fit: BoxFit.contain,
                            width:
                                team['ABBREVIATION'] == 'LAC' || team['ABBREVIATION'] == 'CHI'
                                    ? MediaQuery.of(context).size.width * 0.165
                                    : MediaQuery.of(context).size.width * 0.1,
                          )
                        : null,
                    centerTitle: true,
                    pinned: true,
                    floating: false,
                    expandedHeight: MediaQuery.of(context).size.height * 0.28,
                    flexibleSpace: Stack(
                      fit: StackFit.expand,
                      children: [
                        SvgPicture.asset(
                          'images/NBA_Logos/${team['TEAM_ID']}.svg',
                          fit: BoxFit.cover,
                        ),
                        // Gradient mask to fade out the image towards the bottom
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                kTeamColors[team['ABBREVIATION']]!['primaryColor']!
                                    .withOpacity(kTeamColorOpacity[team['ABBREVIATION']]![
                                        'opacity']!), // Transparent at the top
                                kTeamColors[team['ABBREVIATION']]!['primaryColor']!
                                    .withOpacity(1.0), // Opaque at the bottom
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: FlexibleSpaceBar(
                            centerTitle: true,
                            background: TeamInfo(team: team),
                            collapseMode: CollapseMode.pin,
                          ),
                        ),
                      ],
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: kTeamColors[team['ABBREVIATION']]!['secondaryColor']!,
                      indicatorWeight: 3.0,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      labelStyle: kBebasNormal,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Schedule'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Players'),
                        Tab(text: 'Cap Sheet'),
                        Tab(text: 'History'),
                      ],
                    ),
                    actions: [
                      CustomIconButton(
                        icon: Icons.search,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(),
                            ),
                          );
                        },
                      ),
                      CustomIconButton(
                        icon: Icons.compare_arrows,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamComparison(team: team),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ];
              },
              pinnedHeaderSliverHeightBuilder: () {
                return (208 - kToolbarHeight);
              },
              onlyOneScrollInBody: false,
              body: TabBarView(
                controller: _tabController,
                children: _teamPages.map((page) {
                  return page(team: team); // Pass team object to each page
                }).toList(),
              ),
            ),
          );
  }
}

class TeamInfo extends StatelessWidget {
  const TeamInfo({
    super.key,
    required this.team,
  });

  final Map<String, dynamic> team;

  String getStanding(int confRank) {
    switch (confRank) {
      case 1:
        return '${confRank}st';
      case 2:
        return '${confRank}nd';
      case 3:
        return '${confRank}rd';
      case 21:
        return '${confRank}st';
      case 22:
        return '${confRank}nd';
      case 23:
        return '${confRank}rd';
      default:
        return '${confRank}th';
    }
  }

  Map<String, dynamic> getLastGame() {
    Map<String, dynamic> schedule = team['seasons'][kCurrentSeason]['GAMES'];

    // Convert the map to a list of entries
    var entries = schedule.entries.toList();

    // Sort the entries by the GAME_DATE value
    entries.sort((a, b) => a.value['GAME_DATE'].compareTo(b.value['GAME_DATE']));

    // Extract the sorted keys
    var gameIndex = entries.map((e) => e.key).toList();

    return schedule[gameIndex.last];
  }

  @override
  Widget build(BuildContext context) {
    var lastGame = getLastGame();
    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: SvgPicture.asset(
              'images/NBA_Logos/${team['TEAM_ID']}.svg',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.height * 0.15,
            ),
          ),
          const SizedBox(width: 20.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text:
                      "${team['seasons'][kCurrentSeason]['WINS']!.toInt()}-${team['seasons'][kCurrentSeason]['LOSSES']!.toInt()}",
                  style: kBebasNormal.copyWith(fontSize: 34.0),
                  children: [
                    TextSpan(
                      text:
                          '  (${getStanding(team['seasons'][kCurrentSeason]['CONF_RANK'])} ${team['CONF'].substring(0, 4)})',
                      style: kBebasNormal.copyWith(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "Last Game: ",
                    style: kBebasNormal.copyWith(color: Colors.white70),
                  ),
                  Text(
                    "${lastGame['HOME_AWAY']} ",
                    style: kBebasNormal.copyWith(color: Colors.white70, fontSize: 14.0),
                  ),
                  Text(
                    "${kTeamNames[lastGame['OPP'].toString()][1]} ",
                    style: kBebasNormal.copyWith(color: Colors.white70),
                  ),
                  Text(
                    "(${lastGame['TEAM_PTS'].toString()}-${lastGame['OPP_PTS'].toString()} ",
                    style: kBebasNormal.copyWith(color: Colors.white70),
                  ),
                  Text(
                    "${lastGame['RESULT']}",
                    style: kBebasNormal.copyWith(color: Colors.white70),
                  ),
                  Text(
                    ")",
                    style: kBebasNormal.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Text(
                "Next Game: TBD",
                style: kBebasNormal.copyWith(color: Colors.white70),
              ),
            ],
          )
        ],
      ),
    );
  }
}
