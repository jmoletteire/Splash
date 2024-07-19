import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/team/comparison/team_search_widget.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/team.dart';
import '../../search_screen.dart';
import '../team_home.dart';

class TeamComparison extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamComparison({super.key, required this.team});

  @override
  State<TeamComparison> createState() => _TeamComparisonState();
}

class _TeamComparisonState extends State<TeamComparison> {
  late Map<String, dynamic> teamOne;
  late Map<String, dynamic> teamTwo;
  late List<String> seasonsOne;
  late List<String> seasonsTwo;
  late List<String> seasonTypesOne;
  late List<String> seasonTypesTwo;
  late String selectedSeasonOne;
  late String selectedSeasonTwo;
  late String selectedSeasonTypeOne;
  late String selectedSeasonTypeTwo;

  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;

  double roundToDecimalPlaces(double value, int decimalPlaces) {
    num factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  Future<Map<String, dynamic>> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      return teamCache.getTeam(teamId)!;
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      teamCache.addTeam(teamId, fetchedTeam);
      return fetchedTeam;
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF111111),
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => SearchProvider(),
        child: TeamSearchWidget(
          onTeamSelected: (team) async {
            teamTwo = await getTeam(team["TEAM_ID"].toString());
            setState(() {
              teamTwo.keys.contains('seasons')
                  ? seasonsTwo = teamTwo['seasons'].keys.toList().reversed.toList()
                  : seasonsTwo = [kCurrentSeason];

              selectedSeasonTwo = seasonsTwo.first;

              teamTwo['seasons'][selectedSeasonTwo]['STATS']['PLAYOFFS'].keys.contains('ADV')
                  ? seasonTypesTwo = ['REGULAR SEASON', 'PLAYOFFS']
                  : seasonTypesTwo = ['REGULAR SEASON'];
              selectedSeasonTypeTwo = seasonTypesTwo.first;
            });
          },
        ),
      ),
    );
  }

  String getStanding(int confRank) {
    switch (confRank) {
      case 1:
        return '${confRank}st';
      case 2:
        return '${confRank}nd';
      case 3:
        return '${confRank}rd';
      case 21:
        return '${confRank}st';
      case 22:
        return '${confRank}nd';
      case 23:
        return '${confRank}rd';
      default:
        return '${confRank}th';
    }
  }

  String getPlayoffs(String selectedSeason, int confRank, int poWins) {
    if (kSeasons.indexOf(selectedSeason) < 21) {
      if (confRank > 10) {
        return 'Missed Playoffs';
      } else if (poWins < 4) {
        return 'Lost 1st Round';
      } else if (poWins < 8) {
        return 'Lost Conf Semis';
      } else if (poWins < 12) {
        return 'Lost Conf Finals';
      } else if (poWins < 16) {
        return 'Lost NBA Finals';
      } else if (poWins == 16) {
        return 'Won NBA Finals';
      } else {
        return '-';
      }
    } else {
      if (confRank > 8) {
        return 'Missed Playoffs';
      } else if (poWins < 3) {
        return 'Lost 1st Round';
      } else if (poWins < 7) {
        return 'Lost Conf Semis';
      } else if (poWins < 11) {
        return 'Lost Conf Finals';
      } else if (poWins < 15) {
        return 'Lost NBA Finals';
      } else if (poWins == 15) {
        return 'Won NBA Finals';
      }
    }
    return '-';
  }

  @override
  void initState() {
    super.initState();
    teamOne = widget.team;
    teamTwo = {};

    if (teamOne.keys.contains('seasons')) {
      seasonsOne = teamOne['seasons'].keys.toList().reversed.toList();
      selectedSeasonOne = seasonsOne.first;

      teamOne['seasons'][selectedSeasonOne]['STATS']['PLAYOFFS'].keys.contains('ADV')
          ? seasonTypesOne = ['REGULAR SEASON', 'PLAYOFFS']
          : seasonTypesOne = ['REGULAR SEASON'];
    } else {
      seasonsOne = [kCurrentSeason];
      seasonTypesOne = ['REGULAR SEASON'];
    }

    selectedSeasonOne = seasonsOne.first;
    selectedSeasonTypeOne = seasonTypesOne.first;

    seasonsTwo = [kCurrentSeason];
    seasonTypesTwo = ['REGULAR SEASON'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet();
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    double newOpacity = ((_scrollController.offset - 25) / 100).clamp(0.0, 1.0);
    if (newOpacity != _opacity) {
      setState(() {
        _opacity = newOpacity;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color teamOneColor = kDarkPrimaryColors.contains(teamOne['ABBREVIATION'])
        ? (kTeamColors[teamOne['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[teamOne['ABBREVIATION']]!['primaryColor']!);

    Color teamTwoColor = Colors.transparent;
    if (teamTwo.isNotEmpty) {
      teamTwoColor = kDarkPrimaryColors.contains(teamTwo['ABBREVIATION'])
          ? (kTeamColors[teamTwo['ABBREVIATION']]!['secondaryColor']!)
          : (kTeamColors[teamTwo['ABBREVIATION']]!['primaryColor']!);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        title: const Text('Comparison'),
        titleTextStyle: kBebasBold.copyWith(fontSize: 24.0),
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
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: const Color(0xFF111111),
                            context: context,
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => SearchProvider(),
                              child: TeamSearchWidget(
                                onTeamSelected: (team) async {
                                  teamOne = await getTeam(team["TEAM_ID"].toString());
                                  setState(() {
                                    if (teamOne.keys.contains('seasons')) {
                                      seasonsOne =
                                          teamOne['seasons'].keys.toList().reversed.toList();
                                      selectedSeasonOne = seasonsOne.first;

                                      teamOne['seasons'][selectedSeasonOne]['STATS']
                                                  ['PLAYOFFS']
                                              .keys
                                              .contains('ADV')
                                          ? seasonTypesOne = ['REGULAR SEASON', 'PLAYOFFS']
                                          : seasonTypesOne = ['REGULAR SEASON'];
                                    } else {
                                      seasonsOne = [kCurrentSeason];
                                      seasonTypesOne = ['REGULAR SEASON'];
                                    }

                                    selectedSeasonOne = seasonsOne.first;
                                    selectedSeasonTypeOne = seasonTypesOne.first;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.fromLTRB(11.0, 11.0, 5.0, 5.0),
                          color: Colors.grey.shade900,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/NBA_Logos/${teamOne['TEAM_ID']}.png',
                                        width: MediaQuery.of(context).size.width * 0.125,
                                        height: MediaQuery.of(context).size.width * 0.125,
                                      ),
                                      const SizedBox(height: 5.0),
                                      AutoSizeText(
                                        '${teamOne['CITY']} ${teamOne['NICKNAME']}',
                                        style: kBebasOffWhite.copyWith(
                                            color: Colors.white, fontSize: 18.0),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 5,
                                right: 10,
                                child: Icon(
                                  Icons.compare_arrows, // Replace with the desired icon
                                  color: Colors.white70,
                                  size: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: const Color(0xFF111111),
                            context: context,
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => SearchProvider(),
                              child: TeamSearchWidget(
                                onTeamSelected: (team) async {
                                  teamTwo = await getTeam(team["TEAM_ID"].toString());
                                  setState(() {
                                    if (teamTwo.keys.contains('seasons')) {
                                      seasonsTwo =
                                          teamTwo['seasons'].keys.toList().reversed.toList();
                                      selectedSeasonTwo = seasonsTwo.first;

                                      teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                                  ['PLAYOFFS']
                                              .keys
                                              .contains('ADV')
                                          ? seasonTypesTwo = ['REGULAR SEASON', 'PLAYOFFS']
                                          : seasonTypesTwo = ['REGULAR SEASON'];
                                    } else {
                                      seasonsTwo = [kCurrentSeason];
                                      seasonTypesTwo = ['REGULAR SEASON'];
                                    }

                                    selectedSeasonTwo = seasonsTwo.first;
                                    selectedSeasonTypeTwo = seasonTypesTwo.first;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.fromLTRB(5.0, 11.0, 11.0, 5.0),
                          color: Colors.grey.shade900,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      if (teamTwo.isEmpty)
                                        Image.asset(
                                          'images/NBA_Logos/0.png',
                                          width: MediaQuery.of(context).size.width * 0.125,
                                          height: MediaQuery.of(context).size.width * 0.125,
                                        ),
                                      if (teamTwo.isEmpty) const SizedBox(height: 5.0),
                                      if (teamTwo.isEmpty)
                                        AutoSizeText(
                                          'SELECT TEAM',
                                          style: kBebasOffWhite.copyWith(
                                              color: Colors.white, fontSize: 18.0),
                                          maxLines: 1,
                                        ),
                                      if (teamTwo.isNotEmpty)
                                        Image.asset(
                                          'images/NBA_Logos/${teamTwo['TEAM_ID']}.png',
                                          width: MediaQuery.of(context).size.width * 0.125,
                                          height: MediaQuery.of(context).size.width * 0.125,
                                        ),
                                      if (teamTwo.isNotEmpty) const SizedBox(height: 5.0),
                                      if (teamTwo.isNotEmpty)
                                        AutoSizeText(
                                          '${teamTwo['CITY']} ${teamTwo['NICKNAME']}',
                                          style: kBebasOffWhite.copyWith(
                                              color: Colors.white, fontSize: 18.0),
                                          maxLines: 1,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 5,
                                right: 10,
                                child: Icon(
                                  Icons.compare_arrows, // Replace with the desired icon
                                  color: Colors.white70,
                                  size: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(10.0)),
                        margin: const EdgeInsets.fromLTRB(11.0, 5.0, 5.0, 5.0),
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0,
                          dropdownColor: Colors.grey.shade900,
                          isExpanded: true,
                          underline: Container(),
                          value: selectedSeasonOne,
                          items: seasonsOne.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: kBebasNormal.copyWith(fontSize: 18.0),
                                  ),
                                  const SizedBox(width: 10.0),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 20.0),
                                    child: Image.asset(
                                      'images/NBA_Logos/${teamOne['TEAM_ID']}.png',
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      width: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedSeasonOne = value!;
                              teamOne['seasons'][selectedSeasonOne]['STATS']['PLAYOFFS']
                                      .keys
                                      .contains('ADV')
                                  ? seasonTypesOne = ['REGULAR SEASON', 'PLAYOFFS']
                                  : seasonTypesOne = ['REGULAR SEASON'];
                              selectedSeasonTypeOne = seasonTypesOne.first;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(10.0)),
                        margin: const EdgeInsets.fromLTRB(5.0, 5.0, 11.0, 5.0),
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0,
                          dropdownColor: Colors.grey.shade900,
                          isExpanded: true,
                          underline: Container(),
                          value: teamTwo.isNotEmpty ? selectedSeasonTwo : kCurrentSeason,
                          items: seasonsTwo.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: kBebasNormal.copyWith(
                                      fontSize: 18.0,
                                      color: teamTwo.isNotEmpty ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                  if (teamTwo.isNotEmpty) const SizedBox(width: 10.0),
                                  if (teamTwo.isNotEmpty)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 20.0),
                                      child: Image.asset(
                                        'images/NBA_Logos/${teamTwo['TEAM_ID']}.png',
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        width: 20.0,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: teamTwo.isNotEmpty
                              ? (String? value) {
                                  setState(() {
                                    selectedSeasonTwo = value!;
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']['PLAYOFFS']
                                            .keys
                                            .contains('ADV')
                                        ? seasonTypesTwo = ['REGULAR SEASON', 'PLAYOFFS']
                                        : seasonTypesTwo = ['REGULAR SEASON'];
                                    selectedSeasonTypeTwo = seasonTypesTwo.first;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(10.0)),
                        margin: const EdgeInsets.fromLTRB(11.0, 5.0, 5.0, 5.0),
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0,
                          dropdownColor: Colors.grey.shade900,
                          isExpanded: true,
                          underline: Container(),
                          value: selectedSeasonTypeOne,
                          items: seasonTypesOne.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: kBebasNormal.copyWith(fontSize: 18.0),
                                  ),
                                  const SizedBox(width: 10.0),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 10.0),
                                    child: value == 'REGULAR SEASON'
                                        ? Image.asset(
                                            'images/NBA_Logos/0.png',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                            width: 10.0,
                                          )
                                        : SvgPicture.asset(
                                            'images/playoffs.svg',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                            width: 10.0,
                                          ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedSeasonTypeOne = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(10.0)),
                        margin: const EdgeInsets.fromLTRB(5.0, 5.0, 11.0, 5.0),
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0,
                          dropdownColor: Colors.grey.shade900,
                          isExpanded: true,
                          underline: Container(),
                          value: teamTwo.isNotEmpty ? selectedSeasonTypeTwo : 'REGULAR SEASON',
                          items: seasonTypesTwo.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: kBebasNormal.copyWith(
                                      fontSize: 18.0,
                                      color: teamTwo.isNotEmpty ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                  if (teamTwo.isNotEmpty) const SizedBox(width: 10.0),
                                  if (teamTwo.isNotEmpty)
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 20.0),
                                      child: value == 'REGULAR SEASON'
                                          ? Image.asset(
                                              'images/NBA_Logos/0.png',
                                              fit: BoxFit.contain,
                                              alignment: Alignment.center,
                                              width: 10.0,
                                            )
                                          : SvgPicture.asset(
                                              'images/playoffs.svg',
                                              fit: BoxFit.contain,
                                              alignment: Alignment.center,
                                              width: 10.0,
                                            ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: teamTwo.isNotEmpty
                              ? (String? value) {
                                  setState(() {
                                    selectedSeasonTypeTwo = value!;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                if (teamTwo.isNotEmpty)
                  Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          NonComparisonRow(
                            statName: 'RECORD',
                            teamOne:
                                '${teamOne['seasons'][selectedSeasonOne]['WINS']} - ${teamOne['seasons'][selectedSeasonOne]['LOSSES']}',
                            teamTwo:
                                '${teamTwo['seasons'][selectedSeasonTwo]['WINS']} - ${teamTwo['seasons'][selectedSeasonTwo]['LOSSES']}',
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'WIN %',
                            teamOne: teamOne['seasons'][selectedSeasonOne]['WIN_PCT']
                                .toStringAsFixed(3),
                            teamTwo: teamTwo['seasons'][selectedSeasonTwo]['WIN_PCT']
                                .toStringAsFixed(3),
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'STANDINGS',
                            teamOne: getStanding(
                                teamOne['seasons'][selectedSeasonOne]['CONF_RANK']),
                            teamTwo: getStanding(
                                teamTwo['seasons'][selectedSeasonTwo]['CONF_RANK']),
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'CONF',
                            teamOne: teamOne['CONF'].toString().substring(0, 4),
                            teamTwo: teamTwo['CONF'].toString().substring(0, 4),
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'PLAYOFFS',
                            teamOne: getPlayoffs(
                                selectedSeasonOne,
                                teamOne['seasons'][selectedSeasonOne]['CONF_RANK'],
                                teamOne['seasons'][selectedSeasonOne]['PO_WINS']),
                            teamTwo: getPlayoffs(
                                selectedSeasonTwo,
                                teamTwo['seasons'][selectedSeasonTwo]['CONF_RANK'],
                                teamTwo['seasons'][selectedSeasonTwo]['PO_WINS']),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (teamTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Top Stats', style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'OFF RATING',
                              teamOne: teamOne['seasons'][selectedSeasonOne]['STATS']
                                  [selectedSeasonTypeOne]['ADV']['OFF_RATING'],
                              teamTwo: teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                  [selectedSeasonTypeTwo]['ADV']['OFF_RATING'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'DEF RATING',
                              teamOne: teamOne['seasons'][selectedSeasonOne]['STATS']
                                  [selectedSeasonTypeOne]['ADV']['DEF_RATING'],
                              teamTwo: teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                  [selectedSeasonTypeTwo]['ADV']['DEF_RATING'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'NET RATING',
                              teamOne: teamOne['seasons'][selectedSeasonOne]['STATS']
                                  [selectedSeasonTypeOne]['ADV']['NET_RATING'],
                              teamTwo: teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                  [selectedSeasonTypeTwo]['ADV']['NET_RATING'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'PACE',
                              teamOne: teamOne['seasons'][selectedSeasonOne]['STATS']
                                  [selectedSeasonTypeOne]['ADV']['PACE'],
                              teamTwo: teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                  [selectedSeasonTypeTwo]['ADV']['PACE'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'TOV%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['ADV']['TM_TOV_PCT'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['ADV']['TM_TOV_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                if (teamTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Shooting', style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'FG%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['BASIC']['FG_PCT'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['BASIC']['FG_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: '3P%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['BASIC']['FG3_PCT'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['BASIC']['FG3_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'FG%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['BASIC']['FT_PCT'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['BASIC']['FT_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: '3PA Rate%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['BASIC']['3PAr'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['BASIC']['3PAr'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'FTA Rate%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['BASIC']['FTAr'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['BASIC']['FTAr'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'EFG%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['ADV']['EFG_PCT'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['ADV']['EFG_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'TS%',
                              teamOne: roundToDecimalPlaces(
                                  (teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['ADV']['TS_PCT'] *
                                      100),
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  (teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['ADV']['TS_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                if (teamTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Rebounding', style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'REB PER 100',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['REB_PER_100'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['REB_PER_100'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'OREB PER 100',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['OREB_PER_100'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['OREB_PER_100'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'DREB PER 100',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['DREB_PER_100'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['DREB_PER_100'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'OREB%',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['ADV']['OREB_PCT'] *
                                      100,
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['ADV']['OREB_PCT'] *
                                      100,
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'DREB%',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                          [selectedSeasonTypeOne]['ADV']['DREB_PCT'] *
                                      100,
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                          [selectedSeasonTypeTwo]['ADV']['DREB_PCT'] *
                                      100,
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 15.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'BOX OUTS PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                        [selectedSeasonTypeOne]['HUSTLE']['BOX_OUTS_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                        [selectedSeasonTypeTwo]['HUSTLE']['BOX_OUTS_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'OFF BOXOUTS PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                            [selectedSeasonTypeOne]['HUSTLE']
                                        ['OFF_BOXOUTS_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                            [selectedSeasonTypeTwo]['HUSTLE']
                                        ['OFF_BOXOUTS_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'DEF BOXOUTS PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                            [selectedSeasonTypeOne]['HUSTLE']
                                        ['DEF_BOXOUTS_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                            [selectedSeasonTypeTwo]['HUSTLE']
                                        ['DEF_BOXOUTS_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                if (teamTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Defense', style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'STL PER 100',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['STL_PER_100'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['STL_PER_100'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'DEFLECTIONS PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                            [selectedSeasonTypeOne]['HUSTLE']
                                        ['DEFLECTIONS_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                            [selectedSeasonTypeTwo]['HUSTLE']
                                        ['DEFLECTIONS_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'BLK PER 100',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['BLK_PER_100'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['BLK_PER_100'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'CONTESTS PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                            [selectedSeasonTypeOne]['HUSTLE']
                                        ['CONTESTED_SHOTS_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                            [selectedSeasonTypeTwo]['HUSTLE']
                                        ['CONTESTED_SHOTS_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                if (teamTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Hustle', style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'SCREEN AST PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                            [selectedSeasonTypeOne]['HUSTLE']
                                        ['SCREEN_ASSISTS_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                            [selectedSeasonTypeTwo]['HUSTLE']
                                        ['SCREEN_ASSISTS_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'SCREEN AST PTS PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                            [selectedSeasonTypeOne]['HUSTLE']
                                        ['SCREEN_AST_PTS_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                            [selectedSeasonTypeTwo]['HUSTLE']
                                        ['SCREEN_AST_PTS_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 15.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              ComparisonRow(
                                statName: 'LOOSE BALLS PER 100',
                                teamOne: roundToDecimalPlaces(
                                    teamOne['seasons'][selectedSeasonOne]['STATS']
                                            [selectedSeasonTypeOne]['HUSTLE']
                                        ['LOOSE_BALLS_RECOVERED_PER_100'],
                                    1),
                                teamTwo: roundToDecimalPlaces(
                                    teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                            [selectedSeasonTypeTwo]['HUSTLE']
                                        ['LOOSE_BALLS_RECOVERED_PER_100'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >= 2016)
                              const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'FOULS PER 100',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['PF_PER_100'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['PF_PER_100'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'FOULS DRAWN PER 100',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['PFD_PER_100'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['PFD_PER_100'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 5.0)
              ],
            ),
          ),
          Positioned(
            top: kToolbarHeight - kBottomNavigationBarHeight, // Height of the AppBar
            left: 0,
            right: 0,
            child: Opacity(
              opacity: _opacity,
              child: IgnorePointer(
                ignoring: _opacity != 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: Colors.grey.shade900,
                  height: 60.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeamHome(
                                  teamId: teamOne['TEAM_ID'].toString(),
                                ),
                              ),
                            );
                          });
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  width: MediaQuery.of(context).size.width * 0.125,
                                  'images/NBA_Logos/${teamOne['TEAM_ID']}.png',
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      teamOne['CITY'],
                                      textAlign: TextAlign.start,
                                      style: kBebasOffWhite.copyWith(fontSize: 15.0),
                                      maxLines: 1,
                                    ),
                                    AutoSizeText(
                                      teamOne['NICKNAME'],
                                      textAlign: TextAlign.start,
                                      style: kBebasOffWhite.copyWith(fontSize: 18.0),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (teamTwo.isNotEmpty)
                        IgnorePointer(
                          ignoring: _opacity == 1 ? false : true,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TeamHome(
                                      teamId: teamTwo['TEAM_ID'].toString(),
                                    ),
                                  ),
                                );
                              });
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        AutoSizeText(
                                          teamTwo['CITY'],
                                          style: kBebasOffWhite.copyWith(fontSize: 15.0),
                                          maxLines: 1,
                                        ),
                                        AutoSizeText(
                                          teamTwo['NICKNAME'],
                                          style: kBebasNormal.copyWith(fontSize: 18.0),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10.0),
                                    Image.asset(
                                      width: MediaQuery.of(context).size.width * 0.125,
                                      'images/NBA_Logos/${teamTwo['TEAM_ID']}.png',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NonComparisonRow extends StatelessWidget {
  const NonComparisonRow({
    super.key,
    required this.statName,
    required this.teamOne,
    required this.teamTwo,
  });

  final String statName;
  final dynamic teamOne;
  final dynamic teamTwo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: AutoSizeText(
            teamOne,
            textAlign: TextAlign.start,
            style: kBebasNormal.copyWith(fontSize: 18.0),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 16.0),
          ),
        ),
        Expanded(
          flex: 1,
          child: AutoSizeText(
            teamTwo,
            textAlign: TextAlign.end,
            style: kBebasNormal.copyWith(fontSize: 18.0),
          ),
        ),
      ],
    );
  }
}

class ComparisonRow extends StatelessWidget {
  const ComparisonRow({
    super.key,
    required this.statName,
    required this.teamOne,
    required this.teamTwo,
    this.teamOneColor = Colors.transparent,
    this.teamTwoColor = Colors.transparent,
  });

  final String statName;
  final dynamic teamOne;
  final dynamic teamTwo;
  final Color teamOneColor;
  final Color teamTwoColor;

  @override
  Widget build(BuildContext context) {
    bool oneIsBetter = (statName.contains('DRTG') || statName == 'FOULS PER 75')
        ? teamOne < teamTwo
        : teamOne > teamTwo;
    bool twoIsBetter = (statName.contains('DRTG') || statName == 'FOULS PER 75')
        ? teamTwo < teamOne
        : teamTwo > teamOne;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StatValue(
                value: teamOne,
                isHighlighted: oneIsBetter ? true : false,
                color: teamOneColor,
                isPercentage: statName.contains('%'),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 16.0),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StatValue(
                value: teamTwo,
                isHighlighted: twoIsBetter ? true : false,
                color: teamTwoColor,
                isPercentage: statName.contains('%'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatValue extends StatelessWidget {
  final dynamic value;
  final bool isHighlighted;
  final Color color;
  final bool isPercentage;

  StatValue(
      {required this.value,
      this.isHighlighted = false,
      required this.color,
      required this.isPercentage});

  @override
  Widget build(BuildContext context) {
    Map<Color, Color> lightColors = {
      const Color(0xFFFFFFFF): Color(0xFF000000),
      const Color(0xFFFEC524): Color(0xFF0E2240),
      const Color(0xFFFDBB30): Color(0xFF002D62),
      const Color(0xFFED184D): Color(0xFF0B2240),
      const Color(0xFF78BE20): Color(0xFF0B233F),
      const Color(0xFF85714D): Color(0xFF0C2340),
      const Color(0xFFE56020): Color(0xFF1D1160),
      const Color(0xFFC4CED4): Color(0xFF000000),
      const Color(0xFFFCA200): Color(0xFF002B5C),
      const Color(0xFFE31837): Color(0xFF002B5C),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: isHighlighted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        isPercentage ? '$value%' : '$value',
        style: isHighlighted && lightColors.containsKey(color)
            ? kBebasNormal.copyWith(color: lightColors[color])
            : kBebasNormal,
      ),
    );
  }
}
