import 'package:flutter/material.dart';
import 'package:splash/screens/game/summary/team_season_stats.dart';

import 'game_basic_info.dart';

class GameSummary extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const GameSummary(
      {super.key, required this.game, required this.homeId, required this.awayId});

  @override
  State<GameSummary> createState() => _GameSummaryState();
}

class _GameSummaryState extends State<GameSummary> {
  late Map<String, dynamic> summary;
  late List<dynamic> linescore;
  late Map<String, dynamic> homeLinescore;
  late Map<String, dynamic> awayLinescore;

  @override
  void initState() {
    super.initState();
    summary = widget.game['SUMMARY']['GameSummary'][0];
    linescore = widget.game['SUMMARY']['LineScore'];
    homeLinescore =
        linescore[0]['TEAM_ID'].toString() == widget.homeId ? linescore[0] : linescore[1];
    awayLinescore =
        linescore[0]['TEAM_ID'].toString() == widget.awayId ? linescore[0] : linescore[1];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              GameBasicInfo(game: widget.game),
              TeamSeasonStats(
                season:
                    '${summary['SEASON']}-${(int.parse(summary['SEASON'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                homeId: widget.homeId,
                awayId: widget.awayId,
              )
            ],
          ),
        ),
      ],
    );
  }
}
