import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/game/game_card.dart';
import 'package:splash/screens/search_screen.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

import '../components/custom_icon_button.dart';
import '../utilities/game_dates.dart';
import '../utilities/scroll/scroll_controller_notifier.dart';
import '../utilities/scroll/scroll_controller_provider.dart';

class Scoreboard extends StatefulWidget {
  static const String id = 'scoreboard';
  static const int pageIndex = 0;
  const Scoreboard({super.key});

  @override
  _ScoreboardState createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  late DatesProvider _datesProvider;
  late DateTime maxDate;
  late DateTime selectedDate;
  late DateTime lastSelectedDate;
  bool _showFab = false;

  List<DateTime> _dates = List.generate(15, (index) {
    return DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: index));
  });
  Map<String, dynamic> cachedGames = {};
  bool _isLoading = false;
  bool _pageInitLoad = false;

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _pageInitLoad = true;
    });

    _datesProvider = Provider.of<DatesProvider>(context, listen: false);
    _datesProvider.fetchDates().then((_) {
      if (_datesProvider.dates.isNotEmpty) {
        DateTime maxDate =
            DateTime.parse(_datesProvider.dates.reduce((a, b) => a.compareTo(b) > 0 ? a : b));

        _tabController = TabController(length: _dates.length, vsync: this);
        _tabController.index = _dates.indexWhere((date) => isSameDay(date, DateTime.now()));

        _tabController.addListener(() {
          if (_tabController.indexIsChanging) {
            fetchGames(_dates[_tabController.index]);
            setState(() {}); // Update the UI when the tab index changes
          }
        });

        setDates(maxDate);
        fetchGames(maxDate).then((_) {
          setState(() {
            this.maxDate = maxDate;
            selectedDate = maxDate;
            lastSelectedDate = selectedDate;
            _pageInitLoad = false;
          });
        });
      } else {
        setState(() {
          _pageInitLoad = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController(_scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController(_scrollController);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void setDates(DateTime date) {
    setState(() {
      _dates = List.generate(15, (index) {
        return date.subtract(const Duration(days: 7)).add(Duration(days: index));
      });
    });
  }

  Future<void> fetchGames(DateTime date) async {
    String formattedDate = date.toIso8601String().split('T').first;

    if (cachedGames.containsKey(formattedDate)) {
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      Network network = Network();
      var url = Uri.http(
        kFlaskUrl,
        '/get_games',
        {'date': formattedDate},
      );
      dynamic jsonData = await network.getData(url);
      Map<String, dynamic> gamesData = jsonData ?? {};

      setState(() {
        cachedGames[formattedDate] = gamesData;
        _isLoading = false; // Set loading state to false
      });
    } catch (e) {
      print('Error fetching games: $e');
      setState(() {
        cachedGames[formattedDate] = 'Error fetching games';
        _isLoading = false; // Set loading state to false
      });
    }
  }

  void goToMaxDate() {
    if (lastSelectedDate != maxDate) {
      setState(() {
        lastSelectedDate = maxDate;
        _showFab = false;
      });

      setDates(maxDate);
      _tabController.index = 7;
      fetchGames(maxDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _pageInitLoad
        ? const SpinningIcon()
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.13),
              child: AppBar(
                backgroundColor: Colors.grey.shade900,
                title: kSplashText,
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
                    icon: Icons.calendar_month,
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.grey.shade900,
                        context: context,
                        builder: (BuildContext context) {
                          void onDateChanged(DateTime date) async {
                            // Only update if the day or month has changed
                            if (date.day != lastSelectedDate.day ||
                                date.month != lastSelectedDate.month) {
                              lastSelectedDate = date;
                              setDates(date);
                              _tabController.index = 7;

                              if (lastSelectedDate != maxDate) {
                                _showFab = true;
                              } else {
                                _showFab = false;
                              }

                              Navigator.pop(context);
                              await fetchGames(date);
                            }
                          }

                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.deepOrange,
                                onPrimary: Colors.white,
                                secondary: Colors.white,
                              ),
                            ),
                            child: Consumer<DatesProvider>(
                              builder: (ctx, datesProvider, child) {
                                String sanitizeDateTime(DateTime dateTime) {
                                  String day = dateTime.day.toString().padLeft(2, '0');
                                  String month = dateTime.month.toString().padLeft(2, '0');
                                  String year = dateTime.year.toString();

                                  return "$year-$month-$day";
                                }

                                bool selectableDayPredicate(DateTime val) {
                                  String sanitized = sanitizeDateTime(val);
                                  return datesProvider.dates.contains(sanitized);
                                }

                                DateTime findNearestValidDate(DateTime date) {
                                  DateTime beforeDate = date;
                                  DateTime afterDate = date;

                                  while (!selectableDayPredicate(beforeDate) &&
                                      !selectableDayPredicate(afterDate)) {
                                    beforeDate = beforeDate.subtract(const Duration(days: 1));
                                    afterDate = afterDate.add(const Duration(days: 1));
                                  }

                                  if (selectableDayPredicate(beforeDate)) {
                                    return beforeDate;
                                  } else {
                                    return afterDate;
                                  }
                                }

                                return CalendarDatePicker(
                                  initialDate: findNearestValidDate(lastSelectedDate),
                                  firstDate: DateTime(2017, 9, 30),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                  onDateChanged: onDateChanged,
                                  selectableDayPredicate: selectableDayPredicate,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  indicatorColor: Colors.deepOrange,
                  unselectedLabelColor: Colors.white70,
                  labelColor: Colors.deepOrangeAccent,
                  labelStyle: kBebasNormal,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  onTap: (index) {
                    setState(() {
                      lastSelectedDate = _dates[index];
                      if (lastSelectedDate != maxDate) {
                        _showFab = true;
                      } else {
                        _showFab = false;
                      }
                    });
                  },
                  tabs: _dates.map((date) {
                    return Tab(
                      height: 55.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('E').format(date)),
                          Text(
                              '${DateFormat.d().format(date)} ${DateFormat.MMM().format(date)}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            body: _isLoading
                ? const Center(
                    child: SpinningIcon(
                      color: Colors.deepOrange,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: _dates.map((date) {
                      String formattedDate = date.toIso8601String().split('T').first;
                      var gamesData = cachedGames[formattedDate];

                      if (gamesData is Map && !gamesData.containsKey('error')) {
                        List<Widget> gameCards = [];

                        for (String gameKey in gamesData.keys) {
                          if (gameKey == 'error') {
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.sports_basketball,
                                    color: Colors.white38,
                                    size: 40.0,
                                  ),
                                  const SizedBox(height: 15.0),
                                  Text(
                                    'No Games Available',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 20.0, color: Colors.white54),
                                  ),
                                ],
                              ),
                            );
                          } else if (gamesData[gameKey] is Map) {
                            Map<String, dynamic> game = gamesData[gameKey];
                            gameCards.add(
                              GameCard(
                                game: game,
                                homeTeam: game['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'],
                                awayTeam: game['SUMMARY']['GameSummary'][0]['VISITOR_TEAM_ID'],
                              ),
                            );
                          }
                        }

                        gameCards.add(
                          const Column(
                            children: [
                              SizedBox(height: 50.0),
                              Icon(
                                Icons.sports_basketball,
                                color: Colors.white38,
                                size: 40.0,
                              ),
                              SizedBox(height: 50.0),
                            ],
                          ),
                        );

                        return SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: gameCards,
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sports_basketball,
                                color: Colors.white38,
                                size: 40.0,
                              ),
                              const SizedBox(height: 15.0),
                              Text(
                                'No Games Available',
                                style: kBebasNormal.copyWith(
                                    fontSize: 20.0, color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }
                    }).toList(),
                  ),
            floatingActionButton: _showFab
                ? FloatingActionButton(
                    onPressed: () {
                      goToMaxDate();
                    },
                    backgroundColor: Colors.deepOrange,
                    child: const Icon(
                      Icons.home,
                      size: 28.0,
                    ),
                  )
                : null,
          );
  }
}
