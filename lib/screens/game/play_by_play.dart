import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late List actions;

  @override
  void initState() {
    super.initState();
    actions = widget.game['PBP'];
  }

  @override
  void didUpdateWidget(covariant PlayByPlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the game data has changed
    if (oldWidget.game != widget.game) {
      setState(() {
        // Update the local state with the new game data
        actions = widget.game['PBP'] ?? [];
      });
    }
  }

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
    String homeAbbr = kTeamIdToName[widget.homeId][1];
    Color homeTeamColor = kDarkPrimaryColors.contains(homeAbbr)
        ? (kTeamColors[homeAbbr]!['secondaryColor']!)
        : (kTeamColors[homeAbbr]!['primaryColor']!);

    String awayAbbr = kTeamIdToName[widget.awayId][1];
    Color awayTeamColor = kDarkPrimaryColors.contains(awayAbbr)
        ? (kTeamColors[awayAbbr]!['secondaryColor']!)
        : (kTeamColors[awayAbbr]!['primaryColor']!);

    return CustomScrollView(slivers: [
      SliverList(
          delegate: SliverChildListDelegate([
        for (int i = 0; i < actions.length; i++)
          /*
          LayoutBuilder(builder: (context, constraints) {
            if (action['possession'].toString() == widget.homeId) {
              return Container(
                padding: EdgeInsets.all(8.0.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade600, width: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Distributes items with space between them
                  children: [
                    const Spacer(flex: 2),
                    // Clock in the center
                    Expanded(
                      flex: 1,
                      child: Text(
                        formatDuration(action['clock']),
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                          color: Colors.grey.shade300,
                          fontSize: 15.0.r,
                        ),
                      ),
                    ),
                    // Avatar aligned right
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          if (action['personId'] != 0)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 30.0.r),
                              child: Image.asset('images/NBA_Logos/${action['teamId']}.png'),
                            ),
                          if (action['personId'] != 0)
                            Expanded(
                              flex: 1,
                              child: PlayerAvatar(
                                radius: 16.0.r,
                                backgroundColor: Colors.grey.shade900,
                                playerImageUrl:
                                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${action['personId']}.png',
                              ),
                            ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              action['description'],
                              textAlign: TextAlign.right,
                              style: kBebasNormal.copyWith(
                                  fontSize: 14.0.r, color: Colors.grey.shade300),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                padding: EdgeInsets.all(8.0.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade600, width: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Distributes items with space between them
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              action['description'],
                              textAlign: TextAlign.left,
                              style: kBebasNormal.copyWith(
                                  fontSize: 14.0.r, color: Colors.grey.shade300),
                            ),
                          ),
                          if (action['personId'] != 0)
                            Expanded(
                              flex: 1,
                              child: PlayerAvatar(
                                radius: 16.0.r,
                                backgroundColor: Colors.grey.shade900,
                                playerImageUrl:
                                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${action['personId']}.png',
                              ),
                            ),
                          if (action['personId'] != 0)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 30.0.r),
                              child: Image.asset('images/NBA_Logos/${action['teamId']}.png'),
                            )
                        ],
                      ),
                    ),
                    // Clock in the center
                    Expanded(
                      flex: 1,
                      child: Text(
                        formatDuration(action['clock']),
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                          color: Colors.grey.shade300,
                          fontSize: 15.0.r,
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              );
            }
          }),

           */
          Container(
            padding: EdgeInsets.all(8.0.r),
            decoration: BoxDecoration(
              color: actions[i]['possession'].toString() == widget.homeId
                  ? homeTeamColor.withOpacity(0.25)
                  : actions[i]['possession'].toString() == widget.awayId
                      ? awayTeamColor.withOpacity(0.25)
                      : Colors.grey.shade900,
              border: Border(
                left: i > 0 //&& actions[i]['possession'] != actions[i - 1]['possession']
                    ? BorderSide(
                        color: actions[i]['possession'].toString() == widget.homeId
                            ? homeTeamColor
                            : awayTeamColor,
                        width: 5.0)
                    : const BorderSide(),
                bottom: i < actions.length - 1 &&
                        actions[i]['possession'] != actions[i + 1]['possession']
                    ? BorderSide(
                        color: actions[i + 1]['possession'].toString() == widget.homeId
                            ? homeTeamColor
                            : awayTeamColor,
                        width: 1.0)
                    : BorderSide(color: Colors.grey.shade600, width: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distributes items with space between them
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    formatDuration(actions[i]['clock']),
                    textAlign: TextAlign.start,
                    style: kBebasNormal.copyWith(
                      color: Colors.grey.shade300,
                      fontSize: 15.0.r,
                    ),
                  ),
                ),
                if (actions[i]['personId'] != 0)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 30.0.r, maxHeight: 30.0.r),
                    child: Image.asset(
                        'images/NBA_Logos/${kTeamIdToName.containsKey(actions[i]['teamId'].toString()) ? actions[i]['teamId'] : '0'}.png'),
                  ),
                if (actions[i]['personId'] != 0 && actions[i]['isFieldGoal'] == 1 ||
                    actions[i]['description'].contains('Free Throw'))
                  Expanded(
                      flex: 2,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${actions[i]['scoreAway']}',
                              style: actions[i]['description'].contains('PTS')
                                  ? kBebasBold.copyWith(
                                      fontSize: 16.0.r,
                                      color:
                                          actions[i]['possession'].toString() == widget.awayId
                                              ? Colors.white
                                              : Colors.grey.shade500)
                                  : kBebasNormal.copyWith(
                                      fontSize: 16.0.r, color: Colors.grey.shade400),
                            ),
                            TextSpan(
                              text: '  -  ',
                              style: actions[i]['description'].contains('PTS')
                                  ? kBebasBold.copyWith(
                                      fontSize: 16.0.r, color: Colors.grey.shade400)
                                  : kBebasNormal.copyWith(
                                      fontSize: 16.0.r, color: Colors.grey.shade400),
                            ),
                            TextSpan(
                              text: '${actions[i]['scoreHome']}',
                              style: actions[i]['description'].contains('PTS')
                                  ? kBebasBold.copyWith(
                                      fontSize: 16.0.r,
                                      color:
                                          actions[i]['possession'].toString() == widget.homeId
                                              ? Colors.white
                                              : Colors.grey.shade500)
                                  : kBebasNormal.copyWith(
                                      fontSize: 16.0.r, color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      )),
                if (actions[i]['personId'] == 0 ||
                    actions[i]['isFieldGoal'] != 1 &&
                        !actions[i]['description'].contains('Free Throw'))
                  const Spacer(flex: 2),
                Expanded(
                  flex: 5,
                  child: Text(
                    actions[i]['description'],
                    textAlign: TextAlign.left,
                    style: actions[i]['description'].contains('PTS')
                        ? kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.white)
                        : kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300),
                  ),
                ),
                if (actions[i]['personId'] != 0) SizedBox(width: 8.0.r),
                if (actions[i]['personId'] != 0)
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerHome(
                              playerId: (actions[i]['personId'] ?? 0).toString(),
                            ),
                          ),
                        );
                      },
                      child: PlayerAvatar(
                        radius: 16.0.r,
                        backgroundColor: Colors.grey.shade800,
                        playerImageUrl:
                            'https://cdn.nba.com/headshots/nba/latest/1040x760/${actions[i]['personId']}.png',
                      ),
                    ),
                  ),
              ],
            ),
          )
      ]))
    ]);
  }
}
