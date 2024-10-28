import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/more/draft/by_pick/selections_by_pick.dart';
import 'package:splash/screens/more/draft/by_year/draftRound.dart';
import 'package:splash/screens/more/draft/draft_network_helper.dart';
import 'package:splash/screens/more/draft/draft_stats.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../search_screen.dart';
import 'draft_cache.dart';

class Draft extends StatefulWidget {
  final String? season;
  const Draft({super.key, this.season});

  @override
  State<Draft> createState() => _DraftState();
}

class _DraftState extends State<Draft> with SingleTickerProviderStateMixin {
  late List<dynamic> draft;
  late List<dynamic> draftByPick;
  late Map<String, dynamic> draftStats;
  late Map<String, dynamic> pickStats;
  List<dynamic> firstRound = [];
  List<dynamic> secondRound = [];
  List<dynamic> thirdRound = [];
  List<dynamic> fourthRound = [];
  List<dynamic> fifthRound = [];
  List<dynamic> sixthRound = [];
  List<dynamic> seventhRound = [];
  List<dynamic> eighthRound = [];
  List<dynamic> ninthRound = [];
  List<dynamic> tenthRound = [];
  bool _isLoadingByYear = true;
  bool _isLoadingByPick = true;
  late String selectedSeason;
  late int selectedPick;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  late TabController _tabController;

  List<String> seasons = [
    '2024-25',
    '2023-24',
    '2022-23',
    '2021-22',
    '2020-21',
    '2019-20',
    '2018-19',
    '2017-18',
    '2016-17',
    '2015-16',
    '2014-15',
    '2013-14',
    '2012-13',
    '2011-12',
    '2010-11',
    '2009-10',
    '2008-09',
    '2007-08',
    '2006-07',
    '2005-06',
    '2004-05',
    '2003-04',
    '2002-03',
    '2001-02',
    '2000-01',
    '1999-00',
    '1998-99',
    '1997-98',
    '1996-97',
    '1995-96',
    '1994-95',
    '1993-94',
    '1992-93',
    '1991-92',
    '1990-91',
    '1989-90',
    '1988-89',
    '1987-88',
    '1986-87',
    '1985-86',
    '1984-85',
    '1983-84',
    '1982-83',
    '1981-82',
    '1980-81',
    '1979-80',
    '1978-79',
    '1977-78',
    '1976-77',
    '1975-76',
    '1974-75',
    '1973-74',
    '1972-73',
    '1971-72',
    '1970-71',
    '1969-70',
    '1968-69',
    '1967-68',
    '1966-67',
    '1965-66',
    '1964-65',
    '1963-64',
    '1962-63',
    '1961-62',
    '1960-61',
    '1959-60',
    '1958-59',
    '1957-58',
    '1956-57',
    '1955-56',
    '1954-55',
    '1953-54',
    '1952-53',
    '1951-52',
    '1950-51',
    '1949-50',
    '1948-49',
    '1947-48',
  ];

  Future<void> getDraft(String draftYear) async {
    final draftCache = Provider.of<DraftCache>(context, listen: false);
    if (draftCache.containsDraft(draftYear)) {
      setState(() {
        var fetchedDraft = draftCache.getDraft(draftYear)!;
        draft = fetchedDraft['SELECTIONS'];
        draftStats = {
          'TOTAL': draft.length,
          'HOF': {
            'NUM': fetchedDraft['HOF'] ?? 0,
            'PLAYERS': draft.where((e) => e['HOF'] > 0).toList()
          },
          'MVP': {
            'NUM': fetchedDraft['MVP'] ?? 0,
            'PLAYERS': draft.where((e) => e['MVP'] > 0).toList()
          },
          'ALL_NBA': {
            'NUM': fetchedDraft['ALL_NBA'] ?? 0,
            'PLAYERS': draft.where((e) => e['ALL_NBA'] > 0).toList()
          },
          'ALL_STAR': {
            'NUM': fetchedDraft['ALL_STAR'] ?? 0,
            'PLAYERS': draft.where((e) => e['ALL_STAR'] > 0).toList()
          },
          'STARTERS': {
            'NUM': fetchedDraft['STARTERS'] ?? 0,
            'PLAYERS': draft.where((e) => (e['STARTER'] ?? 0) > 0).toList()
          },
        };
        setPicks();
        _isLoadingByYear = false;
      });
    } else {
      var fetchedDraft = await DraftNetworkHelper().getDraft(draftYear);
      setState(() {
        draft = fetchedDraft['SELECTIONS'];
        draftStats = {
          'TOTAL': draft.length,
          'HOF': {
            'NUM': fetchedDraft['HOF'] ?? 0,
            'PLAYERS': draft.where((e) => e['HOF'] > 0).toList()
          },
          'MVP': {
            'NUM': fetchedDraft['MVP'] ?? 0,
            'PLAYERS': draft.where((e) => e['MVP'] > 0).toList()
          },
          'ALL_NBA': {
            'NUM': fetchedDraft['ALL_NBA'] ?? 0,
            'PLAYERS': draft.where((e) => e['ALL_NBA'] > 0).toList()
          },
          'ALL_STAR': {
            'NUM': fetchedDraft['ALL_STAR'] ?? 0,
            'PLAYERS': draft.where((e) => e['ALL_STAR'] > 0).toList()
          },
          'STARTERS': {
            'NUM': fetchedDraft['STARTERS'] ?? 0,
            'PLAYERS': draft.where((e) => (e['STARTER'] ?? 0) > 0).toList()
          },
        };
        setPicks();
        _isLoadingByYear = false;
      });
      draftCache.addDraft(draftYear, fetchedDraft);
    }
  }

