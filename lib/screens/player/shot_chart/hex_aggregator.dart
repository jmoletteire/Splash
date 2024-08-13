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
          hexagonMap[key]!.FGA += shot['FGA'] as int;
          hexagonMap[key]!.FGM += shot['FGM'] as int;
          break; // Stop checking after finding the first hexagon that contains the shot
        }
      }
    }

    return hexagonMap;
  }

  void adjustHexagons(Map<String, HexagonData> hexagonMap) {
    int maxFGA = hexagonMap.values.map((hex) => hex.FGA).reduce((a, b) => max(a, b));
    for (var hex in hexagonMap.values) {
      double frequency = hex.FGA / maxFGA;
      hex.width *= frequency;
      hex.height *= frequency;

      double FGPercentage = hex.FGM / hex.FGA;
      hex.color = Color.lerp(Colors.blue, Colors.red, FGPercentage)!;
    }
  }
}

class HexagonData {
  final double x;
  final double y;
  double width;
  double height;
  Color color;
  int FGA;
  int FGM;
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
