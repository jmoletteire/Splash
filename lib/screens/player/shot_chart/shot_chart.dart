import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/player/shot_chart/shot_chart_cache.dart';
import 'package:splash/utilities/constants.dart';

import '../../../utilities/player.dart';
import 'hex_aggregator.dart';
import 'hex_map_painter.dart';

class PlayerShotChart extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;

  const PlayerShotChart({super.key, required this.team, required this.player});

  @override
  State<PlayerShotChart> createState() => _PlayerShotChartState();
}

class _PlayerShotChartState extends State<PlayerShotChart> {
  late List shotChart;
  List lgAvg = [];
  Map<String, HexagonData> hexagonMap = {};
  List<HexagonData> hexagons = [];
  late List<String> seasons;
  late List<String> seasonTypes;
  late String selectedSeason;
  late String selectedSeasonType;
  bool _isLoading = true;

  void setSeasonTypes() {
    widget.player['STATS'][selectedSeason].containsKey('PLAYOFFS')
        ? seasonTypes = ['Regular Season', 'Playoffs']
        : seasonTypes = ['Regular Season'];
  }

  @override
  void initState() {
    super.initState();

    widget.player.keys.contains('STATS') && widget.player['STATS'].isNotEmpty
        ? seasons = widget.player['STATS'].keys.toList().reversed.toList()
        : seasons = [kCurrentSeason];
    selectedSeason = seasons.first;

    setSeasonTypes();
    selectedSeasonType = seasonTypes.first;

    // Fetch the shot chart data and process it
    fetchShotChart(widget.player['PERSON_ID'].toString(), selectedSeason, selectedSeasonType);
  }

