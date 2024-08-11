import 'package:flutter/material.dart';

import 'hex_map_painter.dart';

class PlayerShotChart extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;

  const PlayerShotChart({super.key, required this.team, required this.player});

  @override
  State<PlayerShotChart> createState() => _PlayerShotChartState();
}

class _PlayerShotChartState extends State<PlayerShotChart> {
  @override
  Widget build(BuildContext context) {
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
                hexagons: [
                  // Example hexagons, replace with your processed data
                  HexagonData(x: 0, y: 0, size: 10, color: Colors.red),
                  HexagonData(x: 88, y: 239, size: 10, color: Colors.green),
                  HexagonData(x: 131, y: 225, size: 10, color: Colors.blue),
                ],
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

    // Assume the hoop is 40 units in front of the baseline (4 feet)
    final double hoopOffset = (4 / 47) * canvasHeight; // Offset in Flutter canvas units

    final double basketX = canvasWidth / 2;
    final double basketY = canvasHeight - hoopOffset;

    List<HexagonData> mappedHexagons = hexagons.map((hex) {
      // Normalize Python data: (0,0) at the basket
      double normalizedX = hex.x / 250; // Range -1 to 1
      double normalizedY = hex.y / 470; // Range 0 to 1

      // Map to Flutter Canvas, adjusting for (0,0) at the basket with an offset
      double mappedX = basketX + (normalizedX * basketX); // Centered horizontally
      double mappedY = basketY - (normalizedY * canvasHeight); // Bottom to top, adjusted

      return HexagonData(x: mappedX, y: mappedY, size: hex.size, color: hex.color);
    }).toList();

    return CustomPaint(
      size: Size(canvasWidth, canvasHeight),
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
