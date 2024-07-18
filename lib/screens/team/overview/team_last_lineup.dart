import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/utilities/constants.dart';

import '../../player/player_home.dart';

class TeamLastLineup extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamLastLineup({super.key, required this.team});

  @override
  State<TeamLastLineup> createState() => _TeamLastLineupState();
}

class _TeamLastLineupState extends State<TeamLastLineup> {
  Map<String, dynamic> getLastGame() {
    Map<String, dynamic> schedule = widget.team['seasons'][kCurrentSeason]['GAMES'];

    // Convert the map to a list of entries
    var entries = schedule.entries.toList();

    // Sort the entries by the GAME_DATE value
    entries.sort((a, b) => a.value['GAME_DATE'].compareTo(b.value['GAME_DATE']));

    // Extract the sorted keys
    var gameIndex = entries.map((e) => e.key).toList();

    return schedule[gameIndex.last];
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('MMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    var lineup = widget.team['LAST_STARTING_LINEUP'];
    var lastGame = getLastGame();
    return Card(
      margin: const EdgeInsets.all(11.0),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                        ),
                      ),
                      child: Text(
                        'Last Starting Lineup',
                        style: kBebasBold.copyWith(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${formatDate(lastGame['GAME_DATE'])} - ${lastGame['HOME_AWAY']} ${kTeamNames[lastGame['OPP'].toString()][1]} (${lastGame['TEAM_PTS']}-${lastGame['OPP_PTS']} ',
                            style: kBebasBold.copyWith(fontSize: 15.0, color: Colors.grey),
                          ),
                          TextSpan(
                            text: '${lastGame['RESULT']}',
                            style: kBebasBold.copyWith(
                              fontSize: 15.0,
                              color: lastGame['RESULT'] == 'W' ? Colors.green : Colors.red,
                            ),
                          ),
                          TextSpan(
                            text: ')',
                            style: kBebasBold.copyWith(fontSize: 15.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white10,
              child: Stack(children: [
                CustomPaint(
                  size: const Size(189, 289),
                  painter: HalfCourtPainter(),
                ),
                Column(
                  children: [
                    const SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: PlayerCard(
                            playerId: lineup[4]['PLAYER_ID'].toString(),
                            name: lineup[4]['NAME'],
                            position: lineup[4]['POSITION'],
                            team: widget.team,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: lineup[3]['PLAYER_ID'].toString(),
                            name: lineup[3]['NAME'],
                            position: lineup[3]['POSITION'],
                            team: widget.team,
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
                            playerId: lineup[0]['PLAYER_ID'].toString(),
                            name: lineup[0]['NAME'],
                            position: lineup[0]['POSITION'],
                            team: widget.team,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: lineup[2]['PLAYER_ID'].toString(),
                            name: lineup[2]['NAME'],
                            position: lineup[2]['POSITION'],
                            team: widget.team,
                          ),
                        ),
                        Expanded(
                          child: PlayerCard(
                            playerId: lineup[1]['PLAYER_ID'].toString(),
                            name: lineup[1]['NAME'],
                            position: lineup[1]['POSITION'],
                            team: widget.team,
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
  final Map<String, dynamic> team;

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
              teamId: team["TEAM_ID"].toString(),
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

class HalfCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerCircleRadius = size.width * 0.1;
    final threePointLineRadius = size.width * 0.8;
    final keyWidth = size.width * 0.4;
    final keyHeight = size.height * 0.365;

    // Draw center arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 1.95 / 2, 0), radius: keyWidth / 2),
      0,
      3.14,
      false,
      paint,
    );

    // Draw baseline
    canvas.drawLine(
      Offset(0, size.height * 0.98),
      Offset(size.width * 1.95, size.height * 0.98),
      paint,
    );

    // Draw key (free throw lane)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 1.95 / 2, (size.height * 0.98) - (keyHeight / 2)),
        width: keyWidth,
        height: keyHeight,
      ),
      paint,
    );

    // Draw free throw line arc
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width * 1.95 / 2, (size.height * 0.98) - keyHeight),
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
      center: Offset(size.width * 1.95 / 2, (size.height * 0.98) - keyHeight),
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
        path.addArc(arcRect, startAngle, segmentAngle * (dashWidth / (dashWidth + dashSpace)));
      }

      draw = !draw;
    }

    canvas.drawPath(path, paint);

    // Draw restricted area
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width * 1.95 / 2, (size.height * 0.98) - (keyHeight / 4)),
          radius: centerCircleRadius),
      3.14,
      3.14,
      false,
      paint,
    );

    // Draw three-point line with flattened ends
    canvas.drawLine(
      Offset((size.width * 1.95 / 2) + threePointLineRadius, size.height * 0.98),
      Offset((size.width * 1.95 / 2) + threePointLineRadius,
          (size.height * 0.98) - (keyHeight / 2)),
      paint,
    );
    canvas.drawLine(
      Offset((size.width * 1.95 / 2) - threePointLineRadius, size.height * 0.98),
      Offset((size.width * 1.95 / 2) - threePointLineRadius,
          (size.height * 0.98) - (keyHeight / 2)),
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width * 1.95 / 2, (size.height * 0.98) - (keyHeight / 2)),
          radius: threePointLineRadius),
      3.14,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
