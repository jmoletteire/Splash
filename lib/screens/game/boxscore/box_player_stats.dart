import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../components/player_avatar.dart';
import '../../../utilities/constants.dart';
import '../../player/player_home.dart';

class BoxPlayerStats extends StatefulWidget {
  final List<dynamic> players;
  final String playerGroup;
  final ScrollController controller;
  const BoxPlayerStats({
    super.key,
    required this.players,
    required this.playerGroup,
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
      'eFG%',
      'TS%',
      'USG%',
      '+/-',
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
              : MediaQuery.of(context).size.width * 0.3,
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

        /// EFG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// TS%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// USG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// +/-
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// ORTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// DRTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// NRTG
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
            color: Colors.grey.shade800,
            child: Padding(
              padding:
                  column == 0 ? EdgeInsets.only(left: 20.0.r) : EdgeInsets.only(right: 8.0.r),
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
          onTap: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerHome(
                    playerId: widget.players[row]['PLAYER_ID'].toString(),
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
    switch (column) {
      case 0:
        int firstSpaceIndex = widget.players[row]['PLAYER_NAME'].indexOf(' ');
        return Container(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              PlayerAvatar(
                radius: 12.0.r,
                backgroundColor: Colors.white12,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.players[row]['PLAYER_ID']}.png',
              ),
              SizedBox(width: 5.0.r),
              Flexible(
                child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${widget.players[row]['PLAYER_NAME'][0]}. ${widget.players[row]['PLAYER_NAME'].substring(firstSpaceIndex + 1)}',
                          style: kBebasNormal.copyWith(
                            color: Colors.white70,
                            fontSize: 13.0.r,
                          ),
                        ),
                        if (widget.playerGroup == 'STARTERS')
                          TextSpan(
                            text: ', ${widget.players[row]['START_POSITION']}',
                            style: kBebasNormal.copyWith(
                              color: Colors.white,
                              fontSize: 13.0.r,
                            ),
                          ),
                      ],
                    )),
              ),
            ],
          ),
        );
      case 1:
        try {
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.players[row]['POSS']}',
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
              '${widget.players[row]['MIN'].replaceAll(RegExp(r'\..*?(?=:)'), '')}',
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            ),
          );
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 3:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['PTS'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 4:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['REB'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 5:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['AST'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 6:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['TO'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 7:
        try {
          return BoxscoreDataText(
              text:
                  '${widget.players[row]['FGM'].toStringAsFixed(0)}-${widget.players[row]['FGA'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 8:
        try {
          return BoxscoreDataText(
              text:
                  '${widget.players[row]['FG3M'].toStringAsFixed(0)}-${widget.players[row]['FG3A'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 9:
        try {
          return BoxscoreDataText(
              text:
                  '${widget.players[row]['FTM'].toStringAsFixed(0)}-${widget.players[row]['FTA'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 10:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['STL'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 11:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['BLK'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 12:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['OREB'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 13:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['DREB'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 14:
        try {
          return BoxscoreDataText(text: '${widget.players[row]['PF'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 15:
        try {
          return BoxscoreDataText(
              text: '${(widget.players[row]['EFG_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 16:
        try {
          return BoxscoreDataText(
              text: '${(widget.players[row]['TS_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 17:
        try {
          return BoxscoreDataText(
              text: '${(widget.players[row]['USG_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 18:
        try {
          return BoxscoreDataText(
              text: '${widget.players[row]['PLUS_MINUS'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 19:
        try {
          return BoxscoreDataText(
              text: '${widget.players[row]['NET_RATING'].toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 20:
        try {
          return BoxscoreDataText(
              text: '${widget.players[row]['OFF_RATING'].toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 21:
        try {
          return BoxscoreDataText(
              text: '${widget.players[row]['DEF_RATING'].toStringAsFixed(1)}');
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
