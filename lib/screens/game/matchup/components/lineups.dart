import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

import '../../../../components/player_avatar.dart';
import '../../../player/player_home.dart';

class Lineups extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const Lineups({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
  });

  @override
  State<Lineups> createState() => _LineupsState();
}

class _LineupsState extends State<Lineups> {
  late Map<String, dynamic> gameBoxscore;

  @override
  void initState() {
    super.initState();
    gameBoxscore = widget.game['BOXSCORE'];
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> playerStats = gameBoxscore['PlayerStats'];
    List<dynamic> homePlayerStats = [];
    List<dynamic> awayPlayerStats = [];

    for (var player in playerStats) {
      if (player['TEAM_ID'].toString() == widget.homeId) {
        homePlayerStats.add(player);
      } else {
        awayPlayerStats.add(player);
      }
    }

    homePlayerStats = homePlayerStats.sublist(0, 5);
    awayPlayerStats = awayPlayerStats.sublist(0, 5);

    return Card(
      margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 0.0),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                    ),
                  ),
                  child: Text(
                    'Lineups',
                    style: kBebasBold.copyWith(fontSize: 22.0),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white10,
              child: Stack(children: [
                CustomPaint(
                  size: const Size(189, 578),
                  painter: FullCourtPainter(),
                ),
                Column(
                  children: [
                    const SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: PlayerCard(
                            playerId: awayPlayerStats[0]['PLAYER_ID'].toString(),
                            name: awayPlayerStats[0]['PLAYER_NAME'],
                            position: awayPlayerStats[0]['START_POSITION'],
                            team: widget.awayId,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: awayPlayerStats[2]['PLAYER_ID'].toString(),
                            name: awayPlayerStats[2]['PLAYER_NAME'],
                            position: awayPlayerStats[2]['START_POSITION'],
                            team: widget.awayId,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: awayPlayerStats[1]['PLAYER_ID'].toString(),
                            name: awayPlayerStats[1]['PLAYER_NAME'],
                            position: awayPlayerStats[1]['START_POSITION'],
                            team: widget.awayId,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: PlayerCard(
                            playerId: awayPlayerStats[4]['PLAYER_ID'].toString(),
                            name: awayPlayerStats[4]['PLAYER_NAME'],
                            position: awayPlayerStats[4]['START_POSITION'],
                            team: widget.awayId,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: awayPlayerStats[3]['PLAYER_ID'].toString(),
                            name: awayPlayerStats[3]['PLAYER_NAME'],
                            position: awayPlayerStats[3]['START_POSITION'],
                            team: widget.awayId,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: PlayerCard(
                            playerId: homePlayerStats[4]['PLAYER_ID'].toString(),
                            name: homePlayerStats[4]['PLAYER_NAME'],
                            position: homePlayerStats[4]['START_POSITION'],
                            team: widget.homeId,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: homePlayerStats[3]['PLAYER_ID'].toString(),
                            name: homePlayerStats[3]['PLAYER_NAME'],
                            position: homePlayerStats[3]['START_POSITION'],
                            team: widget.homeId,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: PlayerCard(
                            playerId: homePlayerStats[0]['PLAYER_ID'].toString(),
                            name: homePlayerStats[0]['PLAYER_NAME'],
                            position: homePlayerStats[0]['START_POSITION'],
                            team: widget.homeId,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: homePlayerStats[2]['PLAYER_ID'].toString(),
                            name: homePlayerStats[2]['PLAYER_NAME'],
                            position: homePlayerStats[2]['START_POSITION'],
                            team: widget.homeId,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: homePlayerStats[1]['PLAYER_ID'].toString(),
                            name: homePlayerStats[1]['PLAYER_NAME'],
                            position: homePlayerStats[1]['START_POSITION'],
                            team: widget.homeId,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerHome(
              teamId: team,
              playerId: playerId,
            ),
          ),
        );
      },
      child: Column(
        children: [
          PlayerAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade800,
            playerImageUrl: 'https://cdn.nba.com/headshots/nba/latest/1040x760/$playerId.png',
          ),
          const SizedBox(height: 5.0),
          Text(
            name,
            style: kBebasNormal.copyWith(fontSize: 16.0),
          ),
          Text(
            position,
            style: kBebasOffWhite,
          ),
        ],
      ),
    );
  }
}

class FullCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerCircleRadius = size.width * 0.1;
    final threePointLineRadius = size.width * 0.8;
    final keyWidth = size.width * 0.4;
    final keyHeight = size.height * 0.2;
    final halfCourtWidth = size.width;

    // Draw the half court line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * 1.95, size.height / 2),
      paint,
    );

    void drawHalfCourt(double offsetX) {
      // Draw center arc
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(halfCourtWidth + offsetX, size.height / 2), radius: keyWidth / 2),
        0,
        3.14,
        false,
        paint,
      );

      // Draw baseline
      canvas.drawLine(
        Offset(offsetX + 4, size.height * 0.98),
        Offset(halfCourtWidth * 1.95 + offsetX + 4, size.height * 0.98),
        paint,
      );

      // Draw key (free throw lane)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(halfCourtWidth + offsetX, (size.height * 0.98) - (keyHeight / 2)),
          width: keyWidth,
          height: keyHeight,
        ),
        paint,
      );

      // Draw free throw line arc
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(halfCourtWidth + offsetX, (size.height * 0.98) - keyHeight),
            radius: keyWidth / 2),
        3.14,
        3.14,
        false,
        paint,
      );

      // Draw the inner part of the free throw line arc (dashed)
      const dashWidth = 5.0;
      const dashSpace = 5.0;
      final arcRect = Rect.fromCircle(
        center: Offset(halfCourtWidth + offsetX, (size.height * 0.98) - keyHeight),
        radius: keyWidth / 2,
      );

      final path = Path();
      const totalAngle = 3.14; // The arc's angle in radians (half-circle in this case)
      const segments = 10; // Increase for smoother dash transitions
      const segmentAngle = totalAngle / segments;
      bool draw = true;

      for (int i = 0; i < segments; i++) {
        final startAngle = segmentAngle * i;
        final endAngle = startAngle + segmentAngle;

        if (draw) {
          path.addArc(
              arcRect, startAngle, segmentAngle * (dashWidth / (dashWidth + dashSpace)));
        }

        draw = !draw;
      }

      canvas.drawPath(path, paint);

      // Draw restricted area
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(halfCourtWidth + offsetX, (size.height * 0.98) - (keyHeight / 4)),
            radius: centerCircleRadius),
        3.14,
        3.14,
        false,
        paint,
      );

      // Draw three-point line with flattened ends
      canvas.drawLine(
        Offset((halfCourtWidth + offsetX) + threePointLineRadius, size.height * 0.98),
        Offset((halfCourtWidth + offsetX) + threePointLineRadius,
            (size.height * 0.98) - (keyHeight / 2)),
        paint,
      );
      canvas.drawLine(
        Offset((halfCourtWidth + offsetX) - threePointLineRadius, size.height * 0.98),
        Offset((halfCourtWidth + offsetX) - threePointLineRadius,
            (size.height * 0.98) - (keyHeight / 2)),
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(halfCourtWidth + offsetX, (size.height * 0.98) - (keyHeight / 2)),
            radius: threePointLineRadius),
        3.14,
        3.14,
        false,
        paint,
      );
    }

    // Draw the first half court
    drawHalfCourt(-4);

    // Draw the second half court, mirrored
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(3.14);
    drawHalfCourt(-size.width + 4);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