  Future<void> fetchShotChart(String playerId, String season, String seasonType) async {
    final shotChartCache = Provider.of<PlayerShotChartCache>(context, listen: false);

    if (shotChartCache.containsPlayer(playerId, season, seasonType)) {
      setState(() {
        shotChart = shotChartCache.getPlayer(playerId, season, seasonType)!;
      });
    } else {
      var fetchedPlayerShotChart =
          await Player().getShotChart(playerId, selectedSeason, selectedSeasonType);
      setState(() {
        shotChart = fetchedPlayerShotChart['SEASON'][selectedSeason][selectedSeasonType];
      });
      shotChartCache.addPlayer(playerId, selectedSeason, selectedSeasonType, shotChart);
    }

    await fetchLgAvg(selectedSeason, selectedSeasonType);
    processShotChart(shotChart);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchLgAvg(String season, String seasonType) async {
    final shotChartCache = Provider.of<PlayerShotChartCache>(context, listen: false);
    if (shotChartCache.containsPlayer('0', season, seasonType)) {
      setState(() {
        lgAvg = shotChartCache.getPlayer('0', selectedSeason, selectedSeasonType)!;
      });
    } else {
      var fetchedPlayerShotChart =
          await Player().getShotChart('0', selectedSeason, selectedSeasonType);
      setState(() {
        lgAvg = [fetchedPlayerShotChart['SEASON'][selectedSeason][selectedSeasonType]];
      });
      shotChartCache.addPlayer('0', selectedSeason, selectedSeasonType, lgAvg);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void processShotChart(List shotChart) {
    hexagons = generateHexagonGrid(
      hexSizeInFeet: 1.5,
      courtWidthInFeet: 50,
      courtHeightInFeet: 47,
      canvasWidth: 368,
      canvasHeight: 346,
    );

    // Create an instance of the aggregator
    HexagonAggregator aggregator = HexagonAggregator(hexagons[0].width, hexagons[0].height);

    // Aggregate shots by hexagon
    hexagonMap = aggregator.aggregateShots(shotChart, hexagons);

    // Adjust hexagons based on aggregated data
    aggregator.adjustHexagons(hexagonMap, shotChart.length, lgAvg[0]);

    // Update the hexagons list with data from hexagonMap
    for (int i = 0; i < hexagons.length; i++) {
      String key = '${hexagons[i].x},${hexagons[i].y}';
      if (hexagonMap.containsKey(key)) {
        setState(() {
          hexagons[i] = hexagonMap[key]!;
        });
      }
    }

    // Refresh the UI
    setState(() {
      _isLoading = false;
    });
  }

  List<HexagonData> generateHexagonGrid({
    required double hexSizeInFeet,
    required double courtWidthInFeet,
    required double courtHeightInFeet,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    List<HexagonData> hexagons = [];

    double hexMaxWidth = canvasWidth / courtWidthInFeet;
    double hexMaxHeight = canvasHeight / courtHeightInFeet;
    double hexWidth = hexMaxWidth;
    double hexHeight = hexMaxHeight * sqrt(3) / 1.55;

    int cols = (courtWidthInFeet / (hexSizeInFeet * 2)).ceil();
    int rows = 47;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        double x = (col * hexWidth * 4) + ((row % 2) * (hexWidth * 2));
        double y = row * hexHeight * 1.2;

        double adjustedX = x - canvasWidth / 1.515;
        double adjustedY = canvasHeight - y + (6 * hexMaxHeight * sqrt(3));

        hexagons.add(HexagonData(
            x: adjustedX,
            y: adjustedY,
            width: hexWidth,
            height: hexHeight,
            opacity: 1.0,
            color: Colors.transparent));
      }
    }

    return hexagons;
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);
    Color teamSecondaryColor = kDarkSecondaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!);

    if (_isLoading) {
      return SpinningIcon(color: teamColor);
    }

    return Card(
      margin: const EdgeInsets.all(11.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.white10,
          child: Stack(
            children: [
              HexMap(
                hexagons: hexagons,
              ),
              CustomPaint(
                size: const Size(368, 346),
                painter: HalfCourtPainter(),
              ),
              Positioned(
                bottom: kBottomNavigationBarHeight - kToolbarHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade800, width: 0.75),
                      bottom: BorderSide(color: Colors.grey.shade800, width: 0.2),
                    ),
                  ),
                  width: 368,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            border: Border.all(color: teamColor),
                            borderRadius: BorderRadius.circular(10.0)),
                        margin: const EdgeInsets.all(11.0),
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0,
                          dropdownColor: Colors.grey.shade900,
                          isExpanded: false,
                          underline: Container(),
                          value: selectedSeason,
                          items: seasons.map<DropdownMenuItem<String>>((String value) {
                            var teamId = widget.player['STATS'][value]?['REGULAR SEASON']
                                ?['BASIC']?['TEAM_ID'];
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: kBebasNormal.copyWith(fontSize: 19.0),
                                  ),
                                  const SizedBox(width: 10.0),
                                  if (teamId != null)
                                    Image.asset(
                                      'images/NBA_Logos/$teamId.png',
                                      fit: BoxFit.scaleDown,
                                      width: 25.0,
                                      height: 25.0,
                                      alignment: Alignment.center,
                                    )
                                  else
                                    const SizedBox(
                                      width: 25.0,
                                      height: 25.0,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedSeason = value!;
                              selectedSeasonType = 'Regular Season';
                              fetchShotChart(widget.player['PERSON_ID'].toString(),
                                  selectedSeason, selectedSeasonType);
                            });
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            border: Border.all(color: teamColor),
                            borderRadius: BorderRadius.circular(10.0)),
                        margin: const EdgeInsets.all(11.0),
                        child: DropdownButton<String>(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          borderRadius: BorderRadius.circular(10.0),
                          menuMaxHeight: 300.0,
                          dropdownColor: Colors.grey.shade900,
                          isExpanded: false,
                          underline: Container(),
                          value: selectedSeasonType,
                          items: seasonTypes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: kBebasNormal.copyWith(fontSize: 19.0),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedSeasonType = value!;
                              setSeasonTypes();
                              fetchShotChart(widget.player['PERSON_ID'].toString(),
                                  selectedSeason, selectedSeasonType);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HexMap extends StatelessWidget {
  final List<HexagonData> hexagons;

  HexMap({required this.hexagons});

  @override
  Widget build(BuildContext context) {
    const double canvasWidth = 368; // 368 pixels
    const double canvasHeight = 346; // 346 pixels

    // Assume the hoop is 4 feet in front of the baseline
    const double hoopOffset = (4 / 47) * canvasHeight; // Offset in Flutter canvas units

    const double basketX = canvasWidth / 2;
    const double basketY = canvasHeight - hoopOffset;

    List<HexagonData> mappedHexagons = hexagons.map((hex) {
      // Normalize Python data: (0,0) at the basket
      double normalizedX = hex.x / 250; // Range -1 to 1
      double normalizedY = hex.y / 470; // Range 0 to 1

      // Map to Flutter Canvas, adjusting for (0,0) at the basket with an offset
      double mappedX = basketX + (normalizedX * basketX); // Centered horizontally
      double mappedY = basketY - (normalizedY * canvasHeight); // Bottom to top, adjusted

      return HexagonData(
          x: mappedX,
          y: mappedY,
          width: hex.width,
          height: hex.height,
          opacity: hex.opacity,
          color: hex.color);
    }).toList();

    return CustomPaint(
      size: const Size(canvasWidth, canvasHeight),
      painter: HexMapPainter(hexagons: mappedHexagons),
    );
  }
}

class HalfCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    /// 368 Pixels wide = 50 ft (1 pixel = 0.136 ft OR 1.63 inches)
    /// 346 Pixels tall = 47 ft (1 pixel = 0.136 ft OR 1.63 inches)

    final restrictedAreaRadius = size.width * (4 / 50);
    final threePointLineRadius = size.height * (23.75 / 47);
    final keyWidth = size.width * (12 / 50);
    final outerKeyWidth = size.width * (16 / 50);
    final freeThrowLine = size.height * (18.87 / 47);

    // Draw center arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset((size.width / 2), 0), radius: keyWidth / 2),
      0,
      3.14,
      false,
      paint,
    );

    // Draw baseline
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );

