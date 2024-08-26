import 'package:flutter/material.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/utilities/constants.dart';

import '../team/team_home.dart';

class DivisionStandings extends StatefulWidget {
  final List columnNames;
  final List standings;
  final String season;

  DivisionStandings({
    required this.columnNames,
    required this.standings,
    required this.season,
  });

  @override
  State<DivisionStandings> createState() => _DivisionStandingsState();
}

class _DivisionStandingsState extends State<DivisionStandings> {
  late ScrollController scrollController;
  List<Map<String, dynamic>> teams = [];

  String getClinched(Map<String, dynamic> standings) {
    if (int.parse(widget.season.substring(0, 4)) >= 2019) {
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
    } else {
      if (standings['PlayoffRank'] > 8) {
        return ' -o';
      } else if (standings['PlayoffRank'] == 1) {
        return ' -z';
      } else if (standings['DivisionRank'] == 1) {
        return ' -y';
      } else if (standings['PlayoffRank'] <= 8) {
        return ' -x';
      }
      return ' -o';
    }
  }

  void _checkSeasons() {
    for (var team in widget.standings) {
      if (!teams.contains(team) && team['seasons'].containsKey(widget.season)) {
        teams.add(team);
      }
      if (teams.contains(team) && !team['seasons'].containsKey(widget.season)) {
        teams.remove(team);
      }
    }
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
    setState(() {
      teams = [];
    });
    _checkSeasons();

    teams.sort((a, b) {
      return a['seasons'][widget.season]['STANDINGS']['DivisionRank']
          .compareTo(b['seasons'][widget.season]['STANDINGS']['DivisionRank']);
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
      rowCount: teams.length,
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
        child: Stack(
          children: [
            DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.75),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 0.125,
                      style: BorderStyle.solid,
                    ),
                  )),
              child: child,
            ),
          ],
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
                  teamId: teams[row]['TEAM_ID'].toString(),
                ),
              ),
            );
          }),
          splashColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: getContent(teams, row, column, context),
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
                  teams[row]['seasons'][widget.season]['STANDINGS']['DivisionRank'].toString(),
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
                    'images/NBA_Logos/${teams[row]['TEAM_ID']}.png',
                    fit: BoxFit.contain,
                    width: 24.0,
                    height: 24.0,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: teams[row]['ABBREVIATION'],
                        style: kBebasBold.copyWith(fontSize: 20.0),
                      ),
                      TextSpan(
                        text: getClinched(teams[row]['seasons'][widget.season]['STANDINGS']),
                        style: kBebasNormal.copyWith(fontSize: 12.0, letterSpacing: 0.8),
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
            text: teams[row]['seasons'][widget.season]['WINS']!.toStringAsFixed(0));
      case 2:
        return StandingsDataText(
            text: teams[row]['seasons'][widget.season]['LOSSES']!.toStringAsFixed(0));
      case 3:
        return StandingsDataText(
            text: teams[row]['seasons'][widget.season]['WIN_PCT']!.toStringAsFixed(3));
      case 4:
        return StandingsDataText(
            text: teams[row]['seasons'][widget.season]['STANDINGS']['DivisionGamesBack']!
                .toString());
      case 5:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STATS']['REGULAR SEASON']['ADV']
                      ['NET_RATING']!
                  .toStringAsFixed(1));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STATS']['REGULAR SEASON']['ADV']
                      ['OFF_RATING']!
                  .toStringAsFixed(1));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STATS']['REGULAR SEASON']['ADV']
                      ['DEF_RATING']!
                  .toStringAsFixed(1));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 8:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STATS']['REGULAR SEASON']['ADV']
                      ['PACE']!
                  .toStringAsFixed(1));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 9:
        try {
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              teams[row]['seasons'][widget.season]['STANDINGS']['strCurrentStreak']!,
              style: kBebasNormal.copyWith(
                  fontSize: 18.0,
                  color: teams[row]['seasons'][widget.season]['STANDINGS']['strCurrentStreak']!
                          .contains('W')
                      ? Colors.green
                      : Colors.red),
            ),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 10:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STANDINGS']['L10']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 11:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STANDINGS']['HOME']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 12:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STANDINGS']['ROAD']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 13:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STANDINGS']['OppOver500']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 14:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STANDINGS']['vsEast']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 15:
        try {
          return StandingsDataText(
              text: teams[row]['seasons'][widget.season]['STANDINGS']['vsWest']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      default:
        return const Text('');
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
