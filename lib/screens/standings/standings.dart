import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/utilities/constants.dart';

import '../../components/custom_icon_button.dart';
import '../../utilities/scroll/scroll_controller_notifier.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../../utilities/team.dart';
import '../search_screen.dart';
import 'conference_standings.dart';

class Standings extends StatefulWidget {
  static const String id = 'standings';
  const Standings({super.key});

  @override
  State<Standings> createState() => _StandingsState();
}

class _StandingsState extends State<Standings> {
  List<Map<String, dynamic>> eastTeams = [];
  List<Map<String, dynamic>> westTeams = [];
  late String selectedSeason;
  bool _isLoading = true;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;

  int selectedYear = 2023;

  Future<void> _showYearPicker(BuildContext context) async {
    final int? pickedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            'Season',
            style: kBebasBold.copyWith(fontSize: 18.0),
          ),
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.deepOrange, // Selected item color
                  onPrimary: Colors.white, // Selected item text color
                  onSurface: Colors.white, // Unselected item text color
                ),
              ),
              child: YearPicker(
                firstDate: DateTime(1981),
                lastDate: DateTime.now(),
                selectedDate: DateTime(selectedYear),
                onChanged: (DateTime dateTime) {
                  Navigator.pop(context, dateTime.year);
                },
              ),
            ),
          ),
        );
      },
    );

    if (pickedYear != null && pickedYear != selectedYear) {
      setState(() {
        selectedYear = pickedYear;
        selectedSeason = '$selectedYear-${(selectedYear + 1).toString().substring(2)}';
      });
    }
  }

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setTeams();
    selectedSeason = kCurrentSeason;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: SpinningIcon(
              color: Colors.deepOrange,
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xFF111111),
            appBar: AppBar(
              backgroundColor: Colors.grey.shade900,
              surfaceTintColor: Colors.grey.shade900,
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
                    _showYearPicker(context);
                  },
                ),
              ],
            ),
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
                    season: selectedSeason,
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
                    season: selectedSeason,
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
    return const ClampingScrollPhysics();
  }
}
