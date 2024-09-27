import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../../components/player_avatar.dart';
import '../../../../utilities/constants.dart';
import '../../../player/player_home.dart';
import '../../../team/team_home.dart';

class AwardsByAward extends StatefulWidget {
  final List<dynamic> awards;
  final String awardName;

  const AwardsByAward({
    super.key,
    required this.awards,
    required this.awardName,
  });

  @override
  State<AwardsByAward> createState() => _AwardsByAwardState();
}

class _AwardsByAwardState extends State<AwardsByAward> {
  List columnNames = [];

  @override
  void initState() {
    super.initState();
    columnNames = [
      'SEASON',
      'TEAM',
      'NAME',
      if (widget.awardName != 'NBA Champion') 'POS',
      '',
    ];
  }

  @override
  Widget build(BuildContext context) {
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
      rowCount: widget.awards.length,
      rowHeight: MediaQuery.of(context).size.height * 0.05,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// AWARD
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.07
              : MediaQuery.of(context).size.width * 0.20,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.109,
          freezePriority: 1,
        ),

        /// NAME
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width * 0.50,
        ),

        if (widget.awardName != 'NBA Champion')

          /// POSITION
          TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.03
                : MediaQuery.of(context).size.width * 0.14,
          ),

        /// Fill
        TableColumn(
          width: isLandscape
              ? widget.awardName == 'NBA Champion'
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.03
              : widget.awardName == 'NBA Champion'
                  ? MediaQuery.of(context).size.width * 0.19
                  : MediaQuery.of(context).size.width * 0.05,
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
                  column == 0 ? EdgeInsets.only(left: 8.0.r) : EdgeInsets.only(right: 8.0.r),
              child: Align(
                alignment: column <= 2 ? Alignment.centerLeft : Alignment.centerRight,
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
                width: 0.125.h,
              ),
            ),
          ),
          child: child,
        ),
      );

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    String teamId =
        kTeamFullNameToId[widget.awards[row][widget.awardName]['PLAYERS'][0]['TEAM']] ?? '0';
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            {
              if (widget.awards[row][widget.awardName]['DESCRIPTION'] == 'NBA Champion' &&
                  teamId != '0') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamHome(
                      teamId: teamId,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerHome(
                      playerId: widget.awards[row][widget.awardName]['PLAYERS'][0]['PLAYER_ID']
                          .toString(),
                    ),
                  ),
                );
              }
            }
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: EdgeInsets.only(right: column == 2 ? 0.0 : 8.0.r),
              child: getContent(row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(int row, int column, BuildContext context) {
    Map<String, String> positionMap = {
      'Guard': 'G',
      'Guard-Forward': 'G-F',
      'Forward': 'F',
      'Forward-Guard': 'F-G',
      'Forward-Center': 'F-C',
      'Center': 'C',
      'Center-Forward': 'C-F',
    };

    String teamId =
        kTeamFullNameToId[widget.awards[row][widget.awardName]['PLAYERS'][0]['TEAM']] ?? '0';
    String position =
        positionMap[widget.awards[row][widget.awardName]['PLAYERS'][0]['POSITION']] ?? '0';

    switch (column) {
      case 0:
        return Container(
          padding: EdgeInsets.only(left: 8.0.r),
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            widget.awards[row][widget.awardName]['SEASON'] ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(color: Colors.grey.shade400, fontSize: 15.0.r),
          ),
        );
      case 1:
        return Row(
          children: [
            if (teamId == '0') const Spacer(flex: 1),
            Expanded(
              flex: 3,
              child: Image.asset('images/NBA_Logos/$teamId.png'),
            ),
            Spacer(flex: teamId == '0' ? 3 : 1)
          ],
        );
      case 2:
        if (widget.awards[row][widget.awardName]['DESCRIPTION'] == 'NBA Champion') {
          return Container(
            padding: EdgeInsets.only(left: 8.0.r),
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '${widget.awards[row][widget.awardName]['PLAYERS'][0]['TEAM']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.fromLTRB(6.0.r, 8.0.r, 0.0, 8.0.r),
            child: Row(
              children: [
                PlayerAvatar(
                  radius: 13.0.r,
                  backgroundColor: Colors.white70,
                  playerImageUrl:
                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.awards[row][widget.awardName]['PLAYERS'][0]['PLAYER_ID']}.png',
                  //'https://www.basketball-reference.com/req/202106291/images/headshots/$lastSub${firstName.substring(0, 2).toLowerCase()}01.jpg'
                ),
                SizedBox(width: 8.0.r),
                Expanded(
                  flex: 7,
                  child: AutoSizeText(
                    '${widget.awards[row][widget.awardName]['PLAYERS'][0]['FIRST_NAME'] ?? ''} ${widget.awards[row][widget.awardName]['PLAYERS'][0]['LAST_NAME'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBebasNormal.copyWith(fontSize: 15.0.r),
                  ),
                ),
              ],
            ),
          );
        }
      case 3:
        try {
          if (widget.awards[row][widget.awardName]['DESCRIPTION'] == 'NBA Champion') {
            return const StandingsDataText(text: '');
          }
          return StandingsDataText(text: position);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 4:
        return const Text('');
      default:
        return const Text('-');
    }
  }
}

class StandingsDataText extends StatelessWidget {
  const StandingsDataText(
      {super.key, required this.text, this.alignment, this.size, this.color});

  final Alignment? alignment;
  final double? size;
  final Color? color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: kBebasNormal.copyWith(fontSize: size ?? 16.0.r, color: color),
      ),
    );
  }
}
