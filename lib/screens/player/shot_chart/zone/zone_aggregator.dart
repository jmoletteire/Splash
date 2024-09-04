import 'package:flutter/material.dart';

class ZoneAggregator {
  List<ZoneData> zones;
  Size courtSize;

  ZoneAggregator(this.courtSize) : zones = [] {
    _initializeZones();
  }

  void _initializeZones() {
    final double threePointLineRadius = courtSize.height * (23.75 / 47);

    // AB3 LEFT
    Path aboveBreakThreeLeft = Path();
    aboveBreakThreeLeft.moveTo(0, 0);
    aboveBreakThreeLeft.lineTo(courtSize.width / 3, 0);
    aboveBreakThreeLeft.lineTo(
        courtSize.width / 3, courtSize.height - courtSize.height * (27.25 / 47));
    aboveBreakThreeLeft.arcToPoint(
      Offset(courtSize.width * (3 / 50), courtSize.height - courtSize.height * (14 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: false,
    );
    aboveBreakThreeLeft.lineTo(0, courtSize.height - courtSize.height * (14 / 47));
    zones.add(ZoneData(zoneName: 'AB3 (R)', zonePath: aboveBreakThreeLeft));

    // AB3 RIGHT
    Path aboveBreakThreeRight = Path();
    aboveBreakThreeRight.moveTo(courtSize.width, 0);
    aboveBreakThreeRight.lineTo(courtSize.width - courtSize.width / 3, 0);
    aboveBreakThreeRight.lineTo(courtSize.width - courtSize.width / 3,
        courtSize.height - courtSize.height * (27.25 / 47));
    aboveBreakThreeRight.arcToPoint(
      Offset(courtSize.width - courtSize.width * (3 / 50),
          courtSize.height - courtSize.height * (14 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: true,
    );
    aboveBreakThreeRight.lineTo(
        courtSize.width, courtSize.height - courtSize.height * (14 / 47));
    zones.add(ZoneData(zoneName: 'AB3 (L)', zonePath: aboveBreakThreeRight));

    // AB3 CENTER
    Path aboveBreakThreeCenter = Path();
    aboveBreakThreeCenter.moveTo(courtSize.width / 3, 0);
    aboveBreakThreeCenter.lineTo(courtSize.width - courtSize.width / 3, 0);
    aboveBreakThreeCenter.lineTo(courtSize.width - courtSize.width / 3,
        courtSize.height - courtSize.height * (27.25 / 47));
    aboveBreakThreeCenter.arcToPoint(
      Offset(courtSize.width / 3, courtSize.height - courtSize.height * (27.25 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: false,
    );
    aboveBreakThreeCenter.lineTo(courtSize.width / 3, 0);
    zones.add(ZoneData(zoneName: 'AB3 (C)', zonePath: aboveBreakThreeCenter));

    // C3 LEFT
    Path cornerThreeLeft = Path();
    cornerThreeLeft.addRect(Rect.fromLTWH(
      0,
      courtSize.height - courtSize.height * (14 / 47),
      courtSize.width * (3 / 50),
      courtSize.height * (14 / 47),
    ));
    zones.add(ZoneData(zoneName: 'C3 (R)', zonePath: cornerThreeLeft));

    // C3 RIGHT
    Path cornerThreeRight = Path();
    cornerThreeRight.addRect(Rect.fromLTWH(
      courtSize.width - (courtSize.width * 3 / 50),
      courtSize.height - courtSize.height * (14 / 47),
      courtSize.width * (3 / 50),
      courtSize.height * (14 / 47),
    ));
    zones.add(ZoneData(zoneName: 'C3 (L)', zonePath: cornerThreeRight));

    // LONG MID RANGE LEFT
    Path longMidRangeLeft = Path();
    longMidRangeLeft.moveTo(
        (courtSize.width / 2) - (courtSize.width * 15 / 50), courtSize.height);
    longMidRangeLeft.lineTo(courtSize.width * (3 / 50), courtSize.height);
    longMidRangeLeft.lineTo(
        courtSize.width * (3 / 50), courtSize.height - courtSize.height * (14 / 47));
    longMidRangeLeft.arcToPoint(
      Offset(courtSize.width / 3, courtSize.height - courtSize.height * (27.25 / 47)),
      radius: Radius.circular(threePointLineRadius),
    );
    longMidRangeLeft.lineTo(
        courtSize.width / 3, courtSize.height - courtSize.height * (19.25 / 47));
    longMidRangeLeft.arcToPoint(
      Offset((courtSize.width / 2) - (courtSize.width * 15 / 50), courtSize.height),
      radius: Radius.circular(courtSize.width * (16 / 50)),
      clockwise: false,
    );
    zones.add(ZoneData(zoneName: 'LONG MID RANGE (R)', zonePath: longMidRangeLeft));

    // LONG MID RANGE RIGHT
    Path longMidRangeRight = Path();
    longMidRangeRight.moveTo(
        (courtSize.width / 2) + (courtSize.width * 15 / 50), courtSize.height);
    longMidRangeRight.lineTo(courtSize.width - courtSize.width * (3 / 50), courtSize.height);
    longMidRangeRight.lineTo(courtSize.width - courtSize.width * (3 / 50),
        courtSize.height - courtSize.height * (14 / 47));
    longMidRangeRight.arcToPoint(
      Offset(courtSize.width - courtSize.width / 3,
          courtSize.height - courtSize.height * (27.25 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: false,
    );
    longMidRangeRight.lineTo(courtSize.width - courtSize.width / 3,
        courtSize.height - courtSize.height * (19.25 / 47));
    longMidRangeRight.arcToPoint(
      Offset((courtSize.width / 2) + (courtSize.width * 15 / 50), courtSize.height),
      radius: Radius.circular(courtSize.width * (16 / 50)),
      clockwise: true,
    );
    zones.add(ZoneData(zoneName: 'LONG MID RANGE (L)', zonePath: longMidRangeRight));

    // LONG MID RANGE CENTER
    Path longMidRangeCenter = Path();
    longMidRangeCenter.moveTo(
        courtSize.width / 3, courtSize.height - courtSize.height * (19.25 / 47));
    longMidRangeCenter.arcToPoint(
      Offset(courtSize.width - courtSize.width / 3,
          courtSize.height - courtSize.height * (19.25 / 47)),
      radius: Radius.circular(courtSize.width * (16 / 50)),
      clockwise: true,
    );
    longMidRangeCenter.lineTo(courtSize.width - courtSize.width / 3,
        courtSize.height - courtSize.height * (27.25 / 47));
    longMidRangeCenter.arcToPoint(
      Offset(courtSize.width / 3, courtSize.height - courtSize.height * (27.25 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: false,
    );
    longMidRangeCenter.lineTo(
        courtSize.width / 3, courtSize.height - courtSize.height * (19.25 / 47));
    zones.add(ZoneData(zoneName: 'LONG MID RANGE (C)', zonePath: longMidRangeCenter));

    // SHORT MID RANGE
    Path shortMidRange = Path();
    shortMidRange.moveTo(
        (courtSize.width / 2) - (courtSize.width * 15 / 50), courtSize.height);
    shortMidRange.arcToPoint(
      Offset((courtSize.width / 2) + (courtSize.width * 15 / 50), courtSize.height),
      radius: Radius.circular(courtSize.width * (16 / 50)),
      largeArc: true,
    );
    shortMidRange.lineTo((courtSize.width / 2) + (courtSize.width * 7 / 50), courtSize.height);
    shortMidRange.arcToPoint(
      Offset((courtSize.width / 2) - (courtSize.width * 7 / 50), courtSize.height),
      radius: Radius.circular(courtSize.width * (8 / 50)),
      largeArc: true,
      clockwise: false,
    );
    shortMidRange.lineTo(
        (courtSize.width / 2) - (courtSize.width * 15 / 50), courtSize.height);
    zones.add(ZoneData(zoneName: 'SHORT MID RANGE', zonePath: shortMidRange));

    // RESTRICTED AREA
    Path restrictedArea = Path();
    restrictedArea.moveTo(
        (courtSize.width / 2) - (courtSize.width * 7 / 50), courtSize.height);
    restrictedArea.arcToPoint(
      Offset((courtSize.width / 2) + (courtSize.width * 7 / 50), courtSize.height),
      radius: Radius.circular(courtSize.width * (8 / 50)),
      largeArc: true,
    );
    restrictedArea.lineTo(
        (courtSize.width / 2) - (courtSize.width * 7 / 50), courtSize.height);
    zones.add(ZoneData(zoneName: 'RESTRICTED AREA', zonePath: restrictedArea));
  }

  Offset _normalizeShotCoordinate(double x, double y) {
    const double canvasWidth = 368; // 368 pixels
    const double canvasHeight = 346; // 346 pixels

    // Assume the hoop is 4 feet in front of the baseline
    const double hoopOffset = (4 / 47) * canvasHeight; // Offset in Flutter canvas units

    const double basketX = canvasWidth / 2;
    const double basketY = canvasHeight - hoopOffset;

    // Normalize Python data: (0,0) at the basket
    double normalizedX = x / 250; // Range -1 to 1
    double normalizedY = y / 470; // Range 0 to 1

    // Map to Flutter Canvas, adjusting for (0,0) at the basket with an offset
    double mappedX = basketX - (normalizedX * basketX); // Centered horizontally
    double mappedY = basketY - (normalizedY * canvasHeight); // Bottom to top, adjusted

    return Offset(mappedX, mappedY);
  }

  Map<String, ZoneData> aggregateShots(List shotData) {
    Map<String, ZoneData> zoneMap = {};

    for (var shot in shotData) {
      double x = shot['LOC_X'].toDouble();
      double y = shot['LOC_Y'].toDouble();
      Offset normalizedShot = _normalizeShotCoordinate(x, y);

      for (ZoneData zone in zones) {
        if (zone.contains(normalizedShot)) {
          String key = zone.zoneName;
          if (!zoneMap.containsKey(key)) {
            zoneMap[key] = zone;
          }
          zoneMap[key]!.aggregateShotData(shot);
          break; // Stop checking after finding the first zone that contains the shot
        }
      }
    }

    return zoneMap;
  }

  void adjustZones(
      Map<String, ZoneData> zoneMap, int totalFGA, Map<String, dynamic> leagueAverages) {
    for (var zone in zoneMap.values) {
      if (zone.FGA == 0) {
        zone.color = Colors.transparent; // Or any indicator for zero attempts
      } else {
        double fgPercentage = zone.FGM / zone.FGA;
        double shotTypeAverage = leagueAverages['Zone'][zone.zoneName]['FG_PCT'];
        double percentDiff = fgPercentage - shotTypeAverage;

        // Assign colors based on FG% ranges, similar to hexagons
        if (percentDiff < -0.1) {
          zone.color = const Color(0xFF1060BF);
        } else if (percentDiff >= -0.1 && percentDiff < -0.05) {
          zone.color = const Color(0xFF468FDF);
        } else if (percentDiff >= -0.05 && percentDiff < 0.05) {
          zone.color = const Color(0xFFFFFFFF);
        } else if (percentDiff >= 0.05 && percentDiff < 0.1) {
          zone.color = const Color(0xFFFE441B);
        } else {
          zone.color = const Color(0xFFA0261D);
        }
      }
    }
  }
}

class ZoneData {
  final String zoneName;
  final Path zonePath;
  num FGA = 0;
  num FGM = 0;
  double totalDistance = 0;
  double avgDistance = 0;
  Color color = Colors.transparent;

  ZoneData({
    required this.zoneName,
    required this.zonePath,
  });

  bool contains(Offset point) {
    return zonePath.contains(point);
  }

  void aggregateShotData(Map<String, dynamic> shot) {
    FGA += shot['SHOT_ATTEMPTED_FLAG'];
    FGM += shot['SHOT_MADE_FLAG'];
    totalDistance += shot['DISTANCE'];
    avgDistance = totalDistance / FGA;
  }
}
