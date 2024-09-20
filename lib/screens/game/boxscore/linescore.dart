import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/team/team_home.dart';
import 'package:splash/utilities/constants.dart';

class LineScore extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String homeAbbr;
  final String awayAbbr;
  final List<int> homeScores;
  final List<int> awayScores;

  LineScore({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeAbbr,
    required this.awayAbbr,
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
                      color: const Color(0xFF1B1B1B),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                        child: Text('',
                            textAlign: TextAlign.start,
                            style: kBebasBold.copyWith(fontSize: 16.0.r)),
                      ))),
              for (int i = 1; i <= totalQuarters; i++)
                Expanded(
                    child: Container(
                        color: const Color(0xFF1B1B1B),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                          child: Text('Q$i',
                              textAlign: TextAlign.end,
                              style: kBebasBold.copyWith(
                                  fontSize: 14.0.r, color: Colors.grey.shade400)),
                        ))),
              if (overtimes > 0)
                for (int i = 1; i <= overtimes; i++)
                  Expanded(
                      child: Container(
                          color: const Color(0xFF1B1B1B),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                            child: Text(i == 1 ? 'OT' : '${i}OT',
                                textAlign: TextAlign.end,
                                style: kBebasBold.copyWith(
                                    fontSize: 14.0.r, color: Colors.grey.shade400)),
                          ))),
              Expanded(
                  child: Container(
                      color: const Color(0xFF2A2A2A),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                        child: Text('F',
                            textAlign: TextAlign.end,
                            style: kBebasBold.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400)),
                      ))),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0.r),
            child: LineScoreRow(teamId: awayTeam, abbr: awayAbbr, scores: awayScores),
          ),
          Container(
            height: 3.0.r,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0.r),
            child: LineScoreRow(teamId: homeTeam, abbr: homeAbbr, scores: homeScores),
          ),
        ],
      ),
    );
  }
}

class LineScoreRow extends StatelessWidget {
  final String teamId;
  final String abbr;
  final List<int> scores;

  LineScoreRow({required this.teamId, required this.abbr, required this.scores});

  @override
  Widget build(BuildContext context) {
    int totalScore = scores.reduce((a, b) => a + b);

    return InkWell(
      onTap: () {
        if (teamId != '0') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamHome(teamId: teamId),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 8.0.r),
              child: Row(
                children: [
                  if (teamId == '0') SizedBox(width: 5.5.r),
                  Image.asset(
                    'images/NBA_Logos/$teamId.png',
                    width: teamId == '0' ? 11.0.r : 22.0.r,
                  ),
                  if (teamId == '0') SizedBox(width: 5.5.r),
                  SizedBox(width: 5.0.r),
                  Text(abbr,
                      textAlign: TextAlign.start,
                      style: kBebasBold.copyWith(fontSize: 18.0.r)),
                ],
              ),
            ),
          ),
          for (int i = 0; i < scores.length; i++)
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.r),
              child: Text(
                scores[i].toString(),
                textAlign: TextAlign.end,
                style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.grey.shade400),
              ),
            )),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.r),
            child: Text(
              totalScore.toString(),
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 18.0.r),
            ),
          )),
        ],
      ),
    );
  }
}
