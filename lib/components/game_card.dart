import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splash/utilities/constants.dart';

import '../screens/game/game_home.dart';

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
  @override
  Widget build(BuildContext context) {
    var summary = widget.game['SUMMARY']['GameSummary'][0];
    var linescore = widget.game['SUMMARY']['LineScore'];

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'] == widget.homeTeam ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[0]['TEAM_ID'] == widget.awayTeam ? linescore[0] : linescore[1];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameHome(
              gameData: widget.game,
              gameId: widget.game['GAME_ID'],
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
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          summary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LP',
                          style: kGameCardTextStyle.copyWith(color: Colors.white70),
                          textAlign: TextAlign.start,
                        ),
                        if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != null) ...[
                          const SizedBox(width: 5),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'NBA TV')
                            const Icon(
                              Icons.tv_sharp, // TV icon
                              color: Colors.white70,
                              size: 14.0,
                            ),
                          if (summary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV')
                            SvgPicture.asset(
                              'images/NBA_TV.svg',
                              width: 12.0,
                              height: 12.0,
                            ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Text(
                      summary['GAME_STATUS_TEXT'] == 'Final'
                          ? summary['GAME_STATUS_TEXT']
                          : '${summary['LIVE_PC_TIME'].toString()} ${summary['LIVE_PERIOD'].toString()}Q ',
                      style: kGameCardTextStyle.copyWith(
                          color: summary['GAME_STATUS_TEXT'] == 'Final'
                              ? Colors.white70
                              : Colors.white),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),

              /// AWAY TEAM ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 0.0),
                      child: kTeamNames.containsKey(widget.awayTeam.toString())
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 26.0),
                              child: Image.asset(
                                'images/NBA_Logos/${widget.awayTeam}.png',
                                fit: BoxFit.contain,
                                width: 26.0,
                                height: 26.0,
                              ),
                            )
                          : const Text(''),
                    ),
                  ),
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
                              Text(
                                kTeamNames[widget.awayTeam.toString()][0] ??
                                    awayLinescore['TEAM_NICKNAME'],
                                style: kGameCardTextStyle.copyWith(
                                  color: awayLinescore['PTS'] > homeLinescore['PTS']
                                      ? Colors.white // Away team won
                                      : (summary['GAME_STATUS_TEXT'] == 'Final'
                                          ? Colors.grey
                                          : Colors.white), // Away team lost
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                awayLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle,
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
                                    fontSize: 22.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 17.0),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '206.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle,
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
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 0.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 26.0),
                        child: Image.asset(
                          'images/NBA_Logos/${widget.homeTeam}.png',
                          fit: BoxFit.contain,
                          width: 26.0,
                          height: 26.0,
                        ),
                      ),
                    ),
                  ),
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
                              Text(
                                kTeamNames[widget.homeTeam.toString()][0],
                                style: kGameCardTextStyle.copyWith(
                                  color: homeLinescore['PTS'] > awayLinescore['PTS']
                                      ? Colors.white // Home team won
                                      : (summary['GAME_STATUS_TEXT'] == 'Final'
                                          ? Colors.grey
                                          : Colors.white), // Home team lost
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                homeLinescore['TEAM_WINS_LOSSES'],
                                style: kGameCardTextStyle,
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
                                    fontSize: 22.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 17.0),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '-6.5',
                                  textAlign: TextAlign.right,
                                  style: kGameCardTextStyle,
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
