import 'package:flutter/material.dart';

import 'components/game_basic_info.dart';
import 'components/head_to_head.dart';
import 'components/inactives.dart';
import 'components/last_meeting.dart';
import 'components/lineups.dart';
import 'components/team_season_stats.dart';

class GameMatchup extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const GameMatchup(
      {super.key, required this.game, required this.homeId, required this.awayId});

  @override
  State<GameMatchup> createState() => _GameMatchupState();
}

class _GameMatchupState extends State<GameMatchup> {
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
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 50.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                GameBasicInfo(game: widget.game),
                Lineups(game: widget.game, homeId: widget.homeId, awayId: widget.awayId),
                Inactives(
                    inactivePlayers: widget.game['SUMMARY']['InactivePlayers'],
                    homeId: widget.homeId,
                    awayId: widget.awayId),
                H2H(game: widget.game, homeId: widget.homeId, awayId: widget.awayId),
                LastMeeting(
                    lastMeeting: widget.game['SUMMARY']['LastMeeting'][0],
                    homeId: widget.homeId,
                    awayId: widget.awayId),
                TeamSeasonStats(
                  season:
                      '${summary['SEASON']}-${(int.parse(summary['SEASON'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                  homeId: widget.homeId,
                  awayId: widget.awayId,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
