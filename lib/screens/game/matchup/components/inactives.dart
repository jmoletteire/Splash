import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

class Inactives extends StatefulWidget {
  final List<dynamic> inactivePlayers;
  final String homeId;
  final String awayId;
  const Inactives(
      {super.key, required this.inactivePlayers, required this.homeId, required this.awayId});

  @override
  State<Inactives> createState() => _InactivesState();
}

class _InactivesState extends State<Inactives> {
  @override
  Widget build(BuildContext context) {
    List<String> homeInactive = [];
    List<String> awayInactive = [];

    for (var player in widget.inactivePlayers) {
      if (player['TEAM_ID'].toString() == widget.homeId) {
        homeInactive.add('${player['FIRST_NAME']} ${player['LAST_NAME']}');
      } else {
        awayInactive.add('${player['FIRST_NAME']} ${player['LAST_NAME']}');
      }
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                ),
              ),
              child: Text(
                'INACTIVES',
                style: kBebasBold.copyWith(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              children: [
                Text('${kTeamNames[widget.awayId][1]}:',
                    style: kBebasBold.copyWith(fontSize: 16.0)),
                const SizedBox(width: 5.0),
                ...List.generate(awayInactive.length, (index) {
                  return Text(
                    index != awayInactive.length - 1
                        ? '${awayInactive[index]}, '
                        : awayInactive[index],
                    style: kBebasNormal.copyWith(fontSize: 16.0),
                  );
                }),
                if (awayInactive.isEmpty)
                  Text('None', style: kBebasNormal.copyWith(fontSize: 16.0))
              ],
            ),
            Wrap(
              children: [
                Text('${kTeamNames[widget.homeId][1]}:',
                    style: kBebasBold.copyWith(fontSize: 16.0)),
                const SizedBox(width: 5.0),
                ...List.generate(homeInactive.length, (index) {
                  return Text(
                    index != homeInactive.length - 1
                        ? '${homeInactive[index]}, '
                        : homeInactive[index],
                    style: kBebasNormal.copyWith(fontSize: 16.0),
                  );
                }),
                if (homeInactive.isEmpty)
                  Text('None', style: kBebasNormal.copyWith(fontSize: 16.0))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
