import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../components/player_avatar.dart';
import '../../../components/spinning_ball_loading.dart';
import '../../../utilities/constants.dart';
import '../../player/player_home.dart';

class TeamRotation extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamRotation({super.key, required this.team});

  @override
  State<TeamRotation> createState() => _TeamRotationState();
}

class _TeamRotationState extends State<TeamRotation> with AutomaticKeepAliveClientMixin {
  late List<String> seasons;
  late String selectedSeason;
  List<dynamic> starters = []; // Players for the first SliverList (Starters)
  List<dynamic> bench = []; // Players for the second SliverList (Bench)
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  void setPlayers() {
    try {
      if (_isLoading == false) _isLoading = true;

      // Define the custom position hierarchy
      const List<String> positionHierarchy = ['G', 'G-F', 'F-G', 'F', 'F-C', 'C-F', 'C'];

      // Convert the map to a list of entries
      var entries = widget.team['seasons'][selectedSeason]['ROSTER'].entries.toList();

      // Filter out players with GP == 0
      /*
      entries = entries.where((entry) {
        return entry.value['GP'] != 0;
      }).toList();

       */

      // Sort the entries by % Start
      entries.sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) {
        double startPercentA =
            ((a.value['GS'] ?? 0) / (a.value['GP'] ?? 1) ?? 0 as num).toDouble();
        double startPercentB =
            ((b.value['GS'] ?? 0) / (b.value['GP'] ?? 1) ?? 0 as num).toDouble();
        return startPercentB.compareTo(startPercentA);
      });

      // Identify starters (first 5 players) and apply GS < 41 and MPG < 20.0 rule
      List<MapEntry<String, dynamic>> startersEntries = [];
      List<MapEntry<String, dynamic>> benchCandidates = [];

      for (var entry in entries) {
        // Check if player meets the condition for being a starter
        if (startersEntries.length < 5) {
          if (entry.value['GS'] >= 20 &&
              (entry.value['GS'] >= 41 || entry.value['MPG'] >= 20.0)) {
            startersEntries.add(entry);
          } else {
            // If they don't meet the criteria, add them to the benchCandidates list
            benchCandidates.add(entry);
          }
        } else {
          benchCandidates.add(entry); // Remaining players are considered for the bench
        }
      }

      // If we haven't filled all 5 starter spots, take the next players from benchCandidates
      for (var candidate in benchCandidates) {
        if (startersEntries.length < 5) {
          if (candidate.value['GS'] >= 20 &&
              (candidate.value['GS'] >= 41 || candidate.value['MPG'] >= 20.0)) {
            startersEntries.add(candidate);
          }
        }
      }

      // If we still haven't filled all 5 spots, ignore the criteria and just take next players
      while (startersEntries.length < 5) {
        int index = 5 - startersEntries.length - 1;
        startersEntries.add(benchCandidates[index]);
      }

