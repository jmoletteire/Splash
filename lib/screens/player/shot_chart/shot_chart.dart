import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/player/shot_chart/shot_chart_cache.dart';
import 'package:splash/screens/player/shot_chart/zone_map.dart';
import 'package:splash/utilities/constants.dart';

import '../../../utilities/player.dart';
import 'hex_aggregator.dart';
import 'hex_map.dart';

class PlayerShotChart extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;

  const PlayerShotChart({super.key, required this.team, required this.player});

  @override
  State<PlayerShotChart> createState() => _PlayerShotChartState();
}

class _PlayerShotChartState extends State<PlayerShotChart> {
  late List shotChart;
  List filteredShotChart = [];
  List lgAvg = [];
  List<String> distinctShotTypes = [];
  Set<String> selectedShotTypes = {};
  Map<String, String> shotTypeMapping = {};

  Map<String, HexagonData> hexagonMap = {};
  List<HexagonData> hexagons = [];

  late List<String> seasons;
  late List<String> seasonTypes;
  late String selectedSeason;
  late String selectedSeasonType;

  bool _isLoading = true;
  String _displayMap = 'Hex';

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
    // Get distinct SHOT_TYPE values
    distinctShotTypes = collectDistinctShotTypes(shotChart);
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
          color: Colors.transparent,
          borderColor: Colors.transparent,
        ));
      }
    }

    return hexagons;
  }

  List<String> collectDistinctShotTypes(List shotChart) {
    Set<String> shotTypes = {};

    for (var shot in shotChart) {
      if (shot.containsKey('SHOT_TYPE')) {
        String originalShotType = shot['SHOT_TYPE'];
        String modifiedShotType = originalShotType;

        // Apply custom naming rules
        if (modifiedShotType.contains('Tip')) {
          modifiedShotType = 'Tip-In';
        } else if (modifiedShotType.contains('Cutting')) {
          modifiedShotType = 'Cut';
        } else if (modifiedShotType.contains('Putback')) {
          modifiedShotType = 'Putback';
        } else if (modifiedShotType.contains('Floating')) {
          modifiedShotType = 'Floater';
        } else if (modifiedShotType.contains('Turnaround Fadeaway')) {
          modifiedShotType = 'Turnaround Fadeaway Jumper';
        } else if (modifiedShotType.contains('Turnaround')) {
          modifiedShotType = 'Turnaround Jumper';
        } else if (modifiedShotType.contains('Fadeaway')) {
          modifiedShotType = 'Fadeaway Jumper';
        } else if (modifiedShotType.contains('Alley Oop')) {
          modifiedShotType = 'Alley-Oop';
        } else if (modifiedShotType.contains('Reverse Dunk')) {
          modifiedShotType = 'Dunk';
        } else if (modifiedShotType.contains('Reverse Layup')) {
          modifiedShotType = 'Layup';
        } else {
          // Remove specific words and replace "Jump" with "Jumper"
          modifiedShotType = modifiedShotType
              .replaceAll(RegExp(r'\bBank\b'), '')
              .replaceAll(RegExp(r'\bDriving\b'), '')
              .replaceAll(RegExp(r'\bRunning\b'), '')
              .replaceAll(RegExp(r'\bShot\b'), '')
              .replaceAll(RegExp(r'\bshot\b'), '')
              .replaceAll(RegExp(r'\Pullup\b'), 'Pull-Up')
              .replaceAll(RegExp(r'\bJump\b'), 'Jumper')
              .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with a single space
              .trim(); // Remove any leading or trailing whitespace
        }

        if (modifiedShotType.isNotEmpty) {
          shotTypes.add(modifiedShotType);
          shotTypeMapping[originalShotType] = modifiedShotType;
        }
      }
    }

    return shotTypes.toList()..sort();
  }

  void filterShotChart() {
    if (selectedShotTypes.isEmpty) {
      // If no shot types are selected, display all shots
      filteredShotChart = List.from(shotChart);
    } else {
      // Filter shotChart based on selected modified shot types
      filteredShotChart = shotChart.where((shot) {
        String originalShotType = shot['SHOT_TYPE'];
        String? modifiedShotType = shotTypeMapping[originalShotType];
        return modifiedShotType != null && selectedShotTypes.contains(modifiedShotType);
      }).toList();
    }
    processShotChart(filteredShotChart); // Update the hexagon map after filtering
  }

  Map<String, dynamic> calculateFGStats(List shotChart) {
    int fgm = 0;
    int fga = 0;

    if (shotChart.isEmpty) {
      fgm = widget.player['STATS'][selectedSeason][selectedSeasonType.toUpperCase()]['BASIC']
          ['FGM'];
      fga = widget.player['STATS'][selectedSeason][selectedSeasonType.toUpperCase()]['BASIC']
          ['FGA'];
    } else {
      for (var shot in shotChart) {
        fga++;
        if (shot['SHOT_MADE_FLAG'] == 1) {
          fgm++;
        }
      }
    }

    double fgPercentage = fga > 0 ? (fgm / fga) * 100 : 0.0;

    return {
      'FGM': fgm,
      'FGA': fga,
      'FG%': fgPercentage.toStringAsFixed(1), // Limit FG% to one decimal place
    };
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

    // Calculate FGM, FGA, and FG%
    Map<String, dynamic> fgStats = calculateFGStats(filteredShotChart);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 100.0),
            color: Colors.grey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white10,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        IgnorePointer(
                          child: CustomPaint(
                            size: const Size(368, 346),
                            painter: HalfCourtPainter(),
                          ),
                        ),
                        if (_displayMap == 'Hex')
                          HexMap(
                            hexagons: hexagons,
                          ),
                        if (_displayMap == 'Zone') ZoneMap(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _displayMap = 'Hex';
                            });
                          },
                          icon: const Icon(Icons.hexagon_outlined),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _displayMap = 'Zone';
                            });
                          },
                          icon: const Icon(Icons.square),
                        )
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Align center
                      children: [
                        Column(
                          children: [
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: fgStats['FGM']),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, value, child) {
                                return Text(
                                  "$value",
                                  style: kBebasNormal.copyWith(
                                      color: Colors.white, fontSize: 20.0),
                                );
                              },
                            ),
                            Text(
                              "FGM",
                              style:
                                  kBebasNormal.copyWith(color: Colors.white70, fontSize: 14.0),
                            ),
                          ],
                        ),
                        const SizedBox(width: 50.0),
                        Column(
                          children: [
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: fgStats['FGA']),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, value, child) {
                                return Text(
                                  "$value",
                                  style: kBebasNormal.copyWith(
                                      color: Colors.white, fontSize: 20.0),
                                );
                              },
                            ),
                            Text(
                              "FGA",
                              style:
                                  kBebasNormal.copyWith(color: Colors.white70, fontSize: 14.0),
                            ),
                          ],
                        ),
                        const SizedBox(width: 50.0),
                        Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween:
                                  Tween<double>(begin: 0, end: double.parse(fgStats['FG%'])),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, value, child) {
                                return Text(
                                  "${value.toStringAsFixed(1)}%",
                                  style: kBebasNormal.copyWith(
                                      color: Colors.white, fontSize: 20.0),
                                );
                              },
                            ),
                            Text(
                              "FG%",
                              style:
                                  kBebasNormal.copyWith(color: Colors.white70, fontSize: 14.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Wrap(
                      children: distinctShotTypes.map((shotType) {
                        bool isSelected = selectedShotTypes.contains(shotType);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0), // Add some spacing between buttons
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                if (isSelected) {
                                  selectedShotTypes
                                      .remove(shotType); // Deselect if already selected
                                } else {
                                  selectedShotTypes
                                      .add(shotType); // Select if not already selected
                                }
                                filterShotChart(); // Apply filtering after selection
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                isSelected
                                    ? kTeamColors[widget.team['ABBREVIATION']]![
                                        'primaryColor']!
                                    : Colors.grey.shade800,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                    color:
                                        isSelected ? teamSecondaryColor : Colors.grey.shade600,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              foregroundColor: WidgetStateProperty.all(
                                isSelected ? Colors.white : Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              shotType,
                              style: kBebasNormal.copyWith(fontSize: 14.0),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      var teamId = widget.player['STATS'][value]?['REGULAR SEASON']?['BASIC']
                          ?['TEAM_ID'];
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
                        fetchShotChart(widget.player['PERSON_ID'].toString(), selectedSeason,
                            selectedSeasonType);
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
                        fetchShotChart(widget.player['PERSON_ID'].toString(), selectedSeason,
                            selectedSeasonType);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
