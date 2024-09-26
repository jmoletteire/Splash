import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splash/utilities/constants.dart';

import 'game_home.dart';

class GameCard extends StatefulWidget {
  final Map<String, dynamic> game;
  final int homeTeam;
  final int awayTeam;

  const GameCard({
    super.key,
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  Widget gameTitle(String gameId) {
    String seasonTypeCode = gameId[2];

    Map<String, String> seasonTypes = {
      '1': 'Pre-Season',
      '2': 'Regular Season',
      '4': 'Playoffs',
      '5': 'Play-In',
      '6': 'In-Season Tournament',
    };

    switch (seasonTypes[seasonTypeCode]) {
      case 'Playoffs':
        String gameNum = gameId[9];
        String conf;
        String roundId = gameId[7];

        switch (roundId) {
          case '1':
            conf = int.parse(gameId[8]) < 4 ? 'East' : 'West';
          case '2':
            conf = int.parse(gameId[8]) < 2 ? 'East' : 'West';
          case '3':
            conf = gameId[8] == '0' ? 'East' : 'West';
          default:
            conf = '';
        }

        Map<String, String> poRounds = {
          '1': '1st Round',
          '2': 'Semis',
          '3': 'Conf Finals',
          '4': 'NBA Finals',
        };

        return Text(
          'Game $gameNum - $conf ${poRounds[roundId]}',
          style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      case 'Play-In':
        return Text(
          'Play-In Tourney',
          style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      case 'In-Season Tournament':
        return Text(
          'Emirates NBA Cup Final',
          style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
          textAlign: TextAlign.center,
        );
      default:
        return const Text(
          '',
          textAlign: TextAlign.center,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    var summary = widget.game['SUMMARY']['GameSummary'][0];
    var linescore = widget.game['SUMMARY']['LineScore'];

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'] == widget.homeTeam ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[0]['TEAM_ID'] == widget.homeTeam ? linescore[1] : linescore[0];

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameHome(
              gameData: widget.game,
              gameId: widget.game['SUMMARY']['GameSummary'][0]['GAME_ID'],
              homeId: widget.homeTeam.toString(),
              awayId: widget.awayTeam.toString(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.grey.shade800),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ABC' &&
                            summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ESPN' &&
                            summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'TNT')
                          Text(
                            summary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LP',
                            style: kBebasBold.copyWith(
                                fontSize: 12.0.r, color: Colors.grey.shade300),
                            textAlign: TextAlign.start,
                          ),
                        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != null) ...[
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV')
                            SizedBox(width: 3.0.r),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV')
                            SvgPicture.asset(
                              'images/NBA_TV.svg',
                              width: 10.0.r,
                              height: 10.0.r,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'TNT')
                            SvgPicture.asset(
                              'images/TNT.svg',
                              width: 16.0.r,
                              height: 16.0.r,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN')
                            SvgPicture.asset(
                              'images/ESPN.svg',
                              width: 5.0.r,
                              height: 5.0.r,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ABC')
                            SvgPicture.asset(
                              'images/abc.svg',
                              width: 16.0.r,
                              height: 16.0.r,
                            ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(flex: 3, child: gameTitle(summary['GAME_ID'])),
                  Expanded(
                    child: Text(
                      summary['GAME_STATUS_TEXT'] == 'Final'
                          ? summary['GAME_STATUS_TEXT']
                          : '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'].toString()}Q ',
                      style: kBebasNormal.copyWith(
                          fontSize: 13.0.r,
                          color: summary['GAME_STATUS_TEXT'] == 'Final'
                              ? Colors.grey.shade300
                              : Colors.white),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
              SizedBox(height: 5.0.r),

              /// AWAY TEAM ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  /*
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 3.0.r, 10.0.r, 0.0),
                      child: kTeamNames.containsKey(widget.awayTeam.toString())
                          ? ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 24.0.r),
                              child: Image.asset(
                                'images/NBA_Logos/${widget.awayTeam}.png',
                                fit: BoxFit.contain,
                                width: 24.0.r,
                                height: 24.0.r,
                              ),
                            )
                          : const Text(''),
                    ),
                  ),
                   */
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              kTeamIdToName.containsKey(widget.awayTeam.toString())
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/${widget.awayTeam}.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/0.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    ),
                              SizedBox(width: 10.0.r),
                              Text(
                                kTeamIdToName[widget.awayTeam.toString()]?[0] ??
                                    awayLinescore['TEAM_NICKNAME'],
                                style: kGameCardTextStyle.copyWith(
                                  color: awayLinescore['PTS'] > homeLinescore['PTS']
                                      ? Colors.white // Away team won
                                      : (summary['GAME_STATUS_TEXT'] == 'Final'
                                          ? Colors.grey
                                          : Colors.white), // Away team lost
                                  fontSize: 20.0.r,
                                ),
                              ),
                              SizedBox(width: 4.0.r),
                              Text(
                                awayLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle.copyWith(fontSize: 13.0.r),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  awayLinescore['PTS'].toString(),
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(
                                    color: awayLinescore['PTS'] > homeLinescore['PTS']
                                        ? Colors.white // Away team won
                                        : (summary['GAME_STATUS_TEXT'] == 'Final'
                                            ? Colors.grey
                                            : Colors.white), // Away team lost
                                    fontSize: 20.0.r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15.0.r),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '206.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(fontSize: 13.0.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// HOME TEAM ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  /*
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 3.0.r, 10.0.r, 0.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 24.0.r),
                        child: Image.asset(
                          'images/NBA_Logos/${widget.homeTeam}.png',
                          fit: BoxFit.contain,
                          width: 24.0.r,
                          height: 24.0.r,
                        ),
                      ),
                    ),
                  ),
                   */
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              kTeamIdToName.containsKey(widget.homeTeam.toString())
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/${widget.homeTeam}.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    )
                                  : ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 24.0.r),
                                      child: Image.asset(
                                        'images/NBA_Logos/0.png',
                                        fit: BoxFit.contain,
                                        width: 24.0.r,
                                        height: 24.0.r,
                                      ),
                                    ),
                              SizedBox(width: 10.0.r),
                              Text(
                                kTeamIdToName[widget.homeTeam.toString()][0],
                                style: kGameCardTextStyle.copyWith(
                                  color: homeLinescore['PTS'] > awayLinescore['PTS']
                                      ? Colors.white // Home team won
                                      : (summary['GAME_STATUS_TEXT'] == 'Final'
                                          ? Colors.grey
                                          : Colors.white), // Home team lost
                                  fontSize: 20.0.r,
                                ),
                              ),
                              SizedBox(width: 4.0.r),
                              Text(
                                homeLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle.copyWith(fontSize: 13.0.r),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  homeLinescore['PTS'].toString(),
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(
                                    color: homeLinescore['PTS'] > awayLinescore['PTS']
                                        ? Colors.white // Home team won
                                        : (summary['GAME_STATUS_TEXT'] == 'Final'
                                            ? Colors.grey
                                            : Colors.white), // Home team lost
                                    fontSize: 20.0.r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15.0.r),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-6.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle.copyWith(fontSize: 13.0.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
