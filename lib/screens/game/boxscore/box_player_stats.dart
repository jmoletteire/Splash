import 'package:auto_size_text/auto_size_text.dart';
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
  final bool inProgress;
  final ScrollController controller;

  const BoxPlayerStats({
    super.key,
    required this.players,
    required this.playerGroup,
    required this.inProgress,
    required this.controller,
  });

  @override
  State<BoxPlayerStats> createState() => _BoxPlayerStatsState();
}

class _BoxPlayerStatsState extends State<BoxPlayerStats> {
  List columnNames = [];

  @override
  void initState() {
    super.initState();
    columnNames = [
      widget.playerGroup,
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
      '+/-',
      'eFG%',
      'TS%',
      'USG%',
      'NRTG',
      'ORTG',
      'DRTG',
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return SliverTableView.builder(
      horizontalScrollController: widget.controller,
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
      rowHeight: MediaQuery.of(context).size.height * 0.06,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// PLAYER
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.15
              : MediaQuery.of(context).size.width * 0.38,
          freezePriority: 1,
        ),

        /// POSS
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// MIN
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.125,
        ),

        /// PTS
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// REB
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// AST
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// TOV
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.08,
        ),

        /// FGM - FGA
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.11,
        ),

        /// 3PM - 3PA
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.11,
        ),

        /// FTM - FTA
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.11,
        ),

        /// STL
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// BLK
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
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

        /// +/-
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// EFG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// TS%
        if (!widget.inProgress)
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.12,
          ),

        /// USG%
        if (!widget.inProgress)
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.12,
          ),

        /// ORTG
        if (!widget.inProgress)
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.12,
          ),

        /// DRTG
        if (!widget.inProgress)
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.12,
          ),

        /// NRTG
        if (!widget.inProgress)
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.06
                : MediaQuery.of(context).size.width * 0.12,
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
                  builder: (context) => PlayerHome(
                    playerId: (widget.players[row]['personId'] ??
                            widget.players[row]['PLAYER_ID'] ??
                            0)
                        .toString(),
                  ),
                ),
              );
            });
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.r),
              child: getContent(widget.players[row], row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(
      Map<String, dynamic> playerSeasons, int row, int column, BuildContext context) {
    String formatLiveDuration(String input) {
      final regex = RegExp(r'PT(\d+)M(\d+).(\d+)S');
      final match = regex.firstMatch(input);

      if (match != null) {
        final minutes = int.parse(match.group(1)!); // Convert to int to remove leading zeros
        final seconds = match.group(2);

        return '$minutes:$seconds';
      }

      return input; // Return the original string if no match is found
    }

    int onCourt = widget.inProgress ? int.parse(widget.players[row]?['oncourt'] ?? '0') : 0;
    String position =
        widget.players[row]?['position'] ?? widget.players[row]['START_POSITION'] ?? '';
    String minutes = widget.players[row]?['statistics']?['minutes'] != null
        ? formatLiveDuration(widget.players[row]['statistics']['minutes'])
        : '${widget.players[row]['statistics']['MIN']?.replaceAll(RegExp(r'\..*?(?=:)'), '')}';

    switch (column) {
      case 0:
        return Container(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              SizedBox(
                width: 12.0.r,
                child: Text(
                  widget.players[row]['jerseyNum'],
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(color: Colors.grey, fontSize: 12.0.r),
                ),
              ),
              SizedBox(width: 8.0.r),
              PlayerAvatar(
                radius: 12.0.r,
                backgroundColor: Colors.white12,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.players[row]['personId'] ?? widget.players[row]['PLAYER_ID'] ?? '0'}.png',
              ),
              SizedBox(width: 5.0.r),
              Flexible(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.players[row]['nameI'] ??
                            '${widget.players[row]['PLAYER_NAME'][0]}. ${widget.players[row]['PLAYER_NAME'].substring(widget.players[row]['PLAYER_NAME'].indexOf(' ') + 1)}' ??
                            '',
                        style: kBebasNormal.copyWith(
                          color: Colors.white70,
                          fontSize: 14.0.r,
                        ),
                      ),
                      if (widget.playerGroup == 'STARTERS')
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
        );
      case 1:
        try {
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.players[row]['statistics']['POSS'] ?? '-'}',
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            ),
          );
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 2:
        try {
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              minutes == '0:00' ? '-' : minutes,
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            ),
          );
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 3:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['points'] ?? widget.players[row]['PTS']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 4:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['reboundsTotal'] ?? widget.players[row]['REB']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 5:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['assists'] ?? widget.players[row]['AST']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 6:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['turnovers'] ?? widget.players[row]['TO']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 7:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['fieldGoalsMade'] ?? widget.players[row]['FGM']).toStringAsFixed(0)}-${(widget.players[row]?['statistics']?['fieldGoalsAttempted'] ?? widget.players[row]['FGA']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 8:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['threePointersMade'] ?? widget.players[row]['FG3M']).toStringAsFixed(0)}-${(widget.players[row]?['statistics']?['threePointersAttempted'] ?? widget.players[row]['FG3A']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 9:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['freeThrowsMade'] ?? widget.players[row]['FTM']).toStringAsFixed(0)}-${(widget.players[row]?['statistics']?['freeThrowsAttempted'] ?? widget.players[row]['FTA']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 10:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['steals'] ?? widget.players[row]['STL']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 11:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['blocks'] ?? widget.players[row]['BLK']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 12:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['reboundsOffensive'] ?? widget.players[row]['OREB']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 13:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['reboundsDefensive'] ?? widget.players[row]['DREB']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 14:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['foulsPersonal'] ?? widget.players[row]['PF']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 15:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]?['statistics']?['plusMinusPoints'] ?? widget.players[row]['PLUS_MINUS']).toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 16:
        try {
          int fieldGoalsAttempted =
              widget.players[row]?['statistics']?['fieldGoalsAttempted'] ?? 0;

          // Check for division by zero
          if (fieldGoalsAttempted == 0) {
            try {
              return BoxscoreDataText(
                  text:
                      '${(widget.players[row]['statistics']['EFG_PCT'] * 100).toStringAsFixed(1)}%');
            } catch (e) {
              return const BoxscoreDataText(text: '-');
            }
          }

          double efgPct = ((widget.players[row]?['statistics']?['fieldGoalsMade'] +
                      (0.5 * widget.players[row]?['statistics']?['threePointersMade'])) /
                  fieldGoalsAttempted) *
              100;

          return BoxscoreDataText(text: '${efgPct.toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 17:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['statistics']['TS_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 18:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['statistics']['USG_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 19:
        try {
          return BoxscoreDataText(
              text: '${widget.players[row]['statistics']['NET_RATING'].toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 20:
        try {
          return BoxscoreDataText(
              text: '${widget.players[row]['statistics']['OFF_RATING'].toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 21:
        try {
          return BoxscoreDataText(
              text: '${widget.players[row]['statistics']['DEF_RATING'].toStringAsFixed(1)}');
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
      child: AutoSizeText(
        text,
        maxLines: 1,
        style: kBebasNormal.copyWith(fontSize: 15.0.r),
      ),
    );
  }
}
