import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../components/player_avatar.dart';
import '../../../utilities/constants.dart';
import '../../player/player_home.dart';

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
    'HEIGHT',
    'WEIGHT',
    'ORGANIZATION',
    'TYPE',
  ];

  @override
  Widget build(BuildContext context) {
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
          width: MediaQuery.of(context).size.width * 0.1,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.1,
          freezePriority: 1,
        ),

        /// PLAYER
        TableColumn(width: MediaQuery.of(context).size.width * 0.38),

        /// POSITION
        TableColumn(width: MediaQuery.of(context).size.width * 0.13),

        /// HEIGHT
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// WEIGHT
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// ORGANIZATION
        TableColumn(width: MediaQuery.of(context).size.width * 0.25),

        /// ORGANIZATION TYPE
        TableColumn(width: MediaQuery.of(context).size.width * 0.28),
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
                  ? const EdgeInsets.only(left: 8.0)
                  : const EdgeInsets.only(right: 8.0),
              child: Align(
                alignment: column <= 2 ? Alignment.centerLeft : Alignment.centerRight,
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
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            if (widget.selections[row]['LAST_PLAYED'] >= 1997 &&
                widget.selections[row]['PLAYER_PROFILE_FLAG'] == 1) {
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
              padding: const EdgeInsets.only(right: 8.0),
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

    switch (column) {
      case 0:
        return Center(
          child: AutoSizeText(
            (widget.selections[row]['OVERALL_PICK'] ?? (row + 1)).toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(color: Colors.grey, fontSize: 16.0),
          ),
        );
      case 1:
        return Row(
          children: [
            Expanded(
              flex: 4,
              child: Image.asset('images/NBA_Logos/${widget.selections[row]['TEAM_ID']}.png'),
            ),
            const Spacer()
          ],
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.fromLTRB(6.0, 8.0, 0.0, 8.0),
          child: Row(
            children: [
              PlayerAvatar(
                radius: 12.0,
                backgroundColor: Colors.white70,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.selections[row]['PERSON_ID']}.png',
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 5,
                child: Text(
                  widget.selections[row]['PLAYER_NAME'] ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(fontSize: 16.0),
                ),
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
            text: widget.selections[row]['HEIGHT'] ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 5:
        try {
          return StandingsDataText(
            text: widget.selections[row]['WEIGHT'] ?? '-',
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          return StandingsDataText(
            text: widget.selections[row]['ORGANIZATION'] ?? '-',
            size: 14.0,
            color: const Color(0xFFD0D0D0),
          );
        } catch (stack) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          return StandingsDataText(
            text: widget.selections[row]['ORGANIZATION_TYPE'] ?? '-',
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
        style: kBebasNormal.copyWith(fontSize: size ?? 18.0, color: color),
      ),
    );
  }
}
