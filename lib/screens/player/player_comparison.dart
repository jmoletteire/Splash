import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/player/player_cache.dart';
import 'package:splash/screens/player/player_home.dart';
import 'package:splash/utilities/constants.dart';

import '../../components/custom_icon_button.dart';
import '../../components/player_avatar.dart';
import '../../components/search_widget.dart';
import '../../utilities/player.dart';
import '../search_screen.dart';

class PlayerComparison extends StatefulWidget {
  final Map<String, dynamic> player;
  const PlayerComparison({super.key, required this.player});

  @override
  State<PlayerComparison> createState() => _PlayerComparisonState();
}

class _PlayerComparisonState extends State<PlayerComparison> {
  late List<String> seasonsOne;
  late List<String> seasonsTwo;
  late String selectedSeasonOne;
  late String selectedSeasonTwo;
  late Map<String, dynamic> playerOne;
  late Map<String, dynamic> playerTwo;

  ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;

  String calculateAge(String birthDate) {
    int age = DateTime.now().year -
        DateTime.parse(birthDate).year -
        (DateTime.now().month < DateTime.parse(birthDate).month ||
                (DateTime.now().month == DateTime.parse(birthDate).month &&
                    DateTime.now().day < DateTime.parse(birthDate).day)
            ? 1
            : 0);

    return age.toString();
  }

