import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  List columnNames = [
    'DATE',
    'OPP',
    'POSS',
    'MIN',
    'PTS',
    'REB',
    'AST',
    'TO',
    'FG',
    '3P',
    'FT',
    'STL',
    'BLK',
    'ORB',
    'DRB',
    'PF',
    'eFG%',
    'TS%',
    'USG%',
    'NRTG',
    'ORTG',
    'DRTG',
    'PACE',
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
      headerHeight: MediaQuery.of(context).size.height * 0.045,
      rowCount: widget.gameIds.length,
      rowHeight: MediaQuery.of(context).size.height * 0.055,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// DATE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.12,
          freezePriority: 1,
        ),

        /// OPP
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.18,
          freezePriority: 1,
        ),

        /// POSS
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// MIN
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// PTS
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.11,
        ),

        /// REB
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// AST
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// TOV
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// FG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// 3P%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.11,
        ),

        /// FT%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.11,
        ),

        /// STL
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// BLK
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// OREB
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// DREB
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// PF
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// eFG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// TS%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// USG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// NRTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// ORTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// DRTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// PACE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
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
              padding:
                  column == 0 ? EdgeInsets.only(left: 11.0.r) : EdgeInsets.only(right: 8.0.r),
              child: Align(
                alignment: column == 0
                    ? Alignment.centerLeft
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
          child: child,
        ),
      );

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    var gameId = widget.gameIds[row];

    // Check if the row is a season type (not a regular game ID)
    if (seasonTypes.values.contains(gameId)) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
        alignment: Alignment.centerLeft,
        child: Text(
          gameId,
          style: kBebasNormal.copyWith(fontSize: 12.0.r),
        ),
      );
    }

    // Normal row rendering
    var game = widget.schedule[gameId];

    String matchup = game['MATCHUP'].toString();
    String teamId = game['TEAM_ID'].toString();
    String oppId = kTeamAbbrToId[matchup.substring(matchup.length - 3)] ?? '0';
    game['OPP_ID'] = oppId;
    bool homeAway = matchup[4] != '@';
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            if (int.parse(widget.schedule[gameId]['GAME_DATE'].substring(0, 4)) >= 2018) {
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
            }
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: EdgeInsets.only(right: 8.0.r),
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
          padding: EdgeInsets.only(left: 9.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameDate[0],
                style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.white70),
              ),
              Text(
                gameDate[1],
                style: kBebasNormal.copyWith(fontSize: 11.0.r),
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
              style: kBebasBold.copyWith(fontSize: 13.0.r),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 15.0.r),
              child: Image.asset(
                'images/NBA_Logos/${game['OPP_ID']}.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
                width: 15.0.r,
              ),
            ),
          ],
        );
      case 2:
        return StandingsDataText(text: game['POSS'].toStringAsFixed(0) ?? '-');
      case 3:
        String convertMinutes(double decimalMinutes) {
          int wholeMinutes = decimalMinutes.floor();
          int seconds = ((decimalMinutes - wholeMinutes) * 60).round();
          return '${wholeMinutes.toString()}:${seconds.toString().padLeft(2, '0')}';
        }
        return StandingsDataText(
          text: game['MIN'].toStringAsFixed(0) == '0' ? '-' : convertMinutes(game['MIN']),
          size: 14.0.r,
        );
      case 4:
        return StandingsDataText(text: game['PTS'].toStringAsFixed(0) ?? '-');
      case 5:
        return StandingsDataText(text: game['REB'].toStringAsFixed(0) ?? '-');
      case 6:
        return StandingsDataText(text: game['AST'].toStringAsFixed(0) ?? '-');
      case 7:
        return StandingsDataText(text: game['TOV'].toStringAsFixed(0) ?? '-');
      case 8:
        String fgm = game['FGM'].toStringAsFixed(0);
        String fga = game['FGA'].toStringAsFixed(0);
        return StandingsDataText(text: fga == '0' ? '-' : '$fgm-$fga');
      case 9:
        String fg3m = game['FG3M'].toStringAsFixed(0);
        String fg3a = game['FG3A'].toStringAsFixed(0);
        return StandingsDataText(text: fg3a == '0' ? '-' : '$fg3m-$fg3a');
      case 10:
        String ftm = game['FTM'].toStringAsFixed(0);
        String fta = game['FTA'].toStringAsFixed(0);
        return StandingsDataText(text: fta == '0' ? '-' : '$ftm-$fta');
      case 11:
        return StandingsDataText(text: game['STL'].toStringAsFixed(0) ?? '-');
      case 12:
        return StandingsDataText(text: game['BLK'].toStringAsFixed(0) ?? '-');
      case 13:
        return StandingsDataText(text: game['OREB'].toStringAsFixed(0) ?? '-');
      case 14:
        return StandingsDataText(text: game['DREB'].toStringAsFixed(0) ?? '-');
      case 15:
        return StandingsDataText(text: game['PF'].toStringAsFixed(0) ?? '-');
      case 16:
        return StandingsDataText(
            text: '${(game['EFG_PCT'] * 100).toStringAsFixed(1)}%' ?? '-');
      case 17:
        return StandingsDataText(text: '${(game['TS_PCT'] * 100).toStringAsFixed(1)}%');
      case 18:
        return StandingsDataText(text: '${(game['USG_PCT'] * 100).toStringAsFixed(1)}%');
      case 19:
        return StandingsDataText(text: game['NET_RATING'].toStringAsFixed(1) ?? '-');
      case 20:
        return StandingsDataText(text: game['OFF_RATING'].toStringAsFixed(1) ?? '-');
      case 21:
        return StandingsDataText(text: game['DEF_RATING'].toStringAsFixed(1) ?? '-');
      case 22:
        return StandingsDataText(text: game['PACE'].toStringAsFixed(1) ?? '-');
      default:
        return const Text('-');
    }
  }
}

class StandingsDataText extends StatelessWidget {
  const StandingsDataText({super.key, required this.text, this.size, this.alignment});

  final Alignment? alignment;
  final String text;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: AutoSizeText(
        text,
        style: kBebasNormal.copyWith(fontSize: size ?? 15.0.r),
        maxLines: 1,
      ),
    );
  }
}
