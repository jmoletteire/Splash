import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/team/comparison/team_search_widget.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
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

  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
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
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      backgroundColor: const Color(0xFF111111),
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => SearchProvider(),
        child: TeamSearchWidget(
          onTeamSelected: (team) async {
            teamTwo = await getTeam(team["TEAM_ID"].toString());
            setState(() {
              if (teamTwo.keys.contains('seasons')) {
                seasonsTwo = teamTwo['seasons'].keys.toList().reversed.toList();
                seasonsTwo = seasonsTwo
                    .where((season) => int.parse(season.substring(0, 4)) >= 1996)
                    .toList();

                // If season has not started, use previous season
                if (teamTwo['seasons'].containsKey(seasonsTwo.first)) {
                  if (teamTwo['seasons'][seasonsTwo.first]['GP'] > 0) {
                    selectedSeasonTwo = seasonsTwo.first;
                  } else {
                    selectedSeasonTwo = seasonsTwo[1];
                    seasonsTwo.removeAt(0);
                  }
                } else {
                  selectedSeasonTwo = seasonsTwo[1];
                  seasonsTwo.removeAt(0);
                }
                teamTwo['seasons'][selectedSeasonTwo]['STATS'].keys.contains('PLAYOFFS')
                    ? teamTwo['seasons'][selectedSeasonTwo]['STATS']['PLAYOFFS']
                            .keys
                            .contains('ADV')
                        ? seasonTypesTwo = ['REGULAR SEASON', 'PLAYOFFS']
                        : seasonTypesTwo = ['REGULAR SEASON']
                    : seasonTypesTwo = ['REGULAR SEASON'];
                selectedSeasonTypeTwo = seasonTypesTwo.first;
              } else {
                seasonsTwo = [kCurrentSeason];
                seasonTypesTwo = ['REGULAR SEASON'];
                selectedSeasonTypeTwo = seasonTypesTwo.first;
              }
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
      seasonsOne =
          seasonsOne.where((season) => int.parse(season.substring(0, 4)) >= 1996).toList();

      // If season has not started, use previous season
      if (teamOne['seasons'].containsKey(seasonsOne.first)) {
        if (teamOne['seasons'][seasonsOne.first]['GP'] > 0) {
          selectedSeasonOne = seasonsOne.first;
        } else {
          selectedSeasonOne = seasonsOne[1];
          seasonsOne.removeAt(0);
        }
      } else {
        selectedSeasonOne = seasonsOne[1];
        seasonsOne.removeAt(0);
      }

      teamOne['seasons'][selectedSeasonOne]['STATS'].keys.contains('PLAYOFFS')
          ? teamOne['seasons'][selectedSeasonOne]['STATS']['PLAYOFFS'].keys.contains('ADV')
              ? seasonTypesOne = ['REGULAR SEASON', 'PLAYOFFS']
              : seasonTypesOne = ['REGULAR SEASON']
          : seasonTypesOne = ['REGULAR SEASON'];

      selectedSeasonTypeOne = seasonTypesOne.first;
    } else {
      seasonsOne = [kCurrentSeason];
      seasonTypesOne = ['REGULAR SEASON'];
      selectedSeasonTypeOne = seasonTypesOne.first;
    }

    seasonsTwo = [kCurrentSeason];
    seasonTypesTwo = ['REGULAR SEASON'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet();
    });

    _scrollController = ScrollController()..addListener(_scrollListener);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController()..addListener(_scrollListener);
    _notifier.addController('team_compare', _scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController('team_compare');
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
        titleTextStyle: kBebasBold.copyWith(fontSize: 24.0.r),
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
                            constraints:
                                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
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
                                      seasonsOne = seasonsOne
                                          .where((season) =>
                                              int.parse(season.substring(0, 4)) >= 1996)
                                          .toList();

                                      // If season has not started, use previous season
                                      if (teamOne['seasons'].containsKey(seasonsOne.first)) {
                                        if (teamOne['seasons'][seasonsOne.first]['GP'] > 0) {
                                          selectedSeasonOne = seasonsOne.first;
                                        } else {
                                          selectedSeasonOne = seasonsOne[1];
                                          seasonsOne.removeAt(0);
                                        }
                                      } else {
                                        selectedSeasonOne = seasonsOne[1];
                                        seasonsOne.removeAt(0);
                                      }

                                      teamOne['seasons'][selectedSeasonOne]['STATS']
                                                  ['PLAYOFFS']
                                              .keys
                                              .contains('ADV')
                                          ? seasonTypesOne = ['REGULAR SEASON', 'PLAYOFFS']
                                          : seasonTypesOne = ['REGULAR SEASON'];

                                      selectedSeasonTypeOne = seasonTypesOne.first;
                                    } else {
                                      seasonsOne = [kCurrentSeason];
                                      seasonTypesOne = ['REGULAR SEASON'];
                                      selectedSeasonTypeOne = seasonTypesOne.first;
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 5.0.r, 5.0.r),
                          color: Colors.grey.shade900,
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15.0.r),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/NBA_Logos/${teamOne['TEAM_ID']}.png',
                                        width: 100.0.r,
                                        height: 100.0.r,
                                      ),
                                      SizedBox(height: 10.0.r),
                                      AutoSizeText(
                                        '${teamOne['CITY']} ${teamOne['NICKNAME']}',
                                        style: kBebasOffWhite.copyWith(
                                            color: Colors.white, fontSize: 18.0.r),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 10,
                                child: Icon(
                                  Icons.compare_arrows, // Replace with the desired icon
                                  color: Colors.white70,
                                  size: 24.0.r,
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
                            constraints:
                                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
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
                                      seasonsTwo = seasonsTwo
                                          .where((season) =>
                                              int.parse(season.substring(0, 4)) >= 1996)
                                          .toList();

                                      // If season has not started, use previous season
                                      if (teamTwo['seasons'].containsKey(seasonsTwo.first)) {
                                        if (teamTwo['seasons'][seasonsTwo.first]['GP'] > 0) {
                                          selectedSeasonTwo = seasonsTwo.first;
                                        } else {
                                          selectedSeasonTwo = seasonsTwo[1];
                                          seasonsTwo.removeAt(0);
                                        }
                                      } else {
                                        selectedSeasonTwo = seasonsTwo[1];
                                        seasonsTwo.removeAt(0);
                                      }

                                      teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                                  ['PLAYOFFS']
                                              .keys
                                              .contains('ADV')
                                          ? seasonTypesTwo = ['REGULAR SEASON', 'PLAYOFFS']
                                          : seasonTypesTwo = ['REGULAR SEASON'];
                                      selectedSeasonTypeTwo = seasonTypesTwo.first;
                                    } else {
                                      seasonsTwo = [kCurrentSeason];
                                      seasonTypesTwo = ['REGULAR SEASON'];
                                      selectedSeasonTypeTwo = seasonTypesTwo.first;
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.fromLTRB(5.0.r, 11.0.r, 11.0.r, 5.0.r),
                          color: Colors.grey.shade900,
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15.0.r),
                                child: Center(
                                  child: Column(
                                    children: [
                                      if (teamTwo.isEmpty)
                                        Image.asset(
                                          'images/NBA_Logos/0.png',
                                          width: 100.0.r,
                                          height: 100.0.r,
                                        ),
                                      if (teamTwo.isEmpty) SizedBox(height: 5.0.r),
                                      if (teamTwo.isEmpty)
                                        AutoSizeText(
                                          'SELECT TEAM',
                                          style: kBebasOffWhite.copyWith(
                                              color: Colors.white, fontSize: 18.0.r),
                                          maxLines: 1,
                                        ),
                                      if (teamTwo.isNotEmpty)
                                        Image.asset(
                                          'images/NBA_Logos/${teamTwo['TEAM_ID']}.png',
                                          width: 100.0.r,
                                          height: 100.0.r,
                                        ),
                                      if (teamTwo.isNotEmpty) SizedBox(height: 10.0.r),
                                      if (teamTwo.isNotEmpty)
                                        AutoSizeText(
                                          '${teamTwo['CITY']} ${teamTwo['NICKNAME']}',
                                          style: kBebasOffWhite.copyWith(
                                              color: Colors.white, fontSize: 18.0.r),
                                          maxLines: 1,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 10,
                                child: Icon(
                                  Icons.compare_arrows, // Replace with the desired icon
                                  color: Colors.white70,
                                  size: 24.0.r,
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
                        margin: EdgeInsets.fromLTRB(11.0.r, 5.0.r, 5.0.r, 5.0.r),
                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0.r,
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
                                    style: kBebasNormal.copyWith(fontSize: 18.0.r),
                                  ),
                                  SizedBox(width: 10.0.r),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 20.0.r),
                                    child: Image.asset(
                                      'images/NBA_Logos/${teamOne['TEAM_ID']}.png',
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      width: 20.0.r,
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
                        margin: EdgeInsets.fromLTRB(5.0.r, 5.0.r, 11.0.r, 5.0.r),
                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0.r,
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
                                      fontSize: 18.0.r,
                                      color: teamTwo.isNotEmpty ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                  if (teamTwo.isNotEmpty) SizedBox(width: 10.0.r),
                                  if (teamTwo.isNotEmpty)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 20.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/${teamTwo['TEAM_ID']}.png',
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        width: 20.0.r,
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
                        margin: EdgeInsets.fromLTRB(11.0.r, 5.0.r, 5.0.r, 5.0.r),
                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0.r,
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
                                    style: kBebasNormal.copyWith(fontSize: 18.0.r),
                                  ),
                                  SizedBox(width: 10.0.r),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 10.0.r),
                                    child: value == 'REGULAR SEASON'
                                        ? Image.asset(
                                            'images/NBA_Logos/0.png',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                            width: 10.0.r,
                                          )
                                        : SvgPicture.asset(
                                            'images/playoffs.svg',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                            width: 10.0.r,
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
                        margin: EdgeInsets.fromLTRB(5.0.r, 5.0.r, 11.0.r, 5.0.r),
                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0.r,
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
                                      fontSize: 18.0.r,
                                      color: teamTwo.isNotEmpty ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                  if (teamTwo.isNotEmpty) SizedBox(width: 10.0.r),
                                  if (teamTwo.isNotEmpty)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 20.0.r),
                                      child: value == 'REGULAR SEASON'
                                          ? Image.asset(
                                              'images/NBA_Logos/0.png',
                                              fit: BoxFit.contain,
                                              alignment: Alignment.center,
                                              width: 10.0.r,
                                            )
                                          : SvgPicture.asset(
                                              'images/playoffs.svg',
                                              fit: BoxFit.contain,
                                              alignment: Alignment.center,
                                              width: 10.0.r,
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
                    margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                    child: Padding(
                      padding: EdgeInsets.all(15.0.r),
                      child: Column(
                        children: [
                          NonComparisonRow(
                            statName: 'RECORD',
                            teamOne:
                                '${teamOne['seasons'][selectedSeasonOne]['WINS']} - ${teamOne['seasons'][selectedSeasonOne]['LOSSES']}',
                            teamTwo:
                                '${teamTwo['seasons'][selectedSeasonTwo]['WINS']} - ${teamTwo['seasons'][selectedSeasonTwo]['LOSSES']}',
                          ),
                          SizedBox(height: 5.0.r),
                          NonComparisonRow(
                            statName: 'WIN %',
                            teamOne: teamOne['seasons'][selectedSeasonOne]['WIN_PCT']
                                .toStringAsFixed(3),
                            teamTwo: teamTwo['seasons'][selectedSeasonTwo]['WIN_PCT']
                                .toStringAsFixed(3),
                          ),
                          SizedBox(height: 5.0.r),
                          NonComparisonRow(
                            statName: 'STANDINGS',
                            teamOne: getStanding(
                                teamOne['seasons'][selectedSeasonOne]['CONF_RANK']),
                            teamTwo: getStanding(
                                teamTwo['seasons'][selectedSeasonTwo]['CONF_RANK']),
                          ),
                          SizedBox(height: 5.0.r),
                          NonComparisonRow(
                            statName: 'CONF',
                            teamOne: teamOne['CONF'].toString().substring(0, 4),
                            teamTwo: teamTwo['CONF'].toString().substring(0, 4),
                          ),
                          SizedBox(height: 5.0.r),
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
                      margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                      child: Padding(
                        padding: EdgeInsets.all(15.0.r),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Top Stats', style: kBebasBold.copyWith(fontSize: 20.0.r))
                              ],
                            ),
                            SizedBox(height: 15.0.r),
                            ComparisonRow(
                              statName: 'OFF RATING',
                              teamOne: teamOne['seasons'][selectedSeasonOne]['STATS']
                                  [selectedSeasonTypeOne]['ADV']['OFF_RATING'],
                              teamTwo: teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                  [selectedSeasonTypeTwo]['ADV']['OFF_RATING'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            SizedBox(height: 5.0.r),
                            ComparisonRow(
                              statName: 'DEF RATING',
                              teamOne: teamOne['seasons'][selectedSeasonOne]['STATS']
                                  [selectedSeasonTypeOne]['ADV']['DEF_RATING'],
                              teamTwo: teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                  [selectedSeasonTypeTwo]['ADV']['DEF_RATING'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            SizedBox(height: 5.0.r),
                            ComparisonRow(
                              statName: 'NET RATING',
                              teamOne: teamOne['seasons'][selectedSeasonOne]['STATS']
                                  [selectedSeasonTypeOne]['ADV']['NET_RATING'],
                              teamTwo: teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                  [selectedSeasonTypeTwo]['ADV']['NET_RATING'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            SizedBox(height: 15.0.r),
                            ComparisonRow(
                              statName: 'PACE',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['ADV']['PACE'],
                                  1),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['ADV']['PACE'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            SizedBox(height: 5.0.r),
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
                      margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                      child: Padding(
                        padding: EdgeInsets.all(15.0.r),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Shooting', style: kBebasBold.copyWith(fontSize: 20.0.r))
                              ],
                            ),
                            SizedBox(height: 15.0.r),
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
                            SizedBox(height: 5.0.r),
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
                            SizedBox(height: 5.0.r),
                            ComparisonRow(
                              statName: 'FT%',
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
                            SizedBox(height: 15.0.r),
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
                            SizedBox(height: 5.0.r),
                            ComparisonRow(
                              statName: 'FT/FGA',
                              teamOne: roundToDecimalPlaces(
                                  teamOne['seasons'][selectedSeasonOne]['STATS']
                                      [selectedSeasonTypeOne]['BASIC']['FT_PER_FGA'],
                                  2),
                              teamTwo: roundToDecimalPlaces(
                                  teamTwo['seasons'][selectedSeasonTwo]['STATS']
                                      [selectedSeasonTypeTwo]['BASIC']['FT_PER_FGA'],
                                  2),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            SizedBox(height: 15.0.r),
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
                            SizedBox(height: 5.0.r),
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
                      margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                      child: Padding(
                        padding: EdgeInsets.all(15.0.r),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Rebounding',
                                    style: kBebasBold.copyWith(fontSize: 20.0.r))
                              ],
                            ),
                            SizedBox(height: 15.0.r),
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
                            SizedBox(height: 5.0.r),
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
                            SizedBox(height: 5.0.r),
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
                            SizedBox(height: 15.0.r),
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
                            SizedBox(height: 5.0.r),
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
                              SizedBox(height: 15.0.r),
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
                              SizedBox(height: 5.0.r),
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
                              SizedBox(height: 5.0.r),
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
                      margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                      child: Padding(
                        padding: EdgeInsets.all(15.0.r),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Defense', style: kBebasBold.copyWith(fontSize: 20.0.r))
                              ],
                            ),
                            SizedBox(height: 15.0.r),
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
                            SizedBox(height: 5.0.r),
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
                              SizedBox(height: 15.0.r),
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
                              SizedBox(height: 5.0.r),
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
                      margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
                      child: Padding(
                        padding: EdgeInsets.all(15.0.r),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Hustle', style: kBebasBold.copyWith(fontSize: 20.0.r))
                              ],
                            ),
                            SizedBox(height: 15.0.r),
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
                              SizedBox(height: 5.0.r),
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
                              SizedBox(height: 15.0.r),
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
                              SizedBox(height: 15.0.r),
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
                            SizedBox(height: 5.0.r),
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
                SizedBox(height: 5.0.r),
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
                  padding: EdgeInsets.symmetric(horizontal: 20.0.r),
                  color: Colors.grey.shade900,
                  height: 60.0.r,
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
                                  'images/NBA_Logos/${teamOne['TEAM_ID']}.png',
                                  width: 50.0.r,
                                ),
                                SizedBox(width: 10.0.r),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      teamOne['CITY'],
                                      textAlign: TextAlign.start,
                                      style: kBebasOffWhite.copyWith(fontSize: 15.0.r),
                                      maxLines: 1,
                                    ),
                                    AutoSizeText(
                                      teamOne['NICKNAME'],
                                      textAlign: TextAlign.start,
                                      style: kBebasOffWhite.copyWith(fontSize: 18.0.r),
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
                                          style: kBebasOffWhite.copyWith(fontSize: 15.0.r),
                                          maxLines: 1,
                                        ),
                                        AutoSizeText(
                                          teamTwo['NICKNAME'],
                                          style: kBebasNormal.copyWith(fontSize: 18.0.r),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10.0.r),
                                    Image.asset(
                                      'images/NBA_Logos/${teamTwo['TEAM_ID']}.png',
                                      width: 50.0.r,
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
            style: kBebasNormal.copyWith(fontSize: 18.0.r),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 16.0.r),
          ),
        ),
        Expanded(
          flex: 1,
          child: AutoSizeText(
            teamTwo,
            textAlign: TextAlign.end,
            style: kBebasNormal.copyWith(fontSize: 18.0.r),
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
    bool oneIsBetter =
        (statName == 'DEF RATING' || statName.contains('TOV') || statName == 'FOULS PER 75')
            ? teamOne < teamTwo
            : teamOne > teamTwo;
    bool twoIsBetter =
        (statName == 'DEF RATING' || statName.contains('TOV') || statName == 'FOULS PER 75')
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
            style: kBebasNormal.copyWith(fontSize: 16.0.r),
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
      padding: EdgeInsets.symmetric(horizontal: 8.0.r),
      decoration: BoxDecoration(
        color: isHighlighted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        isPercentage ? '$value%' : '$value',
        style: isHighlighted && lightColors.containsKey(color)
            ? kBebasNormal.copyWith(fontSize: 20.0.r, color: lightColors[color])
            : kBebasNormal.copyWith(fontSize: 20.0.r),
      ),
    );
  }
}
