import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../../components/expandable_card_controller.dart';
import '../../../components/player_avatar.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../player/player_home.dart';
import '../../search_screen.dart';
import 'award_cache.dart';
import 'awards_network_helper.dart';
import 'by_award/awards_by_award.dart';
import 'by_year/awards.dart';

class LeagueHistory extends StatefulWidget {
  const LeagueHistory({super.key});

  @override
  State<LeagueHistory> createState() => _LeagueHistoryState();
}

class _LeagueHistoryState extends State<LeagueHistory> with SingleTickerProviderStateMixin {
  Map<String, dynamic> year = {};
  late List awardsByAward;
  bool _isLoadingByYear = true;
  bool _isLoadingByAward = true;
  late String selectedSeason;
  late String selectedAward;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  late TabController _tabController;
  List<bool> _isExpandedList = [];
  List expandableAwards = [];
  List nonExpandableAwards = [];

  Map<String, String> awards = {
    'Champion': 'NBA Champion',
    'Finals MVP': 'NBA Finals Most Valuable Player',
    'MVP': 'NBA Most Valuable Player',
    'DPOY': 'NBA Defensive Player of the Year',
    '6-MOTY': 'NBA Sixth Man of the Year',
    'Most Improved': 'NBA Most Improved Player',
    'ROTY': 'NBA Rookie of the Year',
    'All-Star': 'NBA All-Star',
    'All-NBA': 'All-NBA',
    'All-Defense': 'All-Defensive Team',
    'All-Rookie': 'All-Rookie Team',
    'NBA Cup MVP': 'NBA In-Season Tournament Most Valuable Player',
    'All-NBA Cup': 'NBA In-Season Tournament All-Tournament',
  };

  List<String> seasons = [
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017',
    '2016',
    '2015',
    '2014',
    '2013',
    '2012',
    '2011',
    '2010',
    '2009',
    '2008',
    '2007',
    '2006',
    '2005',
    '2004',
    '2003',
    '2002',
    '2001',
    '2000',
    '1999',
    '1998',
    '1997',
    '1996',
    '1995',
    '1994',
    '1993',
    '1992',
    '1991',
    '1990',
    '1989',
    '1988',
    '1987',
    '1986',
    '1985',
    '1984',
    '1983',
    '1982',
    '1981',
    '1980',
    '1979',
    '1978',
    '1977',
    '1976',
    '1975',
    '1974',
    '1973',
    '1972',
    '1971',
    '1970',
    '1969',
    '1968',
    '1967',
    '1966',
    '1965',
    '1964',
    '1963',
    '1962',
    '1961',
    '1960',
    '1959',
    '1958',
    '1957',
    '1956',
    '1955',
    '1954',
    '1953',
    '1952',
    '1951',
    '1950',
    '1949',
    '1948',
    '1947',
  ];

  Future<void> getAwards(String season) async {
    Map<String, String> awardMap = {
      'NBA Champion': 'Champion',
      'NBA Finals Most Valuable Player': 'Finals MVP',
      'All-NBA': 'All-NBA',
      'All-Defensive Team': 'All-Defensive Team',
      'All-Rookie Team': 'All-Rookie Team',
      'NBA Most Valuable Player': 'Most Valuable Player',
      'NBA Defensive Player of the Year': 'Defensive Player of the Year',
      'NBA Sixth Man of the Year': 'Sixth Man of the Year',
      'NBA Most Improved Player': 'Most Improved Player',
      'NBA Rookie of the Year': 'Rookie of the Year',
      'NBA Clutch Player of the Year': 'Clutch Player of the Year',
      'NBA All-Star': 'All-Star',
      'NBA All-Star Most Valuable Player': 'All-Star Game MVP',
      'NBA In-Season Tournament Most Valuable Player': 'NBA Cup MVP',
      'NBA In-Season Tournament All-Tournament': 'All-NBA Cup Team',
      'NBA Player of the Month': 'Player of the Month',
      'NBA Rookie of the Month': 'Rookie of the Month',
      'NBA Player of the Week': 'Player of the Week',
    };

    final awardCache = Provider.of<AwardsCache>(context, listen: false);

    if (awardCache.containsYear(season)) {
      setState(() {
        var fetchedAwards = awardCache.getYear(season)!;
        for (String award in awardMap.keys) {
          if (fetchedAwards.containsKey(award)) {
            year[awardMap[award]!] = fetchedAwards[award];
          }
        }
        expandableAwards = year.entries
            .toList()
            .where((a) =>
                a.value['PLAYERS'].length > 1 && a.value['DESCRIPTION'] != 'NBA Champion')
            .toList();
        nonExpandableAwards = year.entries
            .toList()
            .where((a) =>
                a.value['PLAYERS'].length <= 1 || a.value['DESCRIPTION'] == 'NBA Champion')
            .toList();
        _isExpandedList = List<bool>.filled(expandableAwards.length, false);
        _isLoadingByYear = false;
      });
    } else {
      var fetchedAwards = await AwardsNetworkHelper().getAwards(season);
      setState(() {
        for (String award in awardMap.keys) {
          if (fetchedAwards.containsKey(award)) {
            year[awardMap[award]!] = fetchedAwards[award];
          }
        }
        expandableAwards = year.entries
            .toList()
            .where((a) =>
                a.value['PLAYERS'].length > 1 && a.value['DESCRIPTION'] != 'NBA Champion')
            .toList();
        nonExpandableAwards = year.entries
            .toList()
            .where((a) =>
                a.value['PLAYERS'].length <= 1 || a.value['DESCRIPTION'] == 'NBA Champion')
            .toList();
        _isExpandedList = List<bool>.filled(expandableAwards.length, false);
        _isLoadingByYear = false;
      });
      awardCache.addYear(season, fetchedAwards);
    }
  }

