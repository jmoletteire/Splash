import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
  final ScrollController controller;

  const CareerStats({
    super.key,
    required this.player,
    required this.seasons,
    required this.seasonType,
    required this.mode,
    required this.controller,
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
  List<String> tradedYears = [];

  void getTradedYears() {
    for (var season in widget.seasons) {
      if (season['TEAM_ABBREVIATION'] == 'TOT') {
        tradedYears.add(season['SEASON_ID']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.seasonType == 'REGULAR SEASON') getTradedYears();
    if (widget.seasonType == 'COLLEGE') {
      columnNames = [
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
      ];
    }
  }

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
      horizontalScrollController: widget.controller,
      headerHeight: MediaQuery.of(context).size.height * 0.045,
      rowCount: widget.seasons.length + 1,
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
              : widget.seasonType == 'COLLEGE'
                  ? MediaQuery.of(context).size.width * 0.2
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
                  : MediaQuery.of(context).size.width * 0.115,
        ),

        /// PPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.1225
                  : MediaQuery.of(context).size.width * 0.13,
        ),

        /// RPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.1
                  : MediaQuery.of(context).size.width * 0.12,
        ),

        /// APG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.1
                  : MediaQuery.of(context).size.width * 0.12,
        ),

        /// SPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.1
                  : MediaQuery.of(context).size.width * 0.12,
        ),

        /// BPG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.1
                  : MediaQuery.of(context).size.width * 0.12,
        ),

        /// TOV
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.1
                  : MediaQuery.of(context).size.width * 0.12,
        ),

        /// FG%
        TableColumn(
          width: isLandscape
              ? widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.06
                  : MediaQuery.of(context).size.width * 0.09
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.15
                  : MediaQuery.of(context).size.width * 0.2,
        ),

        /// 3P%
        TableColumn(
          width: isLandscape
              ? widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.06
                  : MediaQuery.of(context).size.width * 0.075
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.18,
        ),

        /// FT%
        TableColumn(
          width: isLandscape
              ? widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.06
                  : MediaQuery.of(context).size.width * 0.08
              : widget.mode == 'PER GAME'
                  ? MediaQuery.of(context).size.width * 0.13
                  : MediaQuery.of(context).size.width * 0.18,
        ),

        if (widget.seasonType != 'COLLEGE')

          /// eFG%
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.14,
          ),

        if (widget.seasonType != 'COLLEGE')

          /// TS%
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.13,
          ),

        if (widget.seasonType != 'COLLEGE')

          /// USG%
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.13,
          ),

        if (widget.seasonType != 'COLLEGE')

          /// ORTG
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.13,
          ),

        if (widget.seasonType != 'COLLEGE')

          /// DRTG
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.13,
          ),

        if (widget.seasonType != 'COLLEGE')

          /// NRTG
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.13,
          ),

        if (widget.seasonType != 'COLLEGE')

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
            color: const Color(0xFF303030),
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
  Widget _wrapRow(Map<String, dynamic> season, int index, Widget child) => KeyedSubtree(
        key: ValueKey(index),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? const Color(0xFF171717)
                : Colors.grey.shade900,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: index == widget.seasons.length - 1 ? 1.r : 0.15.r,
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
    Map<String, dynamic> season = {};
    if (row < widget.seasons.length) {
      season = widget.seasons.reversed.toList()[row];
    }
    return _wrapRow(
      season,
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            if (season['TEAM_ABBREVIATION'] != 'TOT' &&
                widget.seasonType != 'COLLEGE' &&
                row < widget.seasons.length) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamHome(
                    teamId: season['TEAM_ID'].toString(),
                  ),
                ),
              );
            }
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
    Map<String, dynamic> season = {};
    Map<String, dynamic> careerTotals = {};

    if (row < widget.seasons.length) {
      season = widget.seasons.reversed.toList()[row];
    } else {
      careerTotals = widget.player['CAREER'][widget.seasonType]['TOTALS'];
    }

    switch (column) {
      case 0:
        if (row == widget.seasons.length) {
          return const StandingsDataText(text: 'TOTAL');
        } else if (tradedYears.contains(season['SEASON_ID']) &&
            season['TEAM_ABBREVIATION'] != 'TOT') {
          return const Text('');
        } else {
          return Center(
            child: Text(
              '\'${season['SEASON_ID'].substring(2)}',
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 15.0.r,
              ),
            ),
          );
        }
      case 1:
        try {
          if (row == widget.seasons.length) {
            return const Text('');
          } else if (widget.seasonType == 'COLLEGE') {
            return Center(
              child: AutoSizeText(
                kSchoolNames[season['SCHOOL_NAME']] ?? season['SCHOOL_NAME'] ?? '-',
                style: kBebasNormal.copyWith(fontSize: 13.0.r),
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
          if (row == widget.seasons.length) {
            return const StandingsDataText(text: '');
          }
          return StandingsDataText(
            text: (season['PLAYER_AGE']).toStringAsFixed(0) ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 3:
        try {
          if (row == widget.seasons.length) {
            String gp = NumberFormat.decimalPattern().format(careerTotals['GP'] ?? 0);
            return StandingsDataText(
              text: gp == '0' ? '-' : gp,
              color: const Color(0xFFD0D0D0),
            );
          }
          return StandingsDataText(
            text: (season['GP']).toStringAsFixed(0) ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 4:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(
                text: careerTotals['MPG'].toString(),
                color: const Color(0xFFD0D0D0),
              );
            } else {
              String min = NumberFormat.decimalPattern().format(careerTotals['MIN'] ?? 0);
              return StandingsDataText(
                text: min == '0' ? '-' : min,
                color: const Color(0xFFD0D0D0),
              );
            }
          }
          String min = NumberFormat.decimalPattern().format(season['MIN'] ?? 0);
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['MPG'].toStringAsFixed(1) ?? '-'
                : min == '0'
                    ? '-'
                    : min,
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 5:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(text: careerTotals['PPG'].toString());
            } else {
              String pts = NumberFormat.decimalPattern().format(careerTotals['PTS'] ?? 0);
              return StandingsDataText(text: pts == '0' ? '-' : pts);
            }
          }
          String pts = NumberFormat.decimalPattern().format(season['PTS'] ?? 0);
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['PPG'].toStringAsFixed(1) ?? '-'
                : pts == '0'
                    ? '-'
                    : pts,
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(text: careerTotals['RPG'].toString());
            } else {
              String reb = NumberFormat.decimalPattern().format(careerTotals['REB'] ?? 0);
              return StandingsDataText(text: reb == '0' ? '-' : reb);
            }
          }
          String reb = NumberFormat.decimalPattern().format(season['REB'] ?? 0);
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['RPG'].toStringAsFixed(1) ?? '-'
                : reb == '0'
                    ? '-'
                    : reb,
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(text: careerTotals['APG'].toString());
            } else {
              String ast = NumberFormat.decimalPattern().format(careerTotals['AST'] ?? 0);
              return StandingsDataText(text: ast == '0' ? '-' : ast);
            }
          }
          String ast = NumberFormat.decimalPattern().format(season['AST'] ?? 0);
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['APG'].toStringAsFixed(1) ?? '-'
                : ast == '0'
                    ? '-'
                    : ast,
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 8:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(text: careerTotals['SPG'].toString());
            } else {
              String stl = NumberFormat.decimalPattern().format(careerTotals['STL'] ?? 0);
              return StandingsDataText(text: stl == '0' ? '-' : stl);
            }
          }
          String stl = NumberFormat.decimalPattern().format(season['STL'] ?? 0);
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['SPG'].toStringAsFixed(1) ?? '-'
                : stl == '0'
                    ? '-'
                    : stl,
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 9:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(text: careerTotals['BPG'].toString());
            } else {
              String blk = NumberFormat.decimalPattern().format(careerTotals['BLK'] ?? 0);
              return StandingsDataText(text: blk == '0' ? '-' : blk);
            }
          }
          String blk = NumberFormat.decimalPattern().format(season['BLK'] ?? 0);
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['BPG'].toStringAsFixed(1) ?? '-'
                : blk == '0'
                    ? '-'
                    : blk,
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 10:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(text: careerTotals['TOPG'].toString());
            } else {
              String tov = NumberFormat.decimalPattern().format(careerTotals['TOV'] ?? 0);
              return StandingsDataText(text: tov == '0' ? '-' : tov);
            }
          }
          String tov = NumberFormat.decimalPattern().format(season['TOV'] ?? 0);
          return StandingsDataText(
            text: widget.mode == 'PER GAME'
                ? season['TOPG'].toStringAsFixed(1) ?? '-'
                : tov == '0'
                    ? '-'
                    : tov,
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 11:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(
                  text: '${(careerTotals['FG_PCT'] * 100).toStringAsFixed(1)}%');
            } else {
              String fgm = NumberFormat.decimalPattern().format(careerTotals['FGM']);
              String fga = NumberFormat.decimalPattern().format(careerTotals['FGA']);
              return StandingsDataText(text: '$fgm / $fga');
            }
          }
          double fgPct = season['FG_PCT'] * 100;
          String fgm = NumberFormat.decimalPattern().format(season['FGM']);
          String fga = NumberFormat.decimalPattern().format(season['FGA']);
          return StandingsDataText(
            text: fgPct == 0.0
                ? '-'
                : widget.mode == 'PER GAME'
                    ? '${fgPct.toStringAsFixed(1)}%'
                    : '$fgm / $fga',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 12:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(
                  text: '${(careerTotals['FG3_PCT'] * 100).toStringAsFixed(1)}%');
            } else {
              String fg3m = NumberFormat.decimalPattern().format(careerTotals['FG3M']);
              String fg3a = NumberFormat.decimalPattern().format(careerTotals['FG3A']);
              return StandingsDataText(text: '$fg3m / $fg3a');
            }
          }
          double fg3Pct = season['FG3_PCT'] * 100;
          String fg3m = NumberFormat.decimalPattern().format(season['FG3M']);
          String fg3a = NumberFormat.decimalPattern().format(season['FG3A']);
          return StandingsDataText(
            text: fg3Pct == 0.0
                ? '-'
                : widget.mode == 'PER GAME'
                    ? '${fg3Pct.toStringAsFixed(1)}%'
                    : '$fg3m / $fg3a',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 13:
        try {
          if (row == widget.seasons.length) {
            if (widget.mode == 'PER GAME') {
              return StandingsDataText(
                  text: '${(careerTotals['FT_PCT'] * 100).toStringAsFixed(1)}%');
            } else {
              String ftm = NumberFormat.decimalPattern().format(careerTotals['FTM']);
              String fta = NumberFormat.decimalPattern().format(careerTotals['FTA']);
              return StandingsDataText(text: '$ftm / $fta');
            }
          }
          double ftPct = season['FT_PCT'] * 100;
          String ftm = NumberFormat.decimalPattern().format(season['FTM']);
          String fta = NumberFormat.decimalPattern().format(season['FTA']);
          return StandingsDataText(
            text: ftPct == 0.0
                ? '-'
                : widget.mode == 'PER GAME'
                    ? '${ftPct.toStringAsFixed(1)}%'
                    : '$ftm / $fta',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 14:
        try {
          double efgPct = 0.0;
          if (row == widget.seasons.length) {
            try {
              efgPct = 100 *
                  (careerTotals['FGM'] + (0.5 * careerTotals['FG3M'])) /
                  careerTotals['FGA'];
            } catch (e) {
              efgPct = 0.0;
            }
          } else {
            efgPct = season['EFG_PCT'] * 100;
          }
          return StandingsDataText(
            text: efgPct == 0.0 ? '-' : '${efgPct.toStringAsFixed(1)}%',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 15:
        try {
          double tsPct = 0.0;
          if (row == widget.seasons.length) {
            try {
              tsPct = 100 *
                  careerTotals['PTS'] /
                  (2 * (careerTotals['FGA'] + (0.44 * careerTotals['FTA'])));
            } catch (e) {
              tsPct = 0.0;
            }
          } else {
            tsPct = season['TS_PCT'] * 100;
          }
          return StandingsDataText(
            text: tsPct == 0.0 ? '-' : '${tsPct.toStringAsFixed(1)}%',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 16:
        try {
          double usgPct = season['USG_PCT'] * 100;
          if (row == widget.seasons.length) {
            return const StandingsDataText(text: '-');
          }
          return StandingsDataText(
            text: usgPct == 0.0 ? '-' : '${usgPct.toStringAsFixed(1)}%',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 17:
        try {
          if (row == widget.seasons.length) {
            return const StandingsDataText(text: '-');
          }
          return StandingsDataText(
            text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2007
                ? season['ORTG_ON_OFF'].toStringAsFixed(1)
                : '-',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 18:
        try {
          if (row == widget.seasons.length) {
            return const StandingsDataText(text: '-');
          }
          return StandingsDataText(
            text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2007
                ? season['DRTG_ON_OFF'].toStringAsFixed(1)
                : '-',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 19:
        try {
          if (row == widget.seasons.length) {
            return const StandingsDataText(text: '-');
          }
          return StandingsDataText(
            text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2007
                ? season['NRTG_ON_OFF'].toStringAsFixed(1)
                : '-',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 20:
        try {
          if (row == widget.seasons.length) {
            return const StandingsDataText(text: '-');
          }
          return StandingsDataText(
            text: int.parse(season['SEASON_ID'].substring(0, 4)) >= 2017
                ? season['DEF_IMPACT_EST'].toStringAsFixed(1)
                : '-',
            color: tradedYears.contains(season['SEASON_ID']) &&
                    season['TEAM_ABBREVIATION'] != 'TOT'
                ? Colors.grey.shade300
                : null,
          );
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
      child: AutoSizeText(
        text,
        maxLines: 1,
        style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
      ),
    );
  }
}
