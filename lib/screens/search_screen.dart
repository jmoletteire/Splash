import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/player/player_home.dart';
import 'package:splash/screens/team/team_home.dart';
import 'package:splash/utilities/constants.dart';

import '../utilities/nba_api/library/network.dart';

class SearchProvider with ChangeNotifier {
  List<Map<String, dynamic>> _playerSuggestions = [];
  List<Map<String, dynamic>> _teamSuggestions = [];
  Timer? _debounce;

  List<Map<String, dynamic>> get playerSuggestions => _playerSuggestions;
  List<Map<String, dynamic>> get teamSuggestions => _teamSuggestions;

  Future<void> fetchSuggestions(String query) async {
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

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        title: TextField(
          autofocus: true,
          onChanged: (query) =>
              Provider.of<SearchProvider>(context, listen: false)
                  .onSearchChanged(query),
          decoration: const InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
          ),
          style: kBebasNormal.copyWith(fontSize: 18.0),
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
                    ...searchProvider.playerSuggestions.map(
                      (player) => ListTile(
                        shape: const Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Set the color of the border
                            width: 0.125, // Set the width of the border
                          ),
                        ),
                        title: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.white12,
                              foregroundColor: Colors.white12,
                              foregroundImage: NetworkImage(
                                  'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png'),
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              player['DISPLAY_FIRST_LAST'],
                              style: kBebasNormal.copyWith(fontSize: 18.0),
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
                              margin: const EdgeInsets.only(left: 4.0),
                              child: SvgPicture.asset(
                                '/Users/jackmole/StudioProjects/Splash/images/NBA_Logos/${team['TEAM_ID']}.svg',
                                fit: BoxFit.contain,
                                width: 40,
                                height: 40,
                              ),
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              '${team['CITY']} ${team['NICKNAME']}',
                              style: kBebasNormal.copyWith(fontSize: 18.0),
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
