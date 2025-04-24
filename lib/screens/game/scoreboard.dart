import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/game/scoreboard_app_bar.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

import '../../utilities/game_dates.dart';
import '../../utilities/scroll/scroll_controller_notifier.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../search_screen.dart';
import 'game_card.dart';

class Scoreboard extends StatefulWidget {
  static const String id = 'scoreboard';
  static const int pageIndex = 0;
  const Scoreboard({super.key});

  @override
  ScoreboardState createState() => ScoreboardState();
}

class ScoreboardState extends State<Scoreboard> with SingleTickerProviderStateMixin {
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
    final provider = ScrollControllerProvider.of(context);
    if (provider != null) {
      _notifier = provider.notifier;
    }
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
          '/games/scoreboard',
          {'date': formattedDate},
        );
        dynamic jsonData = await network.getData(url);
        List<dynamic> gamesData = jsonData ?? {};

        gamesData.sort((a, b) {
          int getStatusPriority(int status) {
            // Assign priority: 2 has the highest priority, then 1, and 3 last
            if (status == 2) return 1;
            if (status == 1) return 2;
            return 3; // For status 3 or any other value
          }

          var aStatus = a['status'] ?? 0;
          var bStatus = b['status'] ?? 0;

          // Compare based on custom priority
          int statusCompare = getStatusPriority(aStatus).compareTo(getStatusPriority(bStatus));
          if (statusCompare != 0) {
            return statusCompare;
          } else {
            // If statuses are the same, fall back to sorting by game ID
            var aSequence = a['gameId'] ?? 0;
            var bSequence = b['gameId'] ?? 0;
            return aSequence.compareTo(bSequence);
          }
        });

        // Assign the sorted list back to widget.teams
        Map<String, dynamic> gamesDataFinal = {
          for (var item in gamesData) item['gameId']: item
        };

        setState(() {
          cachedGames[formattedDate] = gamesDataFinal;
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
        '/games/scoreboard',
        {'date': formattedDate},
      );
      dynamic jsonData = await network.getData(url);
      List<dynamic> gamesData = jsonData ?? {};

      gamesData.sort((a, b) {
        var aValue, bValue;

        aValue = a['gameId'] ?? 0;
        bValue = b['gameId'] ?? 0;

        return aValue.compareTo(bValue);
      });

      // Assign the sorted list back to widget.teams
      Map<String, dynamic> gamesDataFinal = {for (var item in gamesData) item['gameId']: item};

      setState(() {
        cachedGames[formattedDate] = gamesDataFinal;
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

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      backgroundColor: Colors.grey.shade900,
      context: context,
      builder: (BuildContext context) {
        void onDateChanged(DateTime date) async {
          // Only update if the day or month has changed
          if (date.day != selectedDate.day || date.month != selectedDate.month) {
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
                lastDate: DateTime(2025, 9, 30),
                onDateChanged: onDateChanged,
                selectableDayPredicate: selectableDayPredicate,
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildGameCards(var gamesData) {
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
                style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
              ),
            ],
          ),
        );
      } else if (gamesData[gameKey] is Map) {
        Map<String, dynamic> game = gamesData[gameKey];
        if (gameKey.substring(2, 3) != "3") {
          gameCards.add(
            GameCard(
              game: game,
              homeTeam: int.tryParse(game['homeTeamId'].toString()) ?? game['homeTeamId'] ?? 0,
              awayTeam: int.tryParse(game['awayTeamId'].toString()) ?? game['awayTeamId'] ?? 0,
            ),
          );
        }
      }
    }
    return gameCards;
  }

  @override
  Widget build(BuildContext context) {
    return _pageInitLoad
        ? const SpinningIcon()
        : Scaffold(
            appBar: ScoreboardAppBar(
              tabController: _tabController,
              dates: _dates,
              onTabTap: (index) {
                setState(() {
                  selectedDate = _dates[index];
                  _showFab = selectedDate != maxDate;
                });
              },
              onSearchPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              onCalendarPressed: () {
                _showDatePicker(context); // Call a method in your State class
              },
            ),
            body: _isLoading
                ? const Center(child: SpinningIcon(color: Colors.deepOrange))
                : TabBarView(
                    controller: _tabController,
                    children: _dates.map((date) {
                      String formattedDate = date.toIso8601String().split('T').first;
                      var gamesData = cachedGames[formattedDate];

                      if (gamesData is Map && !gamesData.containsKey('error')) {
                        List<Widget> gameCards = _buildGameCards(gamesData);
                        return GameList(
                          scrollController: _scrollController,
                          gameCards: gameCards,
                          onRefresh: () async => await fetchGames(selectedDate),
                        );
                      } else {
                        return const NoGamesToday();
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

class GameList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> gameCards;
  final Future<void> Function() onRefresh;

  const GameList({
    super.key,
    required this.scrollController,
    required this.gameCards,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.deepOrange,
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: gameCards.length + 1, // Add 1 for the icon at the end
        itemBuilder: (context, index) {
          if (index < gameCards.length) {
            return gameCards[index];
          } else {
            // Add a basketball icon as a separator at the end
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0.r),
              child: Center(
                child: Icon(Icons.sports_basketball, color: Colors.white38, size: 40.0.r),
              ),
            );
          }
        },
      ),
    );
  }
}

class NoGamesToday extends StatelessWidget {
  const NoGamesToday({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_basketball, color: Colors.white38, size: 40.0.r),
          SizedBox(height: 15.0.r),
          Text('No Games Today',
              style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54)),
        ],
      ),
    );
  }
}
