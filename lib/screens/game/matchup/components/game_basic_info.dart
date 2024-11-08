import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/constants.dart';

class GameBasicInfo extends StatelessWidget {
  const GameBasicInfo({
    super.key,
    required this.game,
    required this.isUpcoming,
  });

  final Map<String, dynamic> game;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    List<String> officials = [];
    String arena = '';

    if (!isUpcoming || (isUpcoming && game.containsKey('BOXSCORE'))) {
      for (Map<String, dynamic> official in game['SUMMARY']['Officials']) {
        officials.add('${official['FIRST_NAME']} ${official['LAST_NAME']}');
      }
      if (game['BOXSCORE'].containsKey('arena')) {
        arena =
            '${game['BOXSCORE']['arena']['arenaName']} - ${game['BOXSCORE']['arena']['arenaCity']}, ${game['BOXSCORE']['arena']['arenaState']}';
      } else {
        if (kArenas.containsKey(game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? '')) {
          arena =
              '${game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? ''} - ${kArenas[game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? '']}';
        } else {
          arena = game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? '';
        }
      }
    } else {
      officials.add('TBA');
      if (kArenas.containsKey(game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? '')) {
        arena =
            '${game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? ''} - ${kArenas[game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? '']}';
      } else {
        arena = game['SUMMARY']?['GameSummary']?[0]?['ARENA_NAME'] ?? '';
      }
    }

    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST']);

    // Format the DateTime object into the desired string format
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(parsedDate).toUpperCase();

    Map<String, String> seasonTypes = {
      '1': 'Pre-Season',
      '2': 'Regular Season',
      '3': 'All-Star Game',
      '4': 'Playoffs',
      '5': 'Play-In',
      '6': 'NBA Cup Final'
    };

    String broadcast =
        game['SUMMARY']['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LEAGUE PASS';
    if (game['SUMMARY']['GameSummary'][0]['HOME_TV_BROADCASTER_ABBREVIATION'] != null) {
      broadcast +=
          ', ${game['SUMMARY']['GameSummary'][0]['HOME_TV_BROADCASTER_ABBREVIATION']}';
    }
    if (game['SUMMARY']['GameSummary'][0]['AWAY_TV_BROADCASTER_ABBREVIATION'] != null) {
      broadcast +=
          ', ${game['SUMMARY']['GameSummary'][0]['AWAY_TV_BROADCASTER_ABBREVIATION']}';
    }

    String homeId = game['SUMMARY']['GameSummary'][0]['HOME_TEAM_ID'].toString();
    var linescore = game['SUMMARY']['LineScore'];

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'].toString() == homeId ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[0]['TEAM_ID'].toString() == homeId ? linescore[1] : linescore[0];

    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: EdgeInsets.all(15.0.r),
        child: Column(
          children: [
            GameBasicInfoRow(
              icon: Icons.calendar_month,
              data: [
                seasonTypes[game['SUMMARY']['GameSummary'][0]['GAME_ID'].substring(2, 3)] ??
                    '-'
              ],
            ),
            SizedBox(height: 10.0.r),
            GameBasicInfoRow(
              icon: Icons.sports_basketball,
              data: [
                '${awayLinescore['TEAM_CITY_NAME']} ${awayLinescore['TEAM_NICKNAME'] ?? awayLinescore['TEAM_NAME']} @ ${homeLinescore['TEAM_CITY_NAME']} ${homeLinescore['TEAM_NICKNAME'] ?? homeLinescore['TEAM_NAME']}'
              ],
            ),
            SizedBox(height: 10.0.r),
            if (int.parse(game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'].substring(0, 4)) <
                2021)
              // Date
              GameBasicInfoRow(
                icon: Icons.calendar_month,
                data: [formattedDate],
              ),
            if (int.parse(game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'].substring(0, 4)) >
                2021)
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
