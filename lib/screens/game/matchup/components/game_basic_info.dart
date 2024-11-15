import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/constants.dart';

class GameBasicInfo extends StatefulWidget {
  const GameBasicInfo({
    super.key,
    required this.game,
    required this.isUpcoming,
    required this.homeLineScore,
    required this.awayLineScore,
  });

  final Map<String, dynamic> game;
  final bool isUpcoming;
  final Map<String, dynamic> homeLineScore;
  final Map<String, dynamic> awayLineScore;

  @override
  State<GameBasicInfo> createState() => _GameBasicInfoState();
}

class _GameBasicInfoState extends State<GameBasicInfo> {
  late Map<String, dynamic> summary;
  late int year;
  late String formattedDate;
  late String seasonType;
  late String awayTeamName;
  late String homeTeamName;
  String broadcast = '';
  String arena = '';
  List<String> officials = [];

  void setSeasonType() {
    Map<String, String> seasonTypes = {
      '1': 'Pre-Season',
      '2': 'Regular Season',
      '3': 'All-Star Game',
      '4': 'Playoffs',
      '5': 'Play-In',
      '6': 'NBA Cup Final'
    };

    seasonType = seasonTypes[summary['GAME_ID'].substring(2, 3)] ?? '-';

    if (summary.containsKey('NBA_CUP')) {
      seasonType = '${summary['NBA_CUP']}  (Regular Season)';
    }
  }

  void setArenaAndOfficials() {
    String arenaName = summary['ARENA_NAME'] ?? '';

    if (!widget.isUpcoming || (widget.isUpcoming && widget.game.containsKey('BOXSCORE'))) {
      for (Map<String, dynamic> official in (widget.game['SUMMARY']?['Officials'] ?? [])) {
        officials.add('${official['FIRST_NAME']} ${official['LAST_NAME']}');
      }
      if (widget.game['BOXSCORE'].containsKey('arena')) {
        arena =
            '${widget.game['BOXSCORE']?['arena']?['arenaName'] ?? ''} - ${widget.game['BOXSCORE']?['arena']?['arenaCity'] ?? ''}, ${widget.game['BOXSCORE']?['arena']?['arenaState'] ?? ''}';
      } else {
        if (kArenas.containsKey(arenaName)) {
          arena = '$arenaName - ${kArenas[arenaName]}';
        } else {
          arena = arenaName;
        }
      }
    } else {
      officials.add('TBA');
      if (kArenas.containsKey(arenaName)) {
        arena = '$arenaName - ${kArenas[arenaName]}';
      } else {
        arena = arenaName;
      }
    }
  }

  void setBroadcast() {
    broadcast = summary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LEAGUE PASS';
    if (summary['HOME_TV_BROADCASTER_ABBREVIATION'] != null) {
      broadcast += ', ${summary['HOME_TV_BROADCASTER_ABBREVIATION']}';
    }
    if (summary['AWAY_TV_BROADCASTER_ABBREVIATION'] != null) {
      broadcast += ', ${summary['AWAY_TV_BROADCASTER_ABBREVIATION']}';
    }
  }

  @override
  void initState() {
    super.initState();

    summary = widget.game['SUMMARY']?['GameSummary']?[0] ?? {};

    year = int.parse((summary['GAME_DATE_EST'] ?? '1900-01-01').substring(0, 4));

    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(summary['GAME_DATE_EST'] ?? '1900-01-01');

    // Format the DateTime object into the desired string format
    formattedDate = DateFormat('EEEE, MMMM d, y').format(parsedDate).toUpperCase();

    awayTeamName =
        '${widget.awayLineScore['TEAM_CITY_NAME'] ?? ''} ${widget.awayLineScore['TEAM_NICKNAME'] ?? widget.awayLineScore['TEAM_NAME'] ?? ''}';
    homeTeamName =
        '${widget.homeLineScore['TEAM_CITY_NAME'] ?? ''} ${widget.homeLineScore['TEAM_NICKNAME'] ?? widget.homeLineScore['TEAM_NAME'] ?? ''}';

    setSeasonType();
    setArenaAndOfficials();
    setBroadcast();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: EdgeInsets.all(15.0.r),
        child: Column(
          children: [
            GameBasicInfoRow(
              icon: Icons.calendar_month,
              data: [seasonType],
            ),
            SizedBox(height: 10.0.r),
            GameBasicInfoRow(
              icon: Icons.sports_basketball,
              data: ['$awayTeamName @ $homeTeamName'],
            ),
            SizedBox(height: 10.0.r),

            // ARENA DATA ONLY AVAILABLE SINCE 2021
            if (year < 2021)
              // Date
              GameBasicInfoRow(
                icon: Icons.calendar_month,
                data: [formattedDate],
              ),
            if (year >= 2021)
              // Date
              GameBasicInfoRow(
                icon: Icons.stadium,
                data: [arena],
              ),

            SizedBox(height: 10.0.r),
            // Broadcast
            GameBasicInfoRow(
              icon: Icons.tv_sharp,
              data: [broadcast],
            ),
            SizedBox(height: 10.0.r),
            // Officials
            GameBasicInfoRow(
              icon: Icons.sports,
              data: officials,
            ),
          ],
        ),
      ),
    );
  }
}

class GameBasicInfoRow extends StatelessWidget {
  const GameBasicInfoRow({
    super.key,
    this.icon,
    required this.data,
  });

  final IconData? icon;
  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        children: [
          if (icon != null)
            Icon(
              icon!,
              size: 20.0.r,
            ),
          SizedBox(width: 15.0.r),
          ...List.generate(data.length, (index) {
            return Text(
              index != data.length - 1 ? '${data[index]}, ' : data[index],
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            );
          }),
        ],
      ),
    );
  }
}
