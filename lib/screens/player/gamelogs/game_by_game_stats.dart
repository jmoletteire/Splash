import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../utilities/constants.dart';
import '../../game/game_home.dart';

class GameByGameStats extends StatefulWidget {
  final Map<String, dynamic> player;
  final List<String> gameIds;
  final Map<String, dynamic> schedule;

  const GameByGameStats({
    super.key,
    required this.player,
    required this.gameIds,
    required this.schedule,
  });

  @override
  State<GameByGameStats> createState() => _GameByGameStatsState();
}

class _GameByGameStatsState extends State<GameByGameStats> {
  bool _gameIdsPrepared = false;

  List columnNames = [
    'DATE',
    'OPP',
    'MIN',
    'PTS',
    'REB',
    'AST',
    'TOV',
    'STL',
    'BLK',
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

  Map<String, String> seasonTypes = {
    '*': 'ALL',
    '1': 'PRE-SEASON',
    '2': 'REGULAR SEASON',
    '4': 'PLAYOFFS',
    '5': 'PLAY-IN',
    '6': 'NBA CUP',
  };

  void _prepareGameIds() {
    if (widget.gameIds.isNotEmpty) {
      // Get the first game in the list
      var firstGame = widget.schedule[widget.gameIds.first];

      if (firstGame != null) {
        // Check if the season type row is already present at the beginning
        String firstSeasonType = seasonTypes[firstGame['GAME_ID'][2]]!;
        if (widget.gameIds.first != firstSeasonType) {
          widget.gameIds.insert(0, firstSeasonType);
        }
      }
    }

    Map<String, dynamic>? lastValidGame;

    // Start loop from index 1 since we already handled the first element
    for (int i = 1; i < widget.gameIds.length; i++) {
      var game = widget.schedule[widget.gameIds[i]];

      // If it's a regular game entry, update lastValidGame
      if (game != null) {
        String currentSeasonType = seasonTypes[game['GAME_ID'][2]]!;

        // Check if the previous item is not the same season type
        if (lastValidGame != null &&
            currentSeasonType != seasonTypes[lastValidGame['GAME_ID'][2]]!) {
          // Check if the season type row already exists before inserting
          if (widget.gameIds[i - 1] != currentSeasonType) {
            widget.gameIds.insert(i, currentSeasonType);
            i++; // Skip the inserted row to avoid re-checking it
          }
        }
        lastValidGame = game; // Update last valid game
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _prepareGameIds();

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
      rowCount: widget.gameIds.length,
      rowHeight: MediaQuery.of(context).size.height * 0.055,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// DATE
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.12,
          freezePriority: 1,
        ),

        /// OPP
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.18,
          freezePriority: 1,
        ),

        /// MIN
        TableColumn(width: MediaQuery.of(context).size.width * 0.12),

        /// PTS
        TableColumn(width: MediaQuery.of(context).size.width * 0.11),

        /// REB
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// AST
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// STL
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// BLK
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// TOV
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// FG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.12),

        /// 3P%
        TableColumn(width: MediaQuery.of(context).size.width * 0.11),

        /// FT%
        TableColumn(width: MediaQuery.of(context).size.width * 0.11),

        /// eFG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.11),

        /// TS%
        TableColumn(width: MediaQuery.of(context).size.width * 0.11),

        /// USG%
        TableColumn(width: MediaQuery.of(context).size.width * 0.11),

        /// ORTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// DRTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// NRTG
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
              padding: column == 0
                  ? const EdgeInsets.only(left: 11.0)
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
          child: child,
        ),
      );

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    var gameId = widget.gameIds[row];