  Future<void> getAwardsByAward(String award) async {
    var fetchedAward = await AwardsNetworkHelper().getAwardsByAward(award);

    setState(() {
      awardsByAward = fetchedAward;
      awardsByAward.sort((a, b) =>
          b[awards[selectedAward]!]['SEASON'].compareTo(a[awards[selectedAward]!]['SEASON']));
      _isLoadingByAward = false;
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

    selectedSeason = seasons.first;
    selectedAward = 'Champion';
    getAwards(selectedSeason);
    getAwardsByAward(awards[selectedAward]!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController('league_history', _scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController('league_history');
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
                year = {};
                expandableAwards = [];
                nonExpandableAwards = [];
              });
              getAwards(selectedSeason);
            },
          ),
        ),
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
          child: DropdownButton<String>(
            menuMaxHeight: 300.0.r,
            isExpanded: false,
            padding: EdgeInsets.symmetric(horizontal: 15.0.r),
            borderRadius: BorderRadius.circular(10.0),
            underline: Container(),
            dropdownColor: Colors.grey.shade900,
            value: selectedAward,
            items: awards.keys.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: kBebasNormal.copyWith(fontSize: 18.0.r),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) async {
              setState(() {
                selectedAward = newValue!;
                _scrollController.jumpTo(0);
                _isLoadingByAward = true;
              });
              getAwardsByAward(awards[selectedAward]!);
            },
          ),
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
    return _isLoadingByYear || _isLoadingByAward
        ? const SpinningIcon()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey.shade900,
              surfaceTintColor: Colors.grey.shade900,
              title: Text(
                'History',
                style: kBebasBold.copyWith(fontSize: 22.0.r),
              ),
              actions: getActions(_tabController.index),
              bottom: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.deepOrange,
                indicatorWeight: 3.0,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                labelStyle: kBebasNormal.copyWith(fontSize: 16.0.r),
                tabs: const [Tab(text: 'By Year'), Tab(text: 'By Award')],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    Awards(
                      awards: nonExpandableAwards,
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate([
                      for (int i = 0; i < expandableAwards.length; i++)
                        ExpandableAwardCard(
                          award: expandableAwards[i],
                          isExpanded: _isExpandedList[i],
                          onExpansionChanged: (isExpanded) {
                            setState(() {
                              _isExpandedList[i] = isExpanded;
                            });
                          },
                        )
                    ]))
                  ],
                ),
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    AwardsByAward(
                      awards: awardsByAward,
                      awardName: awards[selectedAward]!,
                    )
                  ],
                ),
              ],
            ),
          );
  }
}

