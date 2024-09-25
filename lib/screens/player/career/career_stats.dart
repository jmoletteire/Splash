import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../utilities/constants.dart';
import '../../team/team_home.dart';

class CareerStats extends StatefulWidget {
  final Map<String, dynamic> player;
  final List seasons;
  final String seasonType;
  final String mode;

  const CareerStats({
    super.key,
    required this.player,
    required this.seasons,
    required this.seasonType,
    required this.mode,
  });

  @override
  State<CareerStats> createState() => _CareerStatsState();
}

class _CareerStatsState extends State<CareerStats> {
  List columnNames = [
    'YEAR',
    'TEAM',
    'AGE',
    'GP',
    'MIN',
    'PTS',
    'REB',
    'AST',
    'STL',
    'BLK',
    'TOV',
    'FG%',
    '3P%',
    'FT%',
    'eFG%',
    'TS%',
    'USG%',
    'ORTG',
    'DRTG',
    'NRTG',
    'DIE',
  ];

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return SliverTableView.builder(
      style: const TableViewStyle(
        dividers: TableViewDividersStyle(
          vertical: TableViewVerticalDividersStyle.symmetric(
            TableViewVerticalDividerStyle(wigglesPerRow: 0),
          ),
        ),
        scrollbars: TableViewScrollbarsStyle.symmetric(
          TableViewScrollbarStyle(
            scrollPadding: false,
            enabled: TableViewScrollbarEnabled.never,
          ),
        ),
      ),
      headerHeight: MediaQuery.of(context).size.height * 0.045,
      rowCount: widget.seasons.length,
      rowHeight: MediaQuery.of(context).size.height * 0.06,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// YEAR
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.08
              : MediaQuery.of(context).size.width * 0.145,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.155,
          freezePriority: 1,
        ),

