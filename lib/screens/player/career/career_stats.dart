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
  final Map<String, dynamic> seasons;
  final String seasonType;

  const CareerStats({
    super.key,
    required this.player,
    required this.seasons,
    required this.seasonType,
  });

  @override
  State<CareerStats> createState() => _CareerStatsState();
}

class _CareerStatsState extends State<CareerStats> {
  List columnNames = [
    'YEAR',
    'TEAM',
    'GP',
    'MPG',
    'PPG',
    'RPG',
    'APG',
    'SPG',
    'BPG',
    'TOPG',
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
          width: MediaQuery.of(context).size.width * 0.145,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.15,
          freezePriority: 1,
        ),

        /// GP
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// MPG
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// PPG
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// RPG
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// APG
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// SPG
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// BPG
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// TOV
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// FG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// 3P%
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// FT%
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// eFG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// TS%
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// USG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// ORTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// DRTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// NRTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// DIE
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),
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
                alignment: column == 0
                    ? Alignment.center
                    : column == 1
                        ? Alignment.center
                        : Alignment.centerRight,
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
    String season = widget.seasons.keys.toList().reversed.toList()[row];
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
                    teamId: widget.seasons[season][widget.seasonType]['BASIC']['TEAM_ID']
                        .toString(),
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
    String season = widget.seasons.keys.toList().reversed.toList()[row];
    switch (column) {
      case 0:
        return Center(
          child: Text(
            '\'${season.substring(2)}',
            style: kBebasNormal.copyWith(
              color: Colors.white70,
              fontSize: 15.0.r,
            ),
          ),
        );
      case 1:
        try {
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 20.0.r),
                  child: Image.asset(
                    'images/NBA_Logos/${widget.seasons[season][widget.seasonType]['BASIC']['TEAM_ID']}.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    width: 20.0.r,
                  ),
                ),
              ),
              SizedBox(width: 8.0.r),
              Expanded(
                flex: 4,
                child: Text(
                  widget.seasons[season][widget.seasonType]['BASIC']['TEAM_ABBREVIATION'] ??
                      '-',
                  style: kBebasBold.copyWith(fontSize: 15.0.r),
                ),
              ),
            ],
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 2:
        try {
          return StandingsDataText(
            text: (widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                    .toStringAsFixed(0) ??
                '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 3:
        try {
          return StandingsDataText(
            text: (widget.seasons[season][widget.seasonType]['BASIC']['MIN'] /
                        widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                    .toStringAsFixed(1) ??
                '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 4:
        try {
          return StandingsDataText(
              text: (widget.seasons[season][widget.seasonType]['BASIC']['PTS'] /
                          widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                      .toStringAsFixed(1) ??
                  '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 5:
        try {
          return StandingsDataText(
              text: (widget.seasons[season][widget.seasonType]['BASIC']['REB'] /
                          widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                      .toStringAsFixed(1) ??
                  '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          return StandingsDataText(
              text: (widget.seasons[season][widget.seasonType]['BASIC']['AST'] /
                          widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                      .toStringAsFixed(1) ??
                  '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          return StandingsDataText(
              text: (widget.seasons[season][widget.seasonType]['BASIC']['STL'] /
                          widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                      .toStringAsFixed(1) ??
                  '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 8:
        try {
          return StandingsDataText(
              text: (widget.seasons[season][widget.seasonType]['BASIC']['BLK'] /
                          widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                      .toStringAsFixed(1) ??
                  '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 9:
        try {
          return StandingsDataText(
              text: (widget.seasons[season][widget.seasonType]['BASIC']['TOV'] /
                          widget.seasons[season][widget.seasonType]['BASIC']['GP'])
                      .toStringAsFixed(1) ??
                  '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 10:
        try {
          double fgPct = widget.seasons[season][widget.seasonType]['BASIC']['FG_PCT'] * 100;
          return StandingsDataText(text: '${fgPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 11:
        try {
          double fg3Pct = widget.seasons[season][widget.seasonType]['BASIC']['FG3_PCT'] * 100;
          return StandingsDataText(text: '${fg3Pct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 12:
        try {
          double ftPct = widget.seasons[season][widget.seasonType]['BASIC']['FT_PCT'] * 100;
          return StandingsDataText(text: '${ftPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 13:
        try {
          double efgPct = widget.seasons[season][widget.seasonType]['ADV']['EFG_PCT'] * 100;
          return StandingsDataText(text: '${efgPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 14:
        try {
          double tsPct = widget.seasons[season][widget.seasonType]['ADV']['TS_PCT'] * 100;
          return StandingsDataText(text: '${tsPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 15:
        try {
          double usgPct = widget.seasons[season][widget.seasonType]['ADV']['USG_PCT'] * 100;
          return StandingsDataText(text: '${usgPct.toStringAsFixed(1)}%');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 16:
        try {
          return StandingsDataText(
              text: int.parse(season.substring(0, 4)) >= 2007
                  ? widget.seasons[season][widget.seasonType]['ADV']['OFF_RATING_ON_OFF']
                      .toStringAsFixed(1)
                  : '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 17:
        try {
          return StandingsDataText(
              text: int.parse(season.substring(0, 4)) >= 2007
                  ? widget.seasons[season][widget.seasonType]['ADV']['DEF_RATING_ON_OFF']
                      .toStringAsFixed(1)
                  : '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 18:
        try {
          return StandingsDataText(
              text: int.parse(season.substring(0, 4)) >= 2007
                  ? widget.seasons[season][widget.seasonType]['ADV']['NET_RATING_ON_OFF']
                      .toStringAsFixed(1)
                  : '-');
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 19:
        try {
          return StandingsDataText(
              text: int.parse(season.substring(0, 4)) >= 2017
                  ? widget.seasons[season][widget.seasonType]['ADV']['DEF_IMPACT_EST']
                      .toStringAsFixed(1)
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