  Future<void> getDraftByPick(String pick) async {
    var fetchedPicks = await DraftNetworkHelper().getDraftByPick(pick);

    num total = 0;
    num hof = 0;
    num mvp = 0;
    num allNba = 0;
    num allStar = 0;
    num roty = 0;
    num starter = 0;

    List hofPlayers = [];
    List mvpPlayers = [];
    List allNbaPlayers = [];
    List allStarPlayers = [];
    List rotyPlayers = [];
    List starterPlayers = [];

    for (var player in fetchedPicks) {
      total += 1;
      hof += player['HOF'] ?? 0;
      mvp += player['MVP'] ?? 0;
      allNba += player['ALL_NBA'] ?? 0;
      allStar += player['ALL_STAR'] ?? 0;
      roty += player['ROTY'] ?? 0;
      starter += player['STARTER'] ?? 0;

      if (player['HOF'] > 0) {
        hofPlayers.add(player);
        hofPlayers.sort((a, b) => b['SEASON'].compareTo(a['SEASON']));
      }
      if (player['MVP'] > 0) {
        mvpPlayers.add(player);
        mvpPlayers.sort((a, b) => b['SEASON'].compareTo(a['SEASON']));
      }
      if (player['ALL_NBA'] > 0) {
        allNbaPlayers.add(player);
        allNbaPlayers.sort((a, b) => b['SEASON'].compareTo(a['SEASON']));
      }
      if (player['ALL_STAR'] > 0) {
        allStarPlayers.add(player);
        allStarPlayers.sort((a, b) => b['SEASON'].compareTo(a['SEASON']));
      }
      if (player['ROTY'] > 0) {
        rotyPlayers.add(player);
        rotyPlayers.sort((a, b) => b['SEASON'].compareTo(a['SEASON']));
      }
      if ((player['STARTER'] ?? 0) > 0) {
        starterPlayers.add(player);
        starterPlayers.sort((a, b) => b['SEASON'].compareTo(a['SEASON']));
      }
    }
    pickStats = {
      'TOTAL': total.toInt(),
      'HOF': {'NUM': hof.toInt(), 'PLAYERS': hofPlayers},
      'MVP': {'NUM': mvp.toInt(), 'PLAYERS': mvpPlayers},
      'ALL_NBA': {'NUM': allNba.toInt(), 'PLAYERS': allNbaPlayers},
      'ALL_STAR': {'NUM': allStar.toInt(), 'PLAYERS': allStarPlayers},
      'STARTERS': {'NUM': starter.toInt(), 'PLAYERS': starterPlayers},
      'ROTY': {'NUM': roty.toInt(), 'PLAYERS': rotyPlayers},
    };

    setState(() {
      draftByPick = fetchedPicks;
      draftByPick.sort((a, b) => int.parse(b['SEASON']).compareTo(int.parse(a['SEASON'])));
      setPicks();
      _isLoadingByPick = false;
    });
  }

