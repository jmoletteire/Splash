import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/game/scoreboard.dart';
import 'package:splash/screens/more/contracts/contracts.dart';
import 'package:splash/screens/more/league_history/league_history.dart';
import 'package:splash/screens/more/transactions/league_transactions.dart';
import 'package:splash/screens/player/player_home.dart';
import 'package:splash/screens/standings/standings.dart';
import 'package:splash/screens/team/team_home.dart';
import 'package:splash/utilities/constants.dart';

import '../components/player_avatar.dart';
import '../utilities/nba_api/library/network.dart';
import 'more/draft/draft.dart';
import 'more/glossary/glossary.dart';
import 'more/stats_query/stats_query.dart';

class SearchProvider with ChangeNotifier {
  List<Map<String, dynamic>> _playerSuggestions = [];
  List<Map<String, dynamic>> _teamSuggestions = [];
  List<Map<String, dynamic>> _filteredStaticPageSuggestions = [];
  final List<Map<String, dynamic>> _staticPageSuggestions = [
    {
      'title': 'Scores',
      'icon': Icons.scoreboard_outlined,
      'route': const Scoreboard(),
    },
    {
      'title': 'Standings',
      'icon': Icons.stacked_bar_chart,
      'route': const Standings(),
    },
    {
      'title': 'Stats',
      'icon': Icons.leaderboard,
      'route': const StatsQuery(),
    },
    {
      'title': 'Transactions',
      'icon': Icons.compare_arrows,
      'route': const LeagueTransactions(),
    },
    {
      'title': 'Draft',
      'icon': Icons.format_list_numbered,
      'route': const Draft(),
    },
    {
      'title': 'Contracts',
      'icon': Icons.attach_money,
      'route': const Contracts(),
    },
    {
      'title': 'League History',
      'icon': Icons.history,
      'route': const LeagueHistory(),
    },
    {
      'title': 'Glossary',
      'icon': Icons.menu_book,
      'route': const Glossary(),
    },
  ];
  Timer? _debounce;

  List<Map<String, dynamic>> get playerSuggestions => _playerSuggestions;
  List<Map<String, dynamic>> get teamSuggestions => _teamSuggestions;
  List<Map<String, dynamic>> get filteredStaticPageSuggestions =>
      _filteredStaticPageSuggestions;

  Future<void> fetchSuggestions(String query) async {
    // Filter static pages based on the query
    _filteredStaticPageSuggestions = _staticPageSuggestions
        .where((page) => page['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    var response = await searchSuggestions(query);

    _playerSuggestions = List<Map<String, dynamic>>.from(response['players']);
    _teamSuggestions = List<Map<String, dynamic>>.from(response['teams']);
    notifyListeners();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (query.isNotEmpty) {
        fetchSuggestions(query);
      } else {
        _playerSuggestions = [];
        _teamSuggestions = [];
        _filteredStaticPageSuggestions = [];
        notifyListeners();
      }
    });
  }

  Future<Map<String, dynamic>> searchSuggestions(String query) async {
    Network network = Network();
    var url = Uri.http(
      kFlaskUrl,
      '/search',
      {'query': query},
    );
    try {
      var response = await network.getData(url);
      return response ?? {};
    } catch (e) {
      print('Error fetching search suggestions for $query: $e');
      return {};
    }
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        title: TextField(
          autofocus: true,
          autocorrect: false,
          controller: _textEditingController,
          onChanged: (query) =>
              Provider.of<SearchProvider>(context, listen: false).onSearchChanged(query),
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(CupertinoIcons.clear_circled_solid, size: 20.0.r),
              onPressed: () {
                // Clear the text field
                _textEditingController.clear();
                Provider.of<SearchProvider>(context, listen: false).onSearchChanged('');
              },
            ),
          ),
          style: kBebasNormal.copyWith(fontSize: 16.0.r),
          cursorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                return ListView(
                  children: [
                    // Show filtered static pages if there are matches
                    ...searchProvider.filteredStaticPageSuggestions.map(
                      (page) => ListTile(
                        shape: const Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Set the color of the border
                            width: 0.125, // Set the width of the border
                          ),
                        ),
                        title: Row(
                          children: [
                            Icon(page['icon']),
                            SizedBox(width: 15.0.r),
                            Text(
                              page['title'],
                              style: kBebasNormal.copyWith(fontSize: 16.0.r),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => page['route'],
                            ),
                          );
                        },
                      ),
                    ),
                    ...searchProvider.playerSuggestions.map(
                      (player) => ListTile(
                        shape: const Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Set the color of the border
                            width: 0.125, // Set the width of the border
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                PlayerAvatar(
                                  radius: 20.0.r,
                                  backgroundColor: Colors.white12,
                                  playerImageUrl:
                                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png',
                                ),
                                SizedBox(
                                  width: 15.0.r,
                                ),
                                Text(
                                  player['DISPLAY_FIRST_LAST'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                                ),
                              ],
                            ),
                            Text(
                              '${player['FROM_YEAR']} - ${player['TO_YEAR']}',
                              style: kBebasNormal.copyWith(
                                  color: Colors.white70, fontSize: 14.0.r),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerHome(
                                teamId: player["TEAM_ID"].toString(),
                                playerId: player["PERSON_ID"].toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ...searchProvider.teamSuggestions.map(
                      (team) => ListTile(
                        title: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 4.0.r),
                              child: Image.asset(
                                'images/NBA_Logos/${team['TEAM_ID']}.png',
                                fit: BoxFit.contain,
                                width: 40.r,
                                height: 40.r,
                              ),
                            ),
                            SizedBox(width: 15.0.r),
                            Text(
                              '${team['CITY']} ${team['NICKNAME']}',
                              style: kBebasNormal.copyWith(fontSize: 16.0.r),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamHome(
                                teamId: team['TEAM_ID'].toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
