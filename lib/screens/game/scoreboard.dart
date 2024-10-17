import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/game/game_card.dart';
import 'package:splash/screens/search_screen.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

import '../../components/custom_icon_button.dart';
import '../../utilities/game_dates.dart';
import '../../utilities/scroll/scroll_controller_notifier.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';

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
  bool _showFab = false;
  bool _isLoading = false;
  bool _pageInitLoad = false;
  Map<String, dynamic> cachedGames = {};
  late Timer _timer;

  List<DateTime> _dates = List.generate(15, (index) {
    return DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: index));
  });

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void startPolling(DateTime date) {
    // Poll every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchGames(date); // Call fetchGames every 10 seconds to get updated data
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _pageInitLoad = true;
    });

    _datesProvider = Provider.of<DatesProvider>(context, listen: false);
    _datesProvider.fetchDates().then((_) {
      String sanitizeDateTime(DateTime dateTime) {
        String day = dateTime.day.toString().padLeft(2, '0');
        String month = dateTime.month.toString().padLeft(2, '0');
        String year = dateTime.year.toString();

        return "$year-$month-$day";
      }

      bool selectableDayPredicate(DateTime val) {
        String sanitized = sanitizeDateTime(val);
        return _datesProvider.dates.contains(sanitized);
      }

      DateTime findNearestValidDate(DateTime date) {
        DateTime beforeDate = date;
        DateTime afterDate = date;

        while (!selectableDayPredicate(beforeDate) && !selectableDayPredicate(afterDate)) {
          beforeDate = beforeDate.subtract(const Duration(days: 1));
          afterDate = afterDate.add(const Duration(days: 1));
        }

        if (selectableDayPredicate(beforeDate)) {
          return beforeDate;
        } else {
          return afterDate;
        }
      }

      if (_datesProvider.dates.isNotEmpty) {
        DateTime maxDate = findNearestValidDate(DateTime.now());
        //DateTime.parse(_datesProvider.dates.reduce((a, b) => a.compareTo(b) > 0 ? a : b));

        _tabController = TabController(length: _dates.length, vsync: this);
        _tabController.index = _dates.indexWhere((date) => isSameDay(date, DateTime.now()));

        _tabController.addListener(() {
          if (_tabController.indexIsChanging ||
              _tabController.index != _tabController.previousIndex) {
            fetchGames(_dates[_tabController.index]);
            setState(() {
              selectedDate = _dates[_tabController.index];
              if (_dates[_tabController.index] != this.maxDate) {
                _showFab = true;
              } else {
                _showFab = false;
              }
            }); // Update the UI when the tab index changes
          }
        });

        setDates(maxDate);
        fetchGames(maxDate).then((_) {
          setState(() {
            this.maxDate = maxDate;
            selectedDate = maxDate;
            _pageInitLoad = false;
          });
        });
        startPolling(maxDate);
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
    _notifier.addController('scoreboard', _scrollController);
  }

  @override
  void dispose() {
    _tabController.removeListener(() {}); // Remove any potential listeners
    _notifier.removeController('scoreboard');
    _scrollController.dispose();
    _tabController.dispose();
    _timer.cancel();
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
      try {
        Network network = Network();
        var url = Uri.http(
          kFlaskUrl,
          '/get_games',
          {'date': formattedDate},
        );
        dynamic jsonData = await network.getData(url);
        Map<String, dynamic> gamesData = jsonData[0] ?? {};

        setState(() {
          cachedGames[formattedDate] = gamesData;
          _isLoading = false; // Set loading state to false
        });
      } catch (e) {
        print('Error updating games: $e');
        setState(() {
          cachedGames[formattedDate] = 'Error updating games';
        });
      }
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
    if (selectedDate != maxDate) {
      setState(() {
        selectedDate = maxDate;
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
                      showModalBottomSheet(
                        constraints:
                            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        backgroundColor: Colors.grey.shade900,
                        context: context,
                        builder: (BuildContext context) {
                          void onDateChanged(DateTime date) async {
                            // Only update if the day or month has changed
                            if (date.day != selectedDate.day ||
                                date.month != selectedDate.month) {
                              selectedDate = date;
                              setDates(date);
                              _tabController.index = 7;

                              if (selectedDate != maxDate) {
                                _showFab = true;
                              } else {
                                _showFab = false;
                              }

                              Navigator.pop(context);
                              await fetchGames(date);
                              startPolling(selectedDate);
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
                                  initialDate: findNearestValidDate(selectedDate),
                                  firstDate: DateTime(2017, 9, 30),
                                  lastDate: DateTime(2025, 4, 13),
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
                  labelStyle: kBebasNormal.copyWith(fontSize: 20.0.r),
                  labelPadding: EdgeInsets.symmetric(horizontal: 20.0.r),
                  onTap: (index) {
                    setState(() {
                      selectedDate = _dates[index];
                      if (selectedDate != maxDate) {
                        _showFab = true;
                      } else {
                        _showFab = false;
                      }
                    });
                  },
                  tabs: _dates.map((date) {
                    return Tab(
                      height: 50.0.r,
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
                                  Icon(
                                    Icons.sports_basketball,
                                    color: Colors.white38,
                                    size: 40.0.r,
                                  ),
                                  SizedBox(height: 15.0.r),
                                  Text(
                                    'No Games Today',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 18.0.r, color: Colors.white54),
                                  ),
                                ],
                              ),
                            );
                          } else if (gamesData[gameKey] is Map) {
                            Map<String, dynamic> game = gamesData[gameKey];
                            if (!game["SEASON_ID"].toString().startsWith("3") &&
                                (game['SUMMARY']?['LineScore'] ?? {}).isNotEmpty) {
                              gameCards.add(
                                GameCard(
                                  game: game,
                                  homeTeam: game['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'],
                                  awayTeam: game['SUMMARY']['GameSummary'][0]
                                          ['VISITOR_TEAM_ID'] ??
                                      0,
                                ),
                              );
                            }
                          }
                        }

                        gameCards.add(
                          Column(
                            children: [
                              SizedBox(height: MediaQuery.sizeOf(context).height / 10),
                              Icon(
                                Icons.sports_basketball,
                                color: Colors.white38,
                                size: 40.0.r,
                              ),
                              SizedBox(height: MediaQuery.sizeOf(context).height / 10),
                            ],
                          ),
                        );

                        return RefreshIndicator(
                          color: Colors.deepOrange,
                          onRefresh: () async {
                            await fetchGames(selectedDate);
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics:
                                const AlwaysScrollableScrollPhysics(), // Allows pull to refresh
                            itemCount: gameCards.length,
                            itemBuilder: (context, index) {
                              return gameCards[index];
                            },
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_basketball,
                                color: Colors.white38,
                                size: 40.0.r,
                              ),
                              SizedBox(height: 15.0.r),
                              Text(
                                'No Games Today',
                                style: kBebasNormal.copyWith(
                                    fontSize: 18.0.r, color: Colors.white54),
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
                    child: Icon(
                      Icons.home,
                      size: 28.0.r,
                      color: Colors.white,
                    ),
                  )
                : null,
          );
  }
}
