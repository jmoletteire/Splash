import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../components/player_avatar.dart';
import '../../../utilities/constants.dart';
import '../../player/player_home.dart';

class TeamPlayerStats extends StatefulWidget {
  final List<dynamic> players;
  final ScrollController controller;
  const TeamPlayerStats({
    super.key,
    required this.players,
    required this.controller,
  });

  @override
  State<TeamPlayerStats> createState() => _TeamPlayerStatsState();
}

class _TeamPlayerStatsState extends State<TeamPlayerStats> {
  List columnNames = [];

  @override
  void initState() {
    super.initState();
    columnNames = [
      'PLAYER',
      'GP',
      'MPG',
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
      '+/-',
      'NRTG',
      'ORTG',
      'DRTG',
    ];

    // Sort players by MIN / GP for the current or previous season
    String season =
        widget.players[0]['STATS'].containsKey(kCurrentSeason) ? kCurrentSeason : kPrevSeason;
    String seasonType = widget.players[0]['STATS'][season].containsKey('PLAYOFFS')
        ? 'PLAYOFFS'
        : 'REGULAR SEASON';
    widget.players.sort((a, b) {
      try {
        double minPerGameA = (a?['STATS']?[season]?[seasonType]?['BASIC']?['MIN'] ?? 0) /
            (a?['STATS']?[season]?['REGULAR SEASON']?['BASIC']?['GP'] ?? 1);
        double minPerGameB = (b?['STATS']?[season]?[seasonType]?['BASIC']?['MIN'] ?? 0) /
            (b?['STATS']?[season]?['REGULAR SEASON']?['BASIC']?['GP'] ?? 1);

        return minPerGameB.compareTo(minPerGameA); // Sort in descending order
      } catch (e) {
        return 0; // Handle errors if MIN or GP data is missing
      }
    });
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
              : MediaQuery.of(context).size.width * 0.43,
          freezePriority: 1,
        ),

