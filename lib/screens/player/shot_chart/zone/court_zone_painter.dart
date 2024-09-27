import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/player/shot_chart/zone/zone_aggregator.dart';
import 'package:splash/utilities/constants.dart';

class ZonePainter extends CustomPainter {
  final ZoneAggregator zoneAggregator;
  final Map<String, ZoneData> aggregatedZones;
  final Offset? selectedZoneOffset; // Track the tap position
  final ZoneData? selectedZone; // Track the selected zone

  ZonePainter({
    required Size courtSize,
    required this.aggregatedZones,
    this.selectedZoneOffset,
    this.selectedZone,
  }) : zoneAggregator = ZoneAggregator(courtSize);

  @override
  void paint(Canvas canvas, Size size) {
    for (var zone in aggregatedZones.values) {
      final zonePaint = Paint()
        ..color = zone.color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.grey.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawPath(zone.zonePath, zonePaint);
      canvas.drawPath(zone.zonePath, borderPaint);

      // Draw FG% in the center of the zone
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '${(100 * zone.FGM / zone.FGA).toStringAsFixed(1)}%', // FG% text
          style: kBebasNormal.copyWith(fontSize: 16.0.sp),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      Offset center = zone.zonePath.getBounds().center;

      // Adjust position or rotation based on zone
      canvas.save();
      if (zone.zoneName == 'C3 (L)' || zone.zoneName == 'C3 (R)') {
        // Move the canvas origin to the center of the text
        canvas.translate(center.dx, center.dy);
        // Rotate the canvas by 90 degrees counterclockwise
        if (zone.zoneName == 'C3 (R)') {
          canvas.rotate(-90 * 3.14159 / 180);
        } else {
          canvas.rotate(90 * 3.14159 / 180);
        }
        // After rotation, adjust position relative to the new origin
        Offset textPosition = Offset(
          -textPainter.width / 2,
          -textPainter.height / 2,
        );
        textPainter.paint(canvas, textPosition);
      } else {
        // Adjust positions for other zones
        if (zone.zoneName == 'LONG MID RANGE (L)' || zone.zoneName == 'LONG MID RANGE (R)') {
          center = center.translate(0, -30);
        } else if (zone.zoneName == 'SHORT MID RANGE') {
          center = center.translate(0, -38);
        } else if (zone.zoneName == 'RESTRICTED AREA') {
          center = center.translate(0, 10);
        }
        Offset textPosition = Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        );
        textPainter.paint(canvas, textPosition);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint when data changes
  }
}
