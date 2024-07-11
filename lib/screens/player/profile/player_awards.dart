import 'package:flutter/material.dart';

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

  Widget awardCount(String awardName) {
    return Row(
      children: [
        Wrap(
          children: [
            Text(
              widget.playerAwards[awardName].length > 1
                  ? '${widget.playerAwards[awardName].length}x  $awardName'
                  : awardName,
              style: kBebasNormal.copyWith(fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget awardYears(String awardName) {
    if (!allNbaTeams.contains(awardName)) {
      List<dynamic> seasons = widget.playerAwards[awardName]
          .map((award) => award['SEASON'])
          .toList();
      seasons.sort();

      return Wrap(
        children: [
          for (var i = 0; i < seasons.length; i++)
            Text(
              '${seasons[i]}${i == seasons.length - 1 ? '' : ', '}',
              style: kBebasNormal.copyWith(
                fontSize: 15,
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
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                  TextSpan(
                    text: teamAwards[teamNumber]!.join(', '),
                    style: kBebasNormal.copyWith(
                      fontSize: 15,
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
                bottom: BorderSide(color: Colors.grey.shade700, width: 2),
              ),
            ),
            child: Text(
              'Awards',
              style: kBebasBold.copyWith(fontSize: 20.0, color: Colors.white),
            ),
          ),

          if (widget.playerAwards.isEmpty) const SizedBox(height: 10.0),
          if (widget.playerAwards.isEmpty)
            const Row(
              children: [
                Text(
                  'No Awards',
                  style: kBebasNormal,
                ),
              ],
            ),

          // NBA CHAMPION
          if (widget.playerAwards.containsKey('NBA Champion'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('NBA Champion'))
            awardCount('NBA Champion'),
          if (widget.playerAwards.containsKey('NBA Champion'))
            awardYears('NBA Champion'),

          // FINALS MVP
          if (widget.playerAwards
              .containsKey('NBA Finals Most Valuable Player'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards
              .containsKey('NBA Finals Most Valuable Player'))
            awardCount('NBA Finals Most Valuable Player'),
          if (widget.playerAwards
              .containsKey('NBA Finals Most Valuable Player'))
            awardYears('NBA Finals Most Valuable Player'),

          // MVP
          if (widget.playerAwards.containsKey('NBA Most Valuable Player'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('NBA Most Valuable Player'))
            awardCount('NBA Most Valuable Player'),
          if (widget.playerAwards.containsKey('NBA Most Valuable Player'))
            awardYears('NBA Most Valuable Player'),

          // DPOY
          if (widget.playerAwards
              .containsKey('NBA Defensive Player of the Year'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards
              .containsKey('NBA Defensive Player of the Year'))
            awardCount('NBA Defensive Player of the Year'),
          if (widget.playerAwards
              .containsKey('NBA Defensive Player of the Year'))
            awardYears('NBA Defensive Player of the Year'),

          // MIP
          if (widget.playerAwards.containsKey('NBA Most Improved Player'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('NBA Most Improved Player'))
            awardCount('NBA Most Improved Player'),
          if (widget.playerAwards.containsKey('NBA Most Improved Player'))
            awardYears('NBA Most Improved Player'),

          // ROTY
          if (widget.playerAwards.containsKey('NBA Rookie of the Year'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('NBA Rookie of the Year'))
            awardCount('NBA Rookie of the Year'),
          if (widget.playerAwards.containsKey('NBA Rookie of the Year'))
            awardYears('NBA Rookie of the Year'),

          // ALL-NBA
          if (widget.playerAwards.containsKey('All-NBA'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('All-NBA')) awardCount('All-NBA'),
          if (widget.playerAwards.containsKey('All-NBA')) awardYears('All-NBA'),

          // ALL-DEFENSE
          if (widget.playerAwards.containsKey('All-Defensive Team'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('All-Defensive Team'))
            awardCount('All-Defensive Team'),
          if (widget.playerAwards.containsKey('All-Defensive Team'))
            awardYears('All-Defensive Team'),

          // ALL-ROOKIE
          if (widget.playerAwards.containsKey('All-Rookie Team'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('All-Rookie Team'))
            awardCount('All-Rookie Team'),
          if (widget.playerAwards.containsKey('All-Rookie Team'))
            awardYears('All-Rookie Team'),

          // ALL-STAR
          if (widget.playerAwards.containsKey('NBA All-Star'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('NBA All-Star'))
            awardCount('NBA All-Star'),
          if (widget.playerAwards.containsKey('NBA All-Star'))
            awardYears('NBA All-Star'),

          // ASG MVP
          if (widget.playerAwards
              .containsKey('NBA All-Star Most Valuable Player'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards
              .containsKey('NBA All-Star Most Valuable Player'))
            awardCount('NBA All-Star Most Valuable Player'),
          if (widget.playerAwards
              .containsKey('NBA All-Star Most Valuable Player'))
            awardYears('NBA All-Star Most Valuable Player'),

          // Olympic Gold
          if (widget.playerAwards.containsKey('Olympic Gold Medal'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('Olympic Gold Medal'))
            awardCount('Olympic Gold Medal'),
          if (widget.playerAwards.containsKey('Olympic Gold Medal'))
            awardYears('Olympic Gold Medal'),

          // Olympic Silver
          if (widget.playerAwards.containsKey('Olympic Silver Medal'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('Olympic Silver Medal'))
            awardCount('Olympic Silver Medal'),
          if (widget.playerAwards.containsKey('Olympic Silver Medal'))
            awardYears('Olympic Silver Medal'),

          // Olympic Bronze
          if (widget.playerAwards.containsKey('Olympic Bronze Medal'))
            const SizedBox(height: 10.0),
          if (widget.playerAwards.containsKey('Olympic Bronze Medal'))
            awardCount('Olympic Bronze Medal'),
          if (widget.playerAwards.containsKey('Olympic Bronze Medal'))
            awardYears('Olympic Bronze Medal'),
        ],
      ),
    );
  }
}