    // Draw key (free throw lane)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset((size.width / 2), size.height - (freeThrowLine / 2)),
        width: keyWidth,
        height: freeThrowLine,
      ),
      paint,
    );

    // Draw outside key
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset((size.width / 2), size.height - (freeThrowLine / 2)),
        width: outerKeyWidth,
        height: freeThrowLine,
      ),
      paint,
    );

    // Draw free throw line arc
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset((size.width / 2), size.height - freeThrowLine), radius: keyWidth / 2),
      3.14,
      3.14,
      false,
      paint,
    );

    // Draw the inner part of the free throw line arc (dashed)
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final arcRect = Rect.fromCircle(
      center: Offset((size.width / 2), size.height - freeThrowLine),
      radius: keyWidth / 2,
    );

    final path = Path();
    const totalAngle = 3.14; // The arc's angle in radians (half-circle in this case)
    const segments = 10; // Increase for smoother dash transitions
    const segmentAngle = totalAngle / segments;
    bool draw = true;

    for (int i = 0; i < segments; i++) {
      final startAngle = segmentAngle * i;
      final endAngle = startAngle + segmentAngle;

      if (draw) {
        path.addArc(arcRect, startAngle, segmentAngle * (dashWidth / (dashWidth + dashSpace)));
      }

      draw = !draw;
    }

    canvas.drawPath(path, paint);

    // Draw restricted area
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset((size.width / 2), size.height - (size.height * (4 / 47))),
          radius: restrictedAreaRadius),
      3.14,
      3.14,
      false,
      paint,
    );

    // Draw three-point line with short corners
    // Short Corner (Right)
    canvas.drawLine(
      Offset((size.width / 2) + size.width * (22 / 50), size.height),
      Offset(
          (size.width / 2) + size.width * (22 / 50), size.height - (size.height * (14 / 47))),
      paint,
    );

// Short Corner (Left)
    canvas.drawLine(
      Offset((size.width / 2) - size.width * (22 / 50), size.height),
      Offset(
          (size.width / 2) - size.width * (22 / 50), size.height - (size.height * (14 / 47))),
      paint,
    );

// Above the Break (Arc)
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height - (size.height * (5 / 47))),
          radius: threePointLineRadius),
      -3.14 + (0.123 * 3.14), // Start angle in quadrant 2
      (3.14 - (0.123 * 2 * 3.14)),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
