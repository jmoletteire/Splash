import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
  List<dynamic> players = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  void setPlayers() {
    try {
      if (_isLoading == false) _isLoading = true;
      // Convert the map to a list of entries
      var entries = widget.team['seasons'][selectedSeason]['ROSTER'].entries.toList();

      // Sort the entries by minutes per game
      entries.sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) {
        // Ensure that 'MPG' is treated as a double or num for comparison
        double mpgA = (a.value['MPG'] ?? 0 as num).toDouble();
        double mpgB = (b.value['MPG'] ?? 0 as num).toDouble();

        return mpgB.compareTo(mpgA);
      });

      // Extract the sorted keys
      List<dynamic> fetchedPlayers = entries.map((e) => e.key).toList();

      setState(() {
        players = fetchedPlayers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in setPlayers: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    List coaches = widget.team['seasons'][selectedSeason]['COACHES'];
    return _isLoading
        ? Center(
            child: SpinningIcon(
              color: teamColor,
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverPinnedHeader(
                child: Column(
                  children: [
                    Container(
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
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        borderRadius: BorderRadius.circular(10.0),
                        menuMaxHeight: 300.0,
                        dropdownColor: Colors.grey.shade900,
                        isExpanded: true,
                        underline: Container(),
                        value: selectedSeason,
                        items: seasons.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: kBebasOffWhite,
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
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 6.0, 0.0, 6.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF303030),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white30,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Container(
                              color: Colors.transparent,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Player',
                                    style: kBebasOffWhite,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Colors.transparent,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'MIN',
                                    textAlign: TextAlign.start,
                                    style: kBebasOffWhite,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                              playerId: players[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            border: const Border(
                                bottom: BorderSide(color: Colors.white54, width: 0.125))),
                        child: RotationRow(
                          player: widget.team['seasons'][selectedSeason]['ROSTER']
                              [players[index]],
                        ),
                      ),
                    );
                  },
                  childCount: players.length,
                ),
              ),
              SliverPinnedHeader(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 6.0, 0.0, 6.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF303030),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white30,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.transparent,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coaches',
                                    style: kBebasOffWhite,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          border: const Border(
                              bottom: BorderSide(color: Colors.white54, width: 0.125))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 11,
                            child: Row(
                              children: [
                                PlayerAvatar(
                                  radius: 16.0,
                                  backgroundColor: Colors.white12,
                                  playerImageUrl:
                                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${coaches[index]['COACH_ID']}.png',
                                ),
                                const SizedBox(
                                  width: 15.0,
                                ),
                                Text(
                                  coaches[index]['COACH_NAME'],
                                  style: kBebasOffWhite.copyWith(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: AutoSizeText(
                              coaches[index]['COACH_TYPE'],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: kBebasOffWhite.copyWith(fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: coaches.length,
                ),
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
                radius: 16.0,
                backgroundColor: Colors.white12,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PLAYER_ID']}.png',
              ),
              const SizedBox(
                width: 15.0,
              ),
              Flexible(
                child: Text(
                  player['PLAYER'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: kBebasOffWhite.copyWith(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),

        /// Position
        Expanded(
          flex: 1,
          child: Text(
            player['POSITION'],
            textAlign: TextAlign.right,
            style: kBebasNormal.copyWith(fontSize: 17.0),
          ),
        ),
        const SizedBox(width: 5.0),

        /// Horizontal bar percentile (full == 100th, empty == 0th)
        Expanded(
          flex: 4,
          child: LinearPercentIndicator(
            lineHeight: 10.0,
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
                textAlign: TextAlign.center,
                style: kBebasNormal.copyWith(fontSize: 17.0),
              );
            },
          ),
        ),
      ],
    );
  }
}
