import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/standings/playoffs/playoff_bracket.dart';
import 'package:splash/screens/standings/playoffs/playoffs_cache.dart';
import 'package:splash/screens/standings/playoffs/playoffs_network_helper.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/utilities/constants.dart';

import '../../components/custom_icon_button.dart';
import '../../utilities/scroll/scroll_controller_notifier.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../../utilities/team.dart';
import '../search_screen.dart';
import 'conference_standings.dart';
import 'division_standings.dart';
import 'nba_cup/nba_cup.dart';
import 'nba_cup/nba_cup_cache.dart';
import 'nba_cup/nba_cup_network_helper.dart';

class Standings extends StatefulWidget {
  static const String id = 'standings';
  const Standings({super.key});

  @override
  State<Standings> createState() => _StandingsState();
}

class _StandingsState extends State<Standings> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> eastTeams = [];
  List<Map<String, dynamic>> westTeams = [];
  late Map<String, dynamic> divisions;
  late Map<String, dynamic> playoffs;
  late String selectedSeason;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  late LinkedScrollControllerGroup _divControllers;
  late TabController _tabController;
  late ValueNotifier<Map<String, dynamic>> playoffDataNotifier;
  late ValueNotifier<Map<String, dynamic>> cupDataNotifier;

  int selectedYear = 2025;

  void _initializeTabController(int index) {
    int tabLength = 2;
    if (playoffDataNotifier.value.isNotEmpty &&
        !playoffDataNotifier.value.containsKey('error')) {
      tabLength += 1;
    }

    if (selectedYear >= 2024 &&
        cupDataNotifier.value.isNotEmpty &&
        !cupDataNotifier.value.containsKey('error')) {
      tabLength += 1;
    }

    if (index > tabLength - 1) {
      index = 0;
    }

    // Dispose the old TabController if it exists
    _tabController.dispose();

    // Initialize the new TabController
    _tabController = TabController(length: tabLength, vsync: this, initialIndex: index);
  }

  Future<void> _showYearPicker(BuildContext context) async {
    final int? pickedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            'Season',
            style: kBebasBold.copyWith(fontSize: 18.0.r),
          ),
          content: SizedBox(
            width: double.minPositive,
            height: 300.r,
            child: Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.deepOrange, // Selected item color
                    onPrimary: Colors.white, // Selected item text color
                    onSurface: Colors.white, // Unselected item text color
                  ),
                  textTheme: TextTheme(bodyLarge: kBebasNormal.copyWith(fontSize: 18.0.r))),
              child: YearPicker(
                currentDate: DateTime(2025),
                firstDate: DateTime(1981),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                selectedDate: DateTime(selectedYear),
                onChanged: (DateTime dateTime) {
                  Navigator.pop(context, dateTime.year);
                },
              ),
            ),
          ),
        );
      },
    );

    if (pickedYear != null && pickedYear != selectedYear) {
      setState(() {
        selectedYear = pickedYear;
        selectedSeason =
            '${(selectedYear - 1).toString()}-${selectedYear.toString().substring(2)}';
      });
      await setTeams();
      setDivisions();
      await getPlayoffs(selectedSeason);
      await getNbaCup(selectedSeason);

      int tabIndex = _tabController.index;
      _initializeTabController(tabIndex);
    }
  }

  void setDivisions() {
    setState(() {
      divisions = {};

      for (var team in eastTeams) {
        if (team['seasons'].containsKey(selectedSeason)) {
          String div = team['seasons'][selectedSeason]['STANDINGS']['Division'];
          if (!divisions.containsKey(div)) {
            divisions[div] = [];
          }
          divisions[div]!.add(team);
        }
      }

      for (var team in westTeams) {
        if (team['seasons'].containsKey(selectedSeason)) {
          String div = team['seasons'][selectedSeason]['STANDINGS']['Division'];
          if (!divisions.containsKey(div)) {
            divisions[div] = [];
          }
          divisions[div]!.add(team);
        }
      }
      _isLoading = false;
    });
  }

  Future<void> getPlayoffs(String season) async {
    final playoffsCache = Provider.of<PlayoffCache>(context, listen: false);
    if (playoffsCache.containsPlayoffs(season)) {
      playoffDataNotifier.value = playoffsCache.getPlayoffs(season)!;
      setState(() {});
    } else {
      var fetchedPlayoffs = await PlayoffsNetworkHelper().getPlayoffs(season);
      playoffDataNotifier.value = fetchedPlayoffs;
      playoffsCache.addPlayoffs(season, playoffDataNotifier.value);
      setState(() {});
    }
  }

  Future<void> getNbaCup(String season) async {
    final nbaCupCache = Provider.of<NbaCupCache>(context, listen: false);
    if (nbaCupCache.containsNbaCup(season)) {
      cupDataNotifier.value = nbaCupCache.getNbaCup(season)!;
      setState(() {});
    } else {
      var fetchedCup = await NbaCupNetworkHelper().getNbaCup(season);
      cupDataNotifier.value = fetchedCup;
      nbaCupCache.addNbaCup(season, cupDataNotifier.value);
      setState(() {});
    }
  }

  Future<List<Map<String, dynamic>>> getTeams(List<String> teamIds) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    List<Future<Map<String, dynamic>>> teamFutures = teamIds.map((teamId) async {
      try {
        if (teamCache.containsTeam(teamId)) {
          return teamCache.getTeam(teamId)!;
        } else {
          var fetchedTeam = await Team().getTeam(teamId);
          teamCache.addTeam(teamId, fetchedTeam);
          return fetchedTeam;
        }
      } catch (e) {
        return {'error': 'not found'}; // Return an empty map in case of an error
      }
    }).toList();

    return await Future.wait(teamFutures);
  }

  Future<void> setTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedEastTeams = await getTeams(kEastConfTeamIds);
      List<Map<String, dynamic>> fetchedWestTeams = await getTeams(kWestConfTeamIds);

      setState(() {
        eastTeams = fetchedEastTeams;
        westTeams = fetchedWestTeams;
        setDivisions();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    playoffDataNotifier = ValueNotifier<Map<String, dynamic>>({});
    cupDataNotifier = ValueNotifier<Map<String, dynamic>>({});
    selectedSeason = kCurrentSeason;

    _tabController = TabController(length: 2, vsync: this);
    _divControllers = LinkedScrollControllerGroup();

    setTeams();
    getPlayoffs(selectedSeason);
    getNbaCup(selectedSeason);

    // Listen to the changes in playoff and cup data to update tabs
    playoffDataNotifier.addListener(() {
      _initializeTabController(_tabController.index);
    });

    cupDataNotifier.addListener(() {
      _initializeTabController(_tabController.index);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController('standings', _scrollController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController('standings');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: SpinningIcon(
              color: Colors.deepOrange,
            ),
          )
        : ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: playoffDataNotifier,
            builder: (context, playoffData, _) {
              return ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: cupDataNotifier,
                  builder: (context, cupData, _) {
                    return Scaffold(
                      backgroundColor: const Color(0xFF111111),
                      appBar: AppBar(
                        backgroundColor: Colors.grey.shade900,
                        surfaceTintColor: Colors.grey.shade900,
                        title: Text(
                          'Splash',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 32.0.r),
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
                            icon: Icons.calendar_month,
                            size: 30.0.r,
                            onPressed: () {
                              _showYearPicker(context);
                            },
                          ),
                        ],
                        bottom: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: Colors.deepOrange,
                          indicatorWeight: 3.0,
                          unselectedLabelColor: Colors.grey,
                          labelColor: Colors.white,
                          labelStyle:
                              kBebasNormal.copyWith(fontSize: 18.0.r.clamp(14.0, 25.0)),
                          tabs: [
                            const Tab(text: 'Conference'),
                            const Tab(text: 'Division'),
                            if (int.parse(selectedSeason.substring(0, 4)) >= 1986 &&
                                !playoffDataNotifier.value.containsKey('error'))
                              const Tab(text: 'Playoffs'),
                            if (int.parse(selectedSeason.substring(0, 4)) >= 2023 &&
                                !cupDataNotifier.value.containsKey('error'))
                              const Tab(text: 'NBA Cup'),
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
                              slivers: [
                                ConferenceStandings(
                                  columnNames: const [
                                    'EASTERN',
                                    'W',
                                    'L',
                                    'PCT',
                                    'GB',
                                    'NRTG',
                                    'ORTG',
                                    'DRTG',
                                    'PACE',
                                    'STREAK',
                                    'Last 10',
                                    'HOME',
                                    'ROAD',
                                    '> .500',
                                    'EAST',
                                    'WEST',
                                    'ATL',
                                    'CEN',
                                    'SE',
                                    'NW',
                                    'PAC',
                                    'SW',
                                    '100+ PTS',
                                    'LEAD HT',
                                    'LEAD 3Q',
                                    'W - FG%',
                                    'W - REB',
                                    'W - TOV'
                                  ],
                                  standings: eastTeams,
                                  season: selectedSeason,
                                ),
                                ConferenceStandings(
                                  columnNames: const [
                                    'WESTERN',
                                    'W',
                                    'L',
                                    'PCT',
                                    'GB',
                                    'NRTG',
                                    'ORTG',
                                    'DRTG',
                                    'PACE',
                                    'STREAK',
                                    'Last 10',
                                    'HOME',
                                    'ROAD',
                                    '> .500',
                                    'EAST',
                                    'WEST',
                                    'ATL',
                                    'CEN',
                                    'SE',
                                    'NW',
                                    'PAC',
                                    'SW',
                                    '100+ PTS',
                                    'LEAD HT',
                                    'LEAD 3Q',
                                    'W - FG%',
                                    'W - REB',
                                    'W - TOV'
                                  ],
                                  standings: westTeams,
                                  season: selectedSeason,
                                ),
                                const StandingsGlossary(),
                              ],
                            ),
                          ),
                          ScrollConfiguration(
                            behavior: MyCustomScrollBehavior(),
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: divisions.keys.map((divisionName) {
                                return DivisionStandings(
                                  key: UniqueKey(),
                                  columnNames: [
                                    divisionName,
                                    'W',
                                    'L',
                                    'PCT',
                                    'GB',
                                    'NRTG',
                                    'ORTG',
                                    'DRTG',
                                    'PACE',
                                    'STREAK',
                                    'Last 10',
                                    'HOME',
                                    'ROAD',
                                    '> .500',
                                    'EAST',
                                    'WEST',
                                    'ATL',
                                    'CEN',
                                    'SE',
                                    'NW',
                                    'PAC',
                                    'SW',
                                    '100+ PTS',
                                    'LEAD HT',
                                    'LEAD 3Q',
                                    'W - FG%',
                                    'W - REB',
                                    'W - TOV'
                                  ],
                                  standings: divisions[divisionName]!,
                                  season: selectedSeason,
                                  divController: _divControllers.addAndGet(),
                                );
                              }).toList(),
                            ),
                          ),
                          if (int.parse(selectedSeason.substring(0, 4)) >= 1986 &&
                              !playoffDataNotifier.value.containsKey('error'))
                            ValueListenableBuilder<Map<String, dynamic>>(
                              valueListenable: playoffDataNotifier,
                              builder: (context, playoffData, _) {
                                return PlayoffBracket(
                                  key: ValueKey(selectedYear),
                                  playoffData: playoffData,
                                );
                              },
                            ),
                          if (int.parse(selectedSeason.substring(0, 4)) >= 2023 &&
                              !cupDataNotifier.value.containsKey('error'))
                            ValueListenableBuilder<Map<String, dynamic>>(
                              valueListenable: cupDataNotifier,
                              builder: (context, cupData, _) {
                                return NbaCup(
                                  key: ValueKey(selectedYear),
                                  cupData: cupData,
                                  selectedSeason: selectedSeason,
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  });
            });
  }
}

class StandingsGlossary extends StatelessWidget {
  const StandingsGlossary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(8.0.r, 0.0, 8.0.r, 8.0.r),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(15.0.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Standings',
                    style: kBebasNormal.copyWith(fontSize: 18.0.r),
                  ),
                  SizedBox(height: 5.0.r),
                  Row(
                    children: [
                      Text(
                        '-z',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Clinched Conference',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '-y',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Clinched Division',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '-x',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Clinched Playoffs',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '-o',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Eliminated',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0.r),
                  Row(
                    children: [
                      Text(
                        'W',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Wins',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'L',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Losses',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'PCT',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Winning Percentage',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'GB',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      Text(
                        ' - Games Back',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
              LayoutBuilder(builder: (context, constraints) {
                if (isLandscape) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stats',
                        style: kBebasNormal.copyWith(fontSize: 18.0.r),
                      ),
                      SizedBox(height: 5.0.r),
                      Wrap(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'NRTG',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Net Rating',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'ORTG',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Offensive Rating',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'DRTG',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Defensive Rating',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'PACE',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Possessions per 48 Min',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 20.0.r),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Streak',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Current Streak',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Last 10',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Last 10 Games',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Home',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Home Record',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Road',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Road Record',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '> .500',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Teams Over .500',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 20.0.r),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'East',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Eastern Conference',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'West',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Western Conference',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'ATL',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Atlantic Division',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'CEN',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Central Division',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'SE',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Southeast Division',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'NW',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Northwest Division',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'PAC',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Pacific Division',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'SW',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Southwest Division',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 20.0.r),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '100+ PTS',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Scored 100+ Points',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'LEAD HT',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Lead at Halftime',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'LEAD 3Q',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Lead Thru 3 Quarters',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'W - FG%',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Better Field Goal Percentage',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'W - REB',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - More Rebounds',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'W - TOV',
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                  Text(
                                    ' - Fewer Turnovers',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 14.0.r, color: Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stats',
                        style: kBebasNormal.copyWith(fontSize: 18.0.r),
                      ),
                      SizedBox(height: 5.0.r),
                      Row(
                        children: [
                          Text(
                            'NRTG',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Net Rating',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'ORTG',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Offensive Rating',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'DRTG',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Defensive Rating',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'PACE',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Possessions per 48 Minutes',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0.r),
                      Row(
                        children: [
                          Text(
                            'Streak',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Current Streak',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Last 10',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Last 10 Games',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Home',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Home Record',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Road',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Road Record',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '> .500',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Teams Over .500',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0.r),
                      Row(
                        children: [
                          Text(
                            'East',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Eastern Conference',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'West',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Western Conference',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'ATL',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Atlantic Division',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'CEN',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Central Division',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'SE',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Southeast Division',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'NW',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Northwest Division',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'PAC',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Pacific Division',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'SW',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Southwest Division',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0.r),
                      Row(
                        children: [
                          Text(
                            '100+ PTS',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Scored 100+ Points',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'LEAD HT',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Lead at Halftime',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'LEAD 3Q',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Lead Thru 3 Quarters',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'W - FG%',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Better Field Goal Percentage',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'W - REB',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - More Rebounds',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'W - TOV',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          Text(
                            ' - Fewer Turnovers',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              })
            ],
          ),
        ),
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
