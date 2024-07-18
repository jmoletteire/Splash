import 'package:auto_size_text/auto_size_text.dart';
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

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> p) getValue, int columnIndex,
      bool ascending) {
    widget.players.sort((a, b) {
      final aValue = getValue(a);
      final bValue = getValue(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Comparable<dynamic> _getSortingValues(Map<String, dynamic> player, ColumnOption column) {
    Map<String, dynamic> playerStats =
        player['STATS']?[widget.selectedSeason]?[widget.selectedSeasonType];

    switch (column.getIndex(kAllColumns)) {
      case 0:
        return player['DISPLAY_FI_LAST'] ?? '';
      case 1:
        return player['TEAM_ID'] ?? 0;
      case 2:
        return playerStats['BASIC']?['AGE'] ?? 0;
      case 3:
        return player['POSITION'] ?? '';
      case 8:
        int pts = playerStats['BASIC']?['PTS'] ?? 0;
        int gp = playerStats['BASIC']?['GP'] ?? 0;
        return gp != 0 ? pts / gp : 0.0;
      case 9:
        int reb = playerStats['BASIC']?['REB'] ?? 0;
        int gp = playerStats['BASIC']?['GP'] ?? 0;
        return gp != 0 ? reb / gp : 0.0;
      case 10:
        int ast = playerStats['BASIC']?['AST'] ?? 0;
        int gp = playerStats['BASIC']?['GP'] ?? 0;
        return gp != 0 ? ast / gp : 0.0;
      case 11:
        int stl = playerStats['BASIC']?['STL'] ?? 0;
        int gp = playerStats['BASIC']?['GP'] ?? 0;
        return gp != 0 ? stl / gp : 0.0;
      case 12:
        int blk = playerStats['BASIC']?['BLK'] ?? 0;
        int gp = playerStats['BASIC']?['GP'] ?? 0;
        return gp != 0 ? blk / gp : 0.0;
      case 13:
        int tov = playerStats['BASIC']?['TOV'] ?? 0;
        int gp = playerStats['BASIC']?['GP'] ?? 0;
        return gp != 0 ? tov / gp : 0.0;
      default:
        return getValueFromMap(
          playerStats,
          kPlayerStatLabelMap[column.mapKey][column.mapName]['location'],
          kPlayerStatLabelMap[column.mapKey][column.mapName]['TOTAL']['nba_name'],
        );
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
          freezePriority: col.getIndex(kAllColumns) == 0 ? 1 : 0,
        );
      }).toList(),
      rowBuilder: _rowBuilder,
      headerBuilder: _headerBuilder,
    );
  }

  Widget _headerBuilder(BuildContext context, TableRowContentBuilder contentBuilder) =>
      contentBuilder(
        context,
        (context, column) {
          final col = widget.selectedColumns[column];
          return Material(
            color: Colors.grey.shade800,
            child: InkWell(
              onTap: () {
                bool isCurrentlySortedColumn = _sortColumnIndex == column;
                bool ascending = isCurrentlySortedColumn ? !_sortAscending : false;
                _sort<dynamic>(
                  (player) => _getSortingValues(player, col),
                  column,
                  ascending,
                );
              },
              child: Padding(
                padding: column == 0
                    ? const EdgeInsets.only(left: 20.0)
                    : _sortColumnIndex != column
                        ? const EdgeInsets.only(right: 8.0)
                        : EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment:
                      column == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    Text(
                      col.headerName,
                      style: kBebasNormal.copyWith(
                        fontSize: 18.0,
                      ),
                    ),
                    if (_sortColumnIndex == column)
                      Icon(
                        _sortAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
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

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
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
              child: getContent(row, col.getIndex(kAllColumns), col.mapName, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(int row, int column, String statName, BuildContext context) {
    Map<String, dynamic> playerStats =
        widget.players[row]['STATS'][widget.selectedSeason][widget.selectedSeasonType];

    Map<String, Widget> statValues = buildPlayerStatValues(playerStats);

    switch (column) {
      case 0:
        return Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 8.0, 0.0, 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  (row + 1).toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(color: Colors.grey, fontSize: 16.0),
                ),
              ),
              const SizedBox(width: 8.0),
              PlayerAvatar(
                radius: 12.0,
                backgroundColor: Colors.white70,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.players[row]['PERSON_ID']}.png',
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 5,
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
          value = '${playerStats['BASIC']['AGE']!.toStringAsFixed(0)}';
        } catch (e) {
          value = '-';
        }
        return PlayerStatsTableText(text: value);
      case 3:
        return PlayerStatsTableText(text: positionsMap[widget.players[row]['POSITION']!]!);
      case 8:
        String value = '';
        try {
          value =
              '${(playerStats['BASIC']['PTS']! / playerStats['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return PlayerStatsTableText(text: value);
      case 9:
        String value = '';
        try {
          value =
              '${(playerStats['BASIC']['REB']! / playerStats['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return PlayerStatsTableText(text: value);
      case 10:
        String value = '';
        try {
          value =
              '${(playerStats['BASIC']['AST']! / playerStats['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return PlayerStatsTableText(text: value);
      case 11:
        String value = '';
        try {
          value =
              '${(playerStats['BASIC']['STL']! / playerStats['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return PlayerStatsTableText(text: value);
      case 12:
        String value = '';
        try {
          value =
              '${(playerStats['BASIC']['BLK']! / playerStats['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return PlayerStatsTableText(text: value);
      case 13:
        String value = '';
        try {
          value =
              '${(playerStats['BASIC']['TOV']! / playerStats['BASIC']['GP']!).toStringAsFixed(1)}';
        } catch (e) {
          value = '-';
        }
        return PlayerStatsTableText(text: value);
      default:
        return statValues[statName]!;
    }
  }

  dynamic getValueFromMap(Map<String, dynamic> map, List<String> keys, String stat) {
    dynamic value = map;

    for (var key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return 0; // Return null if any key is not found
      }
    }

    return value[stat] ?? 0;
  }

  /// Returns stat value as String for PlayersTable
  Widget getStatText(
    num statValue,
    String perMode,
    String round,
    String convert,
    String statName,
  ) {
    String value = '';
    try {
      statValue = convert == 'true' ? statValue * 100 : statValue;
      value = round == '0'
          ? (perMode == 'PER_75' && statName != 'MIN' && statName != 'GP' && statName != 'POSS'
              ? statValue.toStringAsFixed(1)
              : statValue.toStringAsFixed(0))
          : convert == 'true'
              ? '${statValue.toStringAsFixed(int.parse(round))}%'
              : statValue.toStringAsFixed(int.parse(round));
    } catch (e) {
      value = '-';
    }
    return PlayerStatsTableText(text: value);
  }

  /// Loops through Stats map to create list of stat Texts
  /// Each List represents a row in the PlayersTable
  Map<String, Widget> buildPlayerStatValues(Map<String, dynamic> player) {
    Map<String, Widget> playerStatWidgets = {};

    kPlayerStatLabelMap.forEach((category, stats) {
      stats.forEach((statName, statDetails) {
        if (statName.startsWith('fill')) {
          return; // Skip this iteration
        }
        playerStatWidgets[statName] = getStatText(
          getValueFromMap(
            player,
            statDetails['location'],
            statDetails['TOTAL']['nba_name'],
          ),
          'TOTAL', // or 'PER_75', depending on your use case
          statDetails['round'],
          statDetails['convert'],
          statName,
        );
      });
    });

    return playerStatWidgets;
  }
}

class PlayerStatsTableText extends StatelessWidget {
  const PlayerStatsTableText({super.key, required this.text, this.alignment});

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
