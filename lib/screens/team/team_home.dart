import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/team/overview/team_overview.dart';
import 'package:splash/screens/team/players/team_players_home.dart';
import 'package:splash/screens/team/schedule/team_schedule.dart';
import 'package:splash/screens/team/stats/team_stats.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/screens/team/team_history.dart';
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
          // Save the scroll position of the current tab
          _scrollPositions[_tabController.index] = _scrollController.offset;
        });
      });

    _tabController.addListener(() {
      // If app bar expanded
      if (_scrollController.offset < ((MediaQuery.of(context).size.height * 0.28) - 105.0)) {
        // Remain at current offset
        _scrollController.jumpTo(_scrollController.offset);
      }
      // Else, app bar collapsed and no collapsed position saved
      else {
        // Go to top collapsed position
        _scrollController.jumpTo((MediaQuery.of(context).size.height * 0.28) - 105.0);
      }
    });
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset >= ((MediaQuery.of(context).size.height * 0.28) - 105.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _notifier.addController('team', _scrollController);
  }

  /// ******************************************************
  ///    Dispose of Tab Controller with page to conserve
  ///    memory & improve performance.
  /// ******************************************************

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController('team');
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
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return _isLoading
        ? const SpinningIcon(
            color: Colors.deepOrange,
          )
        : Scaffold(
            body: ExtendedNestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: kTeamColors[team['ABBREVIATION']]!['primaryColor']!,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.28,
                    title: _title
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 40.0),
                            child: Image.asset(
                              team['TEAM_ID'] == 1610612761
                                  ? 'images/NBA_Logos/${team['TEAM_ID']}_alt3.png'
                                  : 'images/NBA_Logos/${team['TEAM_ID']}.png',
                              width: isLandscape
                                  ? MediaQuery.of(context).size.width * 0.0375
                                  : MediaQuery.of(context).size.width * 0.15,
                            ),
                          )
                        : null,
                    centerTitle: true,
                    flexibleSpace: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          child: SvgPicture.asset(
                            'images/NBA_Logos/${team['TEAM_ID']}.svg',
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
                            background: TeamInfo(team: team),
                            collapseMode: CollapseMode.pin,
                          ),
                        ),
                      ],
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      isScrollable: !isLandscape,
                      tabAlignment: !isLandscape ? TabAlignment.start : null,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: kTeamColors[team['ABBREVIATION']]!['secondaryColor']!,
                      indicatorWeight: 3.0,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      labelStyle: kBebasNormal.copyWith(fontSize: 19.0.r),
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
                      CustomIconButton(
                        icon: Icons.people_alt_outlined,
                        size: 30.0.r,
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
                return 104.0 + MediaQuery.of(context).padding.top; // 56 + 49 = 105
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
    for (String season in kSeasons) {
      Map<String, dynamic> schedule = team['seasons']?[season]?['GAMES'] ?? {};

      // Convert the map to a list of entries
      var entries = schedule.entries.toList();

      // Sort the entries by the GAME_DATE value
      entries.sort((a, b) => b.value['GAME_DATE'].compareTo(a.value['GAME_DATE']));

      // Extract the sorted keys
      var games = entries.map((e) => e.key).toList();

      final lastGame = DateTime.parse(schedule[games.last]['GAME_DATE']);
      final today = DateTime.now();

      // Strip the time part by only keeping year, month, and day
      final lastGameDate = DateTime(lastGame.year, lastGame.month, lastGame.day);
      final todayDate = DateTime(today.year, today.month, today.day);

      // If season has started
      if (lastGameDate.compareTo(todayDate) < 0) {
        // Find last game
        for (var game in games) {
          if (DateTime.parse(schedule[game]['GAME_DATE']).compareTo(todayDate) < 0 &&
              schedule[game]['RESULT'] != 'Cancelled') {
            return schedule[game];
          }
        }
      }
    }
    return {};
  }

  Map<String, dynamic> getNextGame() {
    for (String season in kSeasons) {
      Map<String, dynamic> schedule = team['seasons'][season]['GAMES'];

      // Convert the map to a list of entries
      var entries = schedule.entries.toList();

      // Sort the entries by the GAME_DATE value
      entries.sort((a, b) => a.value['GAME_DATE'].compareTo(b.value['GAME_DATE']));

      // Extract the sorted keys
      var games = entries.map((e) => e.key).toList();

      final nextGame = DateTime.parse(schedule[games.last]['GAME_DATE']);
      final today = DateTime.now();

      // Strip the time part by only keeping year, month, and day
      final nextGameDate = DateTime(nextGame.year, nextGame.month, nextGame.day);
      final todayDate = DateTime(today.year, today.month, today.day);

      // If season has not ended
      if (nextGameDate.compareTo(todayDate) >= 0) {
        // Find next game
        for (var game in games) {
          if (DateTime.parse(schedule[game]['GAME_DATE']).compareTo(todayDate) >= 0 &&
              schedule[game]['RESULT'] != 'Cancelled') {
            return schedule[game];
          }
        }
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    var lastGame = getLastGame();
    var nextGame = getNextGame();

    List<String> formatDate(String date) {
      // Parse the string to a DateTime object
      DateTime dateTime = DateTime.parse(date);

      // Create a DateFormat for the abbreviated day of the week
      DateFormat dayOfWeekFormat = DateFormat('E');
      String dayOfWeek = dayOfWeekFormat.format(dateTime);

      // Create a DateFormat for the month and date
      DateFormat monthDateFormat = DateFormat('M/d');
      String monthDate = monthDateFormat.format(dateTime);

      return [dayOfWeek, monthDate];
    }

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 110.0.r, maxWidth: 120.0.r),
              child: SvgPicture.asset(
                'images/NBA_Logos/${team['TEAM_ID']}.svg',
                width: isLandscape
                    ? MediaQuery.of(context).size.width * 0.1
                    : MediaQuery.of(context).size.width * 0.15,
                height: isLandscape
                    ? MediaQuery.of(context).size.width * 0.1
                    : MediaQuery.of(context).size.height * 0.15,
              ),
            ),
            SizedBox(width: 20.0.r),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text:
                        "${team['seasons'][kCurrentSeason]['WINS']!.toInt()}-${team['seasons'][kCurrentSeason]['LOSSES']!.toInt()}",
                    style: kBebasNormal.copyWith(fontSize: 32.0.r),
                    children: [
                      TextSpan(
                        text:
                            '  (${getStanding(team['seasons'][kCurrentSeason]['CONF_RANK'])} ${team['CONF'].substring(0, 4)})',
                        style: kBebasNormal.copyWith(fontSize: 22.0.r),
                      ),
                    ],
                  ),
                ),
                if (lastGame.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        "Last Game: ",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                      Text(
                        "${lastGame['HOME_AWAY']} ",
                        style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.white70),
                      ),
                      Text(
                        "${kTeamIdToName[lastGame['OPP'].toString()]?[1] ?? 'INT\'L'} ",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                      Text(
                        "(${lastGame['TEAM_PTS'].toString()}-${lastGame['OPP_PTS'].toString()} ",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                      Text(
                        "${lastGame['RESULT']}",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                      Text(
                        ")",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                    ],
                  ),
                if (lastGame.isEmpty)
                  Row(
                    children: [
                      Text(
                        "Last Game: ",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                    ],
                  ),
                if (nextGame.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        "Next Game: ",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                      Text(
                        "${nextGame['HOME_AWAY']} ",
                        style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.white70),
                      ),
                      Text(
                        "${kTeamIdToName[nextGame['OPP'].toString()]?[1] ?? 'INT\'L'} ",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                      Text(
                        DateTime.parse(nextGame['GAME_DATE']) ==
                                DateTime(DateTime.now().year, DateTime.now().month,
                                    DateTime.now().day)
                            ? "| Today"
                            : "| ${formatDate(nextGame['GAME_DATE'])[0]}, ${formatDate(nextGame['GAME_DATE'])[1]}",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                    ],
                  ),
                if (nextGame.isEmpty)
                  Row(
                    children: [
                      Text(
                        "Next Game: ",
                        style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white70),
                      ),
                      Text(
                        "TBA",
                        style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.white70),
                      ),
                    ],
                  ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