  void setPicks() {
    setState(() {
      firstRound = draft.where((d) => d['ROUND_NUMBER'] == 1).toList();
      secondRound = draft.where((d) => d['ROUND_NUMBER'] == 2).toList();
      thirdRound = [];
      fourthRound = [];
      fifthRound = [];
      sixthRound = [];
      seventhRound = [];
      eighthRound = [];
      ninthRound = [];
      tenthRound = [];

      // 7 rounds from 1985-86 to 1988-89
      if (int.parse(selectedSeason.substring(0, 4)) < 1989) {
        thirdRound = draft.where((d) => d['ROUND_NUMBER'] == 3).toList();
        fourthRound = draft.where((d) => d['ROUND_NUMBER'] == 4).toList();
        fifthRound = draft.where((d) => d['ROUND_NUMBER'] == 5).toList();
        sixthRound = draft.where((d) => d['ROUND_NUMBER'] == 6).toList();
        seventhRound = draft.where((d) => d['ROUND_NUMBER'] == 7).toList();
      }

      // 7 rounds from 1973-74 to 1984-85
      if (int.parse(selectedSeason.substring(0, 4)) < 1985) {
        eighthRound = draft.where((d) => d['ROUND_NUMBER'] == 8).toList();
        ninthRound = draft.where((d) => d['ROUND_NUMBER'] == 9).toList();
        tenthRound = draft.where((d) => d['ROUND_NUMBER'] == 10).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add a listener to update the AppBar actions when the tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Rebuild the widget when tab index changes
      }
    });

    selectedSeason = widget.season ?? seasons.first;
    selectedPick = 1;
    getDraft(selectedSeason.substring(0, 4));
    getDraftByPick(selectedPick.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController('draft', _scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController('draft');
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> getActions(int index) {
    if (index == 0) {
      return [
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border.all(color: Colors.deepOrange),
              borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.symmetric(vertical: 6.0.r),
          child: DropdownButton<String>(
            menuMaxHeight: 300.0.r,
            isExpanded: false,
            padding: EdgeInsets.symmetric(horizontal: 15.0.r),
            borderRadius: BorderRadius.circular(10.0),
            underline: Container(),
            dropdownColor: Colors.grey.shade900,
            value: selectedSeason.substring(0, 4),
            items: seasons.map((String value) {
              return DropdownMenuItem<String>(
                value: value.substring(0, 4),
                child: Text(
                  value.substring(0, 4),
                  style: kBebasNormal.copyWith(fontSize: 18.0.r),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) async {
              setState(() {
                selectedSeason = newValue!.substring(0, 4);
                _scrollController.jumpTo(0);
              });
              getDraft(selectedSeason);
            },
          ),
        ),
        CustomIconButton(
          icon: Icons.bar_chart_sharp,
          size: 30.0.r,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              backgroundColor: const Color(0xFF111111),
              scrollControlDisabledMaxHeightRatio: 0.7,
              showDragHandle: true,
              builder: (context) {
                return DraftStats(
                  draftStats: draftStats,
                  byPick: false,
                );
              },
            );
          },
        ),
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
      ];
    } else {
      return [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border.all(color: Colors.deepOrange),
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.symmetric(vertical: 6.0.r),
          child: DropdownButton<int>(
            menuMaxHeight: 300.0.r,
            isExpanded: false,
            padding: EdgeInsets.symmetric(horizontal: 15.0.r),
            borderRadius: BorderRadius.circular(10.0),
            underline: Container(),
            dropdownColor: Colors.grey.shade900,
            value: selectedPick, // Ensure selectedValue is an integer
            items: List.generate(60, (index) {
              int value = index + 1; // Generate values from 1 to 60
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value.toString(),
                  style: kBebasNormal.copyWith(fontSize: 18.0.r),
                ),
              );
            }).toList(),
            onChanged: (int? newValue) async {
              setState(() {
                selectedPick = newValue!;
                _scrollController.jumpTo(0);
              });
              getDraftByPick(selectedPick.toString());
            },
          ),
        ),
        CustomIconButton(
          icon: Icons.bar_chart_sharp,
          size: 30.0.r,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              backgroundColor: const Color(0xFF111111),
              scrollControlDisabledMaxHeightRatio: 0.7,
              showDragHandle: true,
              builder: (context) {
                return DraftStats(
                  draftStats: pickStats,
                  byPick: true,
                );
              },
            );
          },
        ),
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
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingByYear || _isLoadingByPick
        ? const SpinningIcon()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey.shade900,
              surfaceTintColor: Colors.grey.shade900,
              title: Text(
                'Draft',
                style: kBebasBold.copyWith(fontSize: 24.0.r),
              ),
              actions: getActions(_tabController.index),
              bottom: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.deepOrange,
                indicatorWeight: 3.0,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                labelStyle: kBebasNormal.copyWith(fontSize: 18.0.r),
                tabs: const [Tab(text: 'By Year'), Tab(text: 'By Pick')],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    DraftRound(
                        round: firstRound, roundNum: 1, isFinalRound: secondRound.isEmpty),
                    if (secondRound.isNotEmpty)
                      DraftRound(
                          round: secondRound, roundNum: 2, isFinalRound: thirdRound.isEmpty),
                    if (thirdRound.isNotEmpty)
                      DraftRound(
                        round: thirdRound,
                        roundNum: 3,
                        isFinalRound: fourthRound.isEmpty,
                      ),
                    if (fourthRound.isNotEmpty)
                      DraftRound(
                        round: fourthRound,
                        roundNum: 4,
                        isFinalRound: fifthRound.isEmpty,
                      ),
                    if (fifthRound.isNotEmpty)
                      DraftRound(
                        round: fifthRound,
                        roundNum: 5,
                        isFinalRound: sixthRound.isEmpty,
                      ),
                    if (sixthRound.isNotEmpty)
                      DraftRound(
                        round: sixthRound,
                        roundNum: 6,
                        isFinalRound: seventhRound.isEmpty,
                      ),
                    if (seventhRound.isNotEmpty)
                      DraftRound(
                        round: seventhRound,
                        roundNum: 7,
                        isFinalRound: eighthRound.isEmpty,
                      ),
                    if (eighthRound.isNotEmpty)
                      DraftRound(
                        round: eighthRound,
                        roundNum: 8,
                        isFinalRound: ninthRound.isEmpty,
                      ),
                    if (ninthRound.isNotEmpty)
                      DraftRound(
                        round: ninthRound,
                        roundNum: 9,
                        isFinalRound: tenthRound.isEmpty,
                      ),
                    if (tenthRound.isNotEmpty)
                      DraftRound(round: tenthRound, roundNum: 10, isFinalRound: true),
                  ],
                ),
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [DraftSelectionsByPick(selections: draftByPick)],
                ),
              ],
            ),
          );
  }
}
