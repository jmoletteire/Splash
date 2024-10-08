import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/utilities/constants.dart';

import '../player/player_home.dart';

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
  late List firstQuarter;
  late List secondQuarter;
  late List thirdQuarter;
  late List fourthQuarter;
  late List overTime;

  @override
  void initState() {
    super.initState();
    _inProgress = widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2;
    if (_inProgress) {
      firstQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 1)
          .toList()
          .reversed
          .toList();
      secondQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 2)
          .toList()
          .reversed
          .toList();
      thirdQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 3)
          .toList()
          .reversed
          .toList();
      fourthQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 4)
          .toList()
          .reversed
          .toList();
      overTime = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] > 4)
          .toList()
          .reversed
          .toList();
    } else {
      firstQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 1)
          .toList();
      secondQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 2)
          .toList();
      thirdQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 3)
          .toList();
      fourthQuarter = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 4)
          .toList();
      overTime = widget.game['PBP']
          .where((e) => e is Map<String, dynamic> && e['period'] != null && e['period'] > 4)
          .toList();
    }
  }

  @override
  void didUpdateWidget(covariant PlayByPlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the game data has changed
    if (oldWidget.game != widget.game) {
      setState(() {
        // Update the local state with the new game data
        if (_inProgress) {
          firstQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 1)
              .toList()
              .reversed
              .toList();
          secondQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 2)
              .toList()
              .reversed
              .toList();
          thirdQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 3)
              .toList()
              .reversed
              .toList();
          fourthQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 4)
              .toList()
              .reversed
              .toList();
          overTime = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] > 4)
              .toList()
              .reversed
              .toList();
        } else {
          firstQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 1)
              .toList();
          secondQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 2)
              .toList();
          thirdQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 3)
              .toList();
          fourthQuarter = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] == 4)
              .toList();
          overTime = widget.game['PBP']
              .where(
                  (e) => e is Map<String, dynamic> && e['period'] != null && e['period'] > 4)
              .toList();
        }
      });
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

    return CustomScrollView(
      slivers: [
        if ((_inProgress && overTime.isNotEmpty) || (!_inProgress && firstQuarter.isNotEmpty))
          Plays(
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
            period: _inProgress ? '4th Quarter' : '2nd Quarter',
            actions: _inProgress ? fourthQuarter : secondQuarter,
            homeId: widget.homeId,
            awayId: widget.awayId,
            homeTeamColor: homeTeamColor,
            awayTeamColor: awayTeamColor,
          ),
        if (thirdQuarter.isNotEmpty)
          Plays(
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
            period: _inProgress ? '2nd Quarter' : '4th Quarter',
            actions: _inProgress ? secondQuarter : fourthQuarter,
            homeId: widget.homeId,
            awayId: widget.awayId,
            homeTeamColor: homeTeamColor,
            awayTeamColor: awayTeamColor,
          ),
        if ((_inProgress && firstQuarter.isNotEmpty) || (!_inProgress && overTime.isNotEmpty))
          Plays(
            period: _inProgress ? '1st Quarter' : 'Overtime',
            actions: _inProgress ? firstQuarter : overTime,
            homeId: widget.homeId,
            awayId: widget.awayId,
            homeTeamColor: homeTeamColor,
            awayTeamColor: awayTeamColor,
          )
      ],
    );
  }
}

class Plays extends StatefulWidget {
  final String period;
  final List actions;
  final String homeId;
  final String awayId;
  final Color homeTeamColor;
  final Color awayTeamColor;

