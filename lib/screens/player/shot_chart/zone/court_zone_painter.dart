import 'package:flutter/material.dart';
import 'package:splash/screens/player/shot_chart/zone/zone_aggregator.dart';

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
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint when data changes
  }
}
