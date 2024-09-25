import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/player/shot_chart/shot_chart_cache.dart';
import 'package:splash/screens/player/shot_chart/zone/zone_aggregator.dart';
import 'package:splash/screens/player/shot_chart/zone/zone_map.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/court_painter.dart';
import '../../../utilities/player.dart';
import 'hex/hex_aggregator.dart';
import 'hex/hex_map.dart';

class PlayerShotChart extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;

  const PlayerShotChart({super.key, required this.team, required this.player});

  @override
  State<PlayerShotChart> createState() => _PlayerShotChartState();
}

class _PlayerShotChartState extends State<PlayerShotChart> with AutomaticKeepAliveClientMixin {
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
  bool _hasData = true;
  String _displayMap = 'Hex';

  @override
  bool get wantKeepAlive => true;

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

    if (widget.player['STATS'].containsKey(selectedSeason)) {
      setSeasonTypes();
      selectedSeasonType = seasonTypes.first;

      // Fetch the shot chart data and process it
      fetchShotChart(
          widget.player['PERSON_ID'].toString(), selectedSeason, selectedSeasonType);
    } else {
      setState(() {
        _hasData = false;
        _isLoading = false;
      });
    }
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
    filterShotChart();
    processShotChart(filteredShotChart);
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
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    hexagons = generateHexagonGrid(
      hexSizeInFeet: 1.5,
      courtWidthInFeet: 50,
      courtHeightInFeet: 47,
      canvasWidth: isLandscape ? 368.r : 368,
      canvasHeight: isLandscape ? 346.r : 346,
    );

    // Create an instance of the aggregator
    HexagonAggregator aggregator = HexagonAggregator(hexagons[0].width, hexagons[0].height);

    // Aggregate shots by hexagon
    hexagonMap = aggregator.aggregateShots(shotChart, hexagons, isLandscape);

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

    ZoneAggregator zoneAggregator =
        ZoneAggregator(isLandscape ? Size(368.r, 346.r) : const Size(368, 346));
    Map<String, ZoneData> aggregatedZones =
        zoneAggregator.aggregateShots(filteredShotChart, isLandscape);

