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

  Map<String, HexagonData> aggregateShots(List shotData, List<HexagonData> hexagons) {
    Map<String, HexagonData> hexagonMap = {};

    for (var shot in shotData) {
      double x = shot['LOC_X'].toDouble();
      double y = shot['LOC_Y'].toDouble();
      Offset shotPoint = Offset(x, y);

      for (var hexagon in hexagons) {
        if (isPointInHexagon(shotPoint, hexagon.vertices)) {
          String key = '${hexagon.x},${hexagon.y}';
          if (!hexagonMap.containsKey(key)) {
            hexagonMap[key] = hexagon;
          }
          hexagonMap[key]!.FGA += shot['SHOT_ATTEMPTED_FLAG'];
          hexagonMap[key]!.FGM += shot['SHOT_MADE_FLAG'];
          break; // Stop checking after finding the first hexagon that contains the shot
        }
      }
    }

    return hexagonMap;
  }

  void adjustHexagons(
      Map<String, HexagonData> hexagonMap, int totalFGA, Map<String, dynamic> leagueAverages) {
    for (var hex in hexagonMap.values) {
      double freq = hex.FGA / totalFGA;
      if (freq == 0) {
        hex.width = 0;
        hex.height = 0;
        //hex.opacity = 0;
      } else {
        // Set discrete sizes based on FGA thresholds
        if (hex.FGA < 2) {
          // Small size
          hex.width *= 0.3; // or any small multiplier
          hex.height *= 0.3;
          //hex.opacity *= 0.33;
        } else if (hex.FGA >= 2 && hex.FGA < 4) {
          // Medium size
          hex.width *= 0.5; // or any medium multiplier
          hex.height *= 0.5;
          //hex.opacity = 0.67;
        } else {
          // Large size
          hex.width *= .88; // or retain original size
          hex.height *= .9;
        }
      }

      double FGPercentage = hex.FGM / hex.FGA;
      double shotTypeAverage =
          leagueAverages[hex.shotZoneRange['Zone']][hex.shotZoneRange['Range']];
      double percentDiff = FGPercentage - shotTypeAverage;

      // Assign colors based on FG% ranges
      if (percentDiff < -0.1) {
        hex.color = const Color(0xFF1060BF);
      } else if (percentDiff >= -0.1 && percentDiff < -0.05) {
        hex.color = const Color(0xFF468FDF);
      } else if (percentDiff >= -0.05 && percentDiff < 0.05) {
        hex.color = const Color(0xFFFFD9C4);
      } else if (percentDiff >= 0.05 && percentDiff < 0.1) {
        hex.color = const Color(0xFFDE441B);
      } else {
        hex.color = const Color(0xFFA0261D);
      }
    }
  }
}

class HexagonData {
  final double x;
  final double y;
  double width;
  double height;
  double opacity;
  Color color;
  Color borderColor;
  num FGA;
  num FGM;
  late Map<String, String> shotZoneRange;
  late List<Offset> vertices;

  HexagonData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.opacity,
    required this.color,
    required this.borderColor,
    this.FGA = 0,
    this.FGM = 0,
  }) {
    shotZoneRange = _shotZoneRange();
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

  bool contains(Offset point) {
    double centerX = x;
    double centerY = y;
    double apothem =
        346 / 47 * sqrt(3); // The distance from the center to the middle of any side

    // Calculate the distance from the point to the center of the hexagon
    double distance = sqrt(pow(point.dx - centerX, 2) + pow(point.dy - centerY, 2));

    // If the distance is less than the apothem, the point is inside the hexagon
    return distance <= apothem;
  }

  Map<String, String> _shotZoneRange() {
    Map<String, String> results = {};

    // Calculate pixels per foot
    double heightPixelsPerFt = (346 / 47) * 2;

    // Convert from pixels to feet
    double xInFeet = x / 10;
    double yInFeet = y / heightPixelsPerFt;

    double shotDistance = sqrt(xInFeet * xInFeet + yInFeet * yInFeet);

    if (shotDistance < 8) {
      results['Zone'] = 'Center(C)';
    } else if (shotDistance > 47) {
      results['Zone'] = 'Back Court(BC)';
    } else if (x <= -150 || (shotDistance < 16 && x >= -150 && x < -50)) {
      results['Zone'] = 'Left Side(L)';
    } else if (shotDistance > 16 && x > -150 && x <= -50) {
      results['Zone'] = 'Left Side Center(LC)';
    } else if (x > -50 && x < 50) {
      results['Zone'] = 'Center(C)';
    } else if (shotDistance > 16 && x >= 50 && x < 150) {
      results['Zone'] = 'Right Side Center(RC)';
    } else if (x >= 150 || (shotDistance < 16 && x >= 50 && x < 150)) {
      results['Zone'] = 'Right Side(R)';
    }

    if (shotDistance < 8) {
      results['Range'] = 'Less Than 8 ft.';
    } else if (shotDistance < 16) {
      results['Range'] = '8-16 ft.';
    } else if (shotDistance < 24) {
      results['Range'] = '16-24 ft.';
    } else if (shotDistance > 24 && shotDistance < 47) {
      results['Range'] = '24+ ft.';
    } else {
      results['Range'] = 'Back Court Shot';
    }

    return results;
  }
}
