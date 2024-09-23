import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../search_screen.dart';
import 'award_cache.dart';
import 'awards_network_helper.dart';

class LeagueHistory extends StatefulWidget {
  const LeagueHistory({super.key});

  @override
  State<LeagueHistory> createState() => _LeagueHistoryState();
}

class _LeagueHistoryState extends State<LeagueHistory> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> year;
  late List<dynamic> draftByPick;
  bool _isLoadingByYear = true;
  bool _isLoadingByPick = true;
  late String selectedSeason;
  late String selectedAward;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  late TabController _tabController;

  List<String> awards = ['Champion'];

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
  ];

  Future<void> getAwards(String season) async {
    final awardCache = Provider.of<AwardsCache>(context, listen: false);
    if (awardCache.containsYear(season)) {
      setState(() {
        var fetchedAwards = awardCache.getYear(season)!;
        year = fetchedAwards;
        setPicks();
        _isLoadingByYear = false;
      });
    } else {
      var fetchedAwards = await AwardsNetworkHelper().getAwards(season);
      setState(() {
        year = fetchedAwards;
        setPicks();
        _isLoadingByYear = false;
      });
      awardCache.addYear(season, fetchedAwards);
    }
  }

  Future<void> getDraftByPick(String season) async {
    var fetchedPicks = await AwardsNetworkHelper().getAwardsByYear(season);

    setState(() {
      draftByPick = fetchedPicks;
      draftByPick.sort((a, b) => int.parse(b['YEAR']).compareTo(int.parse(a['YEAR'])));
      setPicks();
      _isLoadingByPick = false;
    });
  }

  void setPicks() {}

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
    getAwards(selectedSeason.substring(0, 4));
    getDraftByPick(selectedAward.toString());
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
            value: selectedAward, // Ensure selectedValue is an integer
            items: awards.map((String value) {
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
              });
              getDraftByPick(selectedAward.toString());
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
    return _isLoadingByYear || _isLoadingByPick
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
                  slivers: [],
                ),
                /*
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [DraftSelectionsByPick(selections: draftByPick)],
                ),
                 */
              ],
            ),
          );
  }
}
