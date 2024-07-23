import 'package:flutter/material.dart';

import '../../../utilities/constants.dart';

class GameBasicInfo extends StatelessWidget {
  const GameBasicInfo({
    super.key,
    required this.game,
  });

  final Map<String, dynamic> game;

  @override
  Widget build(BuildContext context) {
    List<String> officials = [];
    for (Map<String, dynamic> official in game['SUMMARY']['Officials']) {
      officials.add('${official['FIRST_NAME']} ${official['LAST_NAME']}');
    }

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
              data: [game['SUMMARY']['GameInfo'][0]['GAME_DATE']],
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
    return Row(
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
    );
  }
}
