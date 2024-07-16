import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../components/animated_polar_chart.dart';
import '../../components/player_stat_card.dart';
import '../../utilities/constants.dart';

class PlayerStats extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerStats({super.key, required this.team, required this.player});

  @override
  State<PlayerStats> createState() => _PlayerStatsState();
}

class _PlayerStatsState extends State<PlayerStats> {
  late List<String> seasons;
  late String selectedSeason;
  late String perMode;
  late String selectedSeasonType;
  List<String> modes = ['TOTAL', 'PER_75'];
  bool _playoffSwitch = false;
  int perModeInitialLabelIndex = 0;

  double getPercentile(List<String> location, String stat) {
    num rank = (location.length == 1
            ? widget.player['STATS'][selectedSeason][selectedSeasonType]
                [location[0]]['${stat}_RANK']
            : widget.player['STATS'][selectedSeason][selectedSeasonType]
                [location[0]][location[1]]['${stat}_RANK']) ??
        0;
    return 1 -
        ((rank - 1) /
            (widget.player['STATS'][selectedSeason][selectedSeasonType]['BASIC']
                    ['NUM_PLAYERS'] -
                1));
  }

  double getFinalPercentile(String group) {
    switch (group) {
      case 'Efficiency':
        double result = (getPercentile(['ADV'], 'OFF_RATING_ON_OFF') +
                getPercentile(['ADV'], 'DEF_RATING_ON_OFF') +
                getPercentile(['ADV'], 'NET_RATING_ON_OFF') +
                getPercentile(['ADV', 'TOUCHES'], 'TOV_PER_TOUCH')) /
            4;
        return result;
      case 'Shooting':
        return getPercentile(['ADV'], 'TS_PCT');
      case 'Defense':
        double result = (getPercentile(['ADV'], 'DEF_RATING_ON_OFF') +
                getPercentile(['BASIC'], 'STL_PER_75') +
                getPercentile(['BASIC'], 'BLK_PER_75') +
                getPercentile(['HUSTLE'], 'DEFLECTIONS_PER_75') +
                getPercentile(['HUSTLE'], 'CONTESTED_SHOTS_PER_75')) /
            5;
        return result;
      case 'Rebounding':
        double result = (getPercentile(['ADV'], 'OREB_PCT') +
                getPercentile(['ADV'], 'DREB_PCT') +
                getPercentile(['HUSTLE'], 'BOX_OUTS_PER_75') +
                getPercentile(['HUSTLE'], 'OFF_BOXOUTS_PER_75') +
                getPercentile(['HUSTLE'], 'DEF_BOXOUTS_PER_75')) /
            5;
        return result;
      case 'Passing':
        double result = (getPercentile(['BASIC'], 'AST_PER_75') +
                getPercentile(['ADV', 'PASSING'], 'AST_ADJ_PER_75') +
                getPercentile(['ADV', 'PASSING'], 'AST_TO_PASS_PCT') +
                getPercentile(['ADV', 'PASSING'], 'AST_TO_PASS_PCT_ADJ') +
                getPercentile(['ADV', 'PASSING'], 'POTENTIAL_AST_PER_75')) /
            5;
        return result;
      case 'Hustle':
        double result = (getPercentile(['ADV'], 'PACE') +
                getPercentile(['HUSTLE'], 'CHARGES_DRAWN') +
                getPercentile(['HUSTLE'], 'SCREEN_ASSISTS_PER_75') +
                getPercentile(['HUSTLE'], 'SCREEN_AST_PTS_PER_75') +
                getPercentile(['HUSTLE'], 'LOOSE_BALLS_RECOVERED_PER_75')) /
            5;
        return result;
      default:
        return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.player.keys.contains('STATS') && widget.player['STATS'].isNotEmpty
        ? seasons = widget.player['STATS'].keys.toList().reversed.toList()
        : seasons = [kCurrentSeason];
    selectedSeason = seasons.first;
    selectedSeasonType = 'REGULAR SEASON';
    perMode = modes[0];
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);
    Color teamSecondaryColor =
        kDarkSecondaryColors.contains(widget.team['ABBREVIATION'])
            ? (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!)
            : (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!);
    return !widget.player.keys.contains('STATS') ||
            !widget.player['STATS'].isNotEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_basketball,
                  color: Colors.white38,
                  size: 40.0,
                ),
                const SizedBox(height: 15.0),
                Text(
                  'No Stats Available',
                  style: kBebasNormal.copyWith(
                      fontSize: 20.0, color: Colors.white54),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Card(
                          margin: const EdgeInsets.all(11.0),
                          color: Colors.grey.shade900,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: TweenAnimationBuilder<num>(
                                        tween: Tween(
                                          begin: 0,
                                          end: perMode == 'PER_75'
                                              ? widget.player['STATS']
                                                          [selectedSeason]
                                                      [selectedSeasonType]
                                                  ['BASIC']['PTS_PER_75']
                                              : (widget.player['STATS']
                                                              [selectedSeason]
                                                          [selectedSeasonType]
                                                      ['BASIC']['PTS'] /
                                                  widget.player['STATS']
                                                              [selectedSeason]
                                                          [selectedSeasonType]
                                                      ['BASIC']['GP']),
                                        ),
                                        duration:
                                            const Duration(milliseconds: 250),
                                        builder: (BuildContext context,
                                            num value, Widget? child) {
                                          return Text(
                                            value.toStringAsFixed(1),
                                            textAlign: TextAlign.center,
                                            style: kBebasNormal.copyWith(
                                                fontSize: 22.0),
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TweenAnimationBuilder<num>(
                                          tween: Tween(
                                            begin: 0,
                                            end: perMode == 'PER_75'
                                                ? widget.player['STATS']
                                                            [selectedSeason]
                                                        [selectedSeasonType]
                                                    ['BASIC']['REB_PER_75']
                                                : (widget.player['STATS']
                                                                [selectedSeason]
                                                            [selectedSeasonType]
                                                        ['BASIC']['REB'] /
                                                    widget.player['STATS']
                                                                [selectedSeason]
                                                            [selectedSeasonType]
                                                        ['BASIC']['GP']),
                                          ),
                                          duration:
                                              const Duration(milliseconds: 250),
                                          builder: (BuildContext context,
                                              num value, Widget? child) {
                                            return Text(
                                              value.toStringAsFixed(1),
                                              textAlign: TextAlign.center,
                                              style: kBebasNormal.copyWith(
                                                  fontSize: 22.0),
                                            );
                                          }),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TweenAnimationBuilder<num>(
                                          tween: Tween(
                                            begin: 0,
                                            end: perMode == 'PER_75'
                                                ? (widget.player['STATS'][selectedSeason]
                                                                [selectedSeasonType]
                                                            ['BASIC']['AST'] /
                                                        widget.player['STATS'][selectedSeason]
                                                                [selectedSeasonType]
                                                            ['ADV']['POSS']) *
                                                    75
                                                : (widget.player['STATS'][selectedSeason]
                                                            [selectedSeasonType]
                                                        ['BASIC']['AST'] /
                                                    widget.player['STATS'][selectedSeason]
                                                        [selectedSeasonType]['BASIC']['GP']),
                                          ),
                                          duration:
                                              const Duration(milliseconds: 250),
                                          builder: (BuildContext context,
                                              num value, Widget? child) {
                                            return Text(
                                              value.toStringAsFixed(1),
                                              textAlign: TextAlign.center,
                                              style: kBebasNormal.copyWith(
                                                  fontSize: 22.0),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'PPG',
                                        textAlign: TextAlign.center,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 15.0,
                                            color: Colors.white70),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'RPG',
                                        textAlign: TextAlign.center,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 15.0,
                                            color: Colors.white70),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'APG',
                                        textAlign: TextAlign.center,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 15.0,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (int.parse(selectedSeason.substring(0, 4)) > 2015)
                          Card(
                            margin: const EdgeInsets.fromLTRB(
                                11.0, 0.0, 11.0, 11.0),
                            color: Colors.grey.shade900,
                            child: Padding(
                              padding: const EdgeInsets.all(75.0),
                              child: AnimatedPolarAreaChart(
                                key: ValueKey(selectedSeason),
                                values: [
                                  getFinalPercentile('Defense'),
                                  getFinalPercentile('Rebounding'),
                                  getFinalPercentile('Passing'),
                                  getFinalPercentile('Hustle'),
                                  getFinalPercentile('Efficiency'),
                                  getFinalPercentile('Shooting'),
                                ],
                                colors: [
                                  teamColor.withOpacity(
                                      getFinalPercentile('Defense')),
                                  teamColor.withOpacity(
                                      getFinalPercentile('Rebounding')),
                                  teamColor.withOpacity(
                                      getFinalPercentile('Passing')),
                                  teamColor.withOpacity(
                                      getFinalPercentile('Hustle')),
                                  teamColor.withOpacity(
                                      getFinalPercentile('Efficiency')),
                                  teamColor.withOpacity(
                                      getFinalPercentile('Shooting')),
                                ],
                                labels: const [
                                  'Defense',
                                  'Rebounding',
                                  'Passing',
                                  'Hustle',
                                  'Efficiency',
                                  'Shooting',
                                ],
                                maxPossibleValue: 1.0,
                              ),
                            ),
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'EFFICIENCY',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'SCORING',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'SHOT TYPE',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'CLOSEST DEFENDER',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'REBOUNDING',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'PASSING',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'DEFENSE',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) > 2015)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'HUSTLE',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                          ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 100),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: kBottomNavigationBarHeight - kToolbarHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade800, width: 0.75),
                      bottom:
                          BorderSide(color: Colors.grey.shade800, width: 0.2),
                    ),
                  ),
                  width: MediaQuery.sizeOf(context).width,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            borderRadius: BorderRadius.circular(10.0),
                            menuMaxHeight: 300.0,
                            dropdownColor: Colors.grey.shade900,
                            isExpanded: false,
                            underline: Container(),
                            value: selectedSeason,
                            items: seasons
                                .map<DropdownMenuItem<String>>((String value) {
                              var teamId = widget.player['STATS'][value]
                                  ?['REGULAR SEASON']?['BASIC']?['TEAM_ID'];
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Text(
                                      value,
                                      style:
                                          kBebasNormal.copyWith(fontSize: 19.0),
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
                                selectedSeasonType = 'REGULAR SEASON';
                              });
                            },
                          )),
                      if (widget.player['STATS'][selectedSeason]
                          .containsKey('PLAYOFFS'))
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              Transform.scale(
                                scale: 0.9,
                                child: Transform.rotate(
                                  angle:
                                      -1.5708, // Rotate 90 degrees counterclockwise
                                  child: CupertinoSwitch(
                                    activeColor: teamColor,
                                    value: _playoffSwitch,
                                    onChanged: (value) {
                                      setState(() {
                                        _playoffSwitch = value;
                                        _playoffSwitch
                                            ? selectedSeasonType = 'PLAYOFFS'
                                            : selectedSeasonType =
                                                'REGULAR SEASON';
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                left: 8, // Adjust based on your switch size
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: Visibility(
                                    visible: _playoffSwitch,
                                    child: SvgPicture.asset(
                                      'images/playoffs.svg',
                                      width: 16.0,
                                      height: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            border: Border.all(color: teamColor),
                            borderRadius: BorderRadius.circular(25.0)),
                        margin: const EdgeInsets.all(11.0),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ToggleSwitch(
                            animate: true,
                            animationDuration: 200,
                            cornerRadius: 20.0,
                            curve: Curves.decelerate,
                            customTextStyles: [
                              kBebasNormal.copyWith(fontSize: 16.0),
                              kBebasNormal.copyWith(fontSize: 16.0),
                            ],
                            customWidths: [
                              (MediaQuery.sizeOf(context).width - 28) / 4.5,
                              (MediaQuery.sizeOf(context).width - 28) / 4.5
                            ],
                            activeBgColor: [Colors.grey.shade800],
                            activeFgColor: teamSecondaryColor,
                            inactiveBgColor: Colors.grey.shade900,
                            initialLabelIndex: perModeInitialLabelIndex,
                            labels: const ['Total', 'Per 75'],
                            totalSwitches: 2,
                            onToggle: (index) {
                              setState(() {
                                perMode = modes[index!];
                                perModeInitialLabelIndex = index;
                              });
                            },
                          ),
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
