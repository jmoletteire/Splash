import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/components/game_card.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/search_screen.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/nba_api/library/network.dart';

class Scoreboard extends StatefulWidget {
  static const String id = 'scoreboard';
  static const int pageIndex = 0;
  const Scoreboard({super.key});

  @override
  _ScoreboardState createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DateTime> _dates = List.generate(15, (index) {
    return DateTime.now()
        .subtract(const Duration(days: 7))
        .add(Duration(days: index));
  });
  Map<String, dynamic> cachedGames = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _dates.length, vsync: this);
    _tabController.index = 7; // Default to today

    _tabController.addListener(() {
      if (!_isLoading) {
        fetchGamesAndTeams(_dates[_tabController.index]);
      }
      setState(() {}); // Update the UI when the tab index changes
    });

    setDates(DateTime.now());
    fetchGamesAndTeams(_dates[_tabController.index]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void setDates(DateTime date) {
    setState(() {
      _dates = List.generate(15, (index) {
        return date
            .subtract(const Duration(days: 7))
            .add(Duration(days: index));
      });
    });
  }

  Future<void> fetchGamesAndTeams(DateTime date) async {
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

      /*
      // Fetch team data in parallel for all games
      await Future.wait(gamesData.keys.map((gameKey) async {
        if (gamesData[gameKey] is Map) {
          Map<String, dynamic> game = gamesData[gameKey];

          var teams = await Future.wait([
            getTeam(
                game['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'].toString()),
            getTeam(
                game['SUMMARY']['GameSummary'][0]['VISITOR_TEAM_ID'].toString())
          ]);
          game['homeTeam'] = teams[0];
          game['awayTeam'] = teams[1];
        }
      }));
      */

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

  /*
  Future<Map<String, dynamic>> getTeam(String teamId) async {
    Network network = Network();
    var url = Uri.http(
      kFlaskUrl,
      '/get_team',
      {'team_id': teamId},
    );
    try {
      var response = await network.getData(url);
      return response ?? {};
    } catch (e) {
      print('Error fetching team $teamId: $e');
      return {};
    }
  }
   */

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.13),
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
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.deepOrange,
                          onPrimary: Colors.white,
                          secondary: Colors.white,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: _dates[_tabController.index],
                        firstDate: DateTime(2013, 11, 3),
                        lastDate:
                            DateTime(today.year + 1, today.month, today.day),
                        onDateChanged: (date) async {
                          setDates(date);
                          _tabController.index = 7;
                          Navigator.pop(context);
                          await fetchGamesAndTeams(date);
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
                              'No games available',
                              style: kBebasNormal.copyWith(
                                  fontSize: 20.0, color: Colors.white54),
                            ),
                          ],
                        ),
                      );
                    } else if (gamesData[gameKey] is Map) {
                      Map<String, dynamic> game = gamesData[gameKey];
                      gameCards.add(GameCard(
                        game: game,
                        homeTeam: game['SUMMARY']['GameSummary'][0]
                            ['HOME_TEAM_ID'],
                        awayTeam: game['SUMMARY']['GameSummary'][0]
                            ['VISITOR_TEAM_ID'],
                      ));
                    }
                  }

                  return SingleChildScrollView(
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
                          'No games available',
                          style: kBebasNormal.copyWith(
                              fontSize: 20.0, color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }
              }).toList(),
            ),
    );
  }
}
