import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/game/boxscore/game_preview/team_records.dart';
import 'package:splash/screens/game/matchup/components/last_five_games.dart';
import 'package:splash/utilities/constants.dart';

import 'components/game_basic_info.dart';
import 'components/head_to_head.dart';
import 'components/inactives.dart';
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
  late Inactives inactive;

  @override
  void initState() {
    super.initState();

    if (!widget.isUpcoming || (widget.isUpcoming && widget.game['gameClock'] == 'Pregame')) {
      inactive = Inactives(
        inactivePlayers: widget.game['matchup']?['inactive'],
        homeAbbr: widget.homeTeam['ABBREVIATION'] ?? '',
        awayAbbr: widget.awayTeam['ABBREVIATION'] ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant GameMatchup oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.game['matchup']?['inactive'] != widget.game['matchup']?['inactive']) {
      if (!widget.isUpcoming || (widget.isUpcoming && widget.game['gameClock'] == 'Pregame')) {
        inactive = Inactives(
          inactivePlayers: widget.game['matchup']?['inactive'],
          homeAbbr: widget.homeTeam['ABBREVIATION'] ?? '',
          awayAbbr: widget.awayTeam['ABBREVIATION'] ?? '',
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
                GameBasicInfo(
                  game: widget.game,
                  isUpcoming: widget.isUpcoming,
                  homeTeamName: '${widget.homeTeam['CITY']} ${widget.homeTeam['NICKNAME']}',
                  awayTeamName: '${widget.awayTeam['CITY']} ${widget.awayTeam['NICKNAME']}',
                ),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game['gameClock'] == 'Pregame'))
                  Lineups(
                    game: widget.game,
                    homeId: kTeamIdToName.containsKey(widget.homeTeam['TEAM_ID'])
                        ? widget.homeTeam['TEAM_ID']
                        : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayTeam['TEAM_ID'])
                        ? widget.awayTeam['TEAM_ID']
                        : '0',
                  ),
                if (!widget.isUpcoming ||
                    (widget.isUpcoming && widget.game['gameClock'] == 'Pregame'))
                  inactive,
                if (widget.game['matchup'].keys.toList().contains('series') &&
                    widget.game['matchup']['series'].isNotEmpty)
                  H2H(
                    game: widget.game,
                    homeId: kTeamIdToName.containsKey(widget.homeTeam['TEAM_ID'])
                        ? widget.homeTeam['TEAM_ID']
                        : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayTeam['TEAM_ID'])
                        ? widget.awayTeam['TEAM_ID']
                        : '0',
                    homeAbbr: widget.homeTeam['ABBREVIATION'],
                    awayAbbr: widget.awayTeam['ABBREVIATION'],
                  ),
                if (widget.game['matchup'].keys.toList().contains('lastMeeting') &&
                    widget.game['matchup']['lastMeeting'].isNotEmpty)
                  LastMeeting(
                    lastMeeting: widget.game['matchup']['lastMeeting'] ?? {},
                    homeId: kTeamIdToName.containsKey(widget.homeTeam['TEAM_ID'])
                        ? widget.homeTeam['TEAM_ID']
                        : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayTeam['TEAM_ID'])
                        ? widget.awayTeam['TEAM_ID']
                        : '0',
                  ),
                LastFiveGames(
                  gameDate: widget.game['date'],
                  homeId: kTeamIdToName.containsKey(widget.homeTeam['TEAM_ID'])
                      ? widget.homeTeam['TEAM_ID']
                      : '0',
                  awayId: kTeamIdToName.containsKey(widget.awayTeam['TEAM_ID'])
                      ? widget.awayTeam['TEAM_ID']
                      : '0',
                ),
                TeamRecord(
                  season:
                      '${widget.game['season']}-${(int.parse(widget.game['season'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                  homeId: kTeamIdToName.containsKey(widget.homeTeam['TEAM_ID'])
                      ? widget.homeTeam['TEAM_ID']
                      : '0',
                  awayId: kTeamIdToName.containsKey(widget.awayTeam['TEAM_ID'])
                      ? widget.awayTeam['TEAM_ID']
                      : '0',
                ),
                if (!widget.isUpcoming)
                  TeamSeasonStats(
                    season:
                        '${widget.game['season']}-${(int.parse(widget.game['season'].toString().substring(2)) + 1).toStringAsFixed(0)}',
                    homeId: kTeamIdToName.containsKey(widget.homeTeam['TEAM_ID'])
                        ? widget.homeTeam['TEAM_ID']
                        : '0',
                    awayId: kTeamIdToName.containsKey(widget.awayTeam['TEAM_ID'])
                        ? widget.awayTeam['TEAM_ID']
                        : '0',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
