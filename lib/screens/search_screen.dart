import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/player/player_home.dart';
import 'package:splash/screens/team/team_home.dart';
import 'package:splash/utilities/constants.dart';

import '../components/player_avatar.dart';
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
                            PlayerAvatar(
                              radius: 20.0.r,
                              backgroundColor: Colors.white12,
                              playerImageUrl:
                                  'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png',
                            ),
                            SizedBox(width: 15.0.r),
                            Text(
                              player['DISPLAY_FIRST_LAST'],
                              style: kBebasNormal.copyWith(fontSize: 16.0.r),
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