  double roundToDecimalPlaces(double value, int decimalPlaces) {
    num factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  Future<Map<String, dynamic>> getPlayer(String playerId) async {
    final playerCache = Provider.of<PlayerCache>(context, listen: false);
    if (playerCache.containsPlayer(playerId)) {
      return playerCache.getPlayer(playerId)!;
    } else {
      var fetchedPlayer = await Player().getPlayer(playerId);
      playerCache.addPlayer(playerId, fetchedPlayer);
      return fetchedPlayer;
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF111111),
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => SearchProvider(),
        child: SearchWidget(
          onPlayerSelected: (player) async {
            playerTwo = await getPlayer(player["PERSON_ID"].toString());
            setState(() {
              playerTwo.keys.contains('STATS')
                  ? seasonsTwo =
                      playerTwo['STATS'].keys.toList().reversed.toList()
                  : seasonsTwo = [kCurrentSeason];

              selectedSeasonTwo = seasonsTwo.first;
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    playerOne = widget.player;
    playerTwo = {};

    playerOne.keys.contains('STATS')
        ? seasonsOne = playerOne['STATS'].keys.toList().reversed.toList()
        : seasonsOne = [kCurrentSeason];

    selectedSeasonOne = seasonsOne.first;
    seasonsTwo = [kCurrentSeason];

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
    Color teamOneColor = kDarkPrimaryColors.contains(
            playerOne['STATS'][selectedSeasonOne]['BASIC']['TEAM_ABBREVIATION'])
        ? (kTeamColors[playerOne['STATS'][selectedSeasonOne]['BASIC']
            ['TEAM_ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[playerOne['STATS'][selectedSeasonOne]['BASIC']
            ['TEAM_ABBREVIATION']]!['primaryColor']!);

    Color teamTwoColor = Colors.transparent;
    if (playerTwo.isNotEmpty) {
      teamTwoColor = kDarkPrimaryColors.contains(playerTwo['STATS']
              [selectedSeasonTwo]['BASIC']['TEAM_ABBREVIATION'])
          ? (kTeamColors[playerTwo['STATS'][selectedSeasonTwo]['BASIC']
              ['TEAM_ABBREVIATION']]!['secondaryColor']!)
          : (kTeamColors[playerTwo['STATS'][selectedSeasonTwo]['BASIC']
              ['TEAM_ABBREVIATION']]!['primaryColor']!);
    }

    playerOne['AGE'] = calculateAge(playerOne['BIRTHDATE']);
    if (playerTwo.isNotEmpty) {
      playerTwo['AGE'] = calculateAge(playerTwo['BIRTHDATE']);
    }

    var heightOne = playerOne['HEIGHT'].split('-');
    String playerOneHeight = '${heightOne[0]}\'${heightOne[1]}\"';

    String playerTwoHeight = '';
    if (playerTwo.isNotEmpty) {
      var heightTwo = playerTwo['HEIGHT'].toString().split('-');
      playerTwoHeight = '${heightTwo[0]}\'${heightTwo[1]}\"';
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
                                child: SearchWidget(
                                  onPlayerSelected: (player) async {
                                    playerOne = await getPlayer(
                                        player["PERSON_ID"].toString());
                                    setState(() {
                                      playerOne.keys.contains('STATS')
                                          ? seasonsOne = playerOne['STATS']
                                              .keys
                                              .toList()
                                              .reversed
                                              .toList()
                                          : seasonsOne = [kCurrentSeason];

                                      selectedSeasonOne = seasonsOne.first;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin:
                                const EdgeInsets.fromLTRB(11.0, 11.0, 5.0, 5.0),
                            color: Colors.grey.shade900,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      PlayerAvatar(
                                        radius:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                        backgroundColor: Colors.white70,
                                        playerImageUrl:
                                            'https://cdn.nba.com/headshots/nba/latest/1040x760/${playerOne['PERSON_ID']}.png',
                                      ),
                                      const SizedBox(height: 5.0),
                                      AutoSizeText(
                                        playerOne['DISPLAY_FIRST_LAST'],
                                        style: kBebasOffWhite.copyWith(
                                            color: Colors.white,
                                            fontSize: 18.0),
                                        maxLines: 1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${playerOne['TEAM_CITY']} ${playerOne['TEAM_NAME']}',
                                            style: kBebasOffWhite.copyWith(
                                                color: Colors.grey,
                                                fontSize: 14.0),
                                          ),
                                          const SizedBox(width: 5.0),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 20.0),
                                            child: Image.asset(
                                              'images/NBA_Logos/${playerOne['TEAM_ID']}.png',
                                              fit: BoxFit.contain,
                                              alignment: Alignment.center,
                                              width: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Positioned(
                                  top: 5,
                                  right: 10,
                                  child: Icon(
                                    Icons
                                        .compare_arrows, // Replace with the desired icon
                                    color: Colors.white70,
                                    size: 24.0,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: const Color(0xFF111111),
                            context: context,
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => SearchProvider(),
                              child: SearchWidget(
                                onPlayerSelected: (player) async {
                                  playerTwo = await getPlayer(
                                      player["PERSON_ID"].toString());
                                  setState(() {
                                    playerTwo.keys.contains('STATS')
                                        ? seasonsTwo = playerTwo['STATS']
                                            .keys
                                            .toList()
                                            .reversed
                                            .toList()
                                        : seasonsTwo = [kCurrentSeason];

                                    selectedSeasonTwo = seasonsTwo.first;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin:
                              const EdgeInsets.fromLTRB(5.0, 11.0, 11.0, 5.0),
                          color: Colors.grey.shade900,
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  if (playerTwo.isNotEmpty)
                                    PlayerAvatar(
                                      radius:
                                          MediaQuery.of(context).size.width *
                                              0.06,
                                      backgroundColor: Colors.white70,
                                      playerImageUrl:
                                          'https://cdn.nba.com/headshots/nba/latest/1040x760/${playerTwo['PERSON_ID']}.png',
                                    ),
                                  if (playerTwo.isEmpty)
                                    SvgPicture.asset(
                                      'images/NBA_Logos/0.svg',
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                    ),
                                  const SizedBox(height: 5.0),
                                  AutoSizeText(
                                    playerTwo.isNotEmpty
                                        ? playerTwo['DISPLAY_FIRST_LAST']
                                        : 'Select Player',
                                    style: kBebasOffWhite.copyWith(
                                        color: Colors.white, fontSize: 18.0),
                                    maxLines: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        playerTwo.isNotEmpty
                                            ? '${playerTwo['TEAM_CITY']} ${playerTwo['TEAM_NAME']}'
                                            : '',
                                        style: kBebasOffWhite.copyWith(
                                            color: Colors.grey, fontSize: 14.0),
                                      ),
                                      if (playerTwo.isNotEmpty)
                                        const SizedBox(width: 5.0),
                                      if (playerTwo.isNotEmpty)
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 20.0),
                                          child: Image.asset(
                                            'images/NBA_Logos/${playerTwo['TEAM_ID']}.png',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                            width: 16.0,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              top: 5,
                              right: 10,
                              child: Icon(
                                Icons
                                    .compare_arrows, // Replace with the desired icon
                                color: Colors.white70,
                                size: 24.0,
                              ),
                            ),
                          ]),
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
                          items: seasonsOne
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style:
                                        kBebasNormal.copyWith(fontSize: 18.0),
                                  ),
                                  const SizedBox(width: 10.0),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 20.0),
                                    child: Image.asset(
                                      'images/NBA_Logos/${playerOne['STATS'][value]['BASIC']['TEAM_ID']}.png',
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
                          value: playerTwo.isNotEmpty
                              ? selectedSeasonTwo
                              : kCurrentSeason,
                          items: seasonsTwo
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style:
                                        kBebasNormal.copyWith(fontSize: 18.0),
                                  ),
                                  if (playerTwo.isNotEmpty)
                                    const SizedBox(width: 10.0),
                                  if (playerTwo.isNotEmpty)
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 20.0),
                                      child: Image.asset(
                                        'images/NBA_Logos/${playerTwo['STATS'][value]['BASIC']['TEAM_ID']}.png',
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        width: 20.0,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: playerTwo.isNotEmpty
                              ? (String? value) {
                                  setState(() {
                                    selectedSeasonTwo = value!;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                if (playerTwo.isNotEmpty)
                  Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 11.0, vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          NonComparisonRow(
                            statName: 'POSITION',
                            playerOne: playerOne['POSITION'],
                            playerTwo: playerTwo['POSITION'],
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'AGE',
                            playerOne: playerOne['AGE'],
                            playerTwo: playerTwo['AGE'],
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'HEIGHT',
                            playerOne: playerOneHeight,
                            playerTwo: playerTwoHeight,
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'WEIGHT',
                            playerOne: playerOne['WEIGHT'],
                            playerTwo: playerTwo['WEIGHT'],
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'EXP',
                            playerOne: playerOne['SEASON_EXP'].toString(),
                            playerTwo: playerTwo['SEASON_EXP'].toString(),
                          ),
                          const SizedBox(height: 5.0),
                          NonComparisonRow(
                            statName: 'DRAFT',
                            playerOne: playerOne['DRAFT_YEAR'] == 'Undrafted' ||
                                    playerOne['DRAFT_ROUND'] == null
                                ? 'UDFA (${playerOne['FROM_YEAR']})'
                                : 'R${playerOne['DRAFT_ROUND']}:${playerOne['DRAFT_NUMBER']} (${playerOne['DRAFT_YEAR']})',
                            playerTwo: playerTwo['DRAFT_YEAR'] == 'Undrafted' ||
                                    playerTwo['DRAFT_ROUND'] == null
                                ? 'UDFA (${playerTwo['FROM_YEAR']})'
                                : 'R${playerTwo['DRAFT_ROUND']}:${playerTwo['DRAFT_NUMBER']} (${playerTwo['DRAFT_YEAR']})',
                          ),
                        ],
                      ),
                    ),
                  ),
                if (playerTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Top Stats',
                                    style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'Games Played',
                              playerOne: playerOne['STATS'][selectedSeasonOne]
                                  ['BASIC']['GP'],
                              playerTwo: playerTwo['STATS'][selectedSeasonTwo]
                                  ['BASIC']['GP'],
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'Min Per Game',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                      ['MIN'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                      ['MIN'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'Poss Per Game',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                      ['POSS_PER_GM'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                      ['POSS_PER_GM'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'PPG',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['PTS'] /
                                      playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['GP']),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['PTS'] /
                                      playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['GP']),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'RPG',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['REB'] /
                                      playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['GP']),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['REB'] /
                                      playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['GP']),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'APG',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['AST'] /
                                      playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['GP']),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['AST'] /
                                      playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['GP']),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'Usage %',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]['ADV']
                                          ['USG_PCT'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                          ['USG_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2013 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2013)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2013 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2013)
                              ComparisonRow(
                                statName: 'Touches per 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]['ADV']
                                        ['TOUCHES']['TOUCHES_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                        ['TOUCHES']['TOUCHES_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'PTS per 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['PTS_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['PTS_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2007 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2007)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2007 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2007)
                              ComparisonRow(
                                statName: 'OFF - On/Off',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]['ADV']
                                        ['OFF_RATING_ON_OFF'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                        ['OFF_RATING_ON_OFF'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2007 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2007)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2007 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2007)
                              ComparisonRow(
                                statName: 'DEF - On/Off',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]['ADV']
                                        ['DEF_RATING_ON_OFF'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                        ['DEF_RATING_ON_OFF'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2007 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2007)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2007 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2007)
                              ComparisonRow(
                                statName: 'Net - On/Off',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]['ADV']
                                        ['NET_RATING_ON_OFF'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                        ['NET_RATING_ON_OFF'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                if (playerTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Shooting',
                                    style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'FG%',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['FG_PCT'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['FG_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: '3P%',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['FG3_PCT'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['FG3_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'FT%',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['FT_PCT'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['FT_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: '3PA Rate%',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['3PAr'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['3PAr'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'FTA Rate%',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]
                                          ['BASIC']['FTAr'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]
                                          ['BASIC']['FTAr'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'EFG%',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]['ADV']
                                          ['EFG_PCT'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                          ['EFG_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'TS%',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]['ADV']
                                          ['TS_PCT'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                          ['TS_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                if (playerTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Rebounding',
                                    style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'REB PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['REB_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['REB_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'OREB PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['OREB_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['OREB_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'DREB PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['DREB_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['DREB_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'OREB%',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                          ['OREB_PCT'] *
                                      100,
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                          ['OREB_PCT'] *
                                      100,
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'DREB%',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                          ['DREB_PCT'] *
                                      100,
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                          ['DREB_PCT'] *
                                      100,
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 15.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'BOX OUTS PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                        ['HUSTLE']['BOX_OUTS_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                        ['HUSTLE']['BOX_OUTS_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'OFF BOXOUTS PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                        ['HUSTLE']['OFF_BOXOUTS_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                        ['HUSTLE']['OFF_BOXOUTS_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'DEF BOXOUTS PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                        ['HUSTLE']['DEF_BOXOUTS_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                        ['HUSTLE']['DEF_BOXOUTS_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                if (playerTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 2013 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 2013)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Passing',
                                    style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'AST PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                      ['PASSING']['AST_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                      ['PASSING']['AST_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'ADJ AST PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                      ['PASSING']['AST_ADJ_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                      ['PASSING']['AST_ADJ_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'POT. AST PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                      ['PASSING']['POTENTIAL_AST_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                      ['PASSING']['POTENTIAL_AST_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'AST PTS CREATED PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                      ['PASSING']['AST_PTS_CREATED_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                      ['PASSING']['AST_PTS_CREATED_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'AST - PASS %',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]['ADV']
                                          ['PASSING']['AST_TO_PASS_PCT'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                          ['PASSING']['AST_TO_PASS_PCT'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'ADJ AST - PASS %',
                              playerOne: roundToDecimalPlaces(
                                  (playerOne['STATS'][selectedSeasonOne]['ADV']
                                          ['PASSING']['AST_TO_PASS_PCT_ADJ'] *
                                      100),
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  (playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                          ['PASSING']['AST_TO_PASS_PCT_ADJ'] *
                                      100),
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                if (playerTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Defense',
                                    style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'DRTG - ON',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['ADV']
                                      ['DEF_RATING'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['ADV']
                                      ['DEF_RATING'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'STL PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['STL_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['STL_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'BLK PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['BLK_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['BLK_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 15.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'DEFLECTIONS PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                        ['HUSTLE']['DEFLECTIONS_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                        ['HUSTLE']['DEFLECTIONS_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'CONTESTS PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                        ['HUSTLE']['CONTESTED_SHOTS_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                        ['HUSTLE']['CONTESTED_SHOTS_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                if (playerTwo.isNotEmpty)
                  if (int.parse(selectedSeasonOne.substring(0, 4)) >= 1996 &&
                      int.parse(selectedSeasonTwo.substring(0, 4)) >= 1996)
                    Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 11.0, vertical: 5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Hustle',
                                    style: kBebasBold.copyWith(fontSize: 20.0))
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'SCREEN AST PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                        ['HUSTLE']['SCREEN_ASSISTS_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                        ['HUSTLE']['SCREEN_ASSISTS_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 5.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'SCREEN AST PTS PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                        ['HUSTLE']['SCREEN_AST_PTS_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                        ['HUSTLE']['SCREEN_AST_PTS_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 15.0),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              ComparisonRow(
                                statName: 'LOOSE BALLS PER 75',
                                playerOne: roundToDecimalPlaces(
                                    playerOne['STATS'][selectedSeasonOne]
                                            ['HUSTLE']
                                        ['LOOSE_BALLS_RECOVERED_PER_75'],
                                    1),
                                playerTwo: roundToDecimalPlaces(
                                    playerTwo['STATS'][selectedSeasonTwo]
                                            ['HUSTLE']
                                        ['LOOSE_BALLS_RECOVERED_PER_75'],
                                    1),
                                teamOneColor: teamOneColor,
                                teamTwoColor: teamTwoColor,
                              ),
                            if (int.parse(selectedSeasonOne.substring(0, 4)) >=
                                    2016 &&
                                int.parse(selectedSeasonTwo.substring(0, 4)) >=
                                    2016)
                              const SizedBox(height: 15.0),
                            ComparisonRow(
                              statName: 'FOULS PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['PF_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['PF_PER_75'],
                                  1),
                              teamOneColor: teamOneColor,
                              teamTwoColor: teamTwoColor,
                            ),
                            const SizedBox(height: 5.0),
                            ComparisonRow(
                              statName: 'FOULS DRAWN PER 75',
                              playerOne: roundToDecimalPlaces(
                                  playerOne['STATS'][selectedSeasonOne]['BASIC']
                                      ['PFD_PER_75'],
                                  1),
                              playerTwo: roundToDecimalPlaces(
                                  playerTwo['STATS'][selectedSeasonTwo]['BASIC']
                                      ['PFD_PER_75'],
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
            top: kToolbarHeight -
                kBottomNavigationBarHeight, // Height of the AppBar
            left: 0,
            right: 0,
            child: Opacity(
              opacity: _opacity,
              child: IgnorePointer(
                ignoring: _opacity != 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: Colors.grey.shade900,
                  height: 65.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerHome(
                                  teamId: playerOne['TEAM_ID'].toString(),
                                  playerId: playerOne['PERSON_ID'].toString(),
                                ),
                              ),
                            );
                          });
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                PlayerAvatar(
                                  radius:
                                      MediaQuery.of(context).size.width * 0.055,
                                  backgroundColor: Colors.white70,
                                  playerImageUrl:
                                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${playerOne['PERSON_ID']}.png',
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      playerOne['FIRST_NAME'],
                                      textAlign: TextAlign.start,
                                      style: kBebasOffWhite.copyWith(
                                          fontSize: 15.0),
                                      maxLines: 1,
                                    ),
                                    AutoSizeText(
                                      playerOne['LAST_NAME'],
                                      textAlign: TextAlign.start,
                                      style: kBebasOffWhite.copyWith(
                                          fontSize: 18.0),
                                      maxLines: 1,
                                    ),
                                    Row(
                                      children: [
                                        AutoSizeText(
                                          playerOne['POSITION'],
                                          style: kBebasNormal.copyWith(
                                              color: Colors.grey.shade400,
                                              fontSize: 12.0),
                                          maxLines: 1,
                                        ),
                                        const SizedBox(width: 5.0),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 20.0),
                                          child: Image.asset(
                                            'images/NBA_Logos/${playerOne['TEAM_ID']}.png',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                            width: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (playerTwo.isNotEmpty)
                        IgnorePointer(
                          ignoring: _opacity == 1 ? false : true,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerHome(
                                      teamId: playerTwo['TEAM_ID'].toString(),
                                      playerId:
                                          playerTwo['PERSON_ID'].toString(),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        AutoSizeText(
                                          playerTwo['FIRST_NAME'],
                                          style: kBebasOffWhite.copyWith(
                                              fontSize: 15.0),
                                          maxLines: 1,
                                        ),
                                        AutoSizeText(
                                          playerTwo['LAST_NAME'],
                                          style: kBebasWhite.copyWith(
                                              fontSize: 18.0),
                                          maxLines: 1,
                                        ),
                                        Row(
                                          children: [
                                            AutoSizeText(
                                              playerTwo['POSITION'],
                                              style: kBebasNormal.copyWith(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 12.0),
                                              maxLines: 1,
                                            ),
                                            const SizedBox(width: 5.0),
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 20.0),
                                              child: Image.asset(
                                                'images/NBA_Logos/${playerTwo['TEAM_ID']}.png',
                                                fit: BoxFit.contain,
                                                alignment: Alignment.center,
                                                width: 18.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10.0),
                                    PlayerAvatar(
                                      radius:
                                          MediaQuery.of(context).size.width *
                                              0.055,
                                      backgroundColor: Colors.white70,
                                      playerImageUrl:
                                          'https://cdn.nba.com/headshots/nba/latest/1040x760/${playerTwo['PERSON_ID']}.png',
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
    required this.playerOne,
    required this.playerTwo,
  });

  final String statName;
  final dynamic playerOne;
  final dynamic playerTwo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: AutoSizeText(
            playerOne,
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
            playerTwo,
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
    required this.playerOne,
    required this.playerTwo,
    this.teamOneColor = Colors.transparent,
    this.teamTwoColor = Colors.transparent,
  });

  final String statName;
  final dynamic playerOne;
  final dynamic playerTwo;
  final Color teamOneColor;
  final Color teamTwoColor;

  @override
  Widget build(BuildContext context) {
    bool oneIsBetter = (statName == 'DEF - On/Off' ||
            statName.contains('DRTG') ||
            statName == 'FOULS PER 75')
        ? playerOne < playerTwo
        : playerOne > playerTwo;
    bool twoIsBetter = (statName == 'DEF - On/Off' ||
            statName.contains('DRTG') ||
            statName == 'FOULS PER 75')
        ? playerTwo < playerOne
        : playerTwo > playerOne;
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
                value: playerOne,
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
                value: playerTwo,
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
