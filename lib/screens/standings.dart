import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/base_appbar.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/utilities/constants.dart';

import '../utilities/conference_standings.dart';
import '../utilities/team.dart';

class Standings extends StatefulWidget {
  static const String id = 'standings';
  const Standings({super.key});

  @override
  State<Standings> createState() => _StandingsState();
}

class _StandingsState extends State<Standings> {
  List<Map<String, dynamic>> eastTeams = [];
  List<Map<String, dynamic>> westTeams = [];
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();
  final ScrollController _eastScrollController = ScrollController();
  final ScrollController _westScrollController = ScrollController();

  double _eastSavedScrollPosition = 0.0;
  double _westSavedScrollPosition = 0.0;

  Future<List<Map<String, dynamic>>> getTeams(List<String> teamIds) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    List<Future<Map<String, dynamic>>> teamFutures =
        teamIds.map((teamId) async {
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
        return {
          'error': 'not found'
        }; // Return an empty map in case of an error
      }
    }).toList();

    return await Future.wait(teamFutures);
  }

  void setTeams() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedEastTeams =
          await getTeams(kEastConfTeamIds);
      List<Map<String, dynamic>> fetchedWestTeams =
          await getTeams(kWestConfTeamIds);

      setState(() {
        eastTeams = fetchedEastTeams;
        westTeams = fetchedWestTeams;
        isLoading = false;
      });
    } catch (e) {
      print('Error in setTeams: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setTeams();
    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {}
    });

    _eastScrollController.addListener(() {
      _eastSavedScrollPosition = _eastScrollController.position.pixels;
      print("East Scroll position saved: $_eastSavedScrollPosition");
      _eastScrollController.jumpTo(_eastSavedScrollPosition);
    });

    _westScrollController.addListener(() {
      _westSavedScrollPosition = _westScrollController.position.pixels;
      print("West Scroll position saved: $_westSavedScrollPosition");
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _eastScrollController.dispose();
    _westScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.deepOrange,
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xFF111111),
            appBar: BaseAppBar(),
            body: ScrollConfiguration(
              behavior: MyCustomScrollBehavior(),
              child: CustomScrollView(
                controller: _scrollController,
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
            ),
          );
  }
}

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return ClampingScrollPhysics();
  }
}
