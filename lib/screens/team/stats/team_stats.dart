import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splash/utilities/constants.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../components/animated_polar_chart.dart';
import 'team_stat_card.dart';

class TeamStats extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamStats({super.key, required this.team});

  @override
  State<TeamStats> createState() => _TeamStatsState();
}

class _TeamStatsState extends State<TeamStats> {
  late List<String> seasons;
  late String selectedSeason;
  late String selectedSeasonType;
  late String perMode;
  List<String> modes = ['TOTAL', 'PER_100'];
  int initialLabelIndex = 0;
  bool _playoffSwitch = false;

  String getStanding(int confRank) {
    switch (confRank) {
      case 0:
        return '';
      case 1:
        return '${confRank}st';
      case 2:
        return '${confRank}nd';
      case 3:
        return '${confRank}rd';
      case 21:
        return '${confRank}st';
      case 22:
        return '${confRank}nd';
      case 23:
        return '${confRank}rd';
      default:
        return '${confRank}th';
    }
  }

  String getPlayoffs(dynamic teamSeason) {
    if (!teamSeason.containsKey('CONF_RANK') || teamSeason['CONF_RANK'] == 0) {
      return '-';
    }

    if (int.parse(selectedSeason.substring(0, 4)) > 2019) {
      if (teamSeason['CONF_RANK'] > 10) {
        return 'Missed Playoffs';
      } else if (teamSeason['PO_WINS'] < 4) {
        return 'Lost 1st Round';
      } else if (teamSeason['PO_WINS'] < 8) {
        return 'Lost Conf Semis';
      } else if (teamSeason['PO_WINS'] < 12) {
        return 'Lost Conf Finals';
      } else if (teamSeason['PO_WINS'] < 16) {
        return 'Lost NBA Finals';
      } else if (teamSeason['PO_WINS'] == 16) {
        return 'Won NBA Finals';
      } else {
        return '-';
      }
    } else {
      if (teamSeason['CONF_RANK'] > 8) {
        return 'Missed Playoffs';
      } else if (teamSeason['PO_WINS'] < 3) {
        return 'Lost 1st Round';
      } else if (teamSeason['PO_WINS'] < 7) {
        return 'Lost Conf Semis';
      } else if (teamSeason['PO_WINS'] < 11) {
        return 'Lost Conf Finals';
      } else if (teamSeason['PO_WINS'] < 15) {
        return 'Lost NBA Finals';
      } else if (teamSeason['PO_WINS'] == 15) {
        return 'Won NBA Finals';
      }
    }
    return '-';
  }

