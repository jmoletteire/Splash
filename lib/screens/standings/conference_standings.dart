import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';
import 'package:splash/utilities/constants.dart';

import '../team/team_home.dart';

class ConferenceStandings extends StatefulWidget {
  final List columnNames;
  final List<Map<String, dynamic>> standings;
  final String season;
  final ScrollController scrollController;

  const ConferenceStandings({
    super.key,
    required this.columnNames,
    required this.standings,
    required this.season,
    required this.scrollController,
  });

  @override
  State<ConferenceStandings> createState() => _ConferenceStandingsState();
}

class _ConferenceStandingsState extends State<ConferenceStandings>
    with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;
  late double availableWidth;
  late double availableHeight;
  late double logicalImageSize;
  late double devicePixelRatio;
  late int cacheImageSize;
  bool isLandscape = false;
  List<Map<String, dynamic>> teams = [];
  List<Image> teamLogos = [];
  List<TableColumn> tableColumns = [];
  Widget? _cachedHeader;
  final Map<int, Map<int, Widget>> _cachedContent = {};

  @override
  bool get wantKeepAlive => true;

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

  void _initializeTableColumns() {
    tableColumns = [
      TableColumn(
        width: availableWidth * (isLandscape ? 0.12 : 0.3),
        freezePriority: 1,
      ),

      /// W
      TableColumn(width: availableWidth * (isLandscape ? 0.05 : 0.08)),

      /// L
      TableColumn(width: availableWidth * (isLandscape ? 0.05 : 0.08)),

      /// PCT
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.165)),

      /// GB
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.125)),

      /// NRTG
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// ORTG
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// DRTG
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// PACE
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// SOS
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// rSOS
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// STREAK
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// xPTS
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// LAST 10
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// HOME
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// ROAD
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// Opp .500+
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// EAST
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// WEST
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// VS ATLANTIC
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.135)),

      /// VS CENTRAL
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.115)),

      /// VS SOUTHEAST
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.115)),

      /// VS NORTHWEST
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.115)),

      /// VS PACIFIC
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.115)),

      /// VS SOUTHWEST
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.115)),

      /// SCORE 100+ PTS
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.165)),

      /// LEAD AT HALF
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// LEAD THRU 3Q
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// WIN FG%
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// WIN REB
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),

      /// WIN TO
      TableColumn(width: availableWidth * (isLandscape ? 0.08 : 0.15)),
    ];
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _checkSeasons();

    teams.sort((a, b) {
      return a['SEASONS'][widget.season]['STANDINGS']['PlayoffRank']
          .compareTo(b['SEASONS'][widget.season]['STANDINGS']['PlayoffRank']);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set image size
    logicalImageSize = 24.0.r;
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    cacheImageSize = (logicalImageSize * devicePixelRatio).toInt();

    // Check device orientation
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    availableWidth = MediaQuery.of(context).size.width;
    availableHeight = MediaQuery.of(context).size.height;

    for (var team in teams) {
      teamLogos.add(Image.asset(
        'images/NBA_Logos/${team['TEAM_ID']}.png',
        fit: BoxFit.contain,
        width: logicalImageSize,
        height: logicalImageSize,
      ));
    }

    // Initialize table columns
    _initializeTableColumns();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SliverTableView.builder(
      addAutomaticKeepAlives: true,
      horizontalScrollController: widget.scrollController,
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
      headerHeight: availableHeight * 0.045,
      rowCount: teams.length,
      rowHeight: availableHeight * 0.055,
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
          color: Colors.grey.shade800,
          child: Padding(
            padding:
                column == 0 ? EdgeInsets.only(left: 20.0.r) : EdgeInsets.only(right: 8.0.r),
            child: Align(
              alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: AutoSizeText('${widget.columnNames[column]}',
                  maxLines: 1,
                  style: kBebasNormal.copyWith(
                    fontSize: 16.0.r,
                  )),
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
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade900.withValues(alpha: 0.75),
                border: _getRowBorder(index),
              ),
              child: child,
            ),
            if (int.parse(widget.season.substring(0, 4)) >= 2019 && index == 5)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  painter: DashedLinePainter(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                  child: Container(
                    height: 1.0,
                  ),
                ),
              ),
          ],
        ),
      );

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    return _wrapRow(
      row,
      Material(
          type: MaterialType.transparency,
          child: TeamRow(
            teamId: teams[row]['TEAM_ID'].toString(),
            child: contentBuilder(context, (context, column) {
              return Padding(
                padding: _getPaddingForColumn(column),
                child: getContent(row, column, context),
              );
            }),
          )),
    );
  }

  BoxBorder? _getRowBorder(int index) {
    if (int.parse(widget.season.substring(0, 4)) < 2019 || index != 5) {
      return Border(
        bottom: BorderSide(
          color: (int.parse(widget.season.substring(0, 4)) >= 2019 && index == 9) ||
                  (int.parse(widget.season.substring(0, 4)) < 2019 &&
                      int.parse(widget.season.substring(0, 4)) > 1983 &&
                      index == 7) ||
                  (int.parse(widget.season.substring(0, 4)) <= 1983 && index == 5)
              ? Colors.white
              : Colors.grey.shade700,
          width: int.parse(widget.season.substring(0, 4)) >= 2019 && index == 9
              ? 3.0
              : int.parse(widget.season.substring(0, 4)) < 2019 &&
                      int.parse(widget.season.substring(0, 4)) > 1983 &&
                      index == 7
                  ? 3.0
                  : int.parse(widget.season.substring(0, 4)) <= 1983 && index == 5
                      ? 3.0
                      : 0.5,
          style: BorderStyle.solid,
        ),
      );
    } else {
      return null;
    }
  }

  EdgeInsets _getPaddingForColumn(int column) {
    List<String> noPadding = ['ORTG', 'DRTG', 'PACE', 'SOR', 'R-SOS'];
    if (noPadding.contains(widget.columnNames[column])) {
      return EdgeInsets.only(right: 0.0.r);
    } else {
      return EdgeInsets.only(right: 8.0.r);
    }
  }

  Widget getContent(int row, int column, BuildContext context) {
    if (_cachedContent.containsKey(row)) {
      if (_cachedContent[row]!.containsKey(column)) {
        return _cachedContent[row]![column]!;
      }
    } else {
      _cachedContent[row] = {};
    }

    switch (column) {
      case 0:
        return _cachedContent[row]![column] ??= Padding(
          padding: EdgeInsets.fromLTRB(8.0.r, 8.0.r, 3.0.r, 8.0.r),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  teams[row]['SEASONS'][widget.season]['STANDINGS']['PlayoffRank'].toString(),
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
                  child: teamLogos[row],
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
                        style: kBebasNormal.copyWith(fontSize: 11.0.r, letterSpacing: 0.8),
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
          String wins = teams[row]['SEASONS'][widget.season]['WINS']!.toStringAsFixed(0);
          return _cachedContent[row]![column] ??=
              StandingsDataText(key: ValueKey(wins), text: wins);
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
        }
      case 2:
        try {
          String losses = teams[row]['SEASONS'][widget.season]['LOSSES']!.toStringAsFixed(0);
          return _cachedContent[row]![column] ??=
              StandingsDataText(key: ValueKey(losses), text: losses);
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
        }
      case 3:
        try {
          String winPct = teams[row]['SEASONS'][widget.season]['WIN_PCT']!.toStringAsFixed(3);
          return _cachedContent[row]![column] ??=
              StandingsDataText(key: ValueKey(winPct), text: winPct);
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
        }
      case 4:
        String gb = teams[row]['SEASONS'][widget.season]['STANDINGS']['ConferenceGamesBack']!
            .toString();
        return _cachedContent[row]![column] ??=
            StandingsDataText(key: ValueKey(gb), text: gb == '0.0' ? '-' : gb);
      case 5:
        try {
          double netRating = double.parse(teams[row]['SEASONS'][widget.season]['STATS']
              ['REGULAR SEASON']['NRTG']['Totals']['Value']);
          String positive = netRating > 0.0 ? '+' : '';
          return _cachedContent[row]![column] ??= Container(
            alignment: Alignment.centerRight,
            child: Text('$positive${netRating.toStringAsFixed(1)}',
                style: kBebasNormal.copyWith(
                  fontSize: 16.0.r,
                  color: netRating > 0.0 ? const Color(0xFF55F86F) : const Color(0xFFFC3126),
                )),
          );
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
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

          return _cachedContent[row]![column] ??= Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1), // background with lighter opacity
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(
              offRating.toStringAsFixed(1),
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
            ),
          );
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
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

          return _cachedContent[row]![column] ??= Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1), // background with lighter opacity
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(
              defRating.toStringAsFixed(1),
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
            ),
          );
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
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

          return _cachedContent[row]![column] ??= Container(
            alignment: Alignment.centerRight,
            color: color.withOpacity(0.1), // background with lighter opacity
            padding: EdgeInsets.only(right: 5.0.r),
            child: Text(
              pace.toStringAsFixed(1),
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color),
            ),
          );
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
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

          return _cachedContent[row]![column] ??= Container(
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
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
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

          return _cachedContent[row]![column] ??= Container(
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
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
        }
      case 11:
        try {
          String streak =
              teams[row]['SEASONS'][widget.season]['STANDINGS']['strCurrentStreak'];
          return _cachedContent[row]![column] ??= Container(
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
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
        }
      case 12:
        try {
          String xPts =
              '${teams[row]['SEASONS']?[widget.season]?['xPTS_W'] ?? '0'} - ${teams[row]['SEASONS']?[widget.season]?['xPTS_L'] ?? '0'}';
          return _cachedContent[row]![column] ??=
              StandingsDataText(key: ValueKey(xPts), text: xPts);
        } catch (e) {
          return _cachedContent[row]![column] ??= const StandingsDataText(text: '-');
        }
      case 13:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'L10');
      case 14:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'HOME');
      case 15:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'ROAD');
      case 16:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'OppOver500');
      case 17:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsEast');
      case 18:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsWest');
      case 19:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsAtlantic');
      case 20:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsCentral');
      case 21:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsSoutheast');
      case 22:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsNorthwest');
      case 23:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsPacific');
      case 24:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'vsSouthwest');
      case 25:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'Score100PTS');
      case 26:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'AheadAtHalf');
      case 27:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'AheadAtThird');
      case 28:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'LeadInFGPCT');
      case 29:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'LeadInReb');
      case 30:
        return _cachedContent[row]![column] ??= getStandingsData(row, 'FewerTurnovers');
      default:
        return const Text('');
    }
  }

  Widget getStandingsData(int row, String name) {
    try {
      String stat = teams[row]['SEASONS'][widget.season]['STANDINGS'][name]!;
      return StandingsDataText(key: ValueKey(stat), text: stat);
    } catch (e) {
      return const StandingsDataText(key: ValueKey('-'), text: '-');
    }
  }
}

class StandingsDataText extends StatelessWidget {
  const StandingsDataText({super.key, required this.text, this.color, this.alignment});

  final Alignment? alignment;
  final Color? color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        color: color?.withOpacity(0.1) ?? Colors.transparent,
        alignment: alignment ?? Alignment.centerRight,
        child: Text(
          text,
          style: kBebasNormal.copyWith(fontSize: 17.0.r, color: color),
        ),
      ),
    );
  }
}

class TeamRow extends StatelessWidget {
  final String teamId;
  final Widget child;

  const TeamRow({super.key, required this.teamId, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamHome(teamId: teamId),
        ),
      ),
      splashColor: Colors.white,
      child: child,
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double startX = 0;
    final double y = size.height;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
