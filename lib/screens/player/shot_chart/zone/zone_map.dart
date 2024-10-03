import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/player/shot_chart/zone/zone_aggregator.dart';
import 'package:splash/utilities/constants.dart';

import '../../../../components/video_player.dart';
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
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    ZoneAggregator aggregator = ZoneAggregator(widget.courtSize);
    Map<String, ZoneData> aggregatedZones =
        aggregator.aggregateShots(widget.shotData, isLandscape);

    double canvasWidth = isLandscape ? 368.r : 368.w;
    double canvasHeight = isLandscape ? 346.r : 346.h;
    double tooltipWidth = isLandscape ? 150.r : 150.w; // Approximate width of the tooltip
    double tooltipHeight = isLandscape ? 50.r : 50.h; // Approximate height of the tooltip

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
          double adjustedX = tapPosition.dx + 10.r; // Default offset to the right
          double adjustedY = tapPosition.dy + 10.r; // Default offset to the bottom

          // Check if the tooltip would overflow the right edge
          if (adjustedX + tooltipWidth > canvasWidth) {
            adjustedX = tapPosition.dx - tooltipWidth + 30.r; // Place it to the left
          }

          // Check if the tooltip would overflow the bottom edge
          if (adjustedY + tooltipHeight > canvasHeight - 100.r) {
            adjustedY = tapPosition.dy - tooltipHeight - 100.r; // Place it above
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
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    ZoneAggregator zones = ZoneAggregator(widget.courtSize);
    Map<String, ZoneData> aggregatedZones = zones.aggregateShots(widget.shotData, isLandscape);
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
                  padding: EdgeInsets.all(8.0.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Zone: ${_selectedZone!.zoneName}\n'
                        'Avg Dist: ${_selectedZone!.avgDistance.toStringAsFixed(1)} ft.\n'
                        'LA: ${(100 * widget.lgAvg['Zone'][_selectedZone!.zoneName]['FG_PCT']).toStringAsFixed(1)}%\n'
                        'FG: ${_selectedZone!.FGM}/${_selectedZone!.FGA} (${(100 * _selectedZone!.FGM / _selectedZone!.FGA).toStringAsFixed(1)}%)',
                        style: kBebasNormal.copyWith(fontSize: 14.0.r),
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            clipBehavior: Clip.hardEdge,
                            constraints:
                                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                            backgroundColor: const Color(0xFF111111),
                            isScrollControlled: isLandscape,
                            showDragHandle: true,
                            builder: (BuildContext context) {
                              final double videoHeight =
                                  MediaQuery.of(context).size.width * 9 / 16;
                              final double playlistHeight = 68.0.r;
                              return SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: videoHeight + playlistHeight,
                                  child: TikTokVideoPlayer(shotChart: _selectedZone!.shots));
                            },
                          );
                        },
                        icon: const Icon(Icons.video_collection),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
