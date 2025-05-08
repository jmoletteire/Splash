import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../components/player_avatar.dart';
import '../../../utilities/constants.dart';
import '../../player/player_home.dart';

class BoxPlayerStats extends StatefulWidget {
  final List<dynamic> players;
  final String playerGroup;
  final dynamic team;
  final bool inProgress;
  final ScrollController controller;

  const BoxPlayerStats({
    super.key,
    required this.players,
    required this.playerGroup,
    required this.team,
    required this.inProgress,
    required this.controller,
  });

  @override
  State<BoxPlayerStats> createState() => _BoxPlayerStatsState();
}

class _BoxPlayerStatsState extends State<BoxPlayerStats> {
  late double availableWidth;
  late double availableHeight;
  late bool isLandscape;
  final List<Map<String, dynamic>> _players = [];
  List<String> columnNames = [];
  List<TableColumn> tableColumns = [];
  bool hasPoss = false;
  bool hasXPts = false;
  Widget? _cachedHeader;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.players.length; i++) {
      setPlayer(i);
    }

    // Check if possession data is available for any player
    hasPoss = widget.players
        .any((player) => player['statistics']?['POSS'] != null || player['POSS'] != null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    availableWidth = MediaQuery.of(context).size.width;
    availableHeight = MediaQuery.of(context).size.height;
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    _initializeColumns();
  }

  @override
  void didUpdateWidget(covariant BoxPlayerStats oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the game data has changed
    if (oldWidget.players != widget.players) {
      // Loop through both lists of players and compare each field
      for (int i = 0; i < widget.players.length; i++) {
        if (i >= oldWidget.players.length) break;

        final newPlayer = widget.players[i];
        final oldPlayer = oldWidget.players[i];

        // Compare each key in the new player against the old player
        bool hasChanges = false;
        newPlayer.forEach((key, newValue) {
          final oldValue = oldPlayer[key];
          if (newValue != oldValue) {
            hasChanges = true;
            // Call setPlayer() when a change is found and exit the forEach loop
            setPlayer(i);
            return;
          }
        });

        // Move on to the next player if no changes were found
        if (!hasChanges) continue;
      }
    }
  }

  void _initializeColumns() {
    columnNames = [
      widget.playerGroup,
      if (hasPoss) 'POSS',
      'MIN',
      if (hasXPts) 'xPTS', // Only add xPTS if data is available
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
      '+/-',
      'eFG%',
      'TS%',
      'USG%',
      'NRTG',
      'ORTG',
      'DRTG'
    ];
    tableColumns = [
      /// PLAYER
      TableColumn(
        width: isLandscape ? availableWidth * 0.15 : availableWidth * 0.38,
        freezePriority: 1,
      ),

      /// POSS
      if (columnNames.contains('POSS'))
        TableColumn(
          width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.09,
        ),

      /// MIN
      TableColumn(
        width: isLandscape ? availableWidth * 0.05 : availableWidth * 0.125,
      ),

      /// PTS
      TableColumn(
        width: isLandscape ? availableWidth * 0.05 : availableWidth * 0.1,
      ),

      /// REB
      TableColumn(
        width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.08,
      ),

      /// AST
      TableColumn(
        width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.08,
      ),

      /// TOV
      TableColumn(
        width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.08,
      ),

      /// FGM - FGA
      TableColumn(
        width: isLandscape ? availableWidth * 0.05 : availableWidth * 0.11,
      ),

      /// 3PM - 3PA
      TableColumn(
        width: isLandscape ? availableWidth * 0.05 : availableWidth * 0.11,
      ),

      /// FTM - FTA
      TableColumn(
        width: isLandscape ? availableWidth * 0.05 : availableWidth * 0.11,
      ),

      /// STL
      TableColumn(
        width: isLandscape ? availableWidth * 0.04 : availableWidth * 0.1,
      ),

      /// BLK
      TableColumn(
        width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.08,
      ),

      /// OREB
      TableColumn(
        width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.08,
      ),

      /// DREB
      TableColumn(
        width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.08,
      ),

      /// PF
      TableColumn(
        width: isLandscape ? availableWidth * 0.03 : availableWidth * 0.08,
      ),

      /// +/-
      TableColumn(
        width: isLandscape ? availableWidth * 0.05 : availableWidth * 0.1,
      ),

      /// EFG%
      TableColumn(
        width: isLandscape ? availableWidth * 0.06 : availableWidth * 0.13,
      ),

      /// TS%
      if (!widget.inProgress)
        TableColumn(
          width: isLandscape ? availableWidth * 0.06 : availableWidth * 0.13,
        ),

      /// USG%
      if (!widget.inProgress)
        TableColumn(
          width: isLandscape ? availableWidth * 0.06 : availableWidth * 0.13,
        ),

      /// NRTG
      if (!widget.inProgress)
        TableColumn(
          width: isLandscape ? availableWidth * 0.06 : availableWidth * 0.13,
        ),

      /// ORTG
      if (!widget.inProgress)
        TableColumn(
          width: isLandscape ? availableWidth * 0.06 : availableWidth * 0.13,
        ),

      /// DRTG
      if (!widget.inProgress)
        TableColumn(
          width: isLandscape ? availableWidth * 0.06 : availableWidth * 0.13,
        ),
    ];
  }

  void setPlayer(int index) {
    void ensureItemExists(List<Map<String, dynamic>> players, int index) {
      // Check if the list is shorter than the desired index
      if (players.length <= index) {
        // Add empty maps until the desired index is reachable
        players.addAll(List.generate(index + 1 - players.length, (_) => {}));
      }
      // Set the item at the desired index to an empty map
      players[index] = {};
    }

    ensureItemExists(_players, index);

    int played = int.parse(widget.players[index]?['played'] ?? '1');

    _players[index]['nameWidget'] = playerNameWidget(index);
    _players[index]['possWidget'] = possWidget(index, played);
    _players[index]['minutesWidget'] = minutesWidget(index, played);
    _players[index]['ptsWidget'] = basicStatWidget(index, played, 'PTS', 'PTS');
    _players[index]['rebWidget'] = basicStatWidget(index, played, 'REB', 'REB');
    _players[index]['astWidget'] = basicStatWidget(index, played, 'AST', 'AST');
    _players[index]['tovWidget'] = basicStatWidget(index, played, 'TO', 'TO');
    _players[index]['stlWidget'] = basicStatWidget(index, played, 'STL', 'STL');
    _players[index]['blkWidget'] = basicStatWidget(index, played, 'BLK', 'BLK');
    _players[index]['orebWidget'] = basicStatWidget(index, played, 'ORB', 'OREB');
    _players[index]['drebWidget'] = basicStatWidget(index, played, 'DRB', 'DREB');
    _players[index]['pfWidget'] = basicStatWidget(index, played, 'PF', 'PF');
    _players[index]['plusMinusWidget'] =
        basicStatWidget(index, played, 'PlusMinus', 'PLUS_MINUS');
    _players[index]['fgWidget'] =
        shootingAttemptsWidget(index, played, 'FGM', 'FGA', 'FGM', 'FGA');
    _players[index]['fg3Widget'] =
        shootingAttemptsWidget(index, played, '3PM', '3PA', 'FG3M', 'FG3A');
    _players[index]['ftWidget'] =
        shootingAttemptsWidget(index, played, 'FTM', 'FTA', 'FTM', 'FTA');
    _players[index]['efgWidget'] = efgWidget(index, played);
    _players[index]['tsWidget'] = basicStatWidget(index, played, 'TS%', 'TS_PCT');
    _players[index]['usgWidget'] = basicStatWidget(index, played, 'USG%', 'USG_PCT');
    _players[index]['nRtgWidget'] = nRtgWidget(index, played);
    _players[index]['oRtgWidget'] = oRtgWidget(index, played);
    _players[index]['dRtgWidget'] = dRtgWidget(index, played);
  }

  @override
  Widget build(BuildContext context) {
    return SliverTableView.builder(
      addAutomaticKeepAlives: true,
      horizontalScrollController: widget.controller,
      style: const TableViewStyle(
        dividers: TableViewDividersStyle(
          vertical: TableViewVerticalDividersStyle.symmetric(
            TableViewVerticalDividerStyle(wiggleCount: 0),
          ),
        ),
        scrollbars: TableViewScrollbarsStyle.symmetric(
          TableViewScrollbarStyle(
            scrollPadding: false,
            enabled: TableViewScrollbarEnabled.never,
          ),
        ),
      ),
      headerHeight: availableHeight * 0.045,
      rowCount: widget.players.length,
      rowHeight: availableHeight * 0.06,
      minScrollableWidth: availableWidth * 0.01,
      columns: tableColumns,
      rowBuilder: _rowBuilder,
      headerBuilder: _headerBuilder,
    );
  }

  Widget _headerBuilder(BuildContext context, TableRowContentBuilder contentBuilder) {
    // Use the cached header if it exists; otherwise, build and cache it
    return _cachedHeader ??= contentBuilder(
      context,
      (context, column) {
        return Material(
          color: const Color(0xFF303030),
          child: Padding(
            padding:
                column == 0 ? EdgeInsets.only(left: 20.0.r) : EdgeInsets.only(right: 8.0.r),
            child: Align(
              alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
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
  }

  /// This is used to wrap both regular and placeholder rows to achieve fade
  /// transition between them and to insert optional row divider.
  Widget _wrapRow(int index, Widget child) => KeyedSubtree(
        key: ValueKey(index),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade700,
                width: 0.5,
              ),
            ),
          ),
          child: child,
        ),
      );

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    // Build and cache the row if not already cached
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PlayerHome(playerId: widget.players[row]?['personId'] ?? '0'),
              ),
            );
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return RepaintBoundary(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                child: getContent(row, column, context),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(int row, int column, BuildContext context) {
    int adjColumn = hasPoss && hasXPts
        ? column
        : !hasPoss && hasXPts
            ? column >= 1
                ? column + 1
                : column
            : hasPoss && !hasXPts
                ? column >= 3
                    ? column + 1
                    : column
                : column == 0
                    ? column
                    : column == 1
                        ? column + 1
                        : column + 2;

    switch (adjColumn) {
      case 0:
        return _players[row]['nameWidget'];
      case 1:
        return _players[row]['possWidget'];
      case 2:
        return _players[row]['minutesWidget'];
      case 3:
        return _players[row]['xPtsWidget'];
      case 4:
        return _players[row]['ptsWidget'];
      case 5:
        return _players[row]['rebWidget'];
      case 6:
        return _players[row]['astWidget'];
      case 7:
        return _players[row]['tovWidget'];
      case 8:
        return _players[row]['fgWidget'];
      case 9:
        return _players[row]['fg3Widget'];
      case 10:
        return _players[row]['ftWidget'];
      case 11:
        return _players[row]['stlWidget'];
      case 12:
        return _players[row]['blkWidget'];
      case 13:
        return _players[row]['orebWidget'];
      case 14:
        return _players[row]['drebWidget'];
      case 15:
        return _players[row]['pfWidget'];
      case 16:
        return _players[row]['plusMinusWidget'];
      case 17:
        return _players[row]['efgWidget'];
      case 18:
        return _players[row]['tsWidget'];
      case 19:
        return _players[row]['usgWidget'];
      case 20:
        return _players[row]['nRtgWidget'];
      case 21:
        return _players[row]['oRtgWidget'];
      case 22:
        return _players[row]['dRtgWidget'];
      default:
        return const Text('-');
    }
  }

  Widget playerNameWidget(int index) {
    String jersey = widget.players[index]?['number'] ?? '';
    String playerId = widget.players[index]?['personId'] ?? '0';
    String name = widget.players[index]?['name'] ?? '';
    String position = widget.players[index]?['position'] ?? '';
    int onCourt = widget.inProgress ? int.parse(widget.players[index]?['inGame'] ?? '0') : 0;

    return RepaintBoundary(
      key: ValueKey(onCourt),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            if (jersey != '')
              SizedBox(
                width: 12.0.r,
                child: Text(
                  jersey,
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(color: Colors.grey, fontSize: 12.0.r),
                ),
              ),
            SizedBox(width: 8.0.r),
            PlayerAvatar(
              radius: 12.0.r,
              backgroundColor: Colors.white12,
              playerImageUrl:
                  'https://cdn.nba.com/headshots/nba/latest/1040x760/$playerId.png',
            ),
            SizedBox(width: 5.0.r),
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: kBebasNormal.copyWith(
                        color: Colors.white70,
                        fontSize: 14.0.r,
                      ),
                    ),
                    if (position != '')
                      TextSpan(
                        text: ', $position',
                        style: kBebasNormal.copyWith(
                          color: Colors.white,
                          fontSize: 13.0.r,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (onCourt == 1) SizedBox(width: 8.0.r),
            if (onCourt == 1)
              Container(
                width: 6.0.r, // Size of the dot
                height: 6.0.r,
                decoration: const BoxDecoration(
                  color: Color(0xFF55F86F), // Green color for the dot
                  shape: BoxShape.circle, // Circular shape
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget possWidget(int index, int played) {
    try {
      if (played == 0 && !widget.inProgress) {
        return BoxScoreDataText(key: const ValueKey('DNP'), text: 'DNP', size: 14.0.r);
      } else if (int.parse(widget.players[index]?['statistics']?['POSS'] ?? '0') == 0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }
      String text = widget.players[index]?['statistics']?['POSS'] ?? '-';
      return RepaintBoundary(
        key: ValueKey(text),
        child: Container(
          alignment: Alignment.centerRight,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(fontSize: 14.0.r),
          ),
        ),
      );
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }

  Widget minutesWidget(int index, int played) {
    String minutes = widget.players[index]?['statistics']?['MIN'] ?? '-';
    try {
      if (played == 0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }
      return RepaintBoundary(
        key: ValueKey(minutes),
        child: Container(
          alignment: Alignment.centerRight,
          child: Text(
            minutes == '0:00' ? '-' : minutes,
            style: kBebasNormal.copyWith(fontSize: 14.0.r),
          ),
        ),
      );
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }

  Widget basicStatWidget(int index, int played, String statName, String statAbbr) {
    try {
      if (played == 0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }
      String text = statName == 'TS%' || statName == 'USG%'
          ? '${((widget.players[index]?['statistics']?[statName] ?? widget.players[index]?[statAbbr] ?? '-') * 100).toStringAsFixed(1)}%'
          : widget.players[index]?['statistics']?[statName] ?? '-';
      return BoxScoreDataText(key: ValueKey(text), text: text);
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }

  Widget shootingAttemptsWidget(int index, int played, String madeName, String attName,
      String madeAbbr, String attAbbr) {
    try {
      if (played == 0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }
      String text =
          '${widget.players[index]?['statistics']?[madeName] ?? ''}-${widget.players[index]?['statistics']?[attName] ?? ''}';
      return BoxScoreDataText(key: ValueKey(text), text: text);
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }

  Widget efgWidget(int index, int played) {
    try {
      if (played == 0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }
      int fieldGoalsAttempted = int.parse(widget.players[index]?['statistics']?['FGA'] ?? '0');

      // Check for division by zero
      if (fieldGoalsAttempted == 0) {
        try {
          return BoxScoreDataText(
              text:
                  '${((widget.players[index]?['statistics']?['eFG%'] ?? widget.players[index]?['eFG%'] ?? 0) * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxScoreDataText(text: '-');
        }
      }

      double efgPct = (((int.parse(widget.players[index]?['statistics']?['FGM'] ?? '0')) +
                  (0.5 * int.parse(widget.players[index]?['statistics']?['3PM'] ?? '0'))) /
              fieldGoalsAttempted) *
          100;

      String text = '${efgPct.toStringAsFixed(1)}%';

      return BoxScoreDataText(key: ValueKey(text), text: text);
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }

  Widget nRtgWidget(int index, int played) {
    try {
      if (played == 0 ||
          (widget.players[index]?['statistics']?['POSS'] ??
                  widget.players[index]?['POSS'] ??
                  0) ==
              0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }

      int possOn = (widget.players[index]?['statistics']?['POSS'] ??
          widget.players[index]?['POSS'] ??
          0);
      int possOff = ((widget.team['POSS'] ?? 0) - possOn);

      double oRtgOn = (widget.players[index]?['statistics']?['OFF_RATING'] ??
          widget.players[index]?['OFF_RATING'] ??
          0.0);
      int ptsOn = (possOn * oRtgOn / 100).round();
      double ptsOff = ((widget.team['points'] ?? widget.team['PTS'] ?? 0) - ptsOn).toDouble();
      double oRtgOff = 100 * ptsOff / possOff;
      double offOnOff = oRtgOn - oRtgOff;

      double dRtgOn = (widget.players[index]?['statistics']?['DEF_RATING'] ??
          widget.players[index]?['DEF_RATING'] ??
          0.0);
      int ptsAgainstOn = (possOn * dRtgOn / 100).round();
      double ptsAgainstOff = ((widget.team['pointsAgainst'] ??
                  ((widget.team['PTS'] ?? 0) - (widget.team['PLUS_MINUS'] ?? 0))) -
              ptsAgainstOn)
          .toDouble();
      double dRtgOff = 100 * ptsAgainstOff / possOff;
      double defOnOff = dRtgOn - dRtgOff;

      double netOnOff = offOnOff - defOnOff;
      String text =
          netOnOff > 0.0 ? '+${netOnOff.toStringAsFixed(1)}' : netOnOff.toStringAsFixed(1);
      return BoxScoreDataText(
        key: ValueKey(text),
        text: text,
        color: netOnOff == 0.0
            ? Colors.white
            : netOnOff > 0.0
                ? const Color(0xFF55F86F)
                : const Color(0xFFFC3126),
      );
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }

  Widget oRtgWidget(int index, int played) {
    try {
      if (played == 0 ||
          (widget.players[index]?['statistics']?['POSS'] ??
                  widget.players[index]?['POSS'] ??
                  0) ==
              0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }

      int possOn = (widget.players[index]?['statistics']?['POSS'] ??
          widget.players[index]?['POSS'] ??
          0);
      int possOff = ((widget.team['POSS'] ?? 0) - possOn);

      double oRtgOn = (widget.players[index]?['statistics']?['OFF_RATING'] ??
          widget.players[index]?['OFF_RATING'] ??
          0.0);
      int ptsOn = (possOn * oRtgOn / 100).round();
      double ptsOff = ((widget.team['points'] ?? widget.team['PTS'] ?? 0) - ptsOn).toDouble();
      double oRtgOff = 100 * ptsOff / possOff;
      double onOff = oRtgOn - oRtgOff;

      String text = onOff > 0.0 ? '+${onOff.toStringAsFixed(1)}' : onOff.toStringAsFixed(1);

      return BoxScoreDataText(
        key: ValueKey(text),
        text: text,
        color: onOff == 0.0
            ? Colors.white
            : onOff > 0.0
                ? const Color(0xFF55F86F)
                : const Color(0xFFFC3126),
      );
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }

  Widget dRtgWidget(int index, int played) {
    try {
      if (played == 0 ||
          (widget.players[index]?['statistics']?['POSS'] ??
                  widget.players[index]?['POSS'] ??
                  0) ==
              0) {
        return const BoxScoreDataText(key: ValueKey('-'), text: '-');
      }

      int possOn = (widget.players[index]?['statistics']?['POSS'] ??
          widget.players[index]?['POSS'] ??
          0);
      int possOff = ((widget.team['POSS'] ?? 0) - possOn);

      double dRtgOn = (widget.players[index]?['statistics']?['DEF_RATING'] ??
          widget.players[index]?['DEF_RATING'] ??
          0.0);
      int ptsAgainstOn = (possOn * dRtgOn / 100).round();
      double ptsAgainstOff = ((widget.team['pointsAgainst'] ??
                  ((widget.team['PTS'] ?? 0) - (widget.team['PLUS_MINUS'] ?? 0))) -
              ptsAgainstOn)
          .toDouble();
      double dRtgOff = 100 * ptsAgainstOff / possOff;
      double onOff = dRtgOn - dRtgOff;
      String text = onOff > 0.0 ? '+${onOff.toStringAsFixed(1)}' : onOff.toStringAsFixed(1);

      return BoxScoreDataText(
        key: ValueKey(text),
        text: text,
        color: onOff == 0.0
            ? Colors.white
            : onOff < 0.0
                ? const Color(0xFF55F86F)
                : const Color(0xFFFC3126),
      );
    } catch (e) {
      return const BoxScoreDataText(key: ValueKey('-'), text: '-');
    }
  }
}

class BoxScoreDataText extends StatelessWidget {
  const BoxScoreDataText({
    super.key,
    required this.text,
    this.color,
    this.alignment,
    this.size,
  });

  final Alignment? alignment;
  final Color? color;
  final double? size;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        alignment: alignment ?? Alignment.centerRight,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: kBebasNormal.copyWith(fontSize: size ?? 15.0.r, color: color),
        ),
      ),
    );
  }
}
