import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

import 'hex_aggregator.dart';
import 'hex_map_painter.dart';

class HexMap extends StatefulWidget {
  final List<HexagonData> hexagons;

  HexMap({required this.hexagons});

  @override
  _HexMapState createState() => _HexMapState();
}

class _HexMapState extends State<HexMap> {
  Offset? _tooltipPosition;
  String _tooltipMessage = '';
  HexagonData? _selectedHexagon; // Track the selected hexagon

  void _handleTap(BuildContext context, Offset tapPosition) {
    const double canvasWidth = 368;
    const double canvasHeight = 346;
    const double tooltipWidth = 150; // Approximate width of the tooltip
    const double tooltipHeight = 50; // Approximate height of the tooltip

    // Adjust for the court dimensions, similar to how you map the hexagons
    const double hoopOffset = (4 / 47) * canvasHeight;
    const double basketX = canvasWidth / 2;
    const double basketY = canvasHeight - hoopOffset;

    // Map the tap position to the normalized court coordinate space
    double normalizedX = (basketX - tapPosition.dx) / basketX; // Normalize to range -1 to 1
    double normalizedY =
        (basketY - tapPosition.dy) / canvasHeight; // Normalize to range 0 to 1

    Offset normalizedTapPosition = Offset(normalizedX * 250, normalizedY * 470);

    // Now check against the original hexagons before they were mapped
    for (var hex in widget.hexagons) {
      if (hex.contains(normalizedTapPosition)) {
        if (hex.FGA == 0 || hex == _selectedHexagon) {
          _dismissTooltip();
          break;
        }
        setState(() {
          _selectedHexagon = hex; // Set the selected hexagon
          // Determine the tooltip position, adjusting for edges
          double adjustedX = tapPosition.dx + 10; // Default offset to the right
          double adjustedY = tapPosition.dy + 10; // Default offset to the bottom

          // Check if the tooltip would overflow the right edge
          if (adjustedX + tooltipWidth > canvasWidth) {
            adjustedX = tapPosition.dx - tooltipWidth + 30; // Place it to the left
          }

          // Check if the tooltip would overflow the bottom edge
          if (adjustedY + tooltipHeight > canvasHeight - 30) {
            adjustedY = tapPosition.dy - tooltipHeight - 30; // Place it above
          }

          // Set the final tooltip position
          _tooltipPosition = Offset(adjustedX, adjustedY);
          _tooltipMessage =
              'Zone: ${hex.shotZoneRange['Zone']}\nAvg Dist: ${hex.avgDistance.toStringAsFixed(1) ?? 0}\nFG: ${hex.FGM}/${hex.FGA}  (${(100 * hex.FGM / hex.FGA).toStringAsFixed(1)}%)';
        });
        break;
      }
    }
  }

  void _dismissTooltip() {
    setState(() {
      _tooltipPosition = null;
      _selectedHexagon = null; // Clear the selection
    });
  }

  @override
  Widget build(BuildContext context) {
    const double canvasWidth = 368; // 368 pixels
    const double canvasHeight = 346; // 346 pixels

    // Assume the hoop is 4 feet in front of the baseline
    const double hoopOffset = (4 / 47) * canvasHeight; // Offset in Flutter canvas units

    const double basketX = canvasWidth / 2;
    const double basketY = canvasHeight - hoopOffset;

    List<HexagonData> mappedHexagons = widget.hexagons.map((hex) {
      // Normalize Python data: (0,0) at the basket
      double normalizedX = hex.x / 250; // Range -1 to 1
      double normalizedY = hex.y / 470; // Range 0 to 1

      // Map to Flutter Canvas, adjusting for (0,0) at the basket with an offset
      double mappedX = basketX - (normalizedX * basketX); // Centered horizontally
      double mappedY = basketY - (normalizedY * canvasHeight); // Bottom to top, adjusted

      if (hex == _selectedHexagon) {
        // Highlight the selected hexagon by changing its color or opacity
        return HexagonData(
          x: mappedX,
          y: mappedY,
          width: hex.width * 1.2,
          height: hex.height * 1.2,
          color: hex.color,
          borderColor: Colors.white,
          FGA: hex.FGA,
          FGM: hex.FGM,
        );
      } else {
        return HexagonData(
          x: mappedX,
          y: mappedY,
          width: hex.width,
          height: hex.height,
          color: hex.color,
          borderColor: Colors.transparent,
        );
      }
    }).toList();

    return GestureDetector(
      onTap: () {
        _dismissTooltip();
      },
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (TapUpDetails details) {
              _handleTap(context, details.localPosition);
            },
            child: CustomPaint(
              size: const Size(canvasWidth, canvasHeight),
              painter: HexMapPainter(hexagons: mappedHexagons),
            ),
          ),
          if (_tooltipPosition != null)
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
                    _tooltipMessage,
                    style: kBebasNormal.copyWith(fontSize: 15.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
