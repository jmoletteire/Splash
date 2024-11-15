import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool isLandscape = false;
  int status = 0;
  List playerStats = [];
  List homePlayerStats = [];
  List awayPlayerStats = [];
  List<Widget> playerWidgets = [];
  late Map<String, dynamic> gameBoxscore;
  late CustomPaint court;

  void _initializePlayers() {
    gameBoxscore = widget.game['BOXSCORE'];

    status = widget.game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'];
    playerStats = status == 3 ? gameBoxscore['PlayerStats'] ?? [] : [];
    homePlayerStats = gameBoxscore['homeTeam']?['players'] ?? [];
    awayPlayerStats = gameBoxscore['awayTeam']?['players'] ?? [];

    if (status == 3 && playerStats.isNotEmpty) {
      for (var player in playerStats) {
        if (player['TEAM_ID'].toString() == widget.homeId) {
          homePlayerStats.add(player);
        } else {
          awayPlayerStats.add(player);
        }
      }
    }

    homePlayerStats = homePlayerStats.sublist(0, 5);
    awayPlayerStats = awayPlayerStats.sublist(0, 5);
  }

  List<Widget> _setPlayerWidgets() {
    if (isLandscape) {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PlayerCard(
              playerId: (awayPlayerStats[0]['PLAYER_ID'] ?? awayPlayerStats[0]['personId'])
                  .toString(),
              name: awayPlayerStats[0]['PLAYER_NAME'] ?? awayPlayerStats[0]['name'],
              position: awayPlayerStats[0]['START_POSITION'] ?? awayPlayerStats[0]['position'],
              team: widget.awayId,
            ),
            PlayerCard(
              playerId: (awayPlayerStats[2]['PLAYER_ID'] ?? awayPlayerStats[2]['personId'])
                  .toString(),
              name: awayPlayerStats[2]['PLAYER_NAME'] ?? awayPlayerStats[2]['name'],
              position: awayPlayerStats[2]['START_POSITION'] ?? awayPlayerStats[2]['position'],
              team: widget.awayId,
            ),
            PlayerCard(
              playerId: (awayPlayerStats[1]['PLAYER_ID'] ?? awayPlayerStats[1]['personId'])
                  .toString(),
              name: awayPlayerStats[1]['PLAYER_NAME'] ?? awayPlayerStats[1]['name'],
              position: awayPlayerStats[1]['START_POSITION'] ?? awayPlayerStats[1]['position'],
              team: widget.awayId,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PlayerCard(
              playerId: (awayPlayerStats[4]['PLAYER_ID'] ?? awayPlayerStats[4]['personId'])
                  .toString(),
              name: awayPlayerStats[4]['PLAYER_NAME'] ?? awayPlayerStats[4]['name'],
              position: awayPlayerStats[4]['START_POSITION'] ?? awayPlayerStats[4]['position'],
              team: widget.awayId,
            ),
            PlayerCard(
              playerId: (awayPlayerStats[3]['PLAYER_ID'] ?? awayPlayerStats[3]['personId'])
                  .toString(),
              name: awayPlayerStats[3]['PLAYER_NAME'] ?? awayPlayerStats[3]['name'],
              position: awayPlayerStats[3]['START_POSITION'] ?? awayPlayerStats[3]['position'],
              team: widget.awayId,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PlayerCard(
              playerId: (homePlayerStats[4]['PLAYER_ID'] ?? homePlayerStats[4]['personId'])
                  .toString(),
              name: homePlayerStats[4]['PLAYER_NAME'] ?? homePlayerStats[4]['name'],
              position: homePlayerStats[4]['START_POSITION'] ?? homePlayerStats[4]['position'],
              team: widget.awayId,
            ),
            PlayerCard(
              playerId: (homePlayerStats[3]['PLAYER_ID'] ?? homePlayerStats[3]['personId'])
                  .toString(),
              name: homePlayerStats[3]['PLAYER_NAME'] ?? homePlayerStats[3]['name'],
              position: homePlayerStats[3]['START_POSITION'] ?? homePlayerStats[3]['position'],
              team: widget.awayId,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlayerCard(
              playerId: (homePlayerStats[0]['PLAYER_ID'] ?? homePlayerStats[0]['personId'])
                  .toString(),
              name: homePlayerStats[0]['PLAYER_NAME'] ?? homePlayerStats[0]['name'],
              position: homePlayerStats[0]['START_POSITION'] ?? homePlayerStats[0]['position'],
              team: widget.awayId,
            ),
            PlayerCard(
              playerId: (homePlayerStats[2]['PLAYER_ID'] ?? homePlayerStats[2]['personId'])
                  .toString(),
              name: homePlayerStats[2]['PLAYER_NAME'] ?? homePlayerStats[2]['name'],
              position: homePlayerStats[2]['START_POSITION'] ?? homePlayerStats[2]['position'],
              team: widget.awayId,
            ),
            PlayerCard(
              playerId: (homePlayerStats[1]['PLAYER_ID'] ?? homePlayerStats[1]['personId'])
                  .toString(),
              name: homePlayerStats[1]['PLAYER_NAME'] ?? homePlayerStats[1]['name'],
              position: homePlayerStats[1]['START_POSITION'] ?? homePlayerStats[1]['position'],
              team: widget.awayId,
            ),
          ],
        ),
      ];
    } else {
      return [
        SizedBox(height: 30.0.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: PlayerCard(
                playerId: (awayPlayerStats[0]['PLAYER_ID'] ?? awayPlayerStats[0]['personId'])
                    .toString(),
                name: awayPlayerStats[0]['PLAYER_NAME'] ?? awayPlayerStats[0]['name'],
                position:
                    awayPlayerStats[0]['START_POSITION'] ?? awayPlayerStats[0]['position'],
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: (awayPlayerStats[2]['PLAYER_ID'] ?? awayPlayerStats[2]['personId'])
                    .toString(),
                name: awayPlayerStats[2]['PLAYER_NAME'] ?? awayPlayerStats[2]['name'],
                position:
                    awayPlayerStats[2]['START_POSITION'] ?? awayPlayerStats[2]['position'],
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: (awayPlayerStats[1]['PLAYER_ID'] ?? awayPlayerStats[1]['personId'])
                    .toString(),
                name: awayPlayerStats[1]['PLAYER_NAME'] ?? awayPlayerStats[1]['name'],
                position:
                    awayPlayerStats[1]['START_POSITION'] ?? awayPlayerStats[1]['position'],
                team: widget.awayId,
              ),
            ),
          ],
        ),
        SizedBox(height: 25.0.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: PlayerCard(
                playerId: (awayPlayerStats[4]['PLAYER_ID'] ?? awayPlayerStats[4]['personId'])
                    .toString(),
                name: awayPlayerStats[4]['PLAYER_NAME'] ?? awayPlayerStats[4]['name'],
                position:
                    awayPlayerStats[4]['START_POSITION'] ?? awayPlayerStats[4]['position'],
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: (awayPlayerStats[3]['PLAYER_ID'] ?? awayPlayerStats[3]['personId'])
                    .toString(),
                name: awayPlayerStats[3]['PLAYER_NAME'] ?? awayPlayerStats[3]['name'],
                position:
                    awayPlayerStats[3]['START_POSITION'] ?? awayPlayerStats[3]['position'],
                team: widget.awayId,
              ),
            ),
          ],
        ),
        SizedBox(height: 30.0.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: PlayerCard(
                playerId: (homePlayerStats[4]['PLAYER_ID'] ?? homePlayerStats[4]['personId'])
                    .toString(),
                name: homePlayerStats[4]['PLAYER_NAME'] ?? homePlayerStats[4]['name'],
                position:
                    homePlayerStats[4]['START_POSITION'] ?? homePlayerStats[4]['position'],
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: (homePlayerStats[3]['PLAYER_ID'] ?? homePlayerStats[3]['personId'])
                    .toString(),
                name: homePlayerStats[3]['PLAYER_NAME'] ?? homePlayerStats[3]['name'],
                position:
                    homePlayerStats[3]['START_POSITION'] ?? homePlayerStats[3]['position'],
                team: widget.awayId,
              ),
            ),
          ],
        ),
        SizedBox(height: 25.0.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: PlayerCard(
                playerId: (homePlayerStats[0]['PLAYER_ID'] ?? homePlayerStats[0]['personId'])
                    .toString(),
                name: homePlayerStats[0]['PLAYER_NAME'] ?? homePlayerStats[0]['name'],
                position:
                    homePlayerStats[0]['START_POSITION'] ?? homePlayerStats[0]['position'],
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: (homePlayerStats[2]['PLAYER_ID'] ?? homePlayerStats[2]['personId'])
                    .toString(),
                name: homePlayerStats[2]['PLAYER_NAME'] ?? homePlayerStats[2]['name'],
                position:
                    homePlayerStats[2]['START_POSITION'] ?? homePlayerStats[2]['position'],
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: (homePlayerStats[1]['PLAYER_ID'] ?? homePlayerStats[1]['personId'])
                    .toString(),
                name: homePlayerStats[1]['PLAYER_NAME'] ?? homePlayerStats[1]['name'],
                position:
                    homePlayerStats[1]['START_POSITION'] ?? homePlayerStats[1]['position'],
                team: widget.awayId,
              ),
            ),
          ],
        ),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    court = CustomPaint(
      size: Size(368.r, 346.r),
      painter: FullCourtPainter(isLandscape: isLandscape),
    );
    playerWidgets = _setPlayerWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15.0.r, 15.0.r, 15.0.r, 3.0.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
                    ),
                  ),
                  child: Text(
                    'Starting Lineups',
                    style: kBebasBold.copyWith(fontSize: 20.0.r),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0.r),
            child: Card(
                color: Colors.white10,
                child: LayoutBuilder(builder: (context, constraints) {
                  if (isLandscape) {
                    return Stack(
                      children: [
                        Row(
                          children: [SizedBox(width: 45.0.r), court],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(height: 30.0.r),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: playerWidgets,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [],
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Stack(
                      children: [
                        Column(
                          children: [SizedBox(height: 1.5.r), court],
                        ),
                        Column(
                          children: playerWidgets,
                        ),
                      ],
                    );
                  }
                })),
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
            radius: 29.0.r,
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

class FullCourtPainter extends CustomPainter {
  final bool isLandscape;

  FullCourtPainter({required this.isLandscape});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Swap width and height if landscape mode
    final courtWidth = isLandscape ? size.height : size.width;
    final courtHeight = isLandscape ? size.width : size.height;

    // Add a scaling factor for the three-point arc radius in landscape mode
    final threePointArcScalingFactor = isLandscape ? 0.8875 : 1.0;

    // Draw the half court line
    isLandscape
        ? canvas.drawLine(
            Offset(courtHeight / (4 / 3), 0),
            Offset(courtHeight / (4 / 3), courtWidth),
            paint,
          )
        : canvas.drawLine(
            Offset(0, courtHeight / (4 / 3)),
            Offset(courtWidth, courtHeight / (4 / 3)),
            paint,
          );

    void drawHalfCourt() {
      /// 368 Pixels wide = 50 ft (1 pixel = 0.136 ft OR 1.63 inches)
      /// 346 Pixels tall = 47 ft (1 pixel = 0.136 ft OR 1.63 inches)

      final restrictedAreaRadius = courtWidth * (4 / 50);
      final threePointLineRadius = courtHeight * (23.75 / 47) * threePointArcScalingFactor;
      final keyWidth = courtWidth * (12 / 50);
      final outerKeyWidth = courtWidth * (16 / 50);
      final freeThrowLine = courtHeight * (18.87 / 47);

      // Draw center arc
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset((courtWidth / 2), courtHeight / 4), radius: keyWidth / 3),
        0,
        3.14,
        false,
        paint,
      );

      // Draw inner center arc
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset((courtWidth / 2), courtHeight / 4), radius: keyWidth / 9),
        0,
        3.14,
        false,
        paint,
      );

      // Draw baseline
      canvas.drawLine(
        Offset(5.r, courtHeight),
        Offset(courtWidth - 5.r, courtHeight),
        paint,
      );

      // Draw key (free throw lane)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset((courtWidth / 2), courtHeight - (freeThrowLine / 2)),
          width: keyWidth,
          height: freeThrowLine,
        ),
        paint,
      );

      // Draw outside key
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset((courtWidth / 2), courtHeight - (freeThrowLine / 2)),
          width: outerKeyWidth,
          height: freeThrowLine,
        ),
        paint,
      );

      // Draw free throw line arc
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset((courtWidth / 2), courtHeight - freeThrowLine),
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
        center: Offset((courtWidth / 2), courtHeight - freeThrowLine),
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
            center: Offset((courtWidth / 2), courtHeight - (courtHeight * (4 / 47))),
            radius: restrictedAreaRadius),
        3.14,
        3.14,
        false,
        paint,
      );

      // Draw three-point line with short corners
      // Short Corner (Right)
      canvas.drawLine(
        Offset((courtWidth / 2) + courtWidth * (22 / 50), courtHeight),
        Offset((courtWidth / 2) + courtWidth * (22 / 50),
            courtHeight - (courtHeight * (14 / 47))),
        paint,
      );

      // Short Corner (Left)
      canvas.drawLine(
        Offset((courtWidth / 2) - courtWidth * (22 / 50), courtHeight),
        Offset((courtWidth / 2) - courtWidth * (22 / 50),
            courtHeight - (courtHeight * (14 / 47))),
        paint,
      );

      // Above the Break (Arc)
      int offset = isLandscape ? -5 : 0;

      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(courtWidth / 2, offset + courtHeight - (courtHeight * (5 / 47))),
            radius: threePointLineRadius),
        -3.14 + (0.123 * 3.14), // Start angle in quadrant 2
        (3.14 - (0.123 * 2 * 3.14)),
        false,
        paint,
      );
    }

    // Adjust for landscape orientation
    if (isLandscape) {
      canvas.rotate(-3.14 / 2); // Rotate canvas for landscape drawing
      canvas.translate(-size.height, 0); // Translate canvas back to fit in landscape mode
    }

    // Draw the first half court
    canvas.translate(0, courtHeight / 2);
    drawHalfCourt();

    // Draw the second half court, mirrored
    canvas.save();
    canvas.translate(courtWidth, courtHeight / 2);
    canvas.rotate(3.14);
    drawHalfCourt();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
