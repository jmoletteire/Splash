import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utilities/constants.dart';

class PlayerAwards extends StatefulWidget {
  final Map<String, dynamic> playerAwards;
  const PlayerAwards({super.key, required this.playerAwards});

  @override
  State<PlayerAwards> createState() => _PlayerAwardsState();
}

class _PlayerAwardsState extends State<PlayerAwards> {
  List<String> allNbaTeams = [
    'All-NBA',
    'All-Defensive Team',
    'All-Rookie Team',
  ];

  List<String> awards = [
    'Hall of Fame Inductee',
    'NBA Champion',
    'NBA Finals Most Valuable Player',
    'NBA Most Valuable Player',
    'NBA Defensive Player of the Year',
    'NBA Sixth Man of the Year',
    'NBA Most Improved Player',
    'NBA Rookie of the Year',
    'All-NBA',
    'All-Defensive Team',
    'All-Rookie Team',
    'NBA All-Star',
    'NBA All-Star Most Valuable Player',
    'Olympic Gold Medal',
    'Olympic Silver Medal',
    'Olympic Bronze Medal',
  ];

  Widget awardCount(String awardName) {
    return Row(
      children: [
        Wrap(
          children: [
            Text(
              widget.playerAwards[awardName].length > 1
                  ? '${widget.playerAwards[awardName].length}x  $awardName'
                  : awardName,
              style: kBebasNormal.copyWith(fontSize: 16.0.r),
            ),
          ],
        ),
      ],
    );
  }

  Widget awardYears(String awardName) {
    if (!allNbaTeams.contains(awardName)) {
      List<dynamic> seasons =
          widget.playerAwards[awardName].map((award) => award['SEASON']).toList();
      seasons.sort();

      return Wrap(
        children: [
          for (var i = 0; i < seasons.length; i++)
            Text(
              '${seasons[i]}${i == seasons.length - 1 ? '' : ', '}',
              style: kBebasNormal.copyWith(
                fontSize: 13.0.r,
                color: Colors.grey,
              ),
            ),
        ],
      );
    } else {
      Map<String, String> teamNum = {
        '1': '1st',
        '2': '2nd',
        '3': '3rd',
      };

      Map<String, List<String>> teamAwards = {};

      for (var award in widget.playerAwards[awardName]) {
        String teamNumber = award['ALL_NBA_TEAM_NUMBER'];
        String season = award['SEASON'];

        if (teamAwards.containsKey(teamNumber)) {
          teamAwards[teamNumber]!.add(season);
        } else {
          teamAwards[teamNumber] = [season];
        }
      }

      List<Widget> awardWidgets = [];
      List<String> orderedTeams = ['1', '2', '3'];

      for (var teamNumber in orderedTeams) {
        if (teamAwards.containsKey(teamNumber)) {
          // Sort the seasons before joining them
          teamAwards[teamNumber]!.sort();
          awardWidgets.add(
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${teamNum[teamNumber]} Team: ',
                    style: kBebasNormal.copyWith(
                      fontSize: 13.0.r,
                      color: Colors.white70,
                    ),
                  ),
                  TextSpan(
                    text: teamAwards[teamNumber]!.join(', '),
                    style: kBebasNormal.copyWith(
                      fontSize: 13.0.r,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: awardWidgets,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasAwards = false;
    for (String key in widget.playerAwards.keys) {
      if (awards.contains(key)) {
        hasAwards = true;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(vertical: 11.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
              ),
            ),
            child: Text(
              'Awards',
              style: kBebasBold.copyWith(fontSize: 18.0.r, color: Colors.white),
            ),
          ),
          if (widget.playerAwards.isEmpty || !hasAwards) SizedBox(height: 10.0.r),
          if (widget.playerAwards.isEmpty || !hasAwards)
            Row(
              children: [
                Text(
                  'No Awards',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r),
                ),
              ],
            ),
          for (String award in awards)
            if (widget.playerAwards.keys.contains(award)) ...[
              SizedBox(height: 10.0.r),
              awardCount(award),
              awardYears(award),
            ],
        ],
      ),
    );
  }
}
