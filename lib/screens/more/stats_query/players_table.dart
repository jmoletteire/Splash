import 'package:flutter/material.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/player_avatar.dart';
import '../../player/player_home.dart';

class PlayersTable extends StatefulWidget {
  final List columnNames;
  final String selectedSeason;
  final List<dynamic> players;

  PlayersTable({
    required this.columnNames,
    required this.selectedSeason,
    required this.players,
  });

  @override
  State<PlayersTable> createState() => _PlayersTableState();
}

class _PlayersTableState extends State<PlayersTable> {
  late ScrollController scrollController;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  Map<String, String> positionsMap = {
    '': '',
    'Guard': 'G',
    'Forward': 'F',
    'Center': 'C',
    'Guard-Forward': 'G-F',
    'Forward-Guard': 'F-G',
    'Forward-Center': 'F-C',
    'Center-Forward': 'C-F',
  };

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> p) getField,
      int columnIndex, bool ascending) {
    widget.players.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Comparable<dynamic> _getSortingKey(Map<String, dynamic> player, int column) {
    switch (column) {
      case 0:
        return player['DISPLAY_FI_LAST'];
      case 1:
        return player['TEAM_ID'];
      case 2:
        return player['STATS'][widget.selectedSeason]['BASIC']['AGE'];
      case 3:
        return player['POSITION'];
      case 4:
        return player['STATS'][widget.selectedSeason]['BASIC']['PTS'] /
            player['STATS'][widget.selectedSeason]['BASIC']['GP'];
      case 5:
        return player['STATS'][widget.selectedSeason]['BASIC']['REB'] /
            player['STATS'][widget.selectedSeason]['BASIC']['GP'];
      case 6:
        return player['STATS'][widget.selectedSeason]['BASIC']['AST'] /
            player['STATS'][widget.selectedSeason]['BASIC']['GP'];
      case 7:
        return player['STATS'][widget.selectedSeason]['BASIC']['STL'] /
            player['STATS'][widget.selectedSeason]['BASIC']['GP'];
      case 8:
        return player['STATS'][widget.selectedSeason]['BASIC']['BLK'] /
            player['STATS'][widget.selectedSeason]['BASIC']['GP'];
      case 9:
        return player['STATS'][widget.selectedSeason]['BASIC']['TOV'] /
            player['STATS'][widget.selectedSeason]['BASIC']['GP'];
      case 10:
        return player['STATS'][widget.selectedSeason]['BASIC']['FG_PCT'];
      case 11:
        return player['STATS'][widget.selectedSeason]['BASIC']['FG3_PCT'];
      case 12:
        return player['STATS'][widget.selectedSeason]['BASIC']['FT_PCT'];
      case 13:
        return player['STATS'][widget.selectedSeason]['ADV']['EFG_PCT'];
      case 14:
        return player['STATS'][widget.selectedSeason]['ADV']['TS_PCT'];
      case 15:
        return player['STATS'][widget.selectedSeason]['ADV']['USG_PCT'];
      case 16:
        return player['STATS'][widget.selectedSeason]['ADV']
            ['NET_RATING_ON_OFF'];
      case 17:
        return player['STATS'][widget.selectedSeason]['ADV']
            ['OFF_RATING_ON_OFF'];
      case 18:
        return player['STATS'][widget.selectedSeason]['ADV']
            ['DEF_RATING_ON_OFF'];
      case 19:
        return player['STATS'][widget.selectedSeason]['ADV']['SHOOTING']
            ['CLOSEST_DEFENDER']['6+ Feet - Wide Open']['FG3_PCT'];
      case 20:
        return player['STATS'][widget.selectedSeason]['BASIC']['PTS'];
      case 21:
        return player['STATS'][widget.selectedSeason]['BASIC']['PTS'];
      case 22:
        return player['STATS'][widget.selectedSeason]['BASIC']['PTS'];
      default:
        return player['DISPLAY_FI_LAST'];
    }
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
      rowCount: widget.players.length,
      rowHeight: MediaQuery.of(context).size.height * 0.055,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.35,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(width: MediaQuery.of(context).size.width * 0.135),

        /// AGE
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// POS
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// PTS
        TableColumn(width: MediaQuery.of(context).size.width * 0.135),

        /// REB
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// AST
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// STL
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// BLK
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// TOV
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// FG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// 3P%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// FT%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// eFG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// TS%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// USG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// NRTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// ORTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// DRTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// WIDE OPEN 3P%
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// VS NORTHWEST
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// VS PACIFIC
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// VS SOUTHWEST
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),
      ],
      rowBuilder: _rowBuilder,
      headerBuilder: _headerBuilder,
    );
  }

  Widget _headerBuilder(
          BuildContext context, TableRowContentBuilder contentBuilder) =>
      contentBuilder(
        context,
        (context, column) {
          return Material(
            color: Colors.grey.shade800,
            child: InkWell(
              onTap: () {
                final isAscending =
                    _sortColumnIndex == column && _sortAscending;
                _sort<dynamic>(
                  (player) => _getSortingKey(player, column),
                  column,
                  !isAscending,
                );
              },
              child: Padding(
                padding: column == 0
                    ? const EdgeInsets.only(left: 20.0)
                    : const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisAlignment: column == 0
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.columnNames[column]}',
                      style: kBebasNormal.copyWith(
                        fontSize: 18.0,
                      ),
                    ),
                    if (_sortColumnIndex == column)
                      Icon(
                        _sortAscending
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        size: 15.0,
                      ),
                  ],
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
            color: Colors.grey.shade900.withOpacity(0.75),
            border: const Border(
              bottom: BorderSide(
                color: Colors.white,
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
                builder: (context) => PlayerHome(
                  teamId: widget.players[row]['TEAM_ID'].toString(),
                  playerId: widget.players[row]['PERSON_ID'].toString(),
                ),
              ),
            );
          }),
          splashColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: getContent(widget.players, row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(
      List<dynamic> listPlayers, int row, int column, BuildContext context) {
    switch (column) {
      case 0:
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 3.0, 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 24.0),
                  child: PlayerAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.white70,
                    playerImageUrl:
                        'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.players[row]['PERSON_ID']}.png',
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 3,
                child: Text(
                  widget.players[row]['DISPLAY_FI_LAST'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(fontSize: 16.0),
                ),
              ),
            ],
          ),
        );
      case 1:
        return Row(
          children: [
            Spacer(),
            Expanded(
              flex: 2,
              child: Image.asset(
                'images/NBA_Logos/${widget.players[row]['TEAM_ID']}.png',
                fit: BoxFit.scaleDown,
                width: 30.0,
                height: 30.0,
              ),
            ),
          ],
        );
      case 2:
        return StandingsDataText(
            text: widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                    ['AGE']!
                .toStringAsFixed(0));
      case 3:
        return StandingsDataText(
            text: positionsMap[widget.players[row]['POSITION']!]!);
      case 4:
        return StandingsDataText(
            text: (widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['PTS']! /
                    widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['GP']!)
                .toStringAsFixed(1));
      case 5:
        return StandingsDataText(
            text: (widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['REB']! /
                    widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['GP']!)
                .toStringAsFixed(1));
      case 6:
        return StandingsDataText(
            text: (widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['AST']! /
                    widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['GP']!)
                .toStringAsFixed(1));
      case 7:
        return StandingsDataText(
            text: (widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['STL']! /
                    widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['GP']!)
                .toStringAsFixed(1));
      case 8:
        return StandingsDataText(
            text: (widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['BLK']! /
                    widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['GP']!)
                .toStringAsFixed(1));
      case 9:
        return StandingsDataText(
            text: (widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['TOV']! /
                    widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                        ['GP']!)
                .toStringAsFixed(1));
      case 10:
        return StandingsDataText(
            text:
                '${(widget.players[row]['STATS'][widget.selectedSeason]['BASIC']['FG_PCT']! * 100).toStringAsFixed(1)}%');
      case 11:
        return StandingsDataText(
            text:
                '${((widget.players[row]['STATS'][widget.selectedSeason]['BASIC']['FG3_PCT'] ?? 0) * 100).toStringAsFixed(1)}%');
      case 12:
        return StandingsDataText(
            text:
                '${(widget.players[row]['STATS'][widget.selectedSeason]['BASIC']['FT_PCT']! * 100).toStringAsFixed(1)}%');
      case 13:
        return StandingsDataText(
            text:
                '${(widget.players[row]['STATS'][widget.selectedSeason]['ADV']['EFG_PCT']! * 100).toStringAsFixed(1)}%');
      case 14:
        return StandingsDataText(
            text:
                '${(widget.players[row]['STATS'][widget.selectedSeason]['ADV']['TS_PCT']! * 100).toStringAsFixed(1)}%');
      case 15:
        return StandingsDataText(
            text:
                '${(widget.players[row]['STATS'][widget.selectedSeason]['ADV']['USG_PCT']! * 100).toStringAsFixed(1)}%');
      case 16:
        return StandingsDataText(
            text: widget.players[row]['STATS'][widget.selectedSeason]['ADV']
                    ['NET_RATING_ON_OFF']!
                .toStringAsFixed(1));
      case 17:
        return StandingsDataText(
            text: widget.players[row]['STATS'][widget.selectedSeason]['ADV']
                    ['OFF_RATING_ON_OFF']!
                .toStringAsFixed(1));
      case 18:
        return StandingsDataText(
            text: widget.players[row]['STATS'][widget.selectedSeason]['ADV']
                    ['DEF_RATING_ON_OFF']!
                .toStringAsFixed(1));
      case 19:
        return StandingsDataText(
            text:
                '${((widget.players[row]['STATS'][widget.selectedSeason]['ADV']['SHOOTING']['CLOSEST_DEFENDER']['6+ Feet - Wide Open']['FG3_PCT'] ?? 0) * 100).toStringAsFixed(1)}%');
      case 20:
        return StandingsDataText(
            text: widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                    ['PTS']!
                .toStringAsFixed(0));
      case 21:
        return StandingsDataText(
            text: widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                    ['PTS']!
                .toStringAsFixed(0));
      case 22:
        return StandingsDataText(
            text: widget.players[row]['STATS'][widget.selectedSeason]['BASIC']
                    ['PTS']!
                .toStringAsFixed(0));
      default:
        return Text('');
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
        style: kBebasWhite.copyWith(fontSize: 19.0),
      ),
    );
  }
}
