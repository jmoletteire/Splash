import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/player_avatar.dart';
import '../../../../utilities/constants.dart';
import '../../../player/player_home.dart';

class TeamLeaders extends StatefulWidget {
  final String season;
  final String homeId;
  final String awayId;
  final List homePlayers;
  final List awayPlayers;
  const TeamLeaders({
    super.key,
    required this.season,
    required this.homeId,
    required this.awayId,
    required this.homePlayers,
    required this.awayPlayers,
  });

  @override
  State<TeamLeaders> createState() => _TeamLeadersState();
}

class _TeamLeadersState extends State<TeamLeaders> {
  dynamic homePtsLeader;
  dynamic homeRebLeader;
  dynamic homeAstLeader;
  late String homeLeaderPpg;
  late String homeLeaderRpg;
  late String homeLeaderApg;

  dynamic awayPtsLeader;
  dynamic awayRebLeader;
  dynamic awayAstLeader;
  late String awayLeaderPpg;
  late String awayLeaderRpg;
  late String awayLeaderApg;

  String homeSeason = '';
  String awaySeason = '';
  String seasonType = '';

  @override
  void initState() {
    super.initState();

    // Sort players by MIN / GP for the current or previous season
    int i = 0;
    while (homeSeason == '') {
      try {
        homeSeason = widget.homePlayers[i]['STATS'].containsKey(kCurrentSeason)
            ? kCurrentSeason
            : kPrevSeason;
      } catch (e) {
        i++;
        continue;
      }
    }

    int j = 0;
    while (awaySeason == '') {
      try {
        awaySeason = widget.awayPlayers[j]['STATS'].containsKey(kCurrentSeason)
            ? kCurrentSeason
            : kPrevSeason;
      } catch (e) {
        j++;
        continue;
      }
    }

    int k = 0;
    while (seasonType == '') {
      try {
        seasonType = widget.homePlayers[k]['STATS'][homeSeason].containsKey('PLAYOFFS')
            ? 'PLAYOFFS'
            : 'REGULAR SEASON';
      } catch (e) {
        k++;
        continue;
      }
    }

    widget.homePlayers.sort((a, b) {
      try {
        double ptsPerGameA = 0.0;
        double ptsPerGameB = 0.0;
        try {
          ptsPerGameA = a['STATS'][homeSeason][seasonType]['BASIC']['PTS'] /
              a['STATS'][homeSeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameA = 0.0;
        }
        try {
          ptsPerGameB = b['STATS'][homeSeason][seasonType]['BASIC']['PTS'] /
              b['STATS'][homeSeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameB = 0.0;
        }

        return ptsPerGameB.compareTo(ptsPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    homePtsLeader = widget.homePlayers[0];
    homeLeaderPpg = (widget.homePlayers[0]['STATS'][homeSeason][seasonType]['BASIC']['PTS'] /
            widget.homePlayers[0]['STATS'][homeSeason][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.homePlayers.sort((a, b) {
      try {
        double rebPerGameA = 0.0;
        double rebPerGameB = 0.0;
        try {
          rebPerGameA = a['STATS'][homeSeason][seasonType]['BASIC']['REB'] /
              a['STATS'][homeSeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameA = 0.0;
        }
        try {
          rebPerGameB = b['STATS'][homeSeason][seasonType]['BASIC']['REB'] /
              b['STATS'][homeSeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameB = 0.0;
        }

        return rebPerGameB.compareTo(rebPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    homeRebLeader = widget.homePlayers[0];
    homeLeaderRpg = (widget.homePlayers[0]['STATS'][homeSeason][seasonType]['BASIC']['REB'] /
            widget.homePlayers[0]['STATS'][homeSeason][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.homePlayers.sort((a, b) {
      try {
        double astPerGameA = 0.0;
        double astPerGameB = 0.0;
        try {
          astPerGameA = a['STATS'][homeSeason][seasonType]['BASIC']['AST'] /
              a['STATS'][homeSeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameA = 0.0;
        }
        try {
          astPerGameB = b['STATS'][homeSeason][seasonType]['BASIC']['AST'] /
              b['STATS'][homeSeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameB = 0.0;
        }

        return astPerGameB.compareTo(astPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    homeAstLeader = widget.homePlayers[0];
    homeLeaderApg = (widget.homePlayers[0]['STATS'][homeSeason][seasonType]['BASIC']['AST'] /
            widget.homePlayers[0]['STATS'][homeSeason][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.awayPlayers.sort((a, b) {
      try {
        double ptsPerGameA = 0.0;
        double ptsPerGameB = 0.0;
        try {
          ptsPerGameA = a['STATS'][awaySeason][seasonType]['BASIC']['PTS'] /
              a['STATS'][awaySeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameA = 0.0;
        }
        try {
          ptsPerGameB = b['STATS'][awaySeason][seasonType]['BASIC']['PTS'] /
              b['STATS'][awaySeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameB = 0.0;
        }

        return ptsPerGameB.compareTo(ptsPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    awayPtsLeader = widget.awayPlayers[0];
    awayLeaderPpg = (widget.awayPlayers[0]['STATS'][awaySeason][seasonType]['BASIC']['PTS'] /
            widget.awayPlayers[0]['STATS'][awaySeason][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.awayPlayers.sort((a, b) {
      try {
        double rebPerGameA = 0.0;
        double rebPerGameB = 0.0;
        try {
          rebPerGameA = a['STATS'][awaySeason][seasonType]['BASIC']['REB'] /
              a['STATS'][awaySeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameA = 0.0;
        }
        try {
          rebPerGameB = b['STATS'][awaySeason][seasonType]['BASIC']['REB'] /
              b['STATS'][awaySeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameB = 0.0;
        }

        return rebPerGameB.compareTo(rebPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    awayRebLeader = widget.awayPlayers[0];
    awayLeaderRpg = (widget.awayPlayers[0]['STATS'][awaySeason][seasonType]['BASIC']['REB'] /
            widget.awayPlayers[0]['STATS'][awaySeason][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.awayPlayers.sort((a, b) {
      try {
        double astPerGameA = 0.0;
        double astPerGameB = 0.0;
        try {
          astPerGameA = a['STATS'][awaySeason][seasonType]['BASIC']['AST'] /
              a['STATS'][awaySeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameA = 0.0;
        }
        try {
          astPerGameB = b['STATS'][awaySeason][seasonType]['BASIC']['AST'] /
              b['STATS'][awaySeason][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameB = 0.0;
        }

        return astPerGameB.compareTo(astPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    awayAstLeader = widget.awayPlayers[0];
    awayLeaderApg = (widget.awayPlayers[0]['STATS'][awaySeason][seasonType]['BASIC']['AST'] /
            widget.awayPlayers[0]['STATS'][awaySeason][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(
        margin: EdgeInsets.fromLTRB(11.0.r, 0.0.r, 11.0.r, 11.0.r),
        color: Colors.grey.shade900,
        child: Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
                  ),
                ),
                child: Text(
                  'Team Leaders',
                  style: kBebasBold.copyWith(fontSize: 16.0.r),
                ),
              ),
              SizedBox(height: 12.5.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PlayerCard(
                      playerId: awayPtsLeader['PERSON_ID'].toString(),
                      name: awayPtsLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[awayPtsLeader['POSITION']]!,
                      jersey: awayPtsLeader['JERSEY'],
                      team: awayPtsLeader['TEAM_ID'].toString(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      awayLeaderPpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 24.0.r),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 12.5.r,
                          width: 1.0,
                          decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white24))),
                        ),
                        SizedBox(height: 15.r),
                        Text(
                          'PTS',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                            fontSize: 15.0.r,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        SizedBox(height: 15.r),
                        Container(
                          height: 12.5.r,
                          width: 1.0,
                          decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white24))),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      homeLeaderPpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 24.0.r),
                    ),
                  ),
                  Expanded(
                    child: PlayerCard(
                      playerId: homePtsLeader['PERSON_ID'].toString(),
                      name: homePtsLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[homePtsLeader['POSITION']]!,
                      jersey: homePtsLeader['JERSEY'],
                      team: homePtsLeader['TEAM_ID'].toString(),
                    ),
                  ),
                ],
              ),
              Container(
                height: 15.0.r,
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white10))),
              ),
              Container(
                height: 15.0.r,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PlayerCard(
                      playerId: awayRebLeader['PERSON_ID'].toString(),
                      name: awayRebLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[awayRebLeader['POSITION']]!,
                      jersey: awayRebLeader['JERSEY'],
                      team: awayRebLeader['TEAM_ID'].toString(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      awayLeaderRpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 24.0.r),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 12.5.r,
                          width: 1.0,
                          decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white24))),
                        ),
                        SizedBox(height: 15.r),
                        Text(
                          'REB',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                            fontSize: 15.0.r,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        SizedBox(height: 15.r),
                        Container(
                          height: 12.5.r,
                          width: 1.0,
                          decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white24))),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      homeLeaderRpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 24.0.r),
                    ),
                  ),
                  Expanded(
                    child: PlayerCard(
                      playerId: homeRebLeader['PERSON_ID'].toString(),
                      name: homeRebLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[homeRebLeader['POSITION']]!,
                      jersey: homeRebLeader['JERSEY'],
                      team: homeRebLeader['TEAM_ID'].toString(),
                    ),
                  ),
                ],
              ),
              Container(
                height: 15.0.r,
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white10))),
              ),
              Container(
                height: 15.0.r,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PlayerCard(
                      playerId: awayAstLeader['PERSON_ID'].toString(),
                      name: awayAstLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[awayAstLeader['POSITION']]!,
                      jersey: awayAstLeader['JERSEY'],
                      team: awayAstLeader['TEAM_ID'].toString(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      awayLeaderApg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 24.0.r),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 12.5.r,
                          width: 1.0,
                          decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white24))),
                        ),
                        SizedBox(height: 15.r),
                        Text(
                          'AST',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                            fontSize: 15.0.r,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        SizedBox(height: 15.r),
                        Container(
                          height: 12.5.r,
                          width: 1.0,
                          decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white24))),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      homeLeaderApg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 24.0.r),
                    ),
                  ),
                  Expanded(
                    child: PlayerCard(
                      playerId: homeAstLeader['PERSON_ID'].toString(),
                      name: homeAstLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[homeAstLeader['POSITION']]!,
                      jersey: homeAstLeader['JERSEY'],
                      team: homeAstLeader['TEAM_ID'].toString(),
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

class PlayerCard extends StatelessWidget {
  final String playerId;
  final String name;
  final String position;
  final String jersey;
  final String team;

  const PlayerCard({
    Key? key,
    required this.playerId,
    required this.name,
    required this.position,
    required this.jersey,
    required this.team,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (team != '0') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerHome(
                playerId: playerId,
              ),
            ),
          );
        }
      },
      child: Column(
        children: [
          PlayerAvatar(
            radius: 22.0.r,
            backgroundColor: Colors.grey.shade800,
            playerImageUrl: 'https://cdn.nba.com/headshots/nba/latest/1040x760/$playerId.png',
          ),
          SizedBox(height: 5.0.r),
          AutoSizeText(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(fontSize: 15.0.r, color: Colors.grey.shade300),
          ),
          Text(
            '#$jersey | $position',
            style: kBebasOffWhite.copyWith(fontSize: 13.0.r, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
