import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/court_painter.dart';
import '../../player/player_home.dart';

class TeamLastLineup extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamLastLineup({super.key, required this.team});

  @override
  State<TeamLastLineup> createState() => _TeamLastLineupState();
}

class _TeamLastLineupState extends State<TeamLastLineup> {
  Map<String, dynamic> getLastGame() {
    for (String season in kSeasons) {
      Map<String, dynamic> schedule = widget.team['seasons']?[season]?['GAMES'] ?? {};

      // Convert the map to a list of entries
      var entries = schedule.entries.toList();

      // Sort the entries by the GAME_DATE value
      entries.sort((a, b) => b.value['GAME_DATE'].compareTo(a.value['GAME_DATE']));

      // Extract the sorted keys
      var games = entries.map((e) => e.key).toList();

      // If season has started
      if (DateTime.parse(schedule[games.last]['GAME_DATE']).compareTo(DateTime.now()) < 0) {
        // Find last game
        for (var game in games) {
          if (DateTime.parse(schedule[game]['GAME_DATE']).compareTo(DateTime.now()) < 0) {
            return schedule[game];
          }
        }
      }
    }
    return {};
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('MMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    var lineup = widget.team['LAST_STARTING_LINEUP'];
    var lastGame = getLastGame();
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Card(
      margin: EdgeInsets.all(11.0.r),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(15.0.r, 15.0.r, 15.0.r, 0.0),
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
                        style: kBebasBold.copyWith(fontSize: 18.0.r, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 5.0.r),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${formatDate(lastGame['GAME_DATE'])} - ${lastGame['HOME_AWAY']} ${kTeamIdToName[lastGame['OPP'].toString()][1]} (${lastGame['TEAM_PTS']}-${lastGame['OPP_PTS']} ',
                            style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.grey),
                          ),
                          TextSpan(
                            text: '${lastGame['RESULT']}',
                            style: kBebasNormal.copyWith(
                              fontSize: 13.0.r,
                              color: lastGame['RESULT'] == 'W'
                                  ? const Color(0xFF55F86F)
                                  : const Color(0xFFFC3126),
                            ),
                          ),
                          TextSpan(
                            text: ')',
                            style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.grey),
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
            padding: EdgeInsets.all(8.0.r),
            child: Card(
              color: Colors.white10,
              child: Stack(children: [
                CustomPaint(
                  size: Size(368.r, 346.r),
                  painter: HalfCourtPainter(courtColor: Colors.grey.shade800),
                ),
                Column(
                  children: [
                    SizedBox(height: 60.0.r),
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
                    SizedBox(height: 35.0.r),
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
              playerId: playerId,
            ),
          ),
        );
      },
      child: Column(
        children: [
          PlayerAvatar(
            radius: 32.r,
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
            style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
          ),
        ],
      ),
    );
  }
}

/*
class HalfCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
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

 */
