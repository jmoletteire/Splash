import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/components/player_avatar.dart';

import '../../../utilities/constants.dart';
import '../player_home.dart';

class SimilarPlayers extends StatefulWidget {
  final List players;
  const SimilarPlayers({super.key, required this.players});

  @override
  State<SimilarPlayers> createState() => _SimilarPlayersState();
}

class _SimilarPlayersState extends State<SimilarPlayers> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 0.0.r, 11.0.r, 11.0.r),
      color: Colors.grey.shade900,
      child: Stack(children: [
        Positioned(
          right: 1,
          child: IconButton(
            onPressed: () {
              showModalBottomSheet(
                constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                backgroundColor: Colors.grey.shade900,
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SingleChildScrollView(
                      child: Column(children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Similar Players\n\n',
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                              TextSpan(
                                text:
                                    'Using each player\'s statistical profile, we determine similar players for a given season based on efficiency, play style, usage, etc., and assign scores 0-100, where 100 represents identical profiles.\n\nThe five most similar players are listed here.',
                                style: TextStyle(fontFamily: 'Roboto'),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              );
            },
            icon: Icon(
              CupertinoIcons.question_circle,
              size: 20.0.r,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.r, vertical: 12.0.r),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(11.0.r, 0.0.r, 11.0.r, 15.0.r),
                child: Text(
                  'SIMILAR PLAYERS',
                  style: TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 16.0.r,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var player in widget.players)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 5) - 8.0.r,
                      child: PlayerCard(
                        playerId: player['PERSON_ID'].toString(),
                        name: player['NAME'],
                        position: player['POSITION'],
                        team: player['TEAM_ID'].toString(),
                        score: player['SIMILARITY_SCORE'],
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class PlayerCard extends StatelessWidget {
  final String playerId;
  final String name;
  final String position;
  final String team;
  final double score;

  const PlayerCard({
    Key? key,
    required this.playerId,
    required this.name,
    required this.position,
    required this.team,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerHome(
              playerId: playerId,
            ),
          ),
        );
      },
      child: Column(
        children: [
          PlayerAvatar(
            radius: 20.0.r,
            backgroundColor: Colors.grey.shade800,
            playerImageUrl: 'https://cdn.nba.com/headshots/nba/latest/1040x760/$playerId.png',
          ),
          SizedBox(height: 5.0.r),
          AutoSizeText(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 13.0.r,
                height: 13.0.r,
                child: Image.asset('images/NBA_Logos/$team.png'),
              ),
              AutoSizeText(
                '  ${kPositionMap[position]!} | ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey.shade300),
              ),
              AutoSizeText(
                score.toStringAsFixed(0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kBebasNormal.copyWith(
                  fontSize: 14.0.r,
                  color: score >= 80
                      ? const Color(0xFF55D86F) //Colors.green
                      : score >= 70
                          ? Colors.yellowAccent
                          : score >= 60
                              ? Colors.orangeAccent
                              : Colors.redAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0.r),
        ],
      ),
    );
  }
}
