import 'package:flutter/material.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../utilities/constants.dart';
import '../team/team_home.dart';

class PlayerCareer extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerCareer({super.key, required this.team, required this.player});

  @override
  State<PlayerCareer> createState() => _PlayerCareerState();
}

class _PlayerCareerState extends State<PlayerCareer> {
  late Map<String, dynamic> seasons;
  final ScrollController _scrollController = ScrollController();

  List columnNames = [
    'YEAR',
    'TEAM',
    'GP',
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
  ];

  @override
  void initState() {
    super.initState();
    widget.player.keys.contains('STATS')
        ? seasons = widget.player['STATS']
        : seasons = {};

    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {}
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.player.keys.contains('STATS') ||
            !widget.player['STATS'].isNotEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_basketball,
                  color: Colors.white38,
                  size: 40.0,
                ),
                const SizedBox(height: 15.0),
                Text(
                  'No Stats Available',
                  style: kBebasNormal.copyWith(
                      fontSize: 20.0, color: Colors.white54),
                ),
              ],
            ),
          )
        : ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: CustomScrollView(
              slivers: [
                SliverTableView.builder(
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
                  rowCount: seasons.length,
                  rowHeight: MediaQuery.of(context).size.height * 0.06,
                  minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
                  columns: [
                    /// YEAR
                    TableColumn(
                      width: MediaQuery.of(context).size.width * 0.165,
                      freezePriority: 1,
                    ),

                    /// TEAM
                    TableColumn(
                      width: MediaQuery.of(context).size.width * 0.18,
                      freezePriority: 1,
                    ),

                    /// GP
                    TableColumn(
                        width: MediaQuery.of(context).size.width * 0.08),

                    /// PPG
                    TableColumn(width: MediaQuery.of(context).size.width * 0.1),

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
                    TableColumn(
                        width: MediaQuery.of(context).size.width * 0.13),

                    /// 3P%
                    TableColumn(
                        width: MediaQuery.of(context).size.width * 0.13),

                    /// FT%
                    TableColumn(
                        width: MediaQuery.of(context).size.width * 0.13),

                    /// eFG%
                    TableColumn(
                        width: MediaQuery.of(context).size.width * 0.13),

                    /// TS%
                    TableColumn(
                        width: MediaQuery.of(context).size.width * 0.13),

                    /// USG%
                    TableColumn(
                        width: MediaQuery.of(context).size.width * 0.13),

                    /// ORTG
                    TableColumn(width: MediaQuery.of(context).size.width * 0.1),

                    /// DRTG
                    TableColumn(width: MediaQuery.of(context).size.width * 0.1),

                    /// NRTG
                    TableColumn(width: MediaQuery.of(context).size.width * 0.1),
                  ],
                  rowBuilder: _rowBuilder,
                  headerBuilder: _headerBuilder,
                ),
              ],
            ),
          );
  }

  Widget _headerBuilder(
          BuildContext context, TableRowContentBuilder contentBuilder) =>
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
                  style: kBebasBold.copyWith(
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

  Widget? _rowBuilder(
      BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    String season = seasons.keys.toList().reversed.toList()[row];
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
                    teamId: seasons[season]['BASIC']['TEAM_ID'].toString(),
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

  Widget getContent(Map<String, dynamic> playerSeasons, int row, int column,
      BuildContext context) {
    String season = seasons.keys.toList().reversed.toList()[row];
    switch (column) {
      case 0:
        return Center(
          child: Text(
            '\'${season.substring(2)}',
            textAlign: TextAlign.center,
            style: kBebasWhite.copyWith(
              color: Colors.white70,
              fontSize: 19.0,
            ),
          ),
        );
      case 1:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 20.0),
                child: Image.asset(
                  'images/NBA_Logos/${seasons[season]['BASIC']['TEAM_ID']}.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  width: 20.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 4,
              child: Text(
                seasons[season]['BASIC']['TEAM_ABBREVIATION'],
                style: kBebasBold,
              ),
            ),
          ],
        );
      case 2:
        return StandingsDataText(
            text: seasons[season]['BASIC']['GP'].toStringAsFixed(0));
      case 3:
        return StandingsDataText(
            text: (seasons[season]['BASIC']['PTS'] /
                    seasons[season]['BASIC']['GP'])
                .toStringAsFixed(1));
      case 4:
        return StandingsDataText(
            text: (seasons[season]['BASIC']['REB'] /
                    seasons[season]['BASIC']['GP'])
                .toStringAsFixed(1));
      case 5:
        return StandingsDataText(
            text: (seasons[season]['BASIC']['AST'] /
                    seasons[season]['BASIC']['GP'])
                .toStringAsFixed(1));
      case 6:
        return StandingsDataText(
            text: (seasons[season]['BASIC']['STL'] /
                    seasons[season]['BASIC']['GP'])
                .toStringAsFixed(1));
      case 7:
        return StandingsDataText(
            text: (seasons[season]['BASIC']['BLK'] /
                    seasons[season]['BASIC']['GP'])
                .toStringAsFixed(1));
      case 8:
        return StandingsDataText(
            text: (seasons[season]['BASIC']['TOV'] /
                    seasons[season]['BASIC']['GP'])
                .toStringAsFixed(1));
      case 9:
        return StandingsDataText(
            text:
                '${(seasons[season]['BASIC']['FG_PCT'] * 100).toStringAsFixed(1)}%');
      case 10:
        return StandingsDataText(
            text:
                '${(seasons[season]['BASIC']['FG3_PCT'] * 100).toStringAsFixed(1)}%');
      case 11:
        return StandingsDataText(
            text:
                '${(seasons[season]['BASIC']['FT_PCT'] * 100).toStringAsFixed(1)}%');
      case 12:
        return StandingsDataText(
            text:
                '${(seasons[season]['ADV']['EFG_PCT'] * 100).toStringAsFixed(1)}%');
      case 13:
        return StandingsDataText(
            text:
                '${(seasons[season]['ADV']['TS_PCT'] * 100).toStringAsFixed(1)}%');
      case 14:
        return StandingsDataText(
            text:
                '${(seasons[season]['ADV']['USG_PCT'] * 100).toStringAsFixed(1)}%');
      case 15:
        return StandingsDataText(
            text: int.parse(season.substring(0, 4)) > 2007
                ? seasons[season]['ADV']['OFF_RATING_ON_OFF'].toStringAsFixed(1)
                : '-');
      case 16:
        return StandingsDataText(
            text: int.parse(season.substring(0, 4)) > 2007
                ? seasons[season]['ADV']['DEF_RATING_ON_OFF'].toStringAsFixed(1)
                : '-');
      case 17:
        return StandingsDataText(
            text: int.parse(season.substring(0, 4)) > 2007
                ? seasons[season]['ADV']['NET_RATING_ON_OFF'].toStringAsFixed(1)
                : '-');
      default:
        return const Text('-');
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
        style: kBebasWhite.copyWith(fontSize: 18.0),
      ),
    );
  }
}

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