        /// AGE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.075,
        ),

        /// GP
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.075,
        ),

        /// MPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.1
                  : MediaQuery.of(context).size.width * 0.11,
        ),

        /// PPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.125,
        ),

        /// RPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// APG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// SPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// BPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// TOV
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// FG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.2,
        ),

        /// 3P%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.18,
        ),

        /// FT%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.18,
        ),

        /// eFG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.16,
        ),

        /// TS%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.16,
        ),

        /// USG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.16,
        ),

        /// ORTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// DRTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// NRTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// DIE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.13,
        ),
      ],
      rowBuilder: _rowBuilder,
      headerBuilder: _headerBuilder,
    );
  }

  Widget _headerBuilder(BuildContext context, TableRowContentBuilder contentBuilder) =>
      contentBuilder(
        context,
        (context, column) {
          return Material(
            color: Colors.grey.shade800,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Align(
                alignment: column <= 1 ? Alignment.center : Alignment.centerRight,
                child: Text(
                  columnNames[column],
                  style: kBebasNormal.copyWith(
                    fontSize: 14.0.r,
                  ),
                ),
              ),
            ),
          );
        },
      );

  /// This is used to wrap both regular and placeholder rows to achieve fade
  /// transition between them and to insert optional row divider.
  Widget _wrapRow(int index, Widget child) => KeyedSubtree(
        key: ValueKey(index),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 0.125,
              ),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: tableRowDefaultAnimatedSwitcherTransitionBuilder,
            child: child,
          ),
        ),
      );

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    Map<String, dynamic> season = widget.seasons.reversed.toList()[row];
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamHome(
                    teamId: season['TEAM_ID'].toString(),
                  ),
                ),
              );
            });
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: getContent(widget.player, row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(
      Map<String, dynamic> playerSeasons, int row, int column, BuildContext context) {
    Map<String, dynamic> season = widget.seasons.reversed.toList()[row];
    switch (column) {
      case 0:
        return Center(
          child: Text(
            '\'${season['SEASON_ID'].substring(2)}',
            style: kBebasNormal.copyWith(
              color: Colors.white70,
              fontSize: 15.0.r,
            ),
          ),
        );
      case 1:
        try {
          if (widget.seasonType == 'COLLEGE') {
            return Center(
              child: AutoSizeText(
                season['SCHOOL_NAME'] ?? '-',
                style: kBebasBold.copyWith(fontSize: 12.5.r),
              ),
            );
          } else {
            return Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 20.0.r),
                  child: Image.asset(
                    'images/NBA_Logos/${season['TEAM_ID'].toString()}.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    width: season['TEAM_ID'] == 0 ? 10.0.r : 20.0.r,
                  ),
                ),
                SizedBox(width: 8.0.r),
                Text(
                  season['TEAM_ABBREVIATION'] ?? '-',
                  style: kBebasBold.copyWith(fontSize: 15.0.r),
                ),
              ],
            );
          }
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 2:
        try {
          return StandingsDataText(
            text: (season['PLAYER_AGE']).toStringAsFixed(0) ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 3:
        try {
          return StandingsDataText(
            text: (season['GP']).toStringAsFixed(0) ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 4:
        try {
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['MPG'].toStringAsFixed(1) ?? '-'
                : season['MIN'].toStringAsFixed(0) ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 5:
        try {
          return StandingsDataText(
              text: widget.mode == 'PER GAME'
                  ? season['PPG'].toStringAsFixed(1) ?? '-'
                  : season['PTS'].toStringAsFixed(0) ?? '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          return StandingsDataText(
              text: widget.mode == 'PER GAME'
                  ? season['RPG'].toStringAsFixed(1) ?? '-'
                  : season['REB'].toStringAsFixed(0) ?? '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          return StandingsDataText(
              text: widget.mode == 'PER GAME'
                  ? season['APG'].toStringAsFixed(1) ?? '-'
                  : season['AST'].toStringAsFixed(0) ?? '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 8:
        try {
          return StandingsDataText(
              text: widget.mode == 'PER GAME'
                  ? season['SPG'].toStringAsFixed(1) ?? '-'
                  : season['STL'].toStringAsFixed(0) ?? '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 9:
        try {
          return StandingsDataText(
              text: widget.mode == 'PER GAME'
                  ? season['BPG'].toStringAsFixed(1) ?? '-'
                  : season['BLK'].toStringAsFixed(0) ?? '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 10:
        try {
          return StandingsDataText(
              text: widget.mode == 'PER GAME'
                  ? season['TOPG'].toStringAsFixed(1) ?? '-'
                  : season['TOV'].toStringAsFixed(0) ?? '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 11:
        try {
          double fgPct = season['FG_PCT'] * 100;
          return StandingsDataText(
              text: fgPct == 0.0
                  ? '-'
                  : widget.mode == 'PER GAME'
                      ? '${fgPct.toStringAsFixed(1)}%'
                      : '${season['FGM']}/${season['FGA']}');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 12:
        try {
          double fg3Pct = season['FG3_PCT'] * 100;
          return StandingsDataText(
              text: fg3Pct == 0.0
                  ? '-'
                  : widget.mode == 'PER GAME'
                      ? '${fg3Pct.toStringAsFixed(1)}%'
                      : '${season['FG3M']}/${season['FG3A']}');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 13:
        try {
          double ftPct = season['FT_PCT'] * 100;
          return StandingsDataText(
              text: ftPct == 0.0
                  ? '-'
                  : widget.mode == 'PER GAME'
                      ? '${ftPct.toStringAsFixed(1)}%'
                      : '${season['FTM']}/${season['FTA']}');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 14:
        try {
          double efgPct = season['EFG_PCT'] * 100;
          return StandingsDataText(
              text: efgPct == 0.0 ? '-' : '${efgPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 15:
        try {
          double tsPct = season['TS_PCT'] * 100;
          return StandingsDataText(text: tsPct == 0.0 ? '-' : '${tsPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 16:
        try {
          double usgPct = season['USG_PCT'] * 100;
          return StandingsDataText(
              text: usgPct == 0.0 ? '-' : '${usgPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 17:
        try {
          return StandingsDataText(
              text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2007
                  ? season['ORTG_ON_OFF'].toStringAsFixed(1)
                  : '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 18:
        try {
          return StandingsDataText(
              text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2007
                  ? season['DRTG_ON_OFF'].toStringAsFixed(1)
                  : '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 19:
        try {
          return StandingsDataText(
              text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2007
                  ? season['NRTG_ON_OFF'].toStringAsFixed(1)
                  : '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 20:
        try {
          return StandingsDataText(
              text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2017
                  ? season['DEF_IMPACT_EST'].toStringAsFixed(1)
                  : '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      default:
        return const Text('-');
    }
  }
}

class StandingsDataText extends StatelessWidget {
  const StandingsDataText({super.key, required this.text, this.alignment, this.color});

  final Alignment? alignment;
  final Color? color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: Text(
        text,
        style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
      ),
    );
  }
}
