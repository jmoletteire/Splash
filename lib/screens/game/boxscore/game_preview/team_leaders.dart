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

  String season = '';
  String seasonType = '';

  @override
  void initState() {
    super.initState();

    // Sort players by MIN / GP for the current or previous season
    int i = 0;
    while (season == '') {
      try {
        season = widget.homePlayers[i]['STATS'].containsKey(kCurrentSeason)
            ? kCurrentSeason
            : kPrevSeason;
      } catch (e) {
        i++;
        continue;
      }
    }

    int j = 0;
    while (seasonType == '') {
      try {
        seasonType = widget.homePlayers[j]['STATS'][season].containsKey('PLAYOFFS')
            ? 'PLAYOFFS'
            : 'REGULAR SEASON';
      } catch (e) {
        j++;
        continue;
      }
    }

    widget.homePlayers.sort((a, b) {
      try {
        double ptsPerGameA = 0.0;
        double ptsPerGameB = 0.0;
        try {
          ptsPerGameA = a['STATS'][season][seasonType]['BASIC']['PTS'] /
              a['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameA = 0.0;
        }
        try {
          ptsPerGameB = b['STATS'][season][seasonType]['BASIC']['PTS'] /
              b['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameB = 0.0;
        }

        return ptsPerGameB.compareTo(ptsPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    homePtsLeader = widget.homePlayers[0];
    homeLeaderPpg = (widget.homePlayers[0]['STATS'][season][seasonType]['BASIC']['PTS'] /
            widget.homePlayers[0]['STATS'][season][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.homePlayers.sort((a, b) {
      try {
        double rebPerGameA = 0.0;
        double rebPerGameB = 0.0;
        try {
          rebPerGameA = a['STATS'][season][seasonType]['BASIC']['REB'] /
              a['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameA = 0.0;
        }
        try {
          rebPerGameB = b['STATS'][season][seasonType]['BASIC']['REB'] /
              b['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameB = 0.0;
        }

        return rebPerGameB.compareTo(rebPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    homeRebLeader = widget.homePlayers[0];
    homeLeaderRpg = (widget.homePlayers[0]['STATS'][season][seasonType]['BASIC']['REB'] /
            widget.homePlayers[0]['STATS'][season][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.homePlayers.sort((a, b) {
      try {
        double astPerGameA = 0.0;
        double astPerGameB = 0.0;
        try {
          astPerGameA = a['STATS'][season][seasonType]['BASIC']['AST'] /
              a['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameA = 0.0;
        }
        try {
          astPerGameB = b['STATS'][season][seasonType]['BASIC']['AST'] /
              b['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameB = 0.0;
        }

        return astPerGameB.compareTo(astPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    homeAstLeader = widget.homePlayers[0];
    homeLeaderApg = (widget.homePlayers[0]['STATS'][season][seasonType]['BASIC']['AST'] /
            widget.homePlayers[0]['STATS'][season][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.awayPlayers.sort((a, b) {
      try {
        double ptsPerGameA = 0.0;
        double ptsPerGameB = 0.0;
        try {
          ptsPerGameA = a['STATS'][season][seasonType]['BASIC']['PTS'] /
              a['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameA = 0.0;
        }
        try {
          ptsPerGameB = b['STATS'][season][seasonType]['BASIC']['PTS'] /
              b['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          ptsPerGameB = 0.0;
        }

        return ptsPerGameB.compareTo(ptsPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    awayPtsLeader = widget.awayPlayers[0];
    awayLeaderPpg = (widget.awayPlayers[0]['STATS'][season][seasonType]['BASIC']['PTS'] /
            widget.awayPlayers[0]['STATS'][season][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.awayPlayers.sort((a, b) {
      try {
        double rebPerGameA = 0.0;
        double rebPerGameB = 0.0;
        try {
          rebPerGameA = a['STATS'][season][seasonType]['BASIC']['REB'] /
              a['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameA = 0.0;
        }
        try {
          rebPerGameB = b['STATS'][season][seasonType]['BASIC']['REB'] /
              b['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          rebPerGameB = 0.0;
        }

        return rebPerGameB.compareTo(rebPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    awayRebLeader = widget.awayPlayers[0];
    awayLeaderRpg = (widget.awayPlayers[0]['STATS'][season][seasonType]['BASIC']['REB'] /
            widget.awayPlayers[0]['STATS'][season][seasonType]['BASIC']['GP'])
        .toStringAsFixed(1);

    widget.awayPlayers.sort((a, b) {
      try {
        double astPerGameA = 0.0;
        double astPerGameB = 0.0;
        try {
          astPerGameA = a['STATS'][season][seasonType]['BASIC']['AST'] /
              a['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameA = 0.0;
        }
        try {
          astPerGameB = b['STATS'][season][seasonType]['BASIC']['AST'] /
              b['STATS'][season][seasonType]['BASIC']['GP'];
        } catch (e) {
          astPerGameB = 0.0;
        }

        return astPerGameB.compareTo(astPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });

    awayAstLeader = widget.awayPlayers[0];
    awayLeaderApg = (widget.awayPlayers[0]['STATS'][season][seasonType]['BASIC']['AST'] /
            widget.awayPlayers[0]['STATS'][season][seasonType]['BASIC']['GP'])
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
              SizedBox(height: 10.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PlayerCard(
                      playerId: awayPtsLeader['PERSON_ID'].toString(),
                      name: awayPtsLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[awayPtsLeader['POSITION']]!,
                      team: awayPtsLeader['TEAM_ID'].toString(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      awayLeaderPpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'PTS',
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(
                        fontSize: 15.0.r,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      homeLeaderPpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    child: PlayerCard(
                      playerId: homePtsLeader['PERSON_ID'].toString(),
                      name: homePtsLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[homePtsLeader['POSITION']]!,
                      team: homePtsLeader['TEAM_ID'].toString(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PlayerCard(
                      playerId: awayRebLeader['PERSON_ID'].toString(),
                      name: awayRebLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[awayRebLeader['POSITION']]!,
                      team: awayRebLeader['TEAM_ID'].toString(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      awayLeaderRpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'REB',
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(
                        fontSize: 15.0.r,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      homeLeaderRpg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    child: PlayerCard(
                      playerId: homeRebLeader['PERSON_ID'].toString(),
                      name: homeRebLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[homeRebLeader['POSITION']]!,
                      team: homeRebLeader['TEAM_ID'].toString(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PlayerCard(
                      playerId: awayAstLeader['PERSON_ID'].toString(),
                      name: awayAstLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[awayAstLeader['POSITION']]!,
                      team: awayAstLeader['TEAM_ID'].toString(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      awayLeaderApg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'AST',
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(
                        fontSize: 15.0.r,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      homeLeaderApg,
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    child: PlayerCard(
                      playerId: homeAstLeader['PERSON_ID'].toString(),
                      name: homeAstLeader['DISPLAY_FI_LAST'],
                      position: kPositionMap[homeAstLeader['POSITION']]!,
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
  final String team;

  const PlayerCard({
    Key? key,
    required this.playerId,
    required this.name,
    required this.position,
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
            radius: 28.0.r,
            backgroundColor: Colors.grey.shade800,
            playerImageUrl: 'https://cdn.nba.com/headshots/nba/latest/1040x760/$playerId.png',
          ),
          SizedBox(height: 5.0.r),
          AutoSizeText(
            name,
            maxLines: 1,
            style: kBebasNormal.copyWith(fontSize: 14.0.r),
          ),
          Text(
            position,
            style: kBebasOffWhite.copyWith(fontSize: 14.0.r, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
