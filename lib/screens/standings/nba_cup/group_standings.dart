import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/utilities/constants.dart';

import '../../team/team_home.dart';

class GroupStandings extends StatefulWidget {
  final Key key;
  final List columnNames;
  final List standings;
  final String season;
  final ScrollController groupController;

  GroupStandings({
    required this.key,
    required this.columnNames,
    required this.standings,
    required this.season,
    required this.groupController,
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
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SliverTableView.builder(
      horizontalScrollController: widget.groupController,
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
          width: MediaQuery.of(context).size.width * (isLandscape ? 0.15 : 0.3),
          freezePriority: 1,
        ),

        /// W
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.05 : 0.08)),

        /// L
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.05 : 0.08)),

        /// PCT
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.165)),

        /// GB
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.125)),

        /// DIFF
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.125)),

        /// PTS
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.125)),

        /// OPP PTS
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.125)),

        /// G1
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.175)),

        /// G2
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.175)),

        /// G3
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.175)),

        /// G4
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.175)),
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
              padding:
                  column == 0 ? EdgeInsets.only(left: 20.0.r) : EdgeInsets.only(right: 8.0.r),
              child: Align(
                alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  widget.columnNames[column],
                  style: kBebasNormal.copyWith(
                    fontSize: 16.0.r,
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
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade700,
                      width: 0.5,
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
              padding: EdgeInsets.only(right: 8.0.r),
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
          padding: EdgeInsets.fromLTRB(8.0.r, 8.0.r, 3.0.r, 8.0.r),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  teams[row]['istGroupRank'].toString(),
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(
                    color: Colors.white70,
                    fontSize: 17.0.r,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 24.0.r),
                  child: Image.asset(
                    'images/NBA_Logos/${teams[row]['teamId']}.png',
                    fit: BoxFit.contain,
                    width: 24.0.r,
                    height: 24.0.r,
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
                        style: kBebasBold.copyWith(fontSize: 18.0.r),
                      ),
                      TextSpan(
                        text: teams[row]['clinchIndicator'],
                        style: kBebasNormal.copyWith(fontSize: 10.0.r, letterSpacing: 0.8),
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
                fontSize: 16.0.r,
                color: teams[row]['diff'] > 0
                    ? const Color(0xFF55F86F)
                    : teams[row]['diff'] == 0
                        ? Colors.white
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
      case 8:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (teams[row]['games'][0]['outcome'] != null)
              Text(
                teams[row]['games'][0]['outcome'],
                textAlign: TextAlign.center,
                style: kBebasNormal.copyWith(
                  fontSize: 17.0.r,
                  color: teams[row]['games'][0]['outcome'] == 'W'
                      ? const Color(0xFF55F86F)
                      : const Color(0xFFFC3126),
                ),
              ),
            if (teams[row]['games'][0]['outcome'] != null) SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][0]['location'] == 'H' ? 'vs' : '@',
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 13.0.r,
              ),
            ),
            SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][0]['opponentTeamAbbreviation'],
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 17.0.r,
              ),
            ),
          ],
        );
      case 9:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (teams[row]['games'][1]['outcome'] != null)
              Text(
                teams[row]['games'][1]['outcome'],
                textAlign: TextAlign.center,
                style: kBebasNormal.copyWith(
                  fontSize: 17.0.r,
                  color: teams[row]['games'][1]['outcome'] == 'W'
                      ? const Color(0xFF55F86F)
                      : const Color(0xFFFC3126),
                ),
              ),
            if (teams[row]['games'][1]['outcome'] != null) SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][1]['location'] == 'H' ? 'vs' : '@',
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 13.0.r,
              ),
            ),
            SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][1]['opponentTeamAbbreviation'],
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 17.0.r,
              ),
            ),
          ],
        );
      case 10:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (teams[row]['games'][2]['outcome'] != null)
              Text(
                teams[row]['games'][2]['outcome'],
                textAlign: TextAlign.center,
                style: kBebasNormal.copyWith(
                  fontSize: 17.0.r,
                  color: teams[row]['games'][2]['outcome'] == 'W'
                      ? const Color(0xFF55F86F)
                      : const Color(0xFFFC3126),
                ),
              ),
            if (teams[row]['games'][2]['outcome'] != null) SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][2]['location'] == 'H' ? 'vs' : '@',
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 13.0.r,
              ),
            ),
            SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][2]['opponentTeamAbbreviation'],
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 17.0.r,
              ),
            ),
          ],
        );
      case 11:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (teams[row]['games'][3]['outcome'] != null)
              Text(
                teams[row]['games'][3]['outcome'],
                textAlign: TextAlign.center,
                style: kBebasNormal.copyWith(
                  fontSize: 17.0.r,
                  color: teams[row]['games'][3]['outcome'] == 'W'
                      ? const Color(0xFF55F86F)
                      : const Color(0xFFFC3126),
                ),
              ),
            if (teams[row]['games'][3]['outcome'] != null) SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][3]['location'] == 'H' ? 'vs' : '@',
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 13.0.r,
              ),
            ),
            SizedBox(width: 5.0.r),
            Text(
              teams[row]['games'][3]['opponentTeamAbbreviation'],
              textAlign: TextAlign.center,
              style: kBebasNormal.copyWith(
                color: Colors.white70,
                fontSize: 17.0.r,
              ),
            ),
          ],
        );
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
        style: kBebasNormal.copyWith(fontSize: 17.0.r),
      ),
    );
  }
}
