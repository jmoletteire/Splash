import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

class LineScore extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final List<int> homeScores;
  final List<int> awayScores;

  LineScore({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScores,
    required this.awayScores,
  });

  @override
  Widget build(BuildContext context) {
    int totalQuarters = 4;
    int totalPeriods = homeScores.length;
    int overtimes = totalPeriods > totalQuarters ? totalPeriods - totalQuarters : 0;

    return Container(
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                      color: const Color(0xFF111111),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text('', textAlign: TextAlign.start, style: kBebasBold),
                      ))),
              for (int i = 1; i <= totalQuarters; i++)
                Expanded(
                    child: Container(
                        color: const Color(0xFF111111),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Q$i',
                              textAlign: TextAlign.end,
                              style: kBebasBold.copyWith(color: Colors.grey.shade400)),
                        ))),
              if (overtimes > 0)
                for (int i = 1; i <= overtimes; i++)
                  Expanded(
                      child: Container(
                          color: const Color(0xFF111111),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('OT$i',
                                textAlign: TextAlign.end,
                                style: kBebasBold.copyWith(color: Colors.grey.shade400)),
                          ))),
              Expanded(
                  child: Container(
                      color: const Color(0xFF2A2A2A),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('F',
                            textAlign: TextAlign.end,
                            style: kBebasBold.copyWith(color: Colors.grey.shade400)),
                      ))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: LineScoreRow(teamId: awayTeam, scores: awayScores),
          ),
          Container(
            height: 3.0,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: LineScoreRow(teamId: homeTeam, scores: homeScores),
          ),
        ],
      ),
    );
  }
}

class LineScoreRow extends StatelessWidget {
  final String teamId;
  final List<int> scores;

  LineScoreRow({required this.teamId, required this.scores});

  @override
  Widget build(BuildContext context) {
    int totalScore = scores.reduce((a, b) => a + b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Image.asset(
                  'images/NBA_Logos/$teamId.png',
                  width: 22.0,
                ),
                const SizedBox(width: 5.0),
                Text(kTeamNames[teamId][1],
                    textAlign: TextAlign.start, style: kBebasBold.copyWith(fontSize: 20.0)),
              ],
            ),
          ),
        ),
        for (int i = 0; i < scores.length; i++)
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              scores[i].toString(),
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(color: Colors.grey.shade400),
            ),
          )),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            totalScore.toString(),
            textAlign: TextAlign.end,
            style: kBebasNormal,
          ),
        )),
      ],
    );
  }
}