    // Adjust hexagons based on aggregated data
    zoneAggregator.adjustZones(aggregatedZones, filteredShotChart.length, lgAvg[0]);

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
        } else if (modifiedShotType.contains('Slam Dunk')) {
          modifiedShotType = 'Dunk';
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
              .replaceAll(RegExp(r'\bPullup\b'), 'Pull-Up')
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

    Map<String, dynamic> fgStats = {};

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (_isLoading) {
      return SpinningIcon(color: teamColor);
    }

    if (!_hasData) {
      return Center(
        heightFactor: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_basketball,
              color: Colors.white38,
              size: 38.0.r,
            ),
            SizedBox(height: 15.0.r),
            Text(
              'No Shot Data',
              style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
            ),
          ],
        ),
      );
    } else {
      // Calculate FGM, FGA, and FG%
      fgStats = calculateFGStats(filteredShotChart);
    }

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
                child: LayoutBuilder(builder: (context, constraints) {
                  if (isLandscape) {
                    return Row(
                      children: [
                        SizedBox(width: 50.0.r),
                        Column(
                          children: [
                            Stack(
                              children: [
                                IgnorePointer(
                                  child: CustomPaint(
                                    size: Size(368.r, 346.r),
                                    painter: HalfCourtPainter(),
                                  ),
                                ),
                                if (_displayMap == 'Hex')
                                  HexMap(
                                    hexagons: hexagons,
                                  ),
                                if (_displayMap == 'Zone')
                                  ZoneMap(
                                      shotData: filteredShotChart,
                                      lgAvg: lgAvg[0],
                                      courtSize: Size(368.r, 346.r))
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
                                  icon: _displayMap == 'Hex'
                                      ? const Icon(Icons.hexagon)
                                      : const Icon(Icons.hexagon_outlined),
                                  color: _displayMap == 'Hex' ? Colors.white : Colors.grey,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _displayMap = 'Zone';
                                    });
                                  },
                                  icon: const Icon(Icons.percent),
                                  color: _displayMap == 'Zone' ? Colors.white : Colors.grey,
                                )
                              ],
                            ),
                            SizedBox(height: 6.0.r),
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
                                              color: Colors.white, fontSize: 18.0.r),
                                        );
                                      },
                                    ),
                                    Text(
                                      "FGM",
                                      style: kBebasNormal.copyWith(
                                          color: Colors.white70, fontSize: 12.0.r),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 50.0.r),
                                Column(
                                  children: [
                                    TweenAnimationBuilder<int>(
                                      tween: IntTween(begin: 0, end: fgStats['FGA']),
                                      duration: const Duration(milliseconds: 200),
                                      builder: (context, value, child) {
                                        return Text(
                                          "$value",
                                          style: kBebasNormal.copyWith(
                                              color: Colors.white, fontSize: 18.0.r),
                                        );
                                      },
                                    ),
                                    Text(
                                      "FGA",
                                      style: kBebasNormal.copyWith(
                                          color: Colors.white70, fontSize: 12.0.r),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 50.0.r),
                                Column(
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                          begin: 0, end: double.parse(fgStats['FG%'])),
                                      duration: const Duration(milliseconds: 200),
                                      builder: (context, value, child) {
                                        return Text(
                                          "${value.toStringAsFixed(1)}%",
                                          style: kBebasNormal.copyWith(
                                              color: Colors.white, fontSize: 18.0.r),
                                        );
                                      },
                                    ),
                                    Text(
                                      "FG%",
                                      style: kBebasNormal.copyWith(
                                          color: Colors.white70, fontSize: 12.0.r),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0.r),
                          ],
                        ),
                        SizedBox(width: 50.0.r),
                        Flexible(
                          child: Wrap(
                            children: distinctShotTypes.map((shotType) {
                              bool isSelected = selectedShotTypes.contains(shotType);

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0.r),
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
                                          color: isSelected
                                              ? kTeamColors[widget.team['ABBREVIATION']]![
                                                  'secondaryColor']!
                                              : Colors.grey.shade600,
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
                                    style: kBebasNormal.copyWith(fontSize: 12.0.r),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
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
                            if (_displayMap == 'Zone')
                              ZoneMap(
                                  shotData: filteredShotChart,
                                  lgAvg: lgAvg[0],
                                  courtSize: const Size(368, 346))
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
                              icon: _displayMap == 'Hex'
                                  ? const Icon(Icons.hexagon)
                                  : const Icon(Icons.hexagon_outlined),
                              color: _displayMap == 'Hex' ? Colors.white : Colors.grey,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _displayMap = 'Zone';
                                });
                              },
                              icon: const Icon(Icons.percent),
                              color: _displayMap == 'Zone' ? Colors.white : Colors.grey,
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
                                  style: kBebasNormal.copyWith(
                                      color: Colors.white70, fontSize: 14.0),
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
                                  style: kBebasNormal.copyWith(
                                      color: Colors.white70, fontSize: 14.0),
                                ),
                              ],
                            ),
                            const SizedBox(width: 50.0),
                            Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                      begin: 0, end: double.parse(fgStats['FG%'])),
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
                                  style: kBebasNormal.copyWith(
                                      color: Colors.white70, fontSize: 14.0),
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
                                        color: isSelected
                                            ? kTeamColors[widget.team['ABBREVIATION']]![
                                                'secondaryColor']!
                                            : Colors.grey.shade600,
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
                    );
                  }
                }),
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
                  margin: EdgeInsets.all(11.0.r),
                  child: DropdownButton<String>(
                    padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                    borderRadius: BorderRadius.circular(10.0),
                    menuMaxHeight: 300.0.r,
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
                              style: kBebasNormal.copyWith(fontSize: 17.0.r),
                            ),
                            SizedBox(width: 10.0.r),
                            if (teamId != null)
                              Image.asset(
                                'images/NBA_Logos/$teamId.png',
                                fit: BoxFit.scaleDown,
                                width: 22.0.r,
                                height: 22.0.r,
                                alignment: Alignment.center,
                              )
                            else
                              SizedBox(
                                width: 25.0.r,
                                height: 25.0.r,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedSeason = value!;
                        selectedSeasonType = 'Regular Season';
                        setSeasonTypes();
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
                  margin: EdgeInsets.all(11.0.r),
                  child: DropdownButton<String>(
                    padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                    borderRadius: BorderRadius.circular(10.0),
                    menuMaxHeight: 300.0.r,
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
                              style: kBebasNormal.copyWith(fontSize: 17.0.r),
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
