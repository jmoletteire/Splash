import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/standings/conference_standings.dart';

import '../../utilities/constants.dart';
import '../../utilities/team.dart';
import '../team/team_cache.dart';

class LeagueHistory extends StatefulWidget {
  const LeagueHistory({super.key});

  @override
  State<LeagueHistory> createState() => _LeagueHistoryState();
}

class _LeagueHistoryState extends State<LeagueHistory> with TickerProviderStateMixin {
  late TabController primaryTC;
  List<Map<String, dynamic>> eastTeams = [];
  List<Map<String, dynamic>> westTeams = [];
  bool _isLoading = true;

  Future<List<Map<String, dynamic>>> getTeams(List<String> teamIds) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    List<Future<Map<String, dynamic>>> teamFutures = teamIds.map((teamId) async {
      try {
        if (teamCache.containsTeam(teamId)) {
          return teamCache.getTeam(teamId)!;
        } else {
          var fetchedTeam = await Team().getTeam(teamId);
          teamCache.addTeam(teamId, fetchedTeam);
          return fetchedTeam;
        }
      } catch (e) {
        print('Error fetching team $teamId: $e');
        return {'error': 'not found'}; // Return an empty map in case of an error
      }
    }).toList();

    return await Future.wait(teamFutures);
  }

  void setTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedEastTeams = await getTeams(kEastConfTeamIds);
      List<Map<String, dynamic>> fetchedWestTeams = await getTeams(kWestConfTeamIds);

      setState(() {
        eastTeams = fetchedEastTeams;
        westTeams = fetchedWestTeams;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in setTeams: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    primaryTC = TabController(length: 3, vsync: this);
    setTeams();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //var tabBarHeight = primaryTabBar.preferredSize.height;
    var pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;

    return Scaffold(
      body: ExtendedNestedScrollView(
          headerSliverBuilder: (c, f) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 200.0,
                title: Text('Title'),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ];
          },
          pinnedHeaderSliverHeightBuilder: () {
            return pinnedHeaderHeight;
          },
          onlyOneScrollInBody: false,
          body: Column(
            children: <Widget>[
              TabBar(
                controller: primaryTC,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Tab1"),
                  Tab(text: "Tab2"),
                  Tab(text: "Tab3"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: primaryTC,
                  children: <Widget>[
                    MyHomePage(),
                    CustomScrollView(
                      slivers: [
                        ConferenceStandings(
                          columnNames: const [
                            'EASTERN',
                            'W',
                            'L',
                            'PCT',
                            'GB',
                            'NRTG',
                            'ORTG',
                            'DRTG',
                            'PACE',
                            'STREAK',
                            'Last 10',
                            'HOME',
                            'ROAD',
                            '> .500',
                            'EAST',
                            'WEST',
                            'ATL',
                            'CEN',
                            'SE',
                            'NW',
                            'PAC',
                            'SW',
                          ],
                          standings: eastTeams,
                        ),
                        ConferenceStandings(
                          columnNames: const [
                            'WESTERN',
                            'W',
                            'L',
                            'PCT',
                            'GB',
                            'NRTG',
                            'ORTG',
                            'DRTG',
                            'PACE',
                            'STREAK',
                            'Last 10',
                            'HOME',
                            'ROAD',
                            '> .500',
                            'EAST',
                            'WEST',
                            'ATL',
                            'CEN',
                            'SE',
                            'NW',
                            'PAC',
                            'SW',
                          ],
                          standings: westTeams,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 75.0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Pinned Header'),
            background: Image.network(
              'https://via.placeholder.com/350x150',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return ListTile(
                title: Text('Item #$index'),
              );
            },
            childCount: 20,
          ),
        ),
      ],
    );
  }
}
