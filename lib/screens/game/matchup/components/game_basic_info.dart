import 'package:flutter/material.dart';
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
    if (!isUpcoming) {
      for (Map<String, dynamic> official in game['SUMMARY']['Officials']) {
        officials.add('${official['FIRST_NAME']} ${official['LAST_NAME']}');
      }
    } else {
      officials.add('TBA');
    }

    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST']);

    // Format the DateTime object into the desired string format
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(parsedDate).toUpperCase();

    return Card(
      margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Date
            GameBasicInfoRow(
              icon: Icons.calendar_month,
              data: [formattedDate],
            ),
            const SizedBox(height: 10.0),
            // Broadcast
            GameBasicInfoRow(
              icon: Icons.tv_sharp,
              data: [
                game['SUMMARY']['GameSummary'][0]['NATL_TV_BROADCASTER_ABBREVIATION'] ??
                    'LEAGUE PASS'
              ],
            ),
            const SizedBox(height: 10.0),
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
    required this.icon,
    required this.data,
  });

  final IconData icon;
  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        children: [
          Icon(
            icon,
            size: 22.0,
          ),
          const SizedBox(width: 15.0),
          ...List.generate(data.length, (index) {
            return Text(
              index != data.length - 1 ? '${data[index]}, ' : data[index],
              style: kBebasNormal.copyWith(fontSize: 16.0),
            );
          }),
        ],
      ),
    );
  }
}
