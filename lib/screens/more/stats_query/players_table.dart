import 'package:flutter/material.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/screens/more/stats_query/util/column_options.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/player_avatar.dart';
import '../../player/player_home.dart';

class PlayersTable extends StatefulWidget {
  final List<ColumnOption> selectedColumns;
  final String selectedSeason;
  final String selectedSeasonType;
  final List<dynamic> players;
  final Function(List<ColumnOption>) updateSelectedColumns;

  PlayersTable({
    required this.selectedColumns,
    required this.selectedSeason,
    required this.selectedSeasonType,
    required this.players,
    required this.updateSelectedColumns,
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
        return player['DISPLAY_FI_LAST'] ?? '';
      case 1:
        return player['TEAM_ID'] ?? 0;
      case 2:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['AGE'] ??
            0;
      case 3:
        return player['POSITION'] ?? '';
      case 4:
        int pts = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['PTS'] ??
            0;
        int gp = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['GP'] ??
            0;
        return gp != 0 ? pts / gp : 0.0;
      case 5:
        int reb = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['REB'] ??
            0;
        int gp = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['GP'] ??
            0;
        return gp != 0 ? reb / gp : 0.0;
      case 6:
        int ast = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['AST'] ??
            0;
        int gp = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['GP'] ??
            0;
        return gp != 0 ? ast / gp : 0.0;
      case 7:
        int stl = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['STL'] ??
            0;
        int gp = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['GP'] ??
            0;
        return gp != 0 ? stl / gp : 0.0;
      case 8:
        int blk = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['BLK'] ??
            0;
        int gp = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['GP'] ??
            0;
        return gp != 0 ? blk / gp : 0.0;
      case 9:
        int tov = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['TOV'] ??
            0;
        int gp = player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['GP'] ??
            0;
        return gp != 0 ? tov / gp : 0.0;
      case 10:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['FG_PCT'] ??
            0;
      case 11:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['FG3_PCT'] ??
            0;
      case 12:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['BASIC']?['FT_PCT'] ??
            0;
      case 13:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['EFG_PCT'] ??
            0;
      case 14:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['TS_PCT'] ??
            0;
      case 15:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['SHOOTING']
                ?['CLOSEST_DEFENDER']?['6+ Feet - Wide Open']?['FG3_PCT'] ??
            0;
      case 16:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['USG_PCT'] ??
            0;
      case 17:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['NET_RATING_ON_OFF'] ??
            0;
      case 18:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['OFF_RATING_ON_OFF'] ??
            0;
      case 19:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['DEF_RATING_ON_OFF'] ??
            0;
      case 20:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['POSS'] ??
            0;
      case 21:
        return player['STATS']?[widget.selectedSeason]
                ?[widget.selectedSeasonType]?['ADV']?['TOUCHES']?['TOUCHES'] ??
            0;
      case 22:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['TOUCHES']
                ?['AVG_DRIB_PER_TOUCH'] ??
            0;
      case 23:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['TOUCHES']
                ?['AVG_SEC_PER_TOUCH'] ??
            0;
      case 24:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['TOUCHES']
                ?['FGA_PER_TOUCH'] ??
            0;
      case 25:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['TOUCHES']
                ?['PASSES_PER_TOUCH'] ??
            0;
      case 26:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['TOUCHES']
                ?['TOV_PER_TOUCH'] ??
            0;
      case 27:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['TOUCHES']
                ?['PFD_PER_TOUCH'] ??
            0;
      case 28:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['PASSING']
                ?['PASSES_MADE'] ??
            0;
      case 29:
        return player['STATS']?[widget.selectedSeason]
                    ?[widget.selectedSeasonType]?['ADV']?['PASSING']
                ?['AST_TO_PASS_PCT_ADJ'] ??
            0;
      default:
        return player['DISPLAY_FI_LAST'] ?? '';
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
      columns: widget.selectedColumns.map((col) {
        return TableColumn(
          width: MediaQuery.of(context).size.width * col.width,
          freezePriority: col.index == 0 ? 1 : 0,
        );
      }).toList(),
      rowBuilder: _rowBuilder,
      headerBuilder: _headerBuilder,
    );
  }

  Widget _headerBuilder(
          BuildContext context, TableRowContentBuilder contentBuilder) =>
      contentBuilder(
        context,
        (context, column) {
          final col = widget.selectedColumns[column];
          return Material(
            color: Colors.grey.shade800,
            child: InkWell(
              onTap: () {
                final isAscending =
                    _sortColumnIndex == column && _sortAscending;
                _sort<dynamic>(
                  (player) => _getSortingKey(player, col.index),
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
                      col.header,
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
      BuildContext context, int row, TableRowContentBuilder contentBuilder) {
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
            final col = widget.selectedColumns[column];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: getContent(widget.players, row, col.index, context),
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
            const Spacer(),
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
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['AGE']!.toStringAsFixed(0)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 3:
        return StandingsDataText(
            text: positionsMap[widget.players[row]['POSITION']!]!);
      case 4:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['PTS']! / widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 5:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['REB']! / widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 6:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['AST']! / widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 7:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['STL']! / widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 8:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['BLK']! / widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 9:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['TOV']! / widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 10:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['FG_PCT'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 11:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['FG3_PCT'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 12:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['BASIC']['FT_PCT'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 13:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['EFG_PCT'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 14:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TS_PCT'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 15:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['SHOOTING']['CLOSEST_DEFENDER']['6+ Feet - Wide Open']['FG3_PCT'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 16:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['USG_PCT'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 17:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['NET_RATING_ON_OFF'].toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 18:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['OFF_RATING_ON_OFF'].toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 19:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['DEF_RATING_ON_OFF'].toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 20:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['POSS'].toStringAsFixed(0)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 21:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TOUCHES']['TOUCHES'].toStringAsFixed(0)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 22:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TOUCHES']['AVG_DRIB_PER_TOUCH'].toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 23:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TOUCHES']['AVG_SEC_PER_TOUCH'].toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 24:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TOUCHES']['FGA_PER_TOUCH'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 25:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TOUCHES']['PASSES_PER_TOUCH'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 26:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TOUCHES']['TOV_PER_TOUCH'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 27:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['TOUCHES']['PFD_PER_TOUCH'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 28:
        String value = '';
        try {
          value =
              '${widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['PASSING']['PASSES_MADE'].toStringAsFixed(0)}';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
      case 29:
        String value = '';
        try {
          value =
              '${(widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType]['ADV']['PASSING']['AST_TO_PASS_PCT_ADJ'] * 100).toStringAsFixed(1)}%';
        } catch (e) {
          value = '-';
        }
        return StandingsDataText(text: value);
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