    // Check if the row is a season type (not a regular game ID)
    if (seasonTypes.values.contains(gameId)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        alignment: Alignment.centerLeft,
        child: Text(
          gameId,
          style: kBebasNormal.copyWith(fontSize: 14.0),
        ),
      );
    }

    // Normal row rendering
    var game = widget.schedule[gameId];

    String matchup = game['MATCHUP'].toString();
    String teamId = game['TEAM_ID'].toString();
    String oppId = kTeamIds[matchup.substring(matchup.length - 3)]!;
    game['OPP_ID'] = oppId;
    bool homeAway = matchup[4] != '@';
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
                  builder: (context) => GameHome(
                    gameId: widget.gameIds[row],
                    homeId: homeAway == true ? teamId : oppId,
                    awayId: homeAway == true ? oppId : teamId,
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
              child: getContent(game, row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(Map<String, dynamic> game, int row, int column, BuildContext context) {
    List<String> formatDate(String date) {
      // Parse the string to a DateTime object
      DateTime dateTime = DateTime.parse(date);

      // Create a DateFormat for the abbreviated day of the week
      DateFormat dayOfWeekFormat = DateFormat('E');
      String dayOfWeek = dayOfWeekFormat.format(dateTime);

      // Create a DateFormat for the month and date
      DateFormat monthDateFormat = DateFormat('M/d');
      String monthDate = monthDateFormat.format(dateTime);

      return [dayOfWeek, monthDate];
    }

    List<String> gameDate = formatDate(game['GAME_DATE']);

    switch (column) {
      case 0:
        return Padding(
          padding: const EdgeInsets.only(left: 11.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameDate[0],
                style: kBebasNormal.copyWith(fontSize: 13.0, color: Colors.white70),
              ),
              Text(
                gameDate[1],
                style: kBebasNormal.copyWith(fontSize: 13.0),
              ),
            ],
          ),
        );
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              game['MATCHUP'][4] == '@'
                  ? game['MATCHUP'].substring(4)
                  : game['MATCHUP'].substring(8) ?? '-',
              style: kBebasBold.copyWith(fontSize: 15.0),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 15.0),
              child: Image.asset(
                'images/NBA_Logos/${game['OPP_ID']}.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
                width: 15.0,
              ),
            ),
          ],
        );
      case 2:
        String convertMinutes(double decimalMinutes) {
          int wholeMinutes = decimalMinutes.floor();
          int seconds = ((decimalMinutes - wholeMinutes) * 60).round();
          return '${wholeMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }
        return StandingsDataText(
            text: game['MIN'].toStringAsFixed(0) == '0' ? '-' : convertMinutes(game['MIN']));
      case 3:
        return StandingsDataText(text: game['PTS'].toStringAsFixed(0) ?? '-');
      case 4:
        return StandingsDataText(text: game['REB'].toStringAsFixed(0) ?? '-');
      case 5:
        return StandingsDataText(text: game['AST'].toStringAsFixed(0) ?? '-');
      case 6:
        return StandingsDataText(text: game['TOV'].toStringAsFixed(0) ?? '-');
      case 7:
        return StandingsDataText(text: game['STL'].toStringAsFixed(0) ?? '-');
      case 8:
        return StandingsDataText(text: game['BLK'].toStringAsFixed(0) ?? '-');
      case 9:
        String fgm = game['FGM'].toStringAsFixed(0);
        String fga = game['FGA'].toStringAsFixed(0);
        return StandingsDataText(text: fga == '0' ? '-' : '$fgm-$fga');
      case 10:
        String fg3m = game['FG3M'].toStringAsFixed(0);
        String fg3a = game['FG3A'].toStringAsFixed(0);
        return StandingsDataText(text: fg3a == '0' ? '-' : '$fg3m-$fg3a');
      case 11:
        String ftm = game['FTM'].toStringAsFixed(0);
        String fta = game['FTA'].toStringAsFixed(0);
        return StandingsDataText(text: fta == '0' ? '-' : '$ftm-$fta');
      case 12:
        return StandingsDataText(text: game['MIN'].toStringAsFixed(0) ?? '-');
      case 13:
        return StandingsDataText(text: game['MIN'].toStringAsFixed(0) ?? '-');
      case 14:
        return StandingsDataText(text: game['MIN'].toStringAsFixed(0) ?? '-');
      case 15:
        return StandingsDataText(text: game['MIN'].toStringAsFixed(0) ?? '-');
      case 16:
        return StandingsDataText(text: game['MIN'].toStringAsFixed(0) ?? '-');
      case 17:
        return StandingsDataText(text: game['MIN'].toStringAsFixed(0) ?? '-');
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
      child: AutoSizeText(
        text,
        style: kBebasNormal.copyWith(fontSize: 17.0),
        maxLines: 1,
      ),
    );
  }
}