  Plays({
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
                    style: kBebasNormal.copyWith(fontSize: 16.0),
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
              delegate: SliverChildListDelegate([
            for (int i = 0; i < widget.actions.length; i++)
              Container(
                padding: EdgeInsets.all(8.0.r),
                decoration: BoxDecoration(
                  color: widget.actions[i]['possession'] != 0 &&
                          widget.actions[i]['possession'].toString() == widget.homeId &&
                          widget.actions[i]['clock'] != "PT12M00.00S"
                      ? widget.homeTeamColor.withOpacity(0.25)
                      : widget.actions[i]['possession'] != 0 &&
                              widget.actions[i]['possession'].toString() == widget.awayId &&
                              widget.actions[i]['clock'] != "PT12M00.00S"
                          ? widget.awayTeamColor.withOpacity(0.25)
                          : Colors.grey.shade900,
                  border: Border(
                    left: widget.actions[i]['clock'] != "PT12M00.00S"
                        ? BorderSide(
                            color: widget.actions[i]['possession'].toString() == widget.homeId
                                ? widget.homeTeamColor
                                : widget.actions[i]['possession'].toString() == widget.awayId
                                    ? widget.awayTeamColor
                                    : Colors.transparent,
                            width: 5.0)
                        : const BorderSide(),
                    bottom: (i < widget.actions.length - 1 &&
                                widget.actions[i]['possession'] !=
                                    widget.actions[i + 1]['possession']) ||
                            widget.actions[i]['description'] == 'Period Start'
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
                        widget.actions[i]['description'].contains('Free Throw'))
                      Expanded(
                          flex: 2,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.actions[i]['scoreAway']}',
                                  style: widget.actions[i]['description'].contains('PTS')
                                      ? kBebasBold.copyWith(
                                          fontSize: 16.0.r,
                                          color: widget.actions[i]['possession'].toString() ==
                                                  widget.awayId
                                              ? Colors.white
                                              : Colors.grey.shade500)
                                      : kBebasNormal.copyWith(
                                          fontSize: 16.0.r, color: Colors.grey.shade400),
                                ),
                                TextSpan(
                                  text: '  -  ',
                                  style: widget.actions[i]['description'].contains('PTS')
                                      ? kBebasBold.copyWith(
                                          fontSize: 16.0.r, color: Colors.grey.shade400)
                                      : kBebasNormal.copyWith(
                                          fontSize: 16.0.r, color: Colors.grey.shade400),
                                ),
                                TextSpan(
                                  text: '${widget.actions[i]['scoreHome']}',
                                  style: widget.actions[i]['description'].contains('PTS')
                                      ? kBebasBold.copyWith(
                                          fontSize: 16.0.r,
                                          color: widget.actions[i]['possession'].toString() ==
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
                            !widget.actions[i]['description'].contains('Free Throw'))
                      const Spacer(flex: 2),
                    Expanded(
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Ensures text stays left aligned and arrow on the right
                        children: [
                          if (widget.actions[i]['description'].contains('Timeout'))
                            Icon(
                              Icons.timer,
                              size: 16.0.r,
                            ),
                          if (widget.actions[i]['description'].contains('Timeout'))
                            SizedBox(width: 5.0.r),
                          Expanded(
                            child: Text(
                              widget.actions[i]['description'].contains('TEAM')
                                  ? '${widget.actions[i]['description']} (${kTeamIdToName[widget.actions[i]['teamId'].toString()]?[1] ?? 'INT\'L'})'
                                  : widget.actions[i]['description'],
                              textAlign: TextAlign.left,
                              style: widget.actions[i]['description'].contains('PTS')
                                  ? kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.white)
                                  : widget.actions[i]['description'].contains('SUB')
                                      ? kBebasBold.copyWith(
                                          fontSize: 14.0.r,
                                          color: Colors.grey.shade300,
                                          fontStyle: FontStyle.italic)
                                      : widget.actions[i]['description'].contains('Timeout')
                                          ? kBebasNormal.copyWith(
                                              fontSize: 15.0.r,
                                              color: Colors.grey.shade300,
                                              fontStyle: FontStyle.italic)
                                          : kBebasNormal.copyWith(
                                              fontSize: 14.0.r, color: Colors.grey.shade300),
                              overflow: TextOverflow.visible, // Ensures text wraps
                            ),
                          ),
                          if (widget.actions[i]['description']
                              .contains('SUB in')) // Check for 'SUB'
                            Icon(
                              Icons.arrow_upward, // Up arrow icon
                              color: Colors.green, // Green color for the arrow
                              size: 16.0.r, // Adjust the size if needed
                            ),
                          if (widget.actions[i]['description']
                              .contains('SUB out')) // Check for 'SUB'
                            Icon(
                              Icons.arrow_downward, // Up arrow icon
                              color: Colors.red, // Green color for the arrow
                              size: 16.0.r, // Adjust the size if needed
                            ),
                        ],
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
                                  playerId: (widget.actions[i]['personId'] ?? 0).toString(),
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
          ])),
        )
      ],
    );
  }
}
