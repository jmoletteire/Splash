import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splash/screens/player/stats/similar_players.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../components/animated_polar_chart.dart';
import '../../../components/expandable_card_controller.dart';
import '../../../utilities/constants.dart';
import 'player_stat_card.dart';

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
  bool expandAll = true;
  late final ExpandableCardController _controller;

  double getPercentile(List<String> location, String stat) {
    try {
      num rank = (location.length == 1
              ? widget.player['STATS'][selectedSeason][selectedSeasonType][location[0]]
                      ['${stat}_RANK'] ??
                  0
              : widget.player['STATS']?[selectedSeason]?[selectedSeasonType]?[location[0]]
                      ?[location[1]]?['${stat}_RANK'] ??
                  0) ??
          0;
      return 1 -
          ((rank - 1) /
              ((widget.player['STATS']?[selectedSeason]?[selectedSeasonType]?['BASIC']
                          ?['NUM_PLAYERS'] ??
                      501) -
                  1));
    } catch (e) {
      return 0.0;
    }
  }

  double getFinalPercentile(String group) {
    switch (group) {
      case 'Efficiency':
        double result = (getPercentile(['ADV'], 'NET_RATING_ON_OFF') +
                getPercentile(['ADV'], 'PLUS_MINUS_PER_75') +
                getPercentile(['ADV'], 'OFFENSIVE_LOAD') +
                getPercentile(['ADV'], 'ADJ_TOV_PCT')) /
            4;
        result = result > 1
            ? 1
            : result < 0
                ? 0
                : result;
        return result;
      case 'Shooting':
        double result = (getPercentile(['ADV'], 'TS_PCT') +
                getPercentile(['ADV', 'SCORING_BREAKDOWN'], 'PCT_UAST_FGM')) /
            2;
        result = result > 1
            ? 1
            : result < 0
                ? 0
                : result;
        return result;
      case 'Defense':
        double result = (getPercentile(['ADV'], 'DEF_IMPACT_EST') +
                getPercentile(['ADV'], 'MATCHUP_DIFFICULTY') +
                getPercentile(['ADV'], 'VERSATILITY_SCORE')) /
            3;
        result = result > 1
            ? 1
            : result < 0
                ? 0
                : result;
        return result;
      case 'Rebounding':
        double result = (getPercentile(['ADV'], 'OREB_PCT') +
                getPercentile(['ADV'], 'DREB_PCT') +
                getPercentile(['HUSTLE'], 'BOX_OUTS_PER_75') +
                getPercentile(['ADV', 'REBOUNDING'], 'REB_CHANCE_PCT_ADJ')) /
            4;
        result = result > 1
            ? 1
            : result < 0
                ? 0
                : result;
        return result;
      case 'Playmaking':
        double result = (getPercentile(['ADV', 'PASSING'], 'AST_ADJ_PER_75') +
                getPercentile(['ADV', 'PASSING'], 'AST_TO_PASS_PCT_ADJ') +
                getPercentile(['ADV', 'PASSING'], 'POTENTIAL_AST_PER_75') +
                getPercentile(['ADV'], 'BOX_CREATION')) /
            4;
        result = result > 1
            ? 1
            : result < 0
                ? 0
                : result;
        return result;
      case 'Hustle':
        double result = (getPercentile(['HUSTLE', 'SPEED'], 'DIST_MILES_PER_75') +
                getPercentile(['HUSTLE', 'SPEED'], 'AVG_SPEED') +
                getPercentile(['HUSTLE'], 'CHARGES_DRAWN') +
                getPercentile(['HUSTLE'], 'SCREEN_AST_PTS_PER_75') +
                getPercentile(['HUSTLE'], 'LOOSE_BALLS_RECOVERED_PER_75')) /
            5;
        result = result > 1
            ? 1
            : result < 0
                ? 0
                : result;
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
    _controller = ExpandableCardController(true); // Set initial expanded state
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);
    Color teamSecondaryColor = kDarkSecondaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!);
    return !widget.player.keys.contains('STATS') ||
            widget.player['STATS'].isEmpty ||
            (widget.player.keys.contains('STATS') &&
                widget.player['STATS'][selectedSeason][selectedSeasonType]['ADV']
                        ['POSS_PER_GM'] ==
                    0)
        ? Center(
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
                  'No Stats Available',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              CustomScrollView(
                cacheExtent: 5000.0,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
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
                                      child: TweenAnimationBuilder<num>(
                                        tween: Tween(
                                          begin: 0,
                                          end: perMode == 'PER_75'
                                              ? widget.player['STATS'][selectedSeason]
                                                  [selectedSeasonType]['BASIC']['PTS_PER_75']
                                              : ((widget.player['STATS']?[selectedSeason]
                                                              ?[selectedSeasonType]?['BASIC']
                                                          ?['PTS'] ??
                                                      0) /
                                                  (widget.player['STATS']?[selectedSeason]
                                                              ?[selectedSeasonType]?['BASIC']
                                                          ?['GP'] ??
                                                      1)),
                                        ),
                                        duration: const Duration(milliseconds: 250),
                                        builder:
                                            (BuildContext context, num value, Widget? child) {
                                          return Text(
                                            value.toStringAsFixed(1),
                                            textAlign: TextAlign.center,
                                            style: kBebasNormal.copyWith(fontSize: 20.0.r),
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
                                                ? widget.player['STATS'][selectedSeason]
                                                    [selectedSeasonType]['BASIC']['REB_PER_75']
                                                : ((widget.player['STATS']?[selectedSeason]
                                                                ?[selectedSeasonType]?['BASIC']
                                                            ?['REB'] ??
                                                        0) /
                                                    (widget.player['STATS']?[selectedSeason]
                                                                ?[selectedSeasonType]?['BASIC']
                                                            ?['GP'] ??
                                                        1)),
                                          ),
                                          duration: const Duration(milliseconds: 250),
                                          builder: (BuildContext context, num value,
                                              Widget? child) {
                                            return Text(
                                              value.toStringAsFixed(1),
                                              textAlign: TextAlign.center,
                                              style: kBebasNormal.copyWith(fontSize: 20.0.r),
                                            );
                                          }),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TweenAnimationBuilder<num>(
                                          tween: Tween(
                                            begin: 0,
                                            end: perMode == 'PER_75'
                                                ? (widget.player['STATS'][selectedSeason][selectedSeasonType]
                                                            ['BASIC']['AST'] /
                                                        widget.player['STATS'][selectedSeason]
                                                                [selectedSeasonType]['ADV']
                                                            ['POSS']) *
                                                    75
                                                : ((widget.player['STATS']?[selectedSeason]?[selectedSeasonType]
                                                            ?['BASIC']?['AST'] ??
                                                        0) /
                                                    (widget.player['STATS']?[selectedSeason]
                                                            ?[selectedSeasonType]?['BASIC']?['GP'] ??
                                                        1)),
                                          ),
                                          duration: const Duration(milliseconds: 250),
                                          builder: (BuildContext context, num value,
                                              Widget? child) {
                                            return Text(
                                              value.toStringAsFixed(1),
                                              textAlign: TextAlign.center,
                                              style: kBebasNormal.copyWith(fontSize: 20.0.r),
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
                                            fontSize: 13.0.r, color: Colors.white70),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'RPG',
                                        textAlign: TextAlign.center,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 13.0.r, color: Colors.white70),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'APG',
                                        textAlign: TextAlign.center,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 13.0.r, color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.player['STATS'][selectedSeason][selectedSeasonType]
                            .containsKey('SIMILAR_PLAYERS'))
                          SimilarPlayers(
                              players: widget.player['STATS'][selectedSeason]
                                  [selectedSeasonType]['SIMILAR_PLAYERS']),
                        if (int.parse(selectedSeason.substring(0, 4)) > 2015)
                          Card(
                            margin: EdgeInsets.fromLTRB(11.0.r, 0.0, 11.0.r, 11.0.r),
                            color: Colors.grey.shade900,
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 1,
                                  child: IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        constraints: BoxConstraints(
                                            minWidth: MediaQuery.of(context).size.width,
                                            maxHeight:
                                                MediaQuery.of(context).size.height * 0.5),
                                        backgroundColor: Colors.grey.shade900,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(30.0),
                                            child: SingleChildScrollView(
                                              child: Column(children: [
                                                RichText(
                                                  text: const TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'What is this?\n\n',
                                                        style: TextStyle(
                                                            fontFamily: 'Roboto',
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 18.0),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            'Percentages are based on aggregate rank in each category. Players are then assigned a percentile based on their aggregate rank.\n\nFor example, a player at 75% in Defense was better than 75% of players (on average) across that category\'s select stats.\n\nThe following stats are used for each category:',
                                                        style: TextStyle(fontFamily: 'Roboto'),
                                                      ),
                                                      TextSpan(
                                                        text: '\n\n  Efficiency',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '\n   • Net Rating On/Off\n   • +/- per 75\n   • Offensive Load\n   • Creation-Based (Adjusted) Turnover%',
                                                        style: TextStyle(fontFamily: 'Roboto'),
                                                      ),
                                                      TextSpan(
                                                        text: '\n\n  Scoring',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '\n   • True Shooting %\n   • Unassisted %',
                                                        style: TextStyle(fontFamily: 'Roboto'),
                                                      ),
                                                      TextSpan(
                                                        text: '\n\n  Defense',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '\n   • Defensive Impact Estimate\n   • Matchup Difficulty\n   • Versatility Score',
                                                        style: TextStyle(fontFamily: 'Roboto'),
                                                      ),
                                                      TextSpan(
                                                        text: '\n\n  Rebounding',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '\n   • Offensive Rebound %\n   • Defensive Rebound %\n   • Box Outs per 75\n   • Adjusted Rebound Chance %',
                                                        style: TextStyle(fontFamily: 'Roboto'),
                                                      ),
                                                      TextSpan(
                                                        text: '\n\n  Playmaking',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '\n   • Adjusted Assists per 75\n   • Potential Assists per 75\n   • Adjusted Assist-to-Pass %\n   • Box Creation',
                                                        style: TextStyle(fontFamily: 'Roboto'),
                                                      ),
                                                      TextSpan(
                                                        text: '\n\n  Hustle',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '\n   • Distance Covered per 75\n   • Average Speed\n   • Loose Balls Recovered per 75\n   • Screen Assist Points per 75\n   • Charges Drawn',
                                                        style: TextStyle(fontFamily: 'Roboto'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      CupertinoIcons.question_circle,
                                      size: 20.0.r,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(75.0.r),
                                    child: AnimatedPolarAreaChart(
                                      key: ValueKey(selectedSeason),
                                      selectedSeasonType: selectedSeasonType,
                                      values: [
                                        getFinalPercentile('Defense'),
                                        getFinalPercentile('Rebounding'),
                                        getFinalPercentile('Playmaking'),
                                        getFinalPercentile('Hustle'),
                                        getFinalPercentile('Efficiency'),
                                        getFinalPercentile('Shooting'),
                                      ],
                                      colors: [
                                        teamColor.withOpacity(getFinalPercentile('Defense')),
                                        teamColor
                                            .withOpacity(getFinalPercentile('Rebounding')),
                                        teamColor
                                            .withOpacity(getFinalPercentile('Playmaking')),
                                        teamColor.withOpacity(getFinalPercentile('Hustle')),
                                        teamColor
                                            .withOpacity(getFinalPercentile('Efficiency')),
                                        teamColor.withOpacity(getFinalPercentile('Shooting')),
                                      ],
                                      labels: const [
                                        'Defense',
                                        'Rebounding',
                                        'Playmaking',
                                        'Hustle',
                                        'Efficiency',
                                        'Scoring',
                                      ],
                                      maxPossibleValue: 1.0,
                                      chartSize: 200.r,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11.0),
                          child: Row(
                            children: [
                              Text('Expand/Collapse All',
                                  style: kBebasNormal.copyWith(fontSize: 16.0.r)),
                              const SizedBox(width: 10.0),
                              Transform.scale(
                                scale: 0.9,
                                child: CupertinoSwitch(
                                  activeColor: teamColor,
                                  value: _controller.isExpandedNotifier.value,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _controller.isExpandedNotifier.value = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'EFFICIENCY',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'SCORING',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'SHOT TYPE',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'CLOSEST DEFENDER',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'DRIVES',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'REBOUNDING',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'PLAYMAKING',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 1996)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'DEFENSE',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        if (int.parse(selectedSeason.substring(0, 4)) >= 2013)
                          PlayerStatCard(
                            playerStats: widget.player['STATS'][selectedSeason],
                            selectedSeason: selectedSeason,
                            statGroup: 'HUSTLE',
                            perMode: perMode,
                            selectedSeasonType: selectedSeasonType,
                            expandableController: _controller,
                          ),
                        Padding(padding: EdgeInsets.only(bottom: 100.0.r))
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
                                      style: kBebasNormal.copyWith(fontSize: 17.0.r),
                                    ),
                                    const SizedBox(width: 10.0),
                                    if (teamId != null)
                                      Image.asset(
                                        'images/NBA_Logos/$teamId.png',
                                        fit: BoxFit.scaleDown,
                                        width: 25.0.r,
                                        height: 25.0.r,
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
                                selectedSeasonType = 'REGULAR SEASON';
                              });
                            },
                          )),
                      if (widget.player['STATS'][selectedSeason].containsKey('PLAYOFFS'))
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
                                  top: 1,
                                  left: 3,
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
                              kBebasNormal.copyWith(fontSize: 14.0.r),
                              kBebasNormal.copyWith(fontSize: 14.0.r),
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
