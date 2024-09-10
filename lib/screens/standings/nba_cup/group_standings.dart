import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/utilities/constants.dart';

import '../../team/team_home.dart';

class GroupStandings extends StatefulWidget {
  final List columnNames;
  final List standings;
  final String season;

  GroupStandings({
    required this.columnNames,
    required this.standings,
    required this.season,
  });

  @override
  State<GroupStandings> createState() => _GroupStandingsState();
}

class _GroupStandingsState extends State<GroupStandings> {
  late ScrollController scrollController;
  late List teams;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    teams = widget.standings;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverTableView.builder(
      horizontalScrollController: scrollController,
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
      rowCount: teams.length,
      rowHeight: MediaQuery.of(context).size.height * 0.055,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.35,
          freezePriority: 1,
        ),

        /// W
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// L
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// PCT
        TableColumn(width: MediaQuery.of(context).size.width * 0.165),

        /// GB
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// DIFF
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// PTS
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// OPP PTS
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),
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
                alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  widget.columnNames[column],
                  style: kBebasNormal.copyWith(
                    fontSize: 18.0,
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
        child: Stack(
          children: [
            DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.75),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 0.125,
                      style: BorderStyle.solid,
                    ),
                  )),
              child: child,
            ),
          ],
        ),
      );

  Widget? _rowBuilder(
    BuildContext context,
    int row,
    TableRowContentBuilder contentBuilder,
  ) {
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamHome(
                  teamId: teams[row]['teamId'].toString(),
                ),
              ),
            );
          }),
          splashColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: getContent(teams, row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(List eastTeams, int row, int column, BuildContext context) {
    switch (column) {
      case 0:
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 3.0, 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  teams[row]['istGroupRank'].toString(),
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(
                    color: Colors.white70,
                    fontSize: 19.0,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 24.0),
                  child: Image.asset(
                    'images/NBA_Logos/${teams[row]['teamId']}.png',
                    fit: BoxFit.contain,
                    width: 24.0,
                    height: 24.0,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: teams[row]['teamAbbreviation'],
                        style: kBebasBold.copyWith(fontSize: 20.0),
                      ),
                      TextSpan(
                        text: teams[row]['clinchIndicator'],
                        style: kBebasNormal.copyWith(fontSize: 12.0, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 1:
        return StandingsDataText(text: teams[row]['wins']!.toStringAsFixed(0));
      case 2:
        return StandingsDataText(text: teams[row]['losses']!.toStringAsFixed(0));
      case 3:
        return StandingsDataText(text: teams[row]['pct']!.toStringAsFixed(3));
      case 4:
        String gb = teams[row]['istGroupGb'].toString();
        return StandingsDataText(text: gb == '0.0' ? '-' : gb);
      case 5:
        try {
          String diff = teams[row]['diff']! > 0
              ? '+${teams[row]['diff']!.toString()}'
              : teams[row]['diff']!.toString();
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              diff,
              style: kBebasNormal.copyWith(
                fontSize: 18.0,
                color: teams[row]['diff'] >= 0
                    ? const Color(0xFF55F86F)
                    : const Color(0xFFFC3126),
              ),
            ),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          return StandingsDataText(text: teams[row]['pts']!.toStringAsFixed(0));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          return StandingsDataText(text: teams[row]['oppPts']!.toStringAsFixed(0));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      default:
        return const Text('');
    }
  }
}

class StandingsDataText extends StatelessWidget {
  const StandingsDataText({super.key, required this.text, this.alignment});

  final Alignment? alignment;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: Text(
        text,
        style: kBebasNormal.copyWith(fontSize: 19.0),
      ),
    );
  }
}
