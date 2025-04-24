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
  List homePlayerStats = [];
  List awayPlayerStats = [];
  List<Widget> playerWidgets = [];
  late String homeAbbr;
  late String awayAbbr;
  late CustomPaint court;

  void _initializePlayers() {
    status = int.parse(widget.game['status'].toString());
    homePlayerStats = widget.game['stats']?['home']?['players'] ?? [];
    awayPlayerStats = widget.game['stats']?['away']?['players'] ?? [];

    homeAbbr = kTeamIdToName[widget.homeId][1];
    awayAbbr = kTeamIdToName[widget.awayId][1];

    void sortPlayers(List players) {
      // Custom sorting logic
      players.sort((a, b) {
        // Check if each element has the 'notPlayingReason' property
        bool aHasReason = a.containsKey('notPlayingReason');
        bool bHasReason = b.containsKey('notPlayingReason');

        // Move elements with 'notPlayingReason' to the end
        if (aHasReason && !bHasReason) return 1;
        if (!aHasReason && bHasReason) return -1;
        if (aHasReason && bHasReason) {
          bool aCoachDecision = a['notPlayingReason'] == 'INACTIVE_COACH';
          bool bCoachDecision = b['notPlayingReason'] == 'INACTIVE_COACH';

          if (aCoachDecision && !bCoachDecision) return -1;
          if (!aCoachDecision && bCoachDecision) return 1;

          return 0;
        }

        // Maintain the original order for the rest
        return 0;
      });
    }

    sortPlayers(homePlayerStats);
    sortPlayers(awayPlayerStats);
  }

  List<Widget> _setPlayerWidgets() {
    if (isLandscape) {
      return [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlayerCard(
                playerId: awayPlayerStats[0]['personId'] ?? '',
                name: awayPlayerStats[0]['name'] ?? '',
                position: awayPlayerStats[0]['position'] ?? '',
                team: widget.awayId,
              ),
              PlayerCard(
                playerId: awayPlayerStats[2]['personId'] ?? '',
                name: awayPlayerStats[2]['name'] ?? '',
                position: awayPlayerStats[2]['position'] ?? '',
                team: widget.awayId,
              ),
              PlayerCard(
                playerId: awayPlayerStats[1]['personId'] ?? '',
                name: awayPlayerStats[1]['name'] ?? '',
                position: awayPlayerStats[1]['position'] ?? '',
                team: widget.awayId,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlayerCard(
                playerId: awayPlayerStats[4]['personId'] ?? '',
                name: awayPlayerStats[4]['name'] ?? '',
                position: awayPlayerStats[4]['position'] ?? '',
                team: widget.awayId,
              ),
              PlayerCard(
                playerId: awayPlayerStats[3]['personId'] ?? '',
                name: awayPlayerStats[3]['name'] ?? '',
                position: awayPlayerStats[3]['position'] ?? '',
                team: widget.awayId,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlayerCard(
                playerId: homePlayerStats[4]['personId'] ?? '',
                name: homePlayerStats[4]['name'] ?? '',
                position: homePlayerStats[4]['position'] ?? '',
                team: widget.homeId,
              ),
              PlayerCard(
                playerId: homePlayerStats[3]['personId'] ?? '',
                name: homePlayerStats[3]['name'] ?? '',
                position: homePlayerStats[3]['position'] ?? '',
                team: widget.homeId,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlayerCard(
                playerId: homePlayerStats[0]['personId'] ?? '',
                name: homePlayerStats[0]['name'] ?? '',
                position: homePlayerStats[0]['position'] ?? '',
                team: widget.homeId,
              ),
              PlayerCard(
                playerId: homePlayerStats[2]['personId'] ?? '',
                name: homePlayerStats[2]['name'] ?? '',
                position: homePlayerStats[2]['position'] ?? '',
                team: widget.homeId,
              ),
              PlayerCard(
                playerId: homePlayerStats[1]['personId'] ?? '',
                name: homePlayerStats[1]['name'] ?? '',
                position: homePlayerStats[1]['position'] ?? '',
                team: widget.homeId,
              ),
            ],
          ),
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
                playerId: awayPlayerStats[0]['personId'] ?? '',
                name: awayPlayerStats[0]['name'] ?? '',
                position: awayPlayerStats[0]['position'] ?? '',
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: awayPlayerStats[2]['personId'] ?? '',
                name: awayPlayerStats[2]['name'] ?? '',
                position: awayPlayerStats[2]['position'] ?? '',
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: awayPlayerStats[1]['personId'] ?? '',
                name: awayPlayerStats[1]['name'] ?? '',
                position: awayPlayerStats[1]['position'] ?? '',
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
                playerId: awayPlayerStats[4]['personId'] ?? '',
                name: awayPlayerStats[4]['name'] ?? '',
                position: awayPlayerStats[4]['position'] ?? '',
                team: widget.awayId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: awayPlayerStats[3]['personId'] ?? '',
                name: awayPlayerStats[3]['name'] ?? '',
                position: awayPlayerStats[3]['position'] ?? '',
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
                playerId: homePlayerStats[4]['personId'] ?? '',
                name: homePlayerStats[4]['name'] ?? '',
                position: homePlayerStats[4]['position'] ?? '',
                team: widget.homeId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: homePlayerStats[3]['personId'] ?? '',
                name: homePlayerStats[3]['name'] ?? '',
                position: homePlayerStats[3]['position'] ?? '',
                team: widget.homeId,
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
                playerId: homePlayerStats[0]['personId'] ?? '',
                name: homePlayerStats[0]['name'] ?? '',
                position: homePlayerStats[0]['position'] ?? '',
                team: widget.homeId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: homePlayerStats[2]['personId'] ?? '',
                name: homePlayerStats[2]['name'] ?? '',
                position: homePlayerStats[2]['position'] ?? '',
                team: widget.homeId,
              ),
            ),
            Expanded(
              child: PlayerCard(
                playerId: homePlayerStats[1]['personId'] ?? '',
                name: homePlayerStats[1]['name'] ?? '',
                position: homePlayerStats[1]['position'] ?? '',
                team: widget.homeId,
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
                          children: [SizedBox(width: 10.0.r), court],
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5.0.r),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: Text(
                                          awayAbbr,
                                          style: kBebasBold.copyWith(fontSize: 16.0.r),
                                        ),
                                      ),
                                      for (var player in awayPlayerStats.sublist(6))
                                        if (player['notPlayingReason'] == null ||
                                            (player['notPlayingReason'] !=
                                                    'INACTIVE_GLEAGUE_TWOWAY' &&
                                                player['notPlayingReason'] !=
                                                    'INACTIVE_NOT_WITH_TEAM'))
                                          BenchRow(player: player),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5.0.r),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: Text(
                                          homeAbbr,
                                          style: kBebasBold.copyWith(fontSize: 16.0.r),
                                        ),
                                      ),
                                      for (var player in homePlayerStats.sublist(6))
                                        if (player['notPlayingReason'] == null ||
                                            (player['notPlayingReason'] !=
                                                    'INACTIVE_GLEAGUE_TWOWAY' &&
                                                player['notPlayingReason'] !=
                                                    'INACTIVE_NOT_WITH_TEAM'))
                                          BenchRow(player: player),
                                    ],
                                  )
                                ],
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

