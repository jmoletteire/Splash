import 'dart:math';

import 'package:flutter/material.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/utilities/constants.dart';

import '../../../utilities/player.dart';
import 'hex_aggregator.dart';
import 'hex_map_painter.dart';

class PlayerShotChart extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;

  const PlayerShotChart({super.key, required this.team, required this.player});

  @override
  State<PlayerShotChart> createState() => _PlayerShotChartState();
}

class _PlayerShotChartState extends State<PlayerShotChart> {
  late Map<String, dynamic> shotChart;
  Map<String, HexagonData> hexagonMap = {};
  List<HexagonData> hexagons = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch the shot chart data and process it
    fetchShotChart();
  }

  Future<void> fetchShotChart() async {
    setState(() {
      _isLoading = true;
    });
    shotChart =
        await Player().getShotChart(widget.player['PERSON_ID'].toString(), kCurrentSeason);
    processShotChart(shotChart);
  }

  void processShotChart(Map<String, dynamic> shotChart) {
    List<Map<String, dynamic>> playerShotData =
        shotChart['SEASON'][kCurrentSeason]['Shot_Chart_Detail']
            .map<Map<String, dynamic>>((item) => {
                  'x': item['LOC_X'], // x coordinate in your data
                  'y': item['LOC_Y'], // y coordinate in your data
                  'FGA': item['SHOT_ATTEMPTED_FLAG'] == 1 ? 1 : 0,
                  'FGM': item['SHOT_MADE_FLAG'] == 1 ? 1 : 0
                })
            .toList();

    List leagueAverages = shotChart['SEASON'][kCurrentSeason]['LeagueAverages'];

    hexagons = generateHexagonGrid(
      hexSizeInFeet: 1.5,
      courtWidthInFeet: 50,
      courtHeightInFeet: 47,
      canvasWidth: 368,
      canvasHeight: 346,
    );

    // Create an instance of the aggregator
    HexagonAggregator aggregator = HexagonAggregator(hexagons[0].width, hexagons[0].height);

    // Aggregate shots by hexagon
    hexagonMap = aggregator.aggregateShots(playerShotData, hexagons);

    // Adjust hexagons based on aggregated data
    aggregator.adjustHexagons(hexagonMap, playerShotData.length);

    // Update the hexagons list with data from hexagonMap
    for (int i = 0; i < hexagons.length; i++) {
      String key = '${hexagons[i].x},${hexagons[i].y}';
      if (hexagonMap.containsKey(key)) {
        setState(() {
          hexagons[i] = hexagonMap[key]!;
        });
      }
    }

    // Refresh the UI
    setState(() {
      _isLoading = false;
    });
  }

  List<HexagonData> generateHexagonGrid({
    required double hexSizeInFeet,
    required double courtWidthInFeet,
    required double courtHeightInFeet,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    List<HexagonData> hexagons = [];

    double hexMaxWidth = canvasWidth / courtWidthInFeet;
    double hexMaxHeight = canvasHeight / courtHeightInFeet;
    double hexWidth = hexMaxWidth;
    double hexHeight = hexMaxHeight * sqrt(3) / 1.55;

    int cols = (courtWidthInFeet / (hexSizeInFeet * 2)).ceil();
    int rows = 47;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        double x = (col * hexWidth * 4) + ((row % 2) * (hexWidth * 2));
        double y = row * hexHeight * 1.2;

        double adjustedX = x - canvasWidth / 1.515;
        double adjustedY = canvasHeight - y + (6 * hexMaxHeight * sqrt(3));

        hexagons.add(HexagonData(
            x: adjustedX,
            y: adjustedY,
            width: hexWidth,
            height: hexHeight,
            color: Colors.transparent));
      }
    }

    return hexagons;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SpinningIcon();
    }

    return Card(
      margin: const EdgeInsets.all(11.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.white10,
          child: Stack(
            children: [
              HexMap(
                hexagons: hexagons,
              ),
              CustomPaint(
                size: const Size(368, 346),
                painter: HalfCourtPainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HexMap extends StatelessWidget {
  final List<HexagonData> hexagons;

  HexMap({required this.hexagons});

  @override
  Widget build(BuildContext context) {
    const double canvasWidth = 368; // 368 pixels
    const double canvasHeight = 346; // 346 pixels

    // Assume the hoop is 4 feet in front of the baseline
    const double hoopOffset = (4 / 47) * canvasHeight; // Offset in Flutter canvas units

    const double basketX = canvasWidth / 2;
    const double basketY = canvasHeight - hoopOffset;

    List<HexagonData> mappedHexagons = hexagons.map((hex) {
      // Normalize Python data: (0,0) at the basket
      double normalizedX = hex.x / 250; // Range -1 to 1
      double normalizedY = hex.y / 470; // Range 0 to 1

      // Map to Flutter Canvas, adjusting for (0,0) at the basket with an offset
      double mappedX = basketX + (normalizedX * basketX); // Centered horizontally
      double mappedY = basketY - (normalizedY * canvasHeight); // Bottom to top, adjusted

      return HexagonData(
          x: mappedX, y: mappedY, width: hex.width, height: hex.height, color: hex.color);
    }).toList();

    return CustomPaint(
      size: const Size(canvasWidth, canvasHeight),
      painter: HexMapPainter(hexagons: mappedHexagons),
    );
  }
}

class HalfCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
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