class ExpandableAwardCard extends StatefulWidget {
  final MapEntry<String, dynamic> award;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const ExpandableAwardCard({
    super.key,
    required this.award,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  State<ExpandableAwardCard> createState() => _ExpandableAwardCardState();
}

class _ExpandableAwardCardState extends State<ExpandableAwardCard> {
  bool _isExpanded = false;
  late final ExpandableCardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableCardController(false);
    _controller.isExpandedNotifier.addListener(_updateExpandedState);
  }

  @override
  void dispose() {
    _controller.isExpandedNotifier.removeListener(_updateExpandedState);
    super.dispose();
  }

  void _updateExpandedState() {
    setState(() {
      _isExpanded = _controller.isExpandedNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    List players = widget.award.value['PLAYERS'];

    if (widget.award.value['PLAYERS'][0]['ALL_NBA_TEAM_NUMBER'] != null) {
      players.sort((a, b) => a['ALL_NBA_TEAM_NUMBER'].compareTo(b['ALL_NBA_TEAM_NUMBER']));
    } else if (widget.award.value['PLAYERS'][0]['MONTH'] != null) {
      players.sort((a, b) => DateFormat('M/d/yyyy')
          .parse(a['MONTH'])
          .compareTo(DateFormat('M/d/yyyy').parse(b['MONTH'])));
    } else if (widget.award.value['PLAYERS'][0]['WEEK'] != null) {
      players.sort((a, b) => a['WEEK'].compareTo(b['WEEK']));
    }

    Map<String, String> teamMap = {
      'Atlanta Hawks': '1610612737',
      'Boston Celtics': '1610612738',
      'Cleveland Cavaliers': '1610612739',
      'New Orleans Pelicans': '1610612740',
      'Chicago Bulls': '1610612741',
      'Dallas Mavericks': '1610612742',
      'Denver Nuggets': '1610612743',
      'Golden State Warriors': '1610612744',
      'Houston Rockets': '1610612745',
      'Los Angeles Clippers': '1610612746',
      'Los Angeles Lakers': '1610612747',
      'Miami Heat': '1610612748',
      'Milwaukee Bucks': '1610612749',
      'Minnesota Timberwolves': '1610612750',
      'Brooklyn Nets': '1610612751',
      'New York Knicks': '1610612752',
      'Orlando Magic': '1610612753',
      'Indiana Pacers': '1610612754',
      'Philadelphia 76ers': '1610612755',
      'Phoenix Suns': '1610612756',
      'Portland Trail Blazers': '1610612757',
      'Sacramento Kings': '1610612758',
      'San Antonio Spurs': '1610612759',
      'Oklahoma City Thunder': '1610612760',
      'Toronto Raptors': '1610612761',
      'Utah Jazz': '1610612762',
      'Memphis Grizzlies': '1610612763',
      'Washington Wizards': '1610612764',
      'Detroit Pistons': '1610612765',
      'Charlotte Hornets': '1610612766',
    };

    String formatDate(String dateString, String format) {
      if (format == 'WEEK') {
        // Format the date to "Nov 21"
        // Parse the date string
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('MMM d').format(dateTime);
      } else {
        // Parse the date string
        DateTime dateTime = DateFormat('M/d/yyyy').parse(dateString);
        return DateFormat('MMM').format(dateTime);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.125,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              elevation: 0,
              materialGapSize: 0.0,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isExpanded = isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  backgroundColor: Colors.transparent,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                      padding: EdgeInsets.only(left: 8.0.r),
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        widget.award.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kBebasNormal.copyWith(
                            color: Colors.grey.shade300, fontSize: 15.0.r),
                      ),
                    );
                  },
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
                    child: Column(
                      children: [
                        for (int i = 0; i < players.length; i++) ...{
                          if (players[i]['ALL_NBA_TEAM_NUMBER'] != null &&
                              (i == 0 ||
                                  (i > 0 &&
                                      players[i]['ALL_NBA_TEAM_NUMBER'] !=
                                          players[i - 1]['ALL_NBA_TEAM_NUMBER'])))
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(8.0.r, 15.0.r, 0.0, 8.0.r),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade600,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          players[i]['ALL_NBA_TEAM_NUMBER'] == '1'
                                              ? 'First Team'
                                              : players[i]['ALL_NBA_TEAM_NUMBER'] == '2'
                                                  ? 'Second Team'
                                                  : 'Third Team',
                                          style: kBebasNormal.copyWith(fontSize: 15.0.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          InkWell(
                            onTap: () {
                              {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerHome(
                                      playerId: players[i]['PLAYER_ID'].toString(),
                                    ),
                                  ),
                                );
                              }
                            },
                            highlightColor: Colors.white54,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                border: Border(
                                  bottom: BorderSide(
                                    color: i == players.length - 1 ||
                                            (players[i]['ALL_NBA_TEAM_NUMBER'] != null &&
                                                (i > 0 &&
                                                    players[i]['ALL_NBA_TEAM_NUMBER'] !=
                                                        players[i + 1]['ALL_NBA_TEAM_NUMBER']))
                                        ? Colors.transparent
                                        : Colors.grey.shade200,
                                    width: 0.125,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(6.0.r, 8.0.r, 0.0, 8.0.r),
                              child: Row(
                                children: [
                                  if (players[i]['MONTH'] != null)
                                    Expanded(
                                      child: Text(
                                        formatDate(players[i]['MONTH'], 'MONTH'),
                                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                      ),
                                    ),
                                  if (players[i]['WEEK'] != null)
                                    Expanded(
                                      child: Text(
                                        formatDate(players[i]['WEEK'], 'WEEK'),
                                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                      ),
                                    ),
                                  Expanded(
                                    flex: 6,
                                    child: Row(
                                      children: [
                                        PlayerAvatar(
                                          radius: 12.0.r,
                                          backgroundColor: Colors.white70,
                                          playerImageUrl:
                                              'https://cdn.nba.com/headshots/nba/latest/1040x760/${players[i]['PLAYER_ID']}.png',
                                          //'https://www.basketball-reference.com/req/202106291/images/headshots/$lastSub${firstName.substring(0, 2).toLowerCase()}01.jpg'
                                        ),
                                        SizedBox(width: 8.0.r),
                                        AutoSizeText(
                                          '${players[i]['FIRST_NAME'] ?? ''} ${players[i]['LAST_NAME'] ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                        ),
                                        SizedBox(width: 8.0.r),
                                        SizedBox(
                                          height: 20.0.r,
                                          width: 20.0.r,
                                          child: Image.asset(
                                              'images/NBA_Logos/${teamMap[players[i]['TEAM']]}.png'),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        }
                      ],
                    ),
                  ),
                  isExpanded: _isExpanded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
