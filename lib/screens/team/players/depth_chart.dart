import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../components/player_avatar.dart';
import '../../../utilities/constants.dart';
import '../../player/player_home.dart';

class DepthChart extends StatefulWidget {
  final Map<String, dynamic> team;
  const DepthChart({super.key, required this.team});

  @override
  State<DepthChart> createState() => _DepthChartState();
}

class _DepthChartState extends State<DepthChart> with AutomaticKeepAliveClientMixin {
  late List<String> seasons;
  late String selectedSeason;
  List<dynamic> guards = []; // Players for the first SliverList (Guards)
  List<dynamic> forwards = []; // Players for the second SliverList (Forwards)
  List<dynamic> centers = []; // Players for the second SliverList (Centers)
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  void setPlayers() {
    try {
      if (_isLoading == false) _isLoading = true;

      // Convert the map to a list of entries
      var guardEntries = widget.team['seasons'][selectedSeason]['ROSTER'].entries
          .where((entry) => entry.value['POSITION'] == 'G' || entry.value['POSITION'] == 'G-F')
          .toList();

      var forwardEntries = widget.team['seasons'][selectedSeason]['ROSTER'].entries
          .where((entry) => entry.value['POSITION'] == 'F' || entry.value['POSITION'] == 'F-G')
          .toList();

      var centerEntries = widget.team['seasons'][selectedSeason]['ROSTER'].entries
          .where((entry) =>
              entry.value['POSITION'] == 'C' ||
              entry.value['POSITION'] == 'F-C' ||
              entry.value['POSITION'] == 'C-F')
          .toList();

      // Sort by MPG
      guardEntries.sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) {
        double mpgA = (a.value['MPG'] ?? 0 as num).toDouble();
        double mpgB = (b.value['MPG'] ?? 0 as num).toDouble();
        return mpgB.compareTo(mpgA); // Higher MPG comes first
      });

