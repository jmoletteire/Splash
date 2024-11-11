import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/screens/game/play_by_play/pbp_video.dart';
import 'package:splash/utilities/constants.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../player/player_home.dart';

class PlayByPlay extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;

  const PlayByPlay({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
  });

  @override
  State<PlayByPlay> createState() => _PlayByPlayState();
}

class _PlayByPlayState extends State<PlayByPlay> {
  late bool _inProgress;
  late List allActions;
  late List firstQuarter;
  late List secondQuarter;
  late List thirdQuarter;
  late List fourthQuarter;
  late List overTime;
  late int selectedPlayer;
  late List<Map<String, dynamic>> players;
  late String selectedTeam;
  late List<String> teams;
  late Map<String, int> teamCodes;
  late String homeTeamAbbr;
  late String awayTeamAbbr;
  int initialLabelIndex = 1;

  void filterActions(int? teamId, int? playerId) {
    if (teamId == 0 && playerId == 0) {
      setState(() {
        allActions = widget.game['PBP'];
      });
    } else if (teamId != 0 && playerId == 0) {
      setState(() {
        allActions = widget.game['PBP'].where((e) => e['possession'] == teamId).toList();
      });
    } else if (teamId == 0 && playerId != 0) {
      setState(() {
        allActions = widget.game['PBP']
            .where(
                (e) => e['personIdsFilter'] != null && e['personIdsFilter'].contains(playerId))
            .toList();
      });
    } else {
      setState(() {
        allActions = widget.game['PBP']
            .where((e) =>
                e['possession'] == teamId &&
                e['personIdsFilter'] != null &&
                e['personIdsFilter'].contains(playerId))
            .toList();
      });
    }

    if (_inProgress) {
      firstQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 1)
          .toList()
          .reversed
          .toList();
      secondQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 2)
          .toList()
          .reversed
          .toList();
      thirdQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 3)
          .toList()
          .reversed
          .toList();
      fourthQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 4)
          .toList()
          .reversed
          .toList();
      overTime = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] > 4)
          .toList()
          .reversed
          .toList();
    } else {
      firstQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 1)
          .toList();
      secondQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 2)
          .toList();
      thirdQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 3)
          .toList();
      fourthQuarter = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 4)
          .toList();
      overTime = allActions
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] > 4)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _inProgress = widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2;

    homeTeamAbbr = kTeamIdToName[widget.homeId][1] ?? 'Home';
    awayTeamAbbr = kTeamIdToName[widget.awayId][1] ?? 'Away';
    teams = [awayTeamAbbr, 'ALL', homeTeamAbbr];

    selectedTeam = 'ALL';
    teamCodes = {
      homeTeamAbbr: int.parse(widget.homeId),
      'ALL': 0,
      awayTeamAbbr: int.parse(widget.awayId),
    };

    selectedPlayer = 0;
    players = [
      {'id': 0, 'name': 'ALL'}
    ];

    if (widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] > 1) {
      if (widget.game['BOXSCORE'].containsKey('homeTeam')) {
        for (var player in widget.game['BOXSCORE']['homeTeam']['players']) {
          Map<String, dynamic> playerData = {
            'id': player['personId'],
            'team': widget.homeId,
            'name': player['nameI'],
            'number': player['jerseyNum'],
          };
          players.add(playerData);
        }
        for (var player in widget.game['BOXSCORE']['awayTeam']['players']) {
          Map<String, dynamic> playerData = {
            'id': player['personId'],
            'team': widget.awayId,
            'name': player['nameI'],
            'number': player['jerseyNum'],
          };
          players.add(playerData);
        }
      } else {
        for (var player in widget.game['BOXSCORE']['PlayerStats']) {
          Map<String, dynamic> playerData = {
            'id': player['PLAYER_ID'],
            'team': player['TEAM_ID'],
            'name': player['PLAYER_NAME'],
            'number': 0,
          };
          players.add(playerData);
        }
      }
    }

    allActions = widget.game['PBP'];
    filterActions(teamCodes[selectedTeam], selectedPlayer);
  }

  @override
  void didUpdateWidget(covariant PlayByPlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the game data has changed
    if (oldWidget.game != widget.game) {
      filterActions(teamCodes[selectedTeam], selectedPlayer);
    }
  }

  double colorDistance(Color color1, Color color2) {
    int r1 = color1.red;
    int g1 = color1.green;
    int b1 = color1.blue;

    int r2 = color2.red;
    int g2 = color2.green;
    int b2 = color2.blue;

    // Calculate the Euclidean distance between the two colors
    double distance =
        sqrt((r2 - r1) * (r2 - r1) + (g2 - g1) * (g2 - g1) + (b2 - b1) * (b2 - b1)).toDouble();

    return distance;
  }

  bool areColorsSimilar(Color color1, Color color2, {double threshold = 100.0}) {
    // Check if the color distance is below the similarity threshold
    return colorDistance(color1, color2) < threshold;
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    String homeAbbr = kTeamIdToName[widget.homeId][1];
    Color homeTeamColor = kDarkPrimaryColors.contains(homeAbbr)
        ? (kTeamColors[homeAbbr]!['secondaryColor']!)
        : (kTeamColors[homeAbbr]!['primaryColor']!);

    String awayAbbr = kTeamIdToName[widget.awayId]?[1] ?? 'FA';
    Color awayTeamColor = kDarkPrimaryColors.contains(awayAbbr)
        ? (kTeamColors[awayAbbr]!['secondaryColor']!)
        : (kTeamColors[awayAbbr]!['primaryColor']!);

    if (areColorsSimilar(homeTeamColor, awayTeamColor)) {
      awayTeamColor == kTeamColors[awayAbbr]!['secondaryColor']!
          ? awayTeamColor = kTeamColors[awayAbbr]!['primaryColor']!
          : awayTeamColor = kTeamColors[awayAbbr]!['secondaryColor']!;

      if (awayTeamColor == const Color(0xFF000000)) {
        awayTeamColor == kTeamColors[awayAbbr]!['secondaryColor']!
            ? awayTeamColor = kTeamColors[awayAbbr]!['primaryColor']!
            : awayTeamColor = kTeamColors[awayAbbr]!['secondaryColor']!;
        homeTeamColor == kTeamColors[homeAbbr]!['secondaryColor']!
            ? homeTeamColor = kTeamColors[homeAbbr]!['primaryColor']!
            : homeTeamColor = kTeamColors[homeAbbr]!['secondaryColor']!;
      }
    }

    return Stack(
      children: [
        allActions.isEmpty
            ? Center(
                heightFactor: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_basketball,
                      color: Colors.white38,
                      size: 38.0.r,
                    ),
                    SizedBox(height: 15.0.r),
                    Text(
                      'No Plays Available',
                      style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  if ((_inProgress && overTime.isNotEmpty) ||
                      (!_inProgress && firstQuarter.isNotEmpty))
                    Plays(
                      allActions: allActions,
                      gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
                      gameDate: widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'],
                      period: _inProgress ? 'Overtime' : '1st Quarter',
                      actions: _inProgress ? overTime : firstQuarter,
                      homeId: widget.homeId,
                      awayId: widget.awayId,
                      homeTeamColor: homeTeamColor,
                      awayTeamColor: awayTeamColor,
                    ),
                  if ((_inProgress && fourthQuarter.isNotEmpty) ||
                      (!_inProgress && secondQuarter.isNotEmpty))
                    Plays(
                      allActions: allActions,
                      gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
                      gameDate: widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'],
                      period: _inProgress ? '4th Quarter' : '2nd Quarter',
                      actions: _inProgress ? fourthQuarter : secondQuarter,
                      homeId: widget.homeId,
                      awayId: widget.awayId,
                      homeTeamColor: homeTeamColor,
                      awayTeamColor: awayTeamColor,
                    ),
                  if (thirdQuarter.isNotEmpty)
                    Plays(
                      allActions: allActions,
                      gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
                      gameDate: widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'],
                      period: '3rd Quarter',
                      actions: thirdQuarter,
                      homeId: widget.homeId,
                      awayId: widget.awayId,
                      homeTeamColor: homeTeamColor,
                      awayTeamColor: awayTeamColor,
                    ),
                  if ((_inProgress && secondQuarter.isNotEmpty) ||
                      (!_inProgress && fourthQuarter.isNotEmpty))
                    Plays(
                      allActions: allActions,
                      gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
                      gameDate: widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'],
                      period: _inProgress ? '2nd Quarter' : '4th Quarter',
                      actions: _inProgress ? secondQuarter : fourthQuarter,
                      homeId: widget.homeId,
                      awayId: widget.awayId,
                      homeTeamColor: homeTeamColor,
                      awayTeamColor: awayTeamColor,
                    ),
                  if ((_inProgress && firstQuarter.isNotEmpty) ||
                      (!_inProgress && overTime.isNotEmpty))
                    Plays(
                      allActions: allActions,
                      gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
                      gameDate: widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'],
                      period: _inProgress ? '1st Quarter' : 'Overtime',
                      actions: _inProgress ? firstQuarter : overTime,
                      homeId: widget.homeId,
                      awayId: widget.awayId,
                      homeTeamColor: homeTeamColor,
                      awayTeamColor: awayTeamColor,
                    ),
                  SliverPadding(padding: EdgeInsets.only(bottom: 100.0.r))
                ],
              ),
        Positioned(
          bottom: kBottomNavigationBarHeight - kToolbarHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(
                top: BorderSide(color: Colors.grey.shade800, width: 0.75),
                bottom: BorderSide(color: Colors.grey.shade800, width: 0.2),
              ),
            ),
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(
                          color: selectedTeam == homeTeamAbbr
                              ? kDarkPrimaryColors.contains(homeAbbr)
                                  ? (kTeamColors[homeAbbr]!['secondaryColor']!)
                                  : (kTeamColors[homeAbbr]!['primaryColor']!)
                              : selectedTeam == awayTeamAbbr
                                  ? kDarkPrimaryColors.contains(awayAbbr)
                                      ? (kTeamColors[awayAbbr]!['secondaryColor']!)
                                      : (kTeamColors[awayAbbr]!['primaryColor']!)
                                  : Colors.deepOrange),
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: EdgeInsets.symmetric(vertical: 6.0.r, horizontal: 8.0.r),
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: DropdownButton<int>(
                    padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                    borderRadius: BorderRadius.circular(10.0),
                    menuMaxHeight: 300.0.r,
                    dropdownColor: Colors.grey.shade900,
                    isExpanded: true,
                    underline: Container(),
                    value: selectedPlayer,
                    items: players.map<DropdownMenuItem<int>>((Map<String, dynamic> player) {
                      return DropdownMenuItem<int>(
                        value: player['id'],
                        child: Row(
                          children: [
                            if (player['name'] != 'ALL')
                              Flexible(
                                flex: 2,
                                child: AutoSizeText(
                                  player['number'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: kBebasNormal.copyWith(
                                      color: Colors.grey, fontSize: 12.0.r),
                                ),
                              ),
                            if (player['name'] != 'ALL') SizedBox(width: 8.0.r),
                            if (player['name'] != 'ALL')
                              Flexible(
                                flex: 3,
                                child: PlayerAvatar(
                                  radius: 12.0.r,
                                  backgroundColor: Colors.white12,
                                  playerImageUrl:
                                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['id'] ?? '0'}.png',
                                ),
                              ),
                            SizedBox(width: 8.0.r),
                            Flexible(
                              flex: 6,
                              child: AutoSizeText(
                                player['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: kBebasNormal.copyWith(fontSize: 15.0.r),
                              ),
                            ),
                            SizedBox(width: 8.0.r),
                            if (player['name'] != 'ALL')
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: 15.0.r, maxHeight: 15.0.r),
                                child: Image.asset(
                                  'images/NBA_Logos/${player['team']}.png',
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        selectedPlayer = value!;
                      });
                      filterActions(teamCodes[selectedTeam], selectedPlayer);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(
                          color: selectedTeam == homeTeamAbbr
                              ? kDarkPrimaryColors.contains(homeAbbr)
                                  ? (kTeamColors[homeAbbr]!['secondaryColor']!)
                                  : (kTeamColors[homeAbbr]!['primaryColor']!)
                              : selectedTeam == awayTeamAbbr
                                  ? kDarkPrimaryColors.contains(awayAbbr)
                                      ? (kTeamColors[awayAbbr]!['secondaryColor']!)
                                      : (kTeamColors[awayAbbr]!['primaryColor']!)
                                  : Colors.deepOrange),
                      borderRadius: BorderRadius.circular(25.0)),
                  margin: EdgeInsets.symmetric(vertical: 6.0.r, horizontal: 0.0.r),
                  child: Padding(
                    padding: EdgeInsets.all(3.0.r),
                    child: ToggleSwitch(
                      initialLabelIndex: initialLabelIndex,
                      totalSwitches: 3,
                      labels: [awayTeamAbbr, 'ALL', homeTeamAbbr],
                      animate: true,
                      animationDuration: 200,
                      curve: Curves.decelerate,
                      cornerRadius: 20.0,
                      customWidths: [
                        (MediaQuery.sizeOf(context).width - 28) / 7,
                        (MediaQuery.sizeOf(context).width - 28) / 7,
                        (MediaQuery.sizeOf(context).width - 28) / 7
                      ],
                      activeBgColor: [Colors.grey.shade800],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey.shade900,
                      customTextStyles: [
                        kBebasNormal.copyWith(fontSize: 14.0.r),
                        kBebasNormal.copyWith(fontSize: 14.0.r),
                        kBebasNormal.copyWith(fontSize: 14.0.r)
                      ],
                      onToggle: (index) {
                        setState(() {
                          selectedTeam = teams[index!];
                          initialLabelIndex = index;
                        });
                        filterActions(teamCodes[selectedTeam], selectedPlayer);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      clipBehavior: Clip.hardEdge,
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                      backgroundColor: const Color(0xFF111111),
                      isScrollControlled: isLandscape,
                      showDragHandle: true,
                      builder: (BuildContext context) {
                        final double videoHeight = MediaQuery.of(context).size.width * 9 / 16;
                        final double playlistHeight = 88.0.r;
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: videoHeight + playlistHeight,
                          child: PbpVideoPlayer(
                            pbpVideo: allActions
                                .where((e) =>
                                    e['videoId'] != null &&
                                    !e['description'].contains('SUB') &&
                                    !e['description'].contains('Timeout') &&
                                    !e['description'].contains('Period Start'))
                                .toList(),
                            gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
                            gameDate: widget.game['SUMMARY']['GameSummary'][0]
                                ['GAME_DATE_EST'],
                            homeAbbr: homeAbbr,
                            awayAbbr: awayAbbr,
                            index: 0,
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.video_collection),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Plays extends StatefulWidget {
  final List allActions;
  final String gameId;
  final String gameDate;
  final String period;
  final List actions;
  final String homeId;
  final String awayId;
  final Color homeTeamColor;
  final Color awayTeamColor;

  Plays({
    required this.allActions,
    required this.gameId,
    required this.gameDate,
    required this.period,
    required this.actions,
    required this.homeId,
    required this.awayId,
    required this.homeTeamColor,
    required this.awayTeamColor,
  });

  @override
  _PlaysState createState() => _PlaysState();
}

class _PlaysState extends State<Plays> {
  bool _isExpanded = true;

  String formatDuration(String inputStr) {
    // Regular expression to match 'PT' followed by minutes and seconds with tenths of a second
    RegExp regex = RegExp(r'PT(\d+)M(\d+)\.(\d+)S');
    Match? match = regex.firstMatch(inputStr);

    if (match != null) {
      int minutes = int.parse(match.group(1)!); // Convert minutes to int
      int seconds = int.parse(match.group(2)!); // Convert seconds to int
      String tenths = match.group(3)![0]; // Take only the first digit for tenths

      if (minutes == 0) {
        // Less than a minute left, return seconds and tenths
        return ":$seconds.$tenths";
      } else {
        // Regular minutes and seconds format, with leading zero for seconds if necessary
        return "$minutes:${seconds.toString().padLeft(2, '0')}";
      }
    }

    // Return original string if no match is found
    return inputStr;
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(20.0.r, 6.0.r, 14.0.r, 6.0.r),
              decoration: const BoxDecoration(
                color: Color(0xFF202020),
                border: Border(
                  top: BorderSide(
                    color: Colors.white30,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.white30,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.period,
                    style: kBebasNormal.copyWith(fontSize: 16.0.r),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: _isExpanded,
          child: SliverList(
            delegate: SliverChildListDelegate(
              [
                for (int i = 0; i < widget.actions.length; i++)
                  Container(
                    padding: EdgeInsets.all(8.0.r),
                    decoration: BoxDecoration(
                      color: widget.actions[i]['possession'] != 0 &&
                              widget.actions[i]['possession'].toString() == widget.homeId &&
                              (widget.actions[i]['clock'] != "PT12M00.00S" ||
                                  widget.actions[i]['description'] == 'Period Start')
                          ? widget.homeTeamColor == const Color(0xFF000000)
                              ? const Color(0xFF111111)
                              : widget.homeTeamColor.withOpacity(0.25)
                          : widget.actions[i]['possession'] != 0 &&
                                  widget.actions[i]['possession'].toString() ==
                                      widget.awayId &&
                                  (widget.actions[i]['clock'] != "PT12M00.00S" ||
                                      widget.actions[i]['description'] == 'Period Start')
                              ? widget.awayTeamColor.withOpacity(0.25)
                              : Colors.grey.shade900,
                      border: Border(
                        left: widget.actions[i]['clock'] != "PT12M00.00S" ||
                                widget.actions[i]['description'] == 'Period Start'
                            ? BorderSide(
                                color:
                                    widget.actions[i]['possession'].toString() == widget.homeId
                                        ? widget.homeTeamColor
                                        : widget.actions[i]['possession'].toString() ==
                                                widget.awayId
                                            ? widget.awayTeamColor
                                            : Colors.transparent,
                                width: 5.0)
                            : const BorderSide(),
                        bottom: (i < widget.actions.length - 1 &&
                                    widget.actions[i]['possession'] !=
                                        widget.actions[i + 1]['possession']) ||
                                widget.actions[i]['description'] == 'Period Start' ||
                                (i < widget.actions.length - 1 &&
                                    widget.actions[i + 1]['description'] == 'Period Start')
                            ? BorderSide(
                                color: i + 1 < widget.actions.length &&
                                        widget.actions[i + 1]['possession'].toString() ==
                                            widget.homeId
                                    ? widget.homeTeamColor
                                    : i + 1 < widget.actions.length &&
                                            widget.actions[i + 1]['possession'].toString() ==
                                                widget.awayId
                                        ? widget.awayTeamColor
                                        : Colors.transparent,
                                width: 1.0)
                            : BorderSide(color: Colors.grey.shade600, width: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Distributes items with space between them
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            formatDuration(widget.actions[i]['clock']),
                            textAlign: TextAlign.start,
                            style: kBebasNormal.copyWith(
                              color: Colors.grey.shade300,
                              fontSize: 15.0.r,
                            ),
                          ),
                        ),
                        if (widget.actions[i]['personId'] != 0)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 30.0.r, maxHeight: 30.0.r),
                            child: Image.asset(
                                'images/NBA_Logos/${kTeamIdToName.containsKey(widget.actions[i]['teamId'].toString()) ? widget.actions[i]['teamId'] : '0'}.png'),
                          ),
                        if (widget.actions[i]['personId'] != 0 &&
                                widget.actions[i]['isFieldGoal'] == 1 ||
                            (widget.actions[i]['description'] is String &&
                                widget.actions[i]['description'].contains('Free Throw')))
                          Expanded(
                              flex: 2,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${widget.actions[i]['scoreAway']}',
                                      style: (widget.actions[i]['description'] is String &&
                                              widget.actions[i]['description'].contains('PTS'))
                                          ? kBebasBold.copyWith(
                                              fontSize: 16.0.r,
                                              color:
                                                  widget.actions[i]['possession'].toString() ==
                                                          widget.awayId
                                                      ? Colors.white
                                                      : Colors.grey.shade500)
                                          : kBebasNormal.copyWith(
                                              fontSize: 16.0.r, color: Colors.grey.shade400),
                                    ),
                                    TextSpan(
                                      text: '  -  ',
                                      style: (widget.actions[i]['description'] is String &&
                                              widget.actions[i]['description'].contains('PTS'))
                                          ? kBebasBold.copyWith(
                                              fontSize: 16.0.r, color: Colors.grey.shade400)
                                          : kBebasNormal.copyWith(
                                              fontSize: 16.0.r, color: Colors.grey.shade400),
                                    ),
                                    TextSpan(
                                      text: '${widget.actions[i]['scoreHome']}',
                                      style: (widget.actions[i]['description'] is String &&
                                              widget.actions[i]['description'].contains('PTS'))
                                          ? kBebasBold.copyWith(
                                              fontSize: 16.0.r,
                                              color:
                                                  widget.actions[i]['possession'].toString() ==
                                                          widget.homeId
                                                      ? Colors.white
                                                      : Colors.grey.shade500)
                                          : kBebasNormal.copyWith(
                                              fontSize: 16.0.r, color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              )),
                        if (widget.actions[i]['personId'] == 0 ||
                            widget.actions[i]['isFieldGoal'] != 1 &&
                                !(widget.actions[i]['description'] is String &&
                                    widget.actions[i]['description'].contains('Free Throw')))
                          const Spacer(flex: 2),
                        Expanded(
                          flex: 5,
                          child: GestureDetector(
                            onTap: () {
                              if (widget.actions[i]['videoId'] != null &&
                                  !(widget.actions[i]['description'] is String &&
                                      widget.actions[i]['description'].contains('SUB')) &&
                                  !(widget.actions[i]['description'] is String &&
                                      widget.actions[i]['description'].contains('Timeout')) &&
                                  !(widget.actions[i]['description'] is String &&
                                      widget.actions[i]['description']
                                          .contains('Period Start'))) {
                                int index = widget.allActions
                                    .where((e) =>
                                        e['videoId'] != null &&
                                        !(e['description'] is String &&
                                            e['description'].contains('SUB')) &&
                                        !(e['description'] is String &&
                                            e['description'].contains('Timeout')) &&
                                        !(e['description'] is String &&
                                            e['description'].contains('Period Start')))
                                    .toList()
                                    .indexWhere(
                                        (e) => e['videoId'] == widget.actions[i]['videoId']);
                                showModalBottomSheet(
                                  context: context,
                                  clipBehavior: Clip.hardEdge,
                                  constraints: BoxConstraints(
                                      minWidth: MediaQuery.of(context).size.width),
                                  backgroundColor: const Color(0xFF111111),
                                  isScrollControlled: MediaQuery.of(context).orientation ==
                                      Orientation.landscape,
                                  showDragHandle: true,
                                  builder: (BuildContext context) {
                                    final double videoHeight =
                                        MediaQuery.of(context).size.width * 9 / 16;
                                    final double playlistHeight = 88.0.r;
                                    return SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        height: videoHeight + playlistHeight,
                                        child: PbpVideoPlayer(
                                          pbpVideo: widget.allActions
                                              .where((e) =>
                                                  e['videoId'] != null &&
                                                  !(e['description'] is String &&
                                                      e['description'].contains('SUB')) &&
                                                  !(e['description'] is String &&
                                                      e['description'].contains('Timeout')) &&
                                                  !(e['description'] is String &&
                                                      e['description']
                                                          .contains('Period Start')))
                                              .toList(),
                                          gameId: widget.gameId,
                                          gameDate: widget.gameDate,
                                          homeAbbr: kTeamIdToName[widget.homeId][1],
                                          awayAbbr: kTeamIdToName[widget.awayId][1],
                                          index: index,
                                        ));
                                  },
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Ensures text stays left aligned and arrow on the right
                              children: [
                                if ((widget.actions[i]['description'] is String &&
                                    widget.actions[i]['description'].contains('Timeout')))
                                  Icon(
                                    Icons.timer,
                                    size: 16.0.r,
                                  ),
                                if ((widget.actions[i]['description'] is String &&
                                    widget.actions[i]['description'].contains('Timeout')))
                                  SizedBox(width: 5.0.r),
                                Expanded(
                                  child: Text(
                                    (widget.actions[i]['description'] is String &&
                                            widget.actions[i]['description'].contains('TEAM'))
                                        ? '${widget.actions[i]['description'].toString()} (${kTeamIdToName[widget.actions[i]['teamId'].toString()]?[1] ?? 'INT\'L'})'
                                        : widget.actions[i]['description'].toString(),
                                    textAlign: TextAlign.left,
                                    style: (widget.actions[i]['description'] is String &&
                                            widget.actions[i]['description'].contains('PTS'))
                                        ? kBebasBold.copyWith(
                                            fontSize: 14.0.r, color: Colors.white)
                                        : (widget.actions[i]['description'] is String &&
                                                widget.actions[i]['description']
                                                    .contains('SUB'))
                                            ? kBebasBold.copyWith(
                                                fontSize: 14.0.r,
                                                color: Colors.grey.shade300,
                                                fontStyle: FontStyle.italic)
                                            : (widget.actions[i]['description'] is String &&
                                                    widget.actions[i]['description']
                                                        .contains('Timeout'))
                                                ? kBebasNormal.copyWith(
                                                    fontSize: 15.0.r,
                                                    color: Colors.grey.shade300,
                                                    fontStyle: FontStyle.italic)
                                                : kBebasNormal.copyWith(
                                                    fontSize: 14.0.r,
                                                    color: Colors.grey.shade300),
                                    overflow: TextOverflow.visible, // Ensures text wraps
                                  ),
                                ),
                                if ((widget.actions[i]['description'] is String &&
                                    widget.actions[i]['description']
                                        .contains('SUB in'))) // Check for 'SUB'
                                  Icon(
                                    Icons.arrow_upward, // Up arrow icon
                                    color: Colors.green, // Green color for the arrow
                                    size: 16.0.r, // Adjust the size if needed
                                  ),
                                if ((widget.actions[i]['description'] is String &&
                                    widget.actions[i]['description']
                                        .contains('SUB out'))) // Check for 'SUB'
                                  Icon(
                                    Icons.arrow_downward, // Up arrow icon
                                    color: Colors.red, // Green color for the arrow
                                    size: 16.0.r, // Adjust the size if needed
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.actions[i]['personId'] != 0) SizedBox(width: 8.0.r),
                        if (widget.actions[i]['personId'] != 0)
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerHome(
                                      playerId:
                                          (widget.actions[i]['personId'] ?? 0).toString(),
                                    ),
                                  ),
                                );
                              },
                              child: PlayerAvatar(
                                radius: 16.0.r,
                                backgroundColor: Colors.transparent,
                                playerImageUrl:
                                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.actions[i]['personId']}.png',
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}
