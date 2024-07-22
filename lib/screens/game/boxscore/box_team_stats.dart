import 'package:flutter/material.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../utilities/constants.dart';
import '../../team/team_home.dart';

class BoxTeamStats extends StatefulWidget {
  final List<dynamic> teams;
  const BoxTeamStats({super.key, required this.teams});

  @override
  State<BoxTeamStats> createState() => _BoxTeamStatsState();
}

class _BoxTeamStatsState extends State<BoxTeamStats> {
  List columnNames = [
    'TEAM',
    '+/-',
    'PTS',
    'REB',
    'AST',
    'STL',
    'BLK',
    'TOV',
    'FGM',
    'FGA',
    'FG%',
    '3PM',
    '3PA',
    '3P%',
    'FTM',
    'FTA',
    'FT%',
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
      rowCount: widget.teams.length,
      rowHeight: MediaQuery.of(context).size.height * 0.06,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// TEAM
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.165,
          freezePriority: 1,
        ),

        /// +/-
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// PTS
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// REB
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// AST
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// STL
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// BLK
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// TOV
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// FGM
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// FGA
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// FG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// 3PM
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// 3PA
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// 3P%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// FTM
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// FTA
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// FT%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),
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
              padding: column == 0
                  ? const EdgeInsets.only(left: 20.0)
                  : const EdgeInsets.only(right: 8.0),
              child: Align(
                alignment: column == 0
                    ? Alignment.centerLeft
                    : column == 1
                        ? Alignment.center
                        : Alignment.centerRight,
                child: Text(
                  columnNames[column],
                  style: kBebasNormal.copyWith(
                    fontSize: 16.0,
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
                    teamId: widget.teams[row]['TEAM_ID'].toString(),
                  ),
                ),
              );
            });
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: getContent(widget.teams[row], row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(
      Map<String, dynamic> playerSeasons, int row, int column, BuildContext context) {
    switch (column) {
      case 0:
        return Center(
          child: Text(
            '${widget.teams[row]['TEAM_ABBREVIATION']}',
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(
              color: Colors.white70,
              fontSize: 19.0,
            ),
          ),
        );
      case 1:
        try {
          return BoxscoreDataText(
              text: '${widget.teams[row]['PLUS_MINUS'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 2:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['PTS'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 3:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['REB'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 4:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['AST'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 5:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['STL'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 6:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['BLK'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 7:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['TO'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 8:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['FGM'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 9:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['FGA'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 10:
        try {
          return BoxscoreDataText(
              text: '${(widget.teams[row]['FG_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 11:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['FG3M'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 12:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['FG3A'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 13:
        try {
          return BoxscoreDataText(
              text: '${(widget.teams[row]['FG3_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 14:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['FTM'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 15:
        try {
          return BoxscoreDataText(text: '${widget.teams[row]['FTA'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 16:
        try {
          return BoxscoreDataText(
              text: '${(widget.teams[row]['FT_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      default:
        return const Text('-');
    }
  }
}

class BoxscoreDataText extends StatelessWidget {
  const BoxscoreDataText({super.key, required this.text, this.alignment});

  final Alignment? alignment;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: Text(
        text,
        style: kBebasNormal.copyWith(fontSize: 18.0),
      ),
    );
  }
}
