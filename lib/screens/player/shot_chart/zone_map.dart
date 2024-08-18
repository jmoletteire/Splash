import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

class ZoneMap extends CustomPainter {
  final List<Zone> zones;

  ZoneMap({required this.zones});

  @override
  void paint(Canvas canvas, Size size) {
    Paint zonePaint = Paint()..style = PaintingStyle.fill;

    for (var zone in zones) {
      zonePaint.color = getColorForZone(zone);

      // Draw the path for the zone
      Path path = Path();
      path.moveTo(zone.start.dx, zone.start.dy); // Start point

      for (var line in zone.lines) {
        if (line.isCurve) {
          path.arcToPoint(line.end,
              radius: Radius.circular(line.radius), clockwise: line.clockwise);
        } else {
          path.lineTo(line.end.dx, line.end.dy);
        }
      }

      path.close();
      canvas.drawPath(path, zonePaint);

      // Draw the text overlay
      drawZoneText(canvas, zone, size);
    }
  }

  Color getColorForZone(Zone zone) {
    // Implement color logic based on FG% difference
    double difference = zone.fgPercent - zone.leagueAverage;
    // Use a color gradient based on the difference
    return difference > 5
        ? Colors.red.withOpacity(0.5)
        : difference < -5
            ? Colors.blue.withOpacity(0.5)
            : Colors.orange.withOpacity(0.5);
  }

  void drawZoneText(Canvas canvas, Zone zone, Size size) {
    TextSpan span = TextSpan(
      style: kBebasNormal.copyWith(fontSize: 14.0),
      text: "${zone.fgPercent}%\nLA: ${zone.leagueAverage}%",
    );
    TextPainter tp =
        TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(zone.center.dx - tp.width / 2, zone.center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Zone {
  final Offset start; // Starting point of the path
  final List<LineSegment> lines; // List of line segments (can be straight or curved)
  final double fgPercent;
  final double leagueAverage;
  final double distribution;
  final Offset center; // Center point for text

  Zone({
    required this.start,
    required this.lines,
    required this.fgPercent,
    required this.leagueAverage,
    required this.distribution,
    required this.center,
  });
}

class LineSegment {
  final Offset end; // End point of the line segment
  final bool isCurve; // Whether this segment is a curve
  final double radius; // Radius for the curve
  final bool clockwise; // Direction of the curve

  LineSegment(
      {required this.end, this.isCurve = false, this.radius = 0.0, this.clockwise = true});
}