class BenchRow extends StatelessWidget {
  const BenchRow({
    super.key,
    required this.player,
  });

  final dynamic player;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerHome(
            playerId: player['personId'].toString(),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 15.0.r,
                child: Text(
                  player['number'] ?? '',
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.grey.shade300),
                ),
              ),
              SizedBox(
                width: 30.0.r,
                child: PlayerAvatar(
                    radius: 11.0.r,
                    backgroundColor: Colors.white10,
                    playerImageUrl:
                        'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['personId']}.png'),
              ),
              SizedBox(
                width: 100.0.r,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: player['PLAYER_NAME'] ?? player['name'],
                        style: kBebasNormal.copyWith(fontSize: 13.0.r),
                      ),
                      if (player['notPlayingDescription'] != null ||
                          player['notPlayingReason'] == 'INACTIVE_COACH')
                        TextSpan(
                          text: '\nOUT',
                          style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.red),
                        ),
                      if (player['notPlayingDescription'] != null)
                        TextSpan(
                          text: ' (${player['notPlayingDescription'].split(';')[0]})',
                          style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.grey),
                        ),
                      if (player['notPlayingReason'] == 'INACTIVE_COACH')
                        TextSpan(
                          text: ' (Coach Decision)',
                          style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.0.r),
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
    super.key,
    required this.playerId,
    required this.name,
    required this.position,
    required this.team,
  });

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
