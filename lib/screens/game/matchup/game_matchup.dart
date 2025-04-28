import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

import '../boxscore/game_preview/team_records.dart';
import 'components/game_basic_info.dart';
import 'components/head_to_head.dart';
import 'components/inactives.dart';
import 'components/last_five_games.dart';
import 'components/last_meeting.dart';
import 'components/lineups.dart';
import 'components/team_season_stats.dart';

class GameMatchup extends StatefulWidget {
  final Map<String, dynamic> game;
  final Map<String, dynamic> homeTeam;
  final Map<String, dynamic> awayTeam;
  final bool isUpcoming;

  const GameMatchup({
    super.key,
    required this.game,
    required this.homeTeam,
    required this.awayTeam,
    required this.isUpcoming,
  });

  @override
  State<GameMatchup> createState() => _GameMatchupState();
}

class _GameMatchupState extends State<GameMatchup> {
  @override
  void didUpdateWidget(covariant GameMatchup oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.homeTeam != oldWidget.homeTeam || widget.awayTeam != oldWidget.awayTeam) {
      setState(() {
        // This triggers a re-build when the teams change
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(bottom: 50.0.r),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                GameBasicInfo(game: widget.game, isUpcoming: widget.isUpcoming),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game['gameClock'] == 'Pregame'))
                  Lineups(
                    game: widget.game,
                    homeId: kTeamIdToName.containsKey(widget.game['homeTeamId'])
                        ? widget.game['homeTeamId']
                        : '0',
                    awayId: kTeamIdToName.containsKey(widget.game['awayTeamId'])
                        ? widget.game['awayTeamId']
                        : '0',
                  ),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game['gameClock'] == 'Pregame'))
                  Inactives(
                    inactivePlayers: widget.game['matchup']?['inactive'],
                    homeAbbr: widget.homeTeam['ABBREVIATION'] ?? '',
                    awayAbbr: widget.awayTeam['ABBREVIATION'] ?? '',
                  ),
                if (widget.game['matchup'].keys.toList().contains('series') &&
                    widget.game['matchup']['series'].isNotEmpty)
                  H2H(
                    game: widget.game,
                    homeId: kTeamIdToName.containsKey(widget.game['homeTeamId'].toString())
                        ? widget.game['homeTeamId'].toString()
                        : '0',
                    awayId: kTeamIdToName.containsKey(widget.game['awayTeamId'].toString())
                        ? widget.game['awayTeamId'].toString()
                        : '0',
                    homeAbbr: kTeamIdToName[widget.game['homeTeamId'].toString()][1] ?? '',
                    awayAbbr: kTeamIdToName[widget.game['awayTeamId'].toString()][1] ?? '',
                  ),
                if (widget.game['matchup'].containsKey('lastMeeting') &&
                    widget.game['matchup']['lastMeeting']['game_id'] != "")
                  LastMeeting(
                    lastMeeting: widget.game['matchup']?['lastMeeting'] ?? {},
                    homeId: kTeamIdToName.containsKey(widget.game['homeTeamId'])
                        ? widget.game['homeTeamId']
                        : '0',
                    awayId: kTeamIdToName.containsKey(widget.game['awayTeamId'])
                        ? widget.game['awayTeamId']
                        : '0',
                  ),
                LastFiveGames(
                  gameDate: widget.game['date'],
                  homeTeam: widget.homeTeam,
                  awayTeam: widget.awayTeam,
                ),
                TeamRecord(
                  season:
                      '${widget.game['season']}-${(int.parse(widget.game['season'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                  homeId: widget.homeTeam['TEAM_ID'].toString(),
                  awayId: widget.awayTeam['TEAM_ID'].toString(),
                  homeTeam: widget.homeTeam,
                  awayTeam: widget.awayTeam,
                ),
                if (!widget.isUpcoming)
                  TeamSeasonStats(
                    season:
                        '${widget.game['season']}-${(int.parse(widget.game['season'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                    homeId: widget.homeTeam['TEAM_ID'].toString(),
                    awayId: widget.awayTeam['TEAM_ID'].toString(),
                    homeTeam: widget.homeTeam,
                    awayTeam: widget.awayTeam,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