      // Sort the starters by Position and MPG
      startersEntries.sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) {
        String positionA = a.value['POSITION'] ?? '';
        String positionB = b.value['POSITION'] ?? '';

        int positionComparison = positionHierarchy
            .indexOf(positionA)
            .compareTo(positionHierarchy.indexOf(positionB));

        if (positionComparison != 0) {
          return positionComparison; // If positions are different, return comparison result
        } else if (positionComparison == 0) {
          // Convert heights from String format "6-10" to total inches for comparison
          int heightA = convertHeightToInches(a.value['HEIGHT'] ?? '0-0');
          int heightB = convertHeightToInches(b.value['HEIGHT'] ?? '0-0');
          int heightComparison = heightA.compareTo(heightB); // Smaller height comes first
          if (heightComparison != 0) {
            return heightComparison;
          } else if (heightComparison == 0) {
            // Convert weights from String to int for comparison
            int weightA = int.parse(a.value['WEIGHT'] ?? '0');
            int weightB = int.parse(b.value['WEIGHT'] ?? '0');
            int weightComparison = weightA.compareTo(weightB); // Smaller weight comes first
            if (weightComparison != 0) {
              return weightComparison;
            } else {
              double mpgA = (a.value['MPG'] ?? 0 as num).toDouble();
              double mpgB = (b.value['MPG'] ?? 0 as num).toDouble();
              return mpgB.compareTo(mpgA);
            }
          }
        }
        return 0;
      });

      // Sort the remaining players (bench) by MPG
      List<MapEntry<String, dynamic>> benchEntries = benchCandidates;
      benchEntries.sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) {
        double mpgA = (a.value['MPG'] ?? 0 as num).toDouble();
        double mpgB = (b.value['MPG'] ?? 0 as num).toDouble();
        return mpgB.compareTo(mpgA); // Higher MPG comes first
      });

      // Extract the sorted keys for both starters and bench
      List<dynamic> fetchedStarters = startersEntries.map((e) => e.key).toList();
      List<dynamic> fetchedBench = benchEntries.map((e) => e.key).toList();

      setState(() {
        starters = fetchedStarters; // Set the starters for the first SliverList
        bench = fetchedBench; // Set the bench players for the second SliverList
        _isLoading = false;
      });
    } catch (e) {
      print('Error in setPlayers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to convert height from "6-10" to total inches
  int convertHeightToInches(String height) {
    // Split the height string by "-" and parse the feet and inches
    List<String> parts = height.split('-');
    if (parts.length != 2) {
      return 0; // Return 0 if the format is invalid
    }
    int feet = int.tryParse(parts[0]) ?? 0;
    int inches = int.tryParse(parts[1]) ?? 0;
    return (feet * 12) + inches; // Convert feet to inches and add the remaining inches
  }

  @override
  void initState() {
    super.initState();
    seasons = widget.team['seasons'].keys.toList().reversed.toList();
    selectedSeason = seasons.first;
    setPlayers();
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);
    return _isLoading
        ? Center(
            child: SpinningIcon(
              color: teamColor,
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverPinnedHeader(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.04,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.white30,
                        width: 1,
                      ),
                    ),
                  ),
                  child: DropdownButton<String>(
                    padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 5.0.r),
                    borderRadius: BorderRadius.circular(10.0),
                    menuMaxHeight: 300.0.r,
                    dropdownColor: Colors.grey.shade900,
                    isExpanded: true,
                    underline: Container(),
                    value: selectedSeason,
                    items: seasons.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedSeason = value!;
                        setPlayers();
                      });
                    },
                  ),
                ),
              ),
              MultiSliver(
                pushPinnedChildren: true,
                children: [
                  SliverPinnedHeader(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(20.0.r, 6.0.r, 0.0, 6.0.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white30,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(right: 14.0.r),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Starters',
                                          style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'MIN',
                                          style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'GS',
                                          style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerHome(
                                  playerId: starters[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.0.r, vertical: 6.0.r),
                            height: MediaQuery.of(context).size.height * 0.05,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                border: const Border(
                                    bottom: BorderSide(color: Colors.white54, width: 0.125))),
                            child: RotationRow(
                              player: widget.team['seasons'][selectedSeason]['ROSTER']
                                  [starters[index]],
                            ),
                          ),
                        );
                      },
                      childCount: 5,
                    ),
                  ),
                ],
              ),
              MultiSliver(
                pushPinnedChildren: true,
                children: [
                  SliverPinnedHeader(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(20.0.r, 6.0.r, 0.0, 6.0.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFF303030),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white30,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(right: 14.0.r),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bench',
                                          style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'MIN',
                                          style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'GS',
                                          style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerHome(
                                  playerId: bench[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.0.r, vertical: 6.0.r),
                            height: MediaQuery.of(context).size.height * 0.05,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                border: const Border(
                                    bottom: BorderSide(color: Colors.white54, width: 0.125))),
                            child: RotationRow(
                              player: widget.team['seasons'][selectedSeason]['ROSTER']
                                  [bench[index]],
                            ),
                          ),
                        );
                      },
                      childCount: bench.length,
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}

class RotationRow extends StatelessWidget {
  final Map<String, dynamic> player;

  const RotationRow({super.key, required this.player});

  Color getProgressColor(double percentile) {
    if (percentile < 1 / 3) {
      return const Color(0xDFFF3333);
    }
    if (percentile > 2 / 3) {
      return const Color(0xBB00FF6F);
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    num minutesPerGame = player['MPG'] ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          flex: 5,
          child: Row(
            children: [
              PlayerAvatar(
                radius: 14.0.r,
                backgroundColor: Colors.white12,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PLAYER_ID']}.png',
              ),
              SizedBox(
                width: 15.0.r,
              ),
              Flexible(
                child: Text(
                  player['PLAYER'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                ),
              ),
            ],
          ),
        ),

        /// Position
        Expanded(
          flex: 1,
          child: Text(
            player['POSITION'] ?? '-',
            textAlign: TextAlign.right,
            style: kBebasNormal.copyWith(fontSize: 15.0.r),
          ),
        ),
        SizedBox(width: 5.0.r),

        /// Horizontal bar percentile (full == 100th, empty == 0th)
        Expanded(
          flex: 4,
          child: LinearPercentIndicator(
            lineHeight: 9.0.r,
            backgroundColor: const Color(0xFF444444),
            progressColor: getProgressColor(minutesPerGame / 48),
            percent: minutesPerGame / 48,
            barRadius: const Radius.circular(10.0),
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 400,
          ),
        ),

        /// MPG
        Expanded(
          flex: 1,
          child: TweenAnimationBuilder<num>(
            tween: Tween(
              begin: 0,
              end: minutesPerGame,
            ),
            duration: const Duration(milliseconds: 250),
            builder: (BuildContext context, num value, Widget? child) {
              return Text(
                value.toStringAsFixed(1),
                textAlign: TextAlign.end,
                style: kBebasNormal.copyWith(fontSize: 15.0.r),
              );
            },
          ),
        ),

        Expanded(
          flex: 1,
          child: TweenAnimationBuilder<num>(
            tween: Tween(
              begin: 0,
              end: player['GS'],
            ),
            duration: const Duration(milliseconds: 250),
            builder: (BuildContext context, num value, Widget? child) {
              return Text(
                value.toStringAsFixed(0),
                textAlign: TextAlign.end,
                style: kBebasNormal.copyWith(fontSize: 15.0.r),
              );
            },
          ),
        ),
      ],
    );
  }
}
