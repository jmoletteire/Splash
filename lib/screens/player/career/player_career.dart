import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:splash/screens/player/career/career_stats.dart';

import '../../../utilities/constants.dart';

class PlayerCareer extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerCareer({super.key, required this.team, required this.player});

  @override
  State<PlayerCareer> createState() => _PlayerCareerState();
}

class _PlayerCareerState extends State<PlayerCareer> {
  late List seasons;
  late List playoffSeasons;
  late List collegeSeasons;
  late String mode;
  List<String> modes = ['TOTALS', 'PER GAME'];
  final ScrollController _scrollController = ScrollController();
  late LinkedScrollControllerGroup _careerStatsControllers;
  late ScrollController _regSeasonController;
  late ScrollController _playoffController;
  final ScrollController _collegeController = ScrollController();

  @override
  void initState() {
    super.initState();
    mode = 'PER GAME';
    _careerStatsControllers = LinkedScrollControllerGroup();
    _regSeasonController = _careerStatsControllers.addAndGet();
    _playoffController = _careerStatsControllers.addAndGet();

    seasons = [];
    if (widget.player.containsKey('CAREER')) {
      if (widget.player['CAREER'].containsKey('REGULAR SEASON')) {
        if (widget.player['CAREER']['REGULAR SEASON'].containsKey('SEASONS')) {
          if (widget.player['CAREER']['REGULAR SEASON']['SEASONS'].isNotEmpty) {
            seasons = widget.player['CAREER']['REGULAR SEASON']['SEASONS'];
          }
        }
      }
    }

    playoffSeasons = [];
    if (widget.player.containsKey('CAREER')) {
      if (widget.player['CAREER'].containsKey('PLAYOFFS')) {
        if (widget.player['CAREER']['PLAYOFFS'].containsKey('SEASONS')) {
          if (widget.player['CAREER']['PLAYOFFS']['SEASONS'].isNotEmpty) {
            playoffSeasons = widget.player['CAREER']['PLAYOFFS']['SEASONS'];
          }
        }
      }
    }

    collegeSeasons = [];
    if (widget.player.containsKey('CAREER')) {
      if (widget.player['CAREER'].containsKey('COLLEGE')) {
        if (widget.player['CAREER']['COLLEGE'].containsKey('SEASONS')) {
          if (widget.player['CAREER']['COLLEGE']['SEASONS'].isNotEmpty) {
            collegeSeasons = widget.player['CAREER']['COLLEGE']['SEASONS'];
          }
        }
      }
    }

    _scrollController.addListener(() {
      if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {}
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.player.keys.contains('CAREER') ||
            widget.player['CAREER'].isEmpty ||
            (seasons.isEmpty && playoffSeasons.isEmpty && collegeSeasons.isEmpty)
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
                    value: mode,
                    items: modes.map<DropdownMenuItem<String>>((String value) {
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
                        mode = value!;
                      });
                    },
                  ),
                ),
              ),
              if (seasons.isNotEmpty)
                MultiSliver(
                  pushPinnedChildren: false,
                  children: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Regular Season',
                          style: kBebasNormal.copyWith(fontSize: 12.0.r),
                        ),
                      ),
                    ),
                    CareerStats(
                      player: widget.player,
                      seasons: seasons,
                      seasonType: 'REGULAR SEASON',
                      mode: mode,
                      controller: _regSeasonController,
                    ),
                  ],
                ),
              if (playoffSeasons.isNotEmpty)
                MultiSliver(
                  children: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Playoffs',
                          style: kBebasNormal.copyWith(fontSize: 12.0.r),
                        ),
                      ),
                    ),
                    CareerStats(
                      player: widget.player,
                      seasons: playoffSeasons,
                      seasonType: 'PLAYOFFS',
                      mode: mode,
                      controller: _playoffController,
                    ),
                  ],
                ),
              if (collegeSeasons.isNotEmpty)
                MultiSliver(
                  children: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'College',
                          style: kBebasNormal.copyWith(fontSize: 12.0.r),
                        ),
                      ),
                    ),
                    CareerStats(
                      player: widget.player,
                      seasons: collegeSeasons,
                      seasonType: 'COLLEGE',
                      mode: mode,
                      controller: _collegeController,
                    ),
                  ],
                ),
            ],
          );
  }
}
