import 'dart:math';

import 'package:flutter/material.dart';

class HexagonAggregator {
  final double hexWidth;
  final double hexHeight;

  HexagonAggregator(this.hexWidth, this.hexHeight);

  bool isPointInHexagon(Offset point, List<Offset> vertices) {
    int n = vertices.length;
    bool inside = false;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      if (((vertices[i].dy > point.dy) != (vertices[j].dy > point.dy)) &&
          (point.dx <
              (vertices[j].dx - vertices[i].dx) *
                      (point.dy - vertices[i].dy) /
                      (vertices[j].dy - vertices[i].dy) +
                  vertices[i].dx)) {
        inside = !inside;
      }
    }
    return inside;
  }

  Map<String, HexagonData> aggregateShots(
      List<Map<String, dynamic>> shotData, List<HexagonData> hexagons) {
    Map<String, HexagonData> hexagonMap = {};

    for (var shot in shotData) {
      double x = shot['x'].toDouble();
      double y = shot['y'].toDouble();
      Offset shotPoint = Offset(x, y);

      for (var hexagon in hexagons) {
        if (isPointInHexagon(shotPoint, hexagon.vertices)) {
          String key = '${hexagon.x},${hexagon.y}';
          if (!hexagonMap.containsKey(key)) {
            hexagonMap[key] = hexagon;
          }
          hexagonMap[key]!.FGA += shot['FGA'];
          hexagonMap[key]!.FGM += shot['FGM'];
          break; // Stop checking after finding the first hexagon that contains the shot
        }
      }
    }

    return hexagonMap;
  }

  void adjustHexagons(Map<String, HexagonData> hexagonMap, int totalFGA) {
    for (var hex in hexagonMap.values) {
      double freq = hex.FGA / totalFGA;
      if (freq == 0) {
        hex.width = 0;
        hex.height = 0;
      } else {
        // Set discrete sizes based on FGA thresholds
        if (freq < 0.0025) {
          // Small size
          hex.width *= 0.5; // or any small multiplier
          hex.height *= 0.5;
        } else if (freq >= 0.0025 && freq < 0.01) {
          // Medium size
          hex.width *= 0.75; // or any medium multiplier
          hex.height *= 0.75;
        } else {
          // Large size
          hex.width *= 1.0; // or retain original size
          hex.height *= 1.0;
        }
      }

      double FGPercentage = hex.FGM / hex.FGA;
      // Assign colors based on FG% ranges
      if (FGPercentage < 0.2) {
        hex.color = Colors.blue.shade900; // Dark Blue
      } else if (FGPercentage >= 0.2 && FGPercentage < 0.4) {
        hex.color = Colors.blue.shade300; // Light Blue
      } else if (FGPercentage >= 0.4 && FGPercentage < 0.6) {
        hex.color = Colors.yellow.shade600; // Yellow
      } else if (FGPercentage >= 0.6 && FGPercentage < 0.8) {
        hex.color = Colors.orange.shade600; // Orange
      } else {
        hex.color = Colors.red.shade900; // Dark Red
      }
    }
  }
}

class HexagonData {
  final double x;
  final double y;
  double width;
  double height;
  Color color;
  num FGA;
  num FGM;
  late List<Offset> vertices;

  HexagonData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    this.FGA = 0,
    this.FGM = 0,
  }) {
    vertices = _calculateVertices(x, y, width, height);
  }

  List<Offset> _calculateVertices(
      double centerX, double centerY, double width, double height) {
    List<Offset> points = [];
    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i;
      double x_i = centerX + width * cos(angle);
      double y_i = centerY + height * sin(angle);
      points.add(Offset(x_i, y_i));
    }
    return points;
  }
}