  double getPercentile(String location, String stat) {
    if (widget.team['seasons'][selectedSeason]['STATS'].containsKey(selectedSeasonType)) {
      if (widget.team['seasons'][selectedSeason]['STATS'][selectedSeasonType]
          .containsKey(location)) {
        if (widget.team['seasons'][selectedSeason]['STATS'][selectedSeasonType][location]
                .containsKey('${stat}_RANK') &&
            widget.team['seasons'][selectedSeason]['STATS'][selectedSeasonType]['BASIC']
                .containsKey('LEAGUE_TEAMS')) {
          return 1 -
              ((widget.team['seasons'][selectedSeason]['STATS'][selectedSeasonType][location]
                          ['${stat}_RANK'] -
                      1) /
                  (widget.team['seasons'][selectedSeason]['STATS'][selectedSeasonType]['BASIC']
                          ['LEAGUE_TEAMS'] -
                      1)) as double;
        } else {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    } else {
      return 0.0;
    }
  }

  double getFinalPercentile(String group) {
    switch (group) {
      case 'Efficiency':
        double result = getPercentile('ADV', 'OFF_RATING');
        return result;
      case 'Shooting':
        double result = (getPercentile('BASIC', 'FG_PCT') +
                getPercentile('BASIC', 'FT_PCT') +
                getPercentile('BASIC', 'FG3_PCT') +
                getPercentile('ADV', 'EFG_PCT') +
                getPercentile('ADV', 'TS_PCT')) /
            5;
        return result;
      case 'Defense':
        double result = (getPercentile('ADV', 'DEF_RATING') +
                getPercentile('BASIC', 'STL_PER_100') +
                getPercentile('BASIC', 'BLK_PER_100') +
                getPercentile('HUSTLE', 'DEFLECTIONS_PER_100') +
                getPercentile('HUSTLE', 'CONTESTED_SHOTS_PER_100')) /
            5;
        return result;
      case 'Rebounding':
        double result = (getPercentile('ADV', 'OREB_PCT') +
                getPercentile('ADV', 'DREB_PCT') +
                getPercentile('HUSTLE', 'BOX_OUTS_PER_100')) /
            3;
        return result;
      case 'Hustle':
        double result = (getPercentile('ADV', 'PACE') +
                getPercentile('HUSTLE', 'SCREEN_ASSISTS_PER_100') +
                getPercentile('HUSTLE', 'SCREEN_AST_PTS_PER_100') +
                getPercentile('HUSTLE', 'LOOSE_BALLS_RECOVERED_PER_100')) /
            5;
        return result;
      default:
        return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    seasons = widget.team['seasons'].keys.toList().reversed.toList();
    seasons = seasons.where((e) => int.parse(e.substring(0, 4)) >= 1996).toList();
    selectedSeason = seasons.first;
    selectedSeasonType = 'REGULAR SEASON';
    perMode = 'TOTAL';
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);
    Color teamSecondaryColor = kDarkSecondaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.all(11.0.r),
                color: Colors.grey.shade900,
                child: Padding(
                  padding: EdgeInsets.all(15.0.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${(widget.team['seasons'][selectedSeason]['WINS'] ?? 0).toString()}-${(widget.team['seasons'][selectedSeason]['LOSSES'] ?? 0).toString()} (${(widget.team['seasons'][selectedSeason]['WIN_PCT'] ?? 0).toStringAsFixed(3)})',
                              textAlign: TextAlign.center,
                              style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${getStanding(widget.team['seasons']?[selectedSeason]?['STANDINGS']?['PlayoffRank'] ?? 0)} ${widget.team['seasons']?[selectedSeason]?['STANDINGS']?['Conference'] ?? widget.team['CONF'].substring(0, 4)}',
                              textAlign: TextAlign.center,
                              style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              getPlayoffs(widget.team['seasons'][selectedSeason]!),
                              textAlign: TextAlign.center,
                              style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'RECORD',
                              textAlign: TextAlign.center,
                              style: kBebasNormal.copyWith(
                                  fontSize: 14.0.r, color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'CONF',
                              textAlign: TextAlign.center,
                              style: kBebasNormal.copyWith(
                                  fontSize: 14.0.r, color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'PLAYOFFS',
                              textAlign: TextAlign.center,
                              style: kBebasNormal.copyWith(
                                  fontSize: 14.0.r, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (seasons.indexOf(selectedSeason) < 8)
                Card(
                  margin: EdgeInsets.fromLTRB(11.0.r, 0.0.r, 11.0.r, 11.0.r),
                  color: Colors.grey.shade900,
                  child: Padding(
                    padding: EdgeInsets.all(60.0.r),
                    child: AnimatedPolarAreaChart(
                      key: ValueKey(selectedSeason),
                      selectedSeasonType: selectedSeasonType,
                      values: [
                        getFinalPercentile('Defense'),
                        getFinalPercentile('Rebounding'),
                        getFinalPercentile('Hustle'),
                        getFinalPercentile('Efficiency'),
                        getFinalPercentile('Shooting'),
                      ],
                      colors: [
                        teamColor.withOpacity(getFinalPercentile('Defense')),
                        teamColor.withOpacity(getFinalPercentile('Rebounding')),
                        teamColor.withOpacity(getFinalPercentile('Hustle')),
                        teamColor.withOpacity(getFinalPercentile('Efficiency')),
                        teamColor.withOpacity(getFinalPercentile('Shooting')),
                      ],
                      labels: const [
                        'Defense',
                        'Rebounding',
                        'Hustle',
                        'Efficiency',
                        'Shooting',
                      ],
                      maxPossibleValue: 1.0,
                      chartSize: 200.r,
                    ),
                  ),
                ),
              if (seasons.indexOf(selectedSeason) < 28)
                TeamStatCard(
                  teamStats: widget.team['seasons'][selectedSeason]['STATS'],
                  selectedSeason: selectedSeason,
                  selectedSeasonType: selectedSeasonType,
                  statGroup: 'EFFICIENCY',
                  perMode: perMode,
                ),
              if (seasons.indexOf(selectedSeason) < 28)
                TeamStatCard(
                  teamStats: widget.team['seasons'][selectedSeason]['STATS'],
                  selectedSeason: selectedSeason,
                  selectedSeasonType: selectedSeasonType,
                  statGroup: 'SCORING',
                  perMode: perMode,
                ),
              if (seasons.indexOf(selectedSeason) < 28)
                TeamStatCard(
                  teamStats: widget.team['seasons'][selectedSeason]['STATS'],
                  selectedSeason: selectedSeason,
                  selectedSeasonType: selectedSeasonType,
                  statGroup: 'REBOUNDING',
                  perMode: perMode,
                ),
              if (seasons.indexOf(selectedSeason) < 28)
                TeamStatCard(
                  teamStats: widget.team['seasons'][selectedSeason]['STATS'],
                  selectedSeason: selectedSeason,
                  selectedSeasonType: selectedSeasonType,
                  statGroup: 'DEFENSE',
                  perMode: perMode,
                ),
              if (seasons.indexOf(selectedSeason) < 8)
                TeamStatCard(
                  teamStats: widget.team['seasons'][selectedSeason]['STATS'],
                  selectedSeason: selectedSeason,
                  selectedSeasonType: selectedSeasonType,
                  statGroup: 'HUSTLE',
                  perMode: perMode,
                ),
              Padding(
                padding: EdgeInsets.only(bottom: 100.r),
              ),
            ],
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
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: kBebasNormal.copyWith(fontSize: 17.0.r),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedSeason = value!;
                        selectedSeasonType = 'REGULAR SEASON';
                      });
                    },
                  ),
                ),

                /// NOTE: Mistake in data. All teams have PLAYOFFS key, but
                /// not PLAYOFFS.ADV, which is why it is used instead.
                if (widget.team['seasons'][selectedSeason]['STATS'].containsKey('PLAYOFFS'))
                  if (widget.team['seasons'][selectedSeason]['STATS']['PLAYOFFS']
                      .containsKey('ADV'))
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          Transform.scale(
                            scale: 0.9,
                            child: Transform.rotate(
                              angle: -1.5708, // Rotate 90 degrees counterclockwise
                              child: CupertinoSwitch(
                                activeColor: teamColor,
                                value: _playoffSwitch,
                                onChanged: (value) {
                                  setState(() {
                                    _playoffSwitch = value;
                                    _playoffSwitch
                                        ? selectedSeasonType = 'PLAYOFFS'
                                        : selectedSeasonType = 'REGULAR SEASON';
                                  });
                                },
                              ),
                            ),
                          ),
                          if (MediaQuery.of(context).orientation == Orientation.landscape)
                            Positioned(
                              top: 1,
                              left: 22,
                              width: 16,
                              height: 16, // Adjust based on your switch size
                              child: IgnorePointer(
                                ignoring: true,
                                child: Visibility(
                                  visible: _playoffSwitch,
                                  child: SvgPicture.asset('images/playoffs.svg'),
                                ),
                              ),
                            ),
                          if (MediaQuery.of(context).orientation == Orientation.portrait)
                            Positioned(
                              top: 2.r,
                              left: 8.r,
                              width: 16.r,
                              height: 16.r, // Adjust based on your switch size
                              child: IgnorePointer(
                                ignoring: true,
                                child: Visibility(
                                  visible: _playoffSwitch,
                                  child: SvgPicture.asset('images/playoffs.svg'),
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
                      initialLabelIndex: initialLabelIndex,
                      totalSwitches: 2,
                      labels: const ['Total', 'Per 100'],
                      animate: true,
                      animationDuration: 200,
                      curve: Curves.decelerate,
                      cornerRadius: 20.0,
                      customWidths: [
                        (MediaQuery.sizeOf(context).width - 28) / 4,
                        (MediaQuery.sizeOf(context).width - 28) / 4
                      ],
                      activeBgColor: [Colors.grey.shade800],
                      activeFgColor: teamSecondaryColor,
                      inactiveBgColor: Colors.grey.shade900,
                      customTextStyles: [
                        kBebasNormal.copyWith(fontSize: 14.0.r),
                        kBebasNormal.copyWith(fontSize: 14.0.r)
                      ],
                      onToggle: (index) {
                        setState(() {
                          perMode = modes[index!];
                          initialLabelIndex = index;
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
