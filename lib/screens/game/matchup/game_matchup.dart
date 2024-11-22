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
  late List<dynamic> lineScore;
  late Map<String, dynamic> homeLineScore;
  late Map<String, dynamic> awayLineScore;
  late Inactives inactive;

  @override
  void initState() {
    super.initState();
    summary = widget.game['SUMMARY']['GameSummary'][0];
    lineScore = widget.game['SUMMARY']['LineScore'];
    homeLineScore =
        lineScore[0]['TEAM_ID'].toString() == widget.homeId ? lineScore[0] : lineScore[1];
    awayLineScore =
        lineScore[0]['TEAM_ID'].toString() == widget.homeId ? lineScore[1] : lineScore[0];

    if (!widget.isUpcoming || (widget.isUpcoming && widget.game.containsKey('BOXSCORE'))) {
      inactive = Inactives(
        inactivePlayers: widget.game['SUMMARY']?['InactivePlayers'],
        homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
        awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
        homeAbbr: homeLineScore['TEAM_ABBREVIATION'],
        awayAbbr: awayLineScore['TEAM_ABBREVIATION'],
      );
    }
  }

  @override
  void didUpdateWidget(covariant GameMatchup oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.game['SUMMARY']?['InactivePlayers'] !=
        widget.game['SUMMARY']?['InactivePlayers']) {
      if (!widget.isUpcoming || (widget.isUpcoming && widget.game.containsKey('BOXSCORE'))) {
        inactive = Inactives(
          inactivePlayers: widget.game['SUMMARY']?['InactivePlayers'],
          homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
          awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
          homeAbbr: homeLineScore['TEAM_ABBREVIATION'],
          awayAbbr: awayLineScore['TEAM_ABBREVIATION'],
        );
      }
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
                if (widget.game['SUMMARY'].containsKey('Highlights'))
                  YoutubeHighlights(videoId: widget.game['SUMMARY']['Highlights']),
                GameBasicInfo(
                  game: widget.game,
                  isUpcoming: widget.isUpcoming,
                  homeLineScore: homeLineScore,
                  awayLineScore: awayLineScore,
                ),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game.containsKey('BOXSCORE')))
                  Lineups(
                      game: widget.game,
                      homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                      awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0'),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game.containsKey('BOXSCORE')))
                  inactive,
                if (widget.game['SUMMARY'].keys.toList().contains('SeasonSeries') &&
                    widget.game['SUMMARY']['SeasonSeries'].isNotEmpty)
                  H2H(
                    game: widget.game,
                    homeId: kTeamIdToName.containsKey(widget.homeId) ? widget.homeId : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayId) ? widget.awayId : '0',
                    homeAbbr: homeLineScore['TEAM_ABBREVIATION'],
                    awayAbbr: awayLineScore['TEAM_ABBREVIATION'],
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
