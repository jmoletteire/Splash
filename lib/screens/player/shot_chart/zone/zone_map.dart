import 'package:flutter/material.dart';
import 'package:splash/screens/player/shot_chart/zone/zone_aggregator.dart';
import 'package:splash/utilities/constants.dart';

import 'court_zone_painter.dart';

class ZoneMap extends StatefulWidget {
  final List shotData;
  final Map<String, dynamic> lgAvg;
  final Size courtSize;

  ZoneMap({required this.shotData, required this.lgAvg, required this.courtSize});

  @override
  _ZoneMapState createState() => _ZoneMapState();
}

class _ZoneMapState extends State<ZoneMap> {
  Offset? _tooltipPosition;
  ZoneData? _selectedZone;

  void _handleTap(BuildContext context, Offset tapPosition) {
    ZoneAggregator aggregator = ZoneAggregator(widget.courtSize);
    Map<String, ZoneData> aggregatedZones = aggregator.aggregateShots(widget.shotData);

    const double canvasWidth = 368;
    const double canvasHeight = 346;
    const double tooltipWidth = 150; // Approximate width of the tooltip
    const double tooltipHeight = 50; // Approximate height of the tooltip

    bool zoneTapped = false;

    for (var zone in aggregatedZones.values) {
      if (zone.contains(tapPosition)) {
        if (zone.zoneName == _selectedZone?.zoneName) {
          _dismissTooltip();
          return;
        }
        setState(() {
          _selectedZone = zone;
          // Determine the tooltip position, adjusting for edges
          double adjustedX = tapPosition.dx + 10; // Default offset to the right
          double adjustedY = tapPosition.dy + 10; // Default offset to the bottom

          // Check if the tooltip would overflow the right edge
          if (adjustedX + tooltipWidth > canvasWidth) {
            adjustedX = tapPosition.dx - tooltipWidth + 30; // Place it to the left
          }

          // Check if the tooltip would overflow the bottom edge
          if (adjustedY + tooltipHeight > canvasHeight - 50) {
            adjustedY = tapPosition.dy - tooltipHeight - 50; // Place it above
          }
          _tooltipPosition = Offset(adjustedX, adjustedY);
        });
        zoneTapped = true;
        break;
      }
    }

    if (!zoneTapped) {
      _dismissTooltip();
    }
  }

  void _dismissTooltip() {
    setState(() {
      _tooltipPosition = null;
      _selectedZone = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ZoneAggregator zones = ZoneAggregator(widget.courtSize);
    Map<String, ZoneData> aggregatedZones = zones.aggregateShots(widget.shotData);
    zones.adjustZones(aggregatedZones, widget.shotData.length, widget.lgAvg);

    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        _handleTap(context, details.localPosition);
      },
      child: Stack(
        children: [
          CustomPaint(
            size: widget.courtSize,
            painter: ZonePainter(
              courtSize: widget.courtSize,
              aggregatedZones: aggregatedZones,
              selectedZoneOffset: _tooltipPosition,
              selectedZone: _selectedZone,
            ),
          ),
          if (_tooltipPosition != null && _selectedZone != null)
            Positioned(
              left: _tooltipPosition!.dx,
              top: _tooltipPosition!.dy,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'Zone: ${_selectedZone!.zoneName}\n'
                    'Avg Dist: ${_selectedZone!.avgDistance.toStringAsFixed(1)} ft.\n'
                    'FG: ${_selectedZone!.FGM}/${_selectedZone!.FGA}\n'
                    'FG%: ${(100 * _selectedZone!.FGM / _selectedZone!.FGA).toStringAsFixed(1)}%',
                    style: kBebasNormal.copyWith(fontSize: 16.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
