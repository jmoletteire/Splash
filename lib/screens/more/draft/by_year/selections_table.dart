import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../../components/player_avatar.dart';
import '../../../../utilities/constants.dart';
import '../../../player/player_home.dart';

class DraftSelections extends StatefulWidget {
  final List<dynamic> selections;

  const DraftSelections({
    super.key,
    required this.selections,
  });

  @override
  State<DraftSelections> createState() => _DraftSelectionsState();
}

class _DraftSelectionsState extends State<DraftSelections> {
  List columnNames = [
    'PICK',
    'TEAM',
    'PLAYER',
    'POSITION',
    'AGE',
    'HEIGHT',
    'WEIGHT',
    'ORGANIZATION',
    'TYPE',
  ];

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
      rowCount: widget.selections.length,
      rowHeight: MediaQuery.of(context).size.height * 0.06,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// PICK
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.1,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
          freezePriority: 1,
        ),

        /// PLAYER
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.2
              : MediaQuery.of(context).size.width * 0.4,
        ),

        /// POSITION
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.13,
        ),

        /// AGE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// HEIGHT
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.125,
        ),

        /// WEIGHT
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.06
              : MediaQuery.of(context).size.width * 0.125,
        ),

        /// ORGANIZATION
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.1
              : MediaQuery.of(context).size.width * 0.25,
        ),

        /// ORGANIZATION TYPE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.1
              : MediaQuery.of(context).size.width * 0.28,
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

  Color getRowColor(int row) {
    if (widget.selections[row]['HOF'] == 1) {
      return Colors.deepOrange.withOpacity(0.5);
    } else if (widget.selections[row]['MVP'] == 1) {
      return Colors.yellow.shade800.withOpacity(0.5);
    } else if (widget.selections[row]['ALL_NBA'] == 1) {
      return Colors.blueGrey.withOpacity(0.85);
    } else if (widget.selections[row]['ALL_STAR'] == 1) {
      return Colors.blueGrey.withOpacity(0.5);
    } else {
      return Colors.grey.shade900.withOpacity(0.8);
    }
  }

  /// This is used to wrap both regular and placeholder rows to achieve fade
  /// transition between them and to insert optional row divider.
  Widget _wrapRow(int index, Widget child) => KeyedSubtree(
        key: ValueKey(index),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: getRowColor(index),
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
            if (widget.selections[row]['PLAYER_PROFILE_FLAG'] == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerHome(
                    playerId: widget.selections[row]['PERSON_ID'].toString(),
                  ),
                ),
              );
            }
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: EdgeInsets.only(right: column == 2 ? 0.0 : 8.0),
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

    String teamId = kEastConfTeamIds.contains(widget.selections[row]['TEAM_ID'].toString()) ||
            kWestConfTeamIds.contains(widget.selections[row]['TEAM_ID'].toString())
        ? widget.selections[row]['TEAM_ID'].toString()
        : '0';

    /*
    String fullName = widget.selections[row]['PLAYER_NAME'];

    // Split the name by spaces
    List<String> nameParts = fullName.split(' ');

    // Assign first and last name
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String lastName = nameParts.length > 1 ? nameParts.last : '';

    String lastSub = '';
    if (lastName.length > 5) {
      lastSub = lastName.substring(0, 5).toLowerCase();
    } else {
      lastSub = lastName.toLowerCase();
    }

     */

    switch (column) {
      case 0:
        return Center(
          child: AutoSizeText(
            (widget.selections[row]['OVERALL_PICK'] ?? (row + 1)).toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(color: Colors.grey, fontSize: 14.0.r),
          ),
        );
      case 1:
        return Row(
          children: [
            if (teamId == '0') const Spacer(flex: 1),
            Expanded(
              flex: 4,
              child: Image.asset('images/NBA_Logos/$teamId.png'),
            ),
            Spacer(flex: teamId == '0' ? 3 : 1)
          ],
        );
      case 2:
        return Padding(
          padding: EdgeInsets.fromLTRB(6.0.r, 8.0.r, 0.0, 8.0.r),
          child: Row(
            children: [
              PlayerAvatar(
                radius: 12.0.r,
                backgroundColor: Colors.white70,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.selections[row]['PERSON_ID']}.png',
                //'https://www.basketball-reference.com/req/202106291/images/headshots/$lastSub${firstName.substring(0, 2).toLowerCase()}01.jpg'
              ),
              SizedBox(width: 8.0.r),
              Expanded(
                flex: 7,
                child: AutoSizeText(
                  widget.selections[row]['ROTY'] == 1
                      ? '${widget.selections[row]['PLAYER_NAME'] ?? '-'}*'
                      : widget.selections[row]['PLAYER_NAME'] ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(fontSize: 14.0.r),
                ),
              ),
              if (widget.selections[row]['HOF'] == 1)
                Image.asset(
                  'images/hof.png',
                  height: 25.0.r,
                ),
            ],
          ),
        );
      case 3:
        try {
          return StandingsDataText(
            text: positionMap[widget.selections[row]['POSITION']] ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 4:
        try {
          return StandingsDataText(
            text: (widget.selections[row]['AGE'] == 0
                    ? '-'
                    : widget.selections[row]['AGE'] ?? '-')
                .toString(),
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 5:
        try {
          var height = widget.selections[row]['HEIGHT'].toString().split('-');
          var heightFinal =
              widget.selections[row]['HEIGHT'] == "" ? "" : '${height[0]}\'${height[1]}\"';

          return StandingsDataText(
            text: widget.selections[row]['HEIGHT'] == '' ? '-' : heightFinal,
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          return StandingsDataText(
            text: widget.selections[row]['WEIGHT'] == ''
                ? '-'
                : widget.selections[row]['WEIGHT'] ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          return StandingsDataText(
            text: widget.selections[row]['ORGANIZATION'] == ''
                ? '-'
                : widget.selections[row]['ORGANIZATION'] ?? '-',
            size: 14.0,
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 8:
        try {
          return StandingsDataText(
            text: widget.selections[row]['ORGANIZATION_TYPE'] == ''
                ? '-'
                : widget.selections[row]['ORGANIZATION_TYPE'] ?? '-',
            size: 14.0,
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
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
