import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/game/boxscore/game_preview/team_records.dart';
import 'package:splash/screens/game/matchup/components/last_five_games.dart';
import 'package:splash/screens/game/matchup/components/youtube_highlights.dart';
import 'package:splash/utilities/constants.dart';

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
  final bool isUpcoming;
  const GameMatchup({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
    required this.isUpcoming,
  });

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
        linescore[0]['TEAM_ID'].toString() == widget.homeId ? linescore[1] : linescore[0];
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
                if (widget.game['SUMMARY'].containsKey('Highlights'))
                  YoutubeHighlights(videoId: widget.game['SUMMARY']['Highlights']),
                GameBasicInfo(game: widget.game, isUpcoming: widget.isUpcoming),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game.containsKey('BOXSCORE')))
                  Lineups(
                      game: widget.game,
                      homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                      awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0'),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game.containsKey('BOXSCORE')))
                  Inactives(
                    inactivePlayers: widget.game['SUMMARY']?['InactivePlayers'],
                    homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
                    homeAbbr: homeLinescore['TEAM_ABBREVIATION'],
                    awayAbbr: awayLinescore['TEAM_ABBREVIATION'],
                  ),
                if (widget.game['SUMMARY'].keys.toList().contains('SeasonSeries') &&
                    widget.game['SUMMARY']['SeasonSeries'].isNotEmpty)
                  H2H(
                    game: widget.game,
                    homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
                    homeAbbr: homeLinescore['TEAM_ABBREVIATION'],
                    awayAbbr: awayLinescore['TEAM_ABBREVIATION'],
                  ),
                if (widget.game['SUMMARY'].keys.toList().contains('LastMeeting') &&
                    widget.game['SUMMARY']['LastMeeting'].isNotEmpty)
                  LastMeeting(
                    lastMeeting: widget.game['SUMMARY']['LastMeeting'][0],
                    homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
                  ),
                LastFiveGames(
                  gameDate: widget.game['SUMMARY']['GameSummary'][0]['GAME_DATE_EST'],
                  homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                  awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
                ),
                TeamRecord(
                  season:
                      '${widget.game['SUMMARY']['GameSummary'][0]['SEASON']}-${(int.parse(widget.game['SUMMARY']['GameSummary'][0]['SEASON'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                  homeId: widget.homeId,
                  awayId: widget.awayId,
                ),
                if (!widget.isUpcoming)
                  TeamSeasonStats(
                    season:
                        '${summary['SEASON']}-${(int.parse(summary['SEASON'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                    homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
