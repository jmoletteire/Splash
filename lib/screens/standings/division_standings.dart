import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/utilities/constants.dart';

import '../team/team_home.dart';

class DivisionStandings extends StatefulWidget {
  final Key key;
  final List columnNames;
  final List standings;
  final String season;
  final ScrollController divController;

  DivisionStandings({
    required this.key,
    required this.columnNames,
    required this.standings,
    required this.season,
    required this.divController,
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
      return '';
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
      if (!teams.contains(team) && team['SEASONS'].containsKey(widget.season)) {
        teams.add(team);
      }
      if (teams.contains(team) && !team['SEASONS'].containsKey(widget.season)) {
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
      return a['SEASONS'][widget.season]['STANDINGS']['DivisionRank']
          .compareTo(b['SEASONS'][widget.season]['STANDINGS']['DivisionRank']);
    });

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SliverTableView.builder(
      horizontalScrollController: widget.divController,
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
          width: MediaQuery.of(context).size.width * (isLandscape ? 0.15 : 0.3),
          freezePriority: 1,
        ),

        /// W
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.05 : 0.08)),

        /// L
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.05 : 0.08)),

        /// PCT
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.165)),

        /// GB
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.125)),

        /// NRTG
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// ORTG
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// DRTG
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// PACE
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// SOR
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// R-SOS
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// STREAK
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// xPTS
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// LAST 10
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// HOME
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// ROAD
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// Over .500
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// EAST
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// WEST
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// VS ATLANTIC
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.135)),

        /// VS CENTRAL
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.115)),

        /// VS SOUTHEAST
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.115)),

        /// VS NORTHWEST
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.115)),

        /// VS PACIFIC
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.115)),

        /// VS SOUTHWEST
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.115)),

        /// SCORE 100+ PTS
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.165)),

        /// LEAD AT HALF
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// LEAD THRU 3Q
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// WIN FG%
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// WIN REB
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),

        /// WIN TO
        TableColumn(width: MediaQuery.of(context).size.width * (isLandscape ? 0.08 : 0.15)),
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
                alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
                child: Text('${widget.columnNames[column]}',
                    style: kBebasNormal.copyWith(
                      fontSize: 16.0.r,
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
              decoration: BoxDecoration(
                  color: Colors.grey.shade900.withValues(alpha: 0.75),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade700,
                      width: 0.5,
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
            List<String> noPadding = ['ORTG', 'DRTG', 'PACE', 'SOR', 'R-SOS'];
            return Padding(
              padding: noPadding.contains(widget.columnNames[column])
                  ? EdgeInsets.only(right: 0.0.r)
                  : EdgeInsets.only(right: 8.0.r),
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
          padding: EdgeInsets.fromLTRB(8.0.r, 8.0.r, 3.0.r, 8.0.r),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  teams[row]['SEASONS'][widget.season]['STANDINGS']['DivisionRank'].toString(),
                  textAlign: TextAlign.center,
                  style: kBebasNormal.copyWith(
                    color: Colors.white70,
                    fontSize: 17.0.r,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 24.0.r),
                  child: Image.asset(
                    'images/NBA_Logos/${teams[row]['TEAM_ID']}.png',
                    fit: BoxFit.contain,
                    width: 24.0.r,
                    height: 24.0.r,
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
                        style: kBebasBold.copyWith(fontSize: 18.0.r),
                      ),
                      TextSpan(
                        text: getClinched(teams[row]['SEASONS'][widget.season]['STANDINGS']),
                        style: kBebasNormal.copyWith(fontSize: 10.0.r, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 1:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['WINS']!.toStringAsFixed(0));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 2:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['LOSSES']!.toStringAsFixed(0));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 3:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['WIN_PCT']!.toStringAsFixed(3));
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 4:
        String gb =
            teams[row]['SEASONS'][widget.season]['STANDINGS']['DivisionGamesBack']!.toString();
        return StandingsDataText(text: gb == '0.0' ? '-' : gb);
      case 5:
        try {
          double netRating = double.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['NRTG']['Totals']['Value']);
          String positive = netRating > 0.0 ? '+' : '';
          return Container(
            alignment: Alignment.centerRight,
            child: Text('$positive${netRating.toStringAsFixed(1)}',
                style: kBebasNormal.copyWith(
                  fontSize: 16.0.r,
                  color: netRating > 0.0 ? const Color(0xFF55F86F) : const Color(0xFFFC3126),
                )),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 6:
        try {
          double offRating = double.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['ORTG']['Totals']['Value']);
          int oRtgRank = int.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['ORTG']['Totals']['Rank']);

          // Define the three colors for the gradient
          Color green = const Color(0xFF55F86F);
          Color lightGreen = Colors.lightGreenAccent;
          Color yellow = Colors.yellowAccent;
          Color orange = Colors.orangeAccent;
          Color red = const Color(0xFFFC3126);

          // Calculate the interpolated color based on oRtgRank
          Color color;
          if (oRtgRank <= 10) {
            // Rank 1-10, full green
            double factor = oRtgRank / 10; // scales 1-10 to 0-1
            color = Color.lerp(green, lightGreen, factor) ?? lightGreen;
          } else if (oRtgRank <= 15) {
            // Rank 11-20, interpolate between green and orange
            double factor = (oRtgRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(lightGreen, yellow, factor) ?? yellow;
          } else if (oRtgRank <= 20) {
            // Rank 11-20, interpolate between green and orange
            double factor = (oRtgRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(yellow, orange, factor) ?? orange;
          } else {
            // Rank 21-30, interpolate between orange and red
            double factor = (oRtgRank - 20) / 10; // scales 21-30 to 0-1
            color = Color.lerp(orange, red, factor) ?? red;
          }

          return Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1), // background with lighter opacity
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(
              offRating.toStringAsFixed(1),
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
            ),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 7:
        try {
          double defRating = double.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['DRTG']['Totals']['Value']);
          int dRtgRank = int.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['DRTG']['Totals']['Rank']);

          // Define the three colors for the gradient
          Color green = const Color(0xFF55F86F);
          Color lightGreen = Colors.lightGreenAccent;
          Color yellow = Colors.yellowAccent;
          Color orange = Colors.orangeAccent;
          Color red = const Color(0xFFFC3126);

          // Calculate the interpolated color based on oRtgRank
          Color color;
          if (dRtgRank <= 10) {
            // Rank 1-10, full green
            double factor = dRtgRank / 10; // scales 1-10 to 0-1
            color = Color.lerp(green, lightGreen, factor) ?? lightGreen;
          } else if (dRtgRank <= 15) {
            // Rank 11-20, interpolate between green and orange
            double factor = (dRtgRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(lightGreen, yellow, factor) ?? yellow;
          } else if (dRtgRank <= 20) {
            // Rank 11-20, interpolate between green and orange
            double factor = (dRtgRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(yellow, orange, factor) ?? orange;
          } else {
            // Rank 21-30, interpolate between orange and red
            double factor = (dRtgRank - 20) / 10; // scales 21-30 to 0-1
            color = Color.lerp(orange, red, factor) ?? red;
          }

          return Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1), // background with lighter opacity
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(
              defRating.toStringAsFixed(1),
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
            ),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 8:
        try {
          double pace = double.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['PACE']['Totals']['Value']);
          int paceRank = int.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['PACE']['Totals']['Rank']);

          // Define the three colors for the gradient
          Color green = Colors.pink;
          Color lightGreen = Colors.pinkAccent;
          Color yellow = Colors.white;
          Color orange = Colors.lightBlueAccent;
          Color red = Colors.blue;

          // Calculate the interpolated color based on oRtgRank
          Color color;
          if (paceRank <= 10) {
            // Rank 1-10, full green
            double factor = paceRank / 10; // scales 1-10 to 0-1
            color = Color.lerp(green, lightGreen, factor) ?? lightGreen;
          } else if (paceRank <= 15) {
            // Rank 11-20, interpolate between green and orange
            double factor = (paceRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(lightGreen, yellow, factor) ?? yellow;
          } else if (paceRank <= 20) {
            // Rank 11-20, interpolate between green and orange
            double factor = (paceRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(yellow, orange, factor) ?? orange;
          } else {
            // Rank 21-30, interpolate between orange and red
            double factor = (paceRank - 20) / 10; // scales 21-30 to 0-1
            color = Color.lerp(orange, red, factor) ?? red;
          }

          return Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1), // background with lighter opacity
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(
              pace.toStringAsFixed(1),
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
            ),
          );
          /*
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STATS']['REGULAR SEASON']['ADV']
                      ['PACE']!
                  .toStringAsFixed(1));

           */
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 9:
        try {
          double sos = teams[row]['SEASONS'][widget.season]['STANDINGS']['SOS'];
          int sosRank = teams[row]['SEASONS'][widget.season]['STANDINGS']['SOS_RANK'];

          // Define the three colors for the gradient
          Color green = const Color(0xFF55F86F);
          Color lightGreen = Colors.lightGreenAccent;
          Color yellow = Colors.yellowAccent;
          Color orange = Colors.orangeAccent;
          Color red = const Color(0xFFFC3126);

          // Calculate the interpolated color based on oRtgRank
          Color color;
          if (sosRank <= 10) {
            // Rank 1-10, full green
            double factor = sosRank / 10; // scales 1-10 to 0-1
            color = Color.lerp(green, lightGreen, factor) ?? lightGreen;
          } else if (sosRank <= 15) {
            // Rank 11-20, interpolate between green and orange
            double factor = (sosRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(lightGreen, yellow, factor) ?? yellow;
          } else if (sosRank <= 20) {
            // Rank 11-20, interpolate between green and orange
            double factor = (sosRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(yellow, orange, factor) ?? orange;
          } else {
            // Rank 21-30, interpolate between orange and red
            double factor = (sosRank - 20) / 10; // scales 21-30 to 0-1
            color = Color.lerp(orange, red, factor) ?? red;
          }

          return Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1),
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(sos.toStringAsFixed(3),
                style: kBebasNormal.copyWith(
                  fontSize: 16.0.r,
                  color: color,
                )),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 10:
        try {
          double sos = teams[row]['SEASONS'][widget.season]['STANDINGS']['rSOS'];
          int sosRank = teams[row]['SEASONS'][widget.season]['STANDINGS']['rSOS_RANK'];

          // Define the three colors for the gradient
          Color green = const Color(0xFF55F86F);
          Color lightGreen = Colors.lightGreenAccent;
          Color yellow = Colors.yellowAccent;
          Color orange = Colors.orangeAccent;
          Color red = const Color(0xFFFC3126);

          // Calculate the interpolated color based on oRtgRank
          Color color;
          if (sosRank <= 10) {
            // Rank 1-10, full green
            double factor = sosRank / 10; // scales 1-10 to 0-1
            color = Color.lerp(green, lightGreen, factor) ?? lightGreen;
          } else if (sosRank <= 15) {
            // Rank 11-20, interpolate between green and orange
            double factor = (sosRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(lightGreen, yellow, factor) ?? yellow;
          } else if (sosRank <= 20) {
            // Rank 11-20, interpolate between green and orange
            double factor = (sosRank - 10) / 10; // scales 11-20 to 0-1
            color = Color.lerp(yellow, orange, factor) ?? orange;
          } else {
            // Rank 21-30, interpolate between orange and red
            double factor = (sosRank - 20) / 10; // scales 21-30 to 0-1
            color = Color.lerp(orange, red, factor) ?? red;
          }

          return Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1),
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(sos.toStringAsFixed(3),
                style: kBebasNormal.copyWith(
                  fontSize: 16.0.r,
                  color: color,
                )),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 11:
        try {
          String streak =
              teams[row]['SEASONS'][widget.season]['STANDINGS']['strCurrentStreak'];
          return Container(
            alignment: Alignment.centerRight,
            child: Text(
              teams[row]['SEASONS'][widget.season]['STANDINGS']['strCurrentStreak']!,
              style: kBebasNormal.copyWith(
                fontSize: 16.0.r,
                color: streak == 'W 0'
                    ? Colors.white
                    : streak.contains('W')
                        ? const Color(0xFF55F86F)
                        : const Color(0xFFFC3126),
              ),
            ),
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 12:
        try {
          return StandingsDataText(
            text:
                '${teams[row]['SEASONS']?[widget.season]?['xPTS_W'] ?? '0'} - ${teams[row]['SEASONS']?[widget.season]?['xPTS_L'] ?? '0'}',
          );
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 13:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['L10']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 14:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['HOME']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 15:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['ROAD']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 16:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['OppOver500']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 17:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsEast']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 18:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsWest']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 19:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsAtlantic']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 20:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsCentral']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 21:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsSoutheast']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 22:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsNorthwest']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 23:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsPacific']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 24:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['vsSouthwest']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 25:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['Score100PTS']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 26:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['AheadAtHalf']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 27:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['AheadAtThird']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 28:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['LeadInFGPCT']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 29:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['LeadInReb']!);
        } catch (e) {
          return const StandingsDataText(text: '-');
        }
      case 30:
        try {
          return StandingsDataText(
              text: teams[row]['SEASONS'][widget.season]['STANDINGS']['FewerTurnovers']!);
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
        style: kBebasNormal.copyWith(fontSize: 16.0.r),
      ),
    );
  }
}
