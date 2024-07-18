import 'package:flutter/material.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/utilities/constants.dart';

import '../team/team_home.dart';

class ConferenceStandings extends StatefulWidget {
  final List columnNames;
  final List<Map<String, dynamic>> standings;

  ConferenceStandings({
    required this.columnNames,
    required this.standings,
  });

  @override
  State<ConferenceStandings> createState() => _ConferenceStandingsState();
}

class _ConferenceStandingsState extends State<ConferenceStandings> {
  late ScrollController scrollController;

  String getClinched(Map<String, dynamic> standings) {
    if (standings['ClinchedConferenceTitle'] == 1) {
      return ' -z';
    } else if (standings['ClinchedDivisionTitle'] == 1) {
      return ' -y';
    } else if (standings['ClinchedPlayoffBirth'] == 1) {
      return ' -x';
    } else if (standings['EliminatedConference'] == 1) {
      return ' -o';
    }
    return ' -pi';
  }

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

  @override
  Widget build(BuildContext context) {
    widget.standings.sort((a, b) {
      return a['seasons'][kCurrentSeason]['CONF_RANK']
          .compareTo(b['seasons'][kCurrentSeason]['CONF_RANK']);
    });

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
      rowCount: widget.standings.length,
      rowHeight: MediaQuery.of(context).size.height * 0.055,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.35,
          freezePriority: 1,
        ),

        /// W
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// L
        TableColumn(width: MediaQuery.of(context).size.width * 0.08),

        /// PCT
        TableColumn(width: MediaQuery.of(context).size.width * 0.165),

        /// GB
        TableColumn(width: MediaQuery.of(context).size.width * 0.125),

        /// NRTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// ORTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// DRTG
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// PACE
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// STREAK
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// LAST 10
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// HOME
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// ROAD
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// Over .500
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// EAST
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// WEST
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// VS ATLANTIC
        TableColumn(width: MediaQuery.of(context).size.width * 0.15),

        /// VS CENTRAL
        TableColumn(width: MediaQuery.of(context).size.width * 0.14),

        /// VS SOUTHEAST
        TableColumn(width: MediaQuery.of(context).size.width * 0.14),

        /// VS NORTHWEST
        TableColumn(width: MediaQuery.of(context).size.width * 0.14),

        /// VS PACIFIC
        TableColumn(width: MediaQuery.of(context).size.width * 0.14),

        /// VS SOUTHWEST
        TableColumn(width: MediaQuery.of(context).size.width * 0.14),
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
                  ? const EdgeInsets.only(left: 20.0)
                  : const EdgeInsets.only(right: 8.0),
              child: Align(
                alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
                child: Text('${widget.columnNames[column]}',
                    style: kBebasNormal.copyWith(
                      fontSize: 18.0,
                    )),
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
            border: Border(
              bottom: BorderSide(
                color: Colors.white,
                width: index == 9 ? 3.0 : (index == 5 ? 1.0 : 0.125),
                style: index == 5
                    ? BorderStyle.solid
                    : (index == 9 ? BorderStyle.solid : BorderStyle.solid),
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

  Widget? _rowBuilder(
    BuildContext context,
    int row,
    TableRowContentBuilder contentBuilder,
  ) {
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamHome(
                  teamId: widget.standings[row]['TEAM_ID'].toString(),
                ),
              ),
            );
          }),
          splashColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: getContent(widget.standings, row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(
      List<Map<String, dynamic>> eastTeams, int row, int column, BuildContext context) {
    switch (column) {
      case 0:
        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 3.0, 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  widget.standings[row]['seasons'][kCurrentSeason]['CONF_RANK'].toString(),
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(
                    color: Colors.white70,
                    fontSize: 19.0,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 24.0),
                  child: Image.asset(
                    'images/NBA_Logos/${widget.standings[row]['TEAM_ID']}.png',
                    fit: BoxFit.contain,
                    width: 24.0,
                    height: 24.0,
                  ),
                ),
                /*
                SvgPicture.string(
                  widget.standings[row]['LOGO'][0],
                  alignment: Alignment.center,
                  width: 24,
                  height: 24,
                ),
                 */
              ),
              Expanded(
                flex: 2,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.standings[row]['ABBREVIATION'],
                        style: kBebasBold.copyWith(fontSize: 20.0),
                      ),
                      TextSpan(
                        text: getClinched(
                            widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']),
                        style: kBebasNormal.copyWith(
                            fontFamily: 'Anton', fontSize: 12.0, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 1:
        return StandingsDataText(
            text:
                widget.standings[row]['seasons'][kCurrentSeason]['WINS']!.toStringAsFixed(0));
      case 2:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['LOSSES']!
                .toStringAsFixed(0));
      case 3:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['WIN_PCT']!
                .toStringAsFixed(3));
      case 4:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']
                    ['ConferenceGamesBack']!
                .toString());
      case 5:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STATS']['ADV']
                    ['NET_RATING']!
                .toStringAsFixed(1));
      case 6:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STATS']['ADV']
                    ['OFF_RATING']!
                .toStringAsFixed(1));
      case 7:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STATS']['ADV']
                    ['DEF_RATING']!
                .toStringAsFixed(1));
      case 8:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STATS']['ADV']['PACE']!
                .toStringAsFixed(1));
      case 9:
        return Container(
          alignment: Alignment.centerRight,
          child: Text(
            widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['strCurrentStreak']!,
            style: kBebasNormal.copyWith(
                fontSize: 18.0,
                color: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']
                            ['strCurrentStreak']!
                        .contains('W')
                    ? Colors.green
                    : Colors.red),
          ),
        );
      case 10:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['L10']!);
      case 11:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['HOME']!);
      case 12:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['ROAD']!);
      case 13:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']
                ['OppOver500']!);
      case 14:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['vsEast']!);
      case 15:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['vsWest']!);
      case 16:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']
                ['vsAtlantic']!);
      case 17:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['vsCentral']!);
      case 18:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']
                ['vsSoutheast']!);
      case 19:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']
                ['vsNorthwest']!);
      case 20:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']['vsPacific']!);
      case 21:
        return StandingsDataText(
            text: widget.standings[row]['seasons'][kCurrentSeason]['STANDINGS']
                ['vsSouthwest']!);
      default:
        return Text('');
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
      child: Text(
        text,
        style: kBebasNormal.copyWith(fontSize: 19.0),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedBorderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    double dashWidth = 5.0;
    double dashSpace = 3.0;
    double startX = 0;
    double startY = 0;

    // Top side
    while (startX < size.width) {
      path.moveTo(startX, startY);
      path.lineTo(startX + dashWidth, startY);
      startX += dashWidth + dashSpace;
    }

    startX = size.width;
    startY = 0;

    // Right side
    while (startY < size.height) {
      path.moveTo(startX, startY);
      path.lineTo(startX, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }

    startX = size.width;
    startY = size.height;

    // Bottom side
    while (startX > 0) {
      path.moveTo(startX, startY);
      path.lineTo(startX - dashWidth, startY);
      startX -= dashWidth + dashSpace;
    }

    startX = 0;
    startY = size.height;

    // Left side
    while (startY > 0) {
      path.moveTo(startX, startY);
      path.lineTo(startX, startY - dashWidth);
      startY -= dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