      forwardEntries.sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) {
        double mpgA = (a.value['MPG'] ?? 0 as num).toDouble();
        double mpgB = (b.value['MPG'] ?? 0 as num).toDouble();
        return mpgB.compareTo(mpgA); // Higher MPG comes first
      });

      centerEntries.sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) {
        double mpgA = (a.value['MPG'] ?? 0 as num).toDouble();
        double mpgB = (b.value['MPG'] ?? 0 as num).toDouble();
        return mpgB.compareTo(mpgA); // Higher MPG comes first
      });

      // Extract the sorted keys for both starters and bench
      List<dynamic> fetchedGuards = guardEntries.map((e) => e.key).toList();
      List<dynamic> fetchedForwards = forwardEntries.map((e) => e.key).toList();
      List<dynamic> fetchedCenters = centerEntries.map((e) => e.key).toList();

      setState(() {
        guards = fetchedGuards; // Set the starters for the first SliverList
        forwards = fetchedForwards; // Set the bench players for the second SliverList
        centers = fetchedCenters; // Set the bench players for the second SliverList
        _isLoading = false;
      });
    } catch (e) {
      print('Error in setPlayers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    seasons = widget.team['seasons'].keys.toList().reversed.toList();
    selectedSeason = seasons.first;
    setPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.04,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: const Border(
              bottom: BorderSide(
                color: Colors.white24,
                width: 1,
              ),
            ),
          ),
          child: DropdownButton<String>(
            padding: EdgeInsets.symmetric(horizontal: 15.0.r),
            borderRadius: BorderRadius.circular(10.0),
            menuMaxHeight: 300.0.r,
            dropdownColor: Colors.grey.shade900,
            isExpanded: true,
            underline: Container(),
            value: selectedSeason,
            items: seasons.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedSeason = value!;
                setPlayers();
              });
            },
          ),
        ),
        Card(
          margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 11.0),
          color: Colors.grey.shade900,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white10,
              child: Stack(children: [
                CustomPaint(
                  size: const Size(368, 346),
                  painter: HalfCourtPainter(),
                ),
                Column(
                  children: [
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PositionCard(
                            players: guards
                                .asMap()
                                .entries
                                .where((entry) => entry.key % 2 == 0)
                                .map((entry) => entry.value)
                                .toList(),
                            team: widget.team,
                            season: selectedSeason,
                          ),
                        ),
                        Expanded(
                          child: PositionCard(
                            players: guards
                                .asMap()
                                .entries
                                .where((entry) => entry.key % 2 == 1)
                                .map((entry) => entry.value)
                                .toList(),
                            team: widget.team,
                            season: selectedSeason,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PositionCard(
                            players: forwards
                                .asMap()
                                .entries
                                .where((entry) => entry.key % 2 == 0)
                                .map((entry) => entry.value)
                                .toList(),
                            team: widget.team,
                            season: selectedSeason,
                          ),
                        ),
                        Expanded(
                          child: PositionCard(
                            players: centers,
                            team: widget.team,
                            season: selectedSeason,
                          ),
                        ),
                        Expanded(
                          child: PositionCard(
                            players: forwards
                                .asMap()
                                .entries
                                .where((entry) => entry.key % 2 == 1)
                                .map((entry) => entry.value)
                                .toList(),
                            team: widget.team,
                            season: selectedSeason,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class PositionCard extends StatelessWidget {
  final List players;
  final Map<String, dynamic> team;
  final String season;

  const PositionCard({
    Key? key,
    required this.players,
    required this.team,
    required this.season,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: players.asMap().entries.map((entry) {
            final int index = entry.key;
            final String player = entry.value;
            final String name = team['seasons'][season]['ROSTER'][player]['PLAYER'];
            final String position = team['seasons'][season]['ROSTER'][player]['POSITION'];

            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerHome(
                        teamId: team['TEAM_ID'].toString(),
                        playerId: player,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Column(
                    children: [
                      PlayerAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade800,
                        playerImageUrl:
                            'https://cdn.nba.com/headshots/nba/latest/1040x760/$player.png',
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '$name, ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: kBebasNormal.copyWith(fontSize: 16.0),
                            ),
                          ),
                          Text(
                            position,
                            style: kBebasNormal.copyWith(
                                fontSize: 16.0, color: Colors.grey.shade300),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.5),
                    ],
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerHome(
                        teamId: team['TEAM_ID'].toString(),
                        playerId: player,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 5.0),
                      Text(
                        (index + 1).toString(),
                        style: kBebasNormal.copyWith(fontSize: 12.0, color: Colors.white70),
                      ),
                      const SizedBox(width: 5.0),
                      Flexible(
                        child: Text(
                          '$name,',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kBebasNormal.copyWith(fontSize: 12.0, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 2.0),
                      Text(
                        position,
                        style: kBebasOffWhite.copyWith(fontSize: 11.0),
                      ),
                    ],
                  ),
                ),
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}

class HalfCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    /// 368 Pixels wide = 50 ft (1 pixel = 0.136 ft OR 1.63 inches)
    /// 346 Pixels tall = 47 ft (1 pixel = 0.136 ft OR 1.63 inches)

    final restrictedAreaRadius = size.width * (4 / 50);
    final threePointLineRadius = size.height * (23.75 / 47);
    final keyWidth = size.width * (12 / 50);
    final outerKeyWidth = size.width * (16 / 50);
    final freeThrowLine = size.height * (18.87 / 47);

    // Draw center arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset((size.width / 2), 0), radius: keyWidth / 2),
      0,
      3.14,
      false,
      paint,
    );

    // Draw inner center arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset((size.width / 2), 0), radius: keyWidth / 6),
      0,
      3.14,
      false,
      paint,
    );

    // Left Hash
    canvas.drawLine(
      Offset(0, size.height - (size.height * 28 / 47)),
      Offset(size.width * (3 / 50), size.height - (size.height * (28 / 47))),
      paint,
    );

    // Right Hash
    canvas.drawLine(
      Offset(size.width - size.width * (3 / 50), size.height - (size.height * 28 / 47)),
      Offset(size.width, size.height - (size.height * (28 / 47))),
      paint,
    );

    // Draw baseline
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );

    // Draw key (free throw lane)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset((size.width / 2), size.height - (freeThrowLine / 2)),
        width: keyWidth,
        height: freeThrowLine,
      ),
      paint,
    );

    // Draw outside key
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset((size.width / 2), size.height - (freeThrowLine / 2)),
        width: outerKeyWidth,
        height: freeThrowLine,
      ),
      paint,
    );

    // Draw free throw line arc
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset((size.width / 2), size.height - freeThrowLine), radius: keyWidth / 2),
      3.14,
      3.14,
      false,
      paint,
    );

    // Draw the inner part of the free throw line arc (dashed)
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final arcRect = Rect.fromCircle(
      center: Offset((size.width / 2), size.height - freeThrowLine),
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
          center: Offset((size.width / 2), size.height - (size.height * (4 / 47))),
          radius: restrictedAreaRadius),
      3.14,
      3.14,
      false,
      paint,
    );

    // Draw three-point line with short corners
    // Short Corner (Right)
    canvas.drawLine(
      Offset((size.width / 2) + size.width * (22 / 50), size.height),
      Offset(
          (size.width / 2) + size.width * (22 / 50), size.height - (size.height * (14 / 47))),
      paint,
    );

// Short Corner (Left)
    canvas.drawLine(
      Offset((size.width / 2) - size.width * (22 / 50), size.height),
      Offset(
          (size.width / 2) - size.width * (22 / 50), size.height - (size.height * (14 / 47))),
      paint,
    );

// Above the Break (Arc)
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height - (size.height * (5 / 47))),
          radius: threePointLineRadius),
      -3.14 + (0.123 * 3.14), // Start angle in quadrant 2
      (3.14 - (0.123 * 2 * 3.14)),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