        /// GP
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.075,
        ),

        /// MIN
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// PTS
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1225,
        ),

        /// REB
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// AST
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// STL
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// BLK
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// TOV
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// FGM - FGA
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.15,
        ),

        /// 3PM - 3PA
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.135,
        ),

        /// FTM - FTA
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.135,
        ),

        /// EFG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.135,
        ),

        /// TS%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.135,
        ),

        /// USG%
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.135,
        ),

        /// +/-
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.125,
        ),

        /// NRTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.125,
        ),

        /// ORTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// DRTG
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
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
  Widget _wrapRow(int index, Widget child) {
    String status = '';
    try {
      status = widget.players[index]?['PlayerRotowires']?[0]?['Injured_Status'] ?? '';
    } catch (e) {
      status = '';
    }
    return KeyedSubtree(
      key: ValueKey(index),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          color: status == ''
              ? Colors.grey.shade900
              : status == 'OUT' || status == 'OFS'
                  ? Colors.redAccent.withOpacity(0.125)
                  : Colors.orangeAccent.withOpacity(0.125),
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
  }

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
                    playerId: widget.players[row]['PERSON_ID'].toString(),
                  ),
                ),
              );
            });
          },
          splashColor: Colors.white10,
          highlightColor: Colors.white10,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: getContent(row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(int row, int column, BuildContext context) {
    String season = widget.players[row]['STATS'].containsKey(kCurrentSeason)
        ? kCurrentSeason
        : kPrevSeason;

    String seasonType = widget.players[0]['STATS'][season].containsKey('PLAYOFFS')
        ? 'PLAYOFFS'
        : 'REGULAR SEASON';

    switch (column) {
      case 0:
        String status = '';
        try {
          status = widget.players[row]?['PlayerRotowires']?[0]?['Injured_Status'] ?? '';
        } catch (e) {
          status = '';
        }
        return RepaintBoundary(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 12.0.r,
                  child: Text(
                    widget.players[row]?['JERSEY'] ?? '',
                    textAlign: TextAlign.center,
                    style: kBebasNormal.copyWith(color: Colors.grey, fontSize: 12.0.r),
                  ),
                ),
                SizedBox(width: 8.0.r),
                PlayerAvatar(
                  radius: 12.0,
                  backgroundColor: Colors.white12,
                  playerImageUrl:
                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.players[row]['PERSON_ID']}.png',
                ),
                SizedBox(width: 5.0.r),
                Flexible(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${widget.players[row]?['DISPLAY_FI_LAST'] ?? ''}',
                          style: kBebasNormal.copyWith(
                            color: Colors.white70,
                            fontSize: 14.0,
                          ),
                        ),
                        TextSpan(
                          text: ', ${kPositionMap[widget.players[row]?['POSITION']] ?? ''}',
                          style: kBebasNormal.copyWith(
                            color: Colors.white,
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 5.0.r),
                Container(
                  margin: EdgeInsets.only(left: 8.0.r),
                  child: AutoSizeText(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBebasNormal.copyWith(
                        fontSize: 13.0.r,
                        color: status == ''
                            ? Colors.grey.shade900
                            : status == 'OUT' || status == 'OFS'
                                ? Colors.red
                                : Colors.orangeAccent),
                  ),
                )
              ],
            ),
          ),
        );
      case 1:
        try {
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              (widget.players[row]?['STATS']?[season]?[seasonType]?['BASIC']?['GP'] ?? '-')
                  .toString(),
              style: kBebasNormal.copyWith(fontSize: 15.0.r, color: const Color(0xFFD0D0D0)),
            ),
          );
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 2:
        try {
          double minPerG = widget.players[row]['STATS'][season][seasonType]['BASIC']['MIN'] /
              widget.players[row]['STATS'][season][seasonType]['BASIC']['GP'];

          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              minPerG.toStringAsFixed(1),
              style: kBebasNormal.copyWith(fontSize: 15.0.r, color: const Color(0xFFD0D0D0)),
            ),
          );
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 3:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['BASIC']['PTS'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['GP']).toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 4:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['BASIC']['REB'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['GP']).toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 5:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['BASIC']['AST'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['GP']).toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 6:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['BASIC']['STL'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['GP']).toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 7:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['BASIC']['BLK'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['GP']).toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 8:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['BASIC']['TOV'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['GP']).toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 9:
        try {
          return BoxscoreDataText(
              text:
                  '${(100 * widget.players[row]['STATS'][season][seasonType]['BASIC']['FGM'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['FGA']).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 10:
        try {
          return BoxscoreDataText(
              text:
                  '${(100 * widget.players[row]['STATS'][season][seasonType]['BASIC']['FG3M'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['FG3A']).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 11:
        try {
          return BoxscoreDataText(
              text:
                  '${(100 * widget.players[row]['STATS'][season][seasonType]['BASIC']['FTM'] / widget.players[row]['STATS'][season][seasonType]['BASIC']['FTA']).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 12:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['ADV']['EFG_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 13:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['ADV']['TS_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 14:
        try {
          return BoxscoreDataText(
              text:
                  '${(widget.players[row]['STATS'][season][seasonType]['ADV']['USG_PCT'] * 100).toStringAsFixed(1)}%');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 15:
        try {
          return BoxscoreDataText(
              text:
                  '${widget.players[row]['STATS'][season][seasonType]['BASIC']['PLUS_MINUS'].toStringAsFixed(0)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 16:
        try {
          return BoxscoreDataText(
              text:
                  '${widget.players[row]['STATS'][season][seasonType]['ADV']['NET_RATING'].toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 17:
        try {
          return BoxscoreDataText(
              text:
                  '${widget.players[row]['STATS'][season][seasonType]['ADV']['OFF_RATING'].toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      case 18:
        try {
          return BoxscoreDataText(
              text:
                  '${widget.players[row]['STATS'][season][seasonType]['ADV']['DEF_RATING'].toStringAsFixed(1)}');
        } catch (e) {
          return const BoxscoreDataText(text: '-');
        }
      default:
        return const Text('-');
    }
  }
}

class BoxscoreDataText extends StatelessWidget {
  const BoxscoreDataText({super.key, required this.text, this.alignment, this.color});

  final Alignment? alignment;
  final Color? color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: AutoSizeText(
        text,
        maxLines: 1,
        style: kBebasNormal.copyWith(fontSize: 15.0.r, color: color),
      ),
    );
  }
}
