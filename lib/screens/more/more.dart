import 'package:flutter/material.dart';
import 'package:splash/screens/more/draft.dart';
import 'package:splash/screens/more/league_history.dart';
import 'package:splash/screens/more/stats_query/stats_leaders.dart';
import 'package:splash/screens/search_screen.dart';

import '../../components/custom_icon_button.dart';
import '../../utilities/constants.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  Map<String, dynamic> pages = {
    'Leaders': [Icons.leaderboard, Leaders()],
    'Draft': [Icons.format_list_numbered, Draft()],
    'League History': [Icons.history, LeagueHistory()],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        title: const Text(
          'More',
          style: TextStyle(
              color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 35.0),
        ),
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
            icon: Icons.settings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ...pages.keys.map(
            (pageName) => ListTile(
              tileColor: Colors.grey.shade900.withOpacity(0.75),
              shape: const Border(
                bottom: BorderSide(
                  color: Colors.grey, // Set the color of the border
                  width: 0.125, // Set the width of the border
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    pages[pageName][0],
                    size: 18.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    pageName,
                    style: kBebasNormal.copyWith(fontSize: 18.0),
                  ),
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => pages[pageName][1],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
