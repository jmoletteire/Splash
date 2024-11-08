import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../../utilities/constants.dart';
import '../../../team/team_home.dart';

class TeamCapSpace extends StatefulWidget {
  final Map<String, dynamic> teams;

  const TeamCapSpace({
    super.key,
    required this.teams,
  });

  @override
  State<TeamCapSpace> createState() => _TeamCapSpaceState();
}

class _TeamCapSpaceState extends State<TeamCapSpace> {
  late Map<String, dynamic> contracts;
  int _sortedColumnIndex = 3; // Default to sorting by '24-25' cap hit
  bool _isAscending = true; // Default sort direction

  Map<String, String> contractTeamIds = {
    '1': 'ATL',
    '2': 'BOS',
    '3': 'BKN',
    '4': 'CHA',
    '5': 'CHI',
    '6': 'CLE',
    '7': 'DAL',
    '8': 'DEN',
    '9': 'DET',
    '10': 'GSW',
    '11': 'HOU',
    '12': 'IND',
    '13': 'LAC',
    '14': 'LAL',
    '15': 'MEM',
    '16': 'MIA',
    '17': 'MIL',
    '18': 'MIN',
    '19': 'NOP',
    '20': 'NYK',
    '21': 'OKC',
    '22': 'ORL',
    '23': 'PHI',
    '24': 'PHX',
    '25': 'POR',
    '26': 'SAC',
    '27': 'SAS',
    '28': 'TOR',
    '29': 'UTA',
    '30': 'WAS'
  };

  List columnNames = [
    'TEAM',
    'AGE',
    'ALLOCATED',
    'CAP SPACE',
    '1st APRON',
    '2nd APRON',
  ];

  @override
  void initState() {
    super.initState();
    contracts = {};
    for (var team in widget.teams.entries) {
      contracts[team.key] = team.value[team.value.length - 1];
      for (var yearKey in team.value[team.value.length - 1]['years'].keys) {
        int leagueCap = kLeagueSalaryCap[yearKey]!;
        int leagueFirstApron = kLeagueFirstApron[yearKey]!;
        int leagueSecondApron = kLeagueSecondApron[yearKey]!;

        int totalCapHit = team.value[team.value.length - 1]['years'][yearKey]['capHit'];

        team.value[team.value.length - 1]['years'][yearKey]['capHitDiff'] =
            leagueCap - totalCapHit;
        team.value[team.value.length - 1]['years'][yearKey]['firstApronDiff'] =
            leagueFirstApron - totalCapHit;
        team.value[team.value.length - 1]['years'][yearKey]['secondApronDiff'] =
            leagueSecondApron - totalCapHit;
      }
    }
    _sortContracts(_sortedColumnIndex, _isAscending);
  }

  void _sortContracts(int columnIndex, bool ascending) {
    setState(() {
      _sortedColumnIndex = columnIndex;
      _isAscending = ascending;

      // Convert the sorted list back into a map
      var sortedEntries = contracts.entries.toList()
        ..sort((a, b) {
          var aValue, bValue;

          if (columnIndex >= 2) {
            String yearKey = '2024';
            aValue = a.value['years'][yearKey]?['capHit'] ?? 0;
            bValue = b.value['years'][yearKey]?['capHit'] ?? 0;
          } else if (columnIndex == 1) {
            aValue = a.value['years']['2024']['age'];
            bValue = b.value['years']['2024']['age'];
          } else {
            aValue = kTeamIdToName[a.value['teamId']][1];
            bValue = kTeamIdToName[b.value['teamId']][1];
          }

          return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        });

      // Assign the sorted list back to widget.teams
      contracts = Map.fromEntries(sortedEntries);
    });
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
      rowCount: contracts.length,
      rowHeight: MediaQuery.of(context).size.height * 0.055,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// TEAM
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.15
              : MediaQuery.of(context).size.width * 0.25,
          freezePriority: 1,
        ),

        /// AGE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.14,
        ),

        /// ALLOCATIONS
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.05
                : MediaQuery.of(context).size.width * 0.19),

        /// CAP SPACE
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.19),

        /// FIRST APRON SPACE
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.19),

        /// SECOND APRON SPACE
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.19),
      ],
      rowBuilder: _rowBuilder,
      headerBuilder: _headerBuilder,
    );
  }

  Widget _headerBuilder(BuildContext context, TableRowContentBuilder contentBuilder) =>
      contentBuilder(
        context,
        (context, column) {
          return GestureDetector(
            onTap: () {
              bool ascending = _sortedColumnIndex == column ? !_isAscending : true;
              _sortContracts(column, ascending);
            },
            child: Material(
              color: const Color(0xFF303030),
              child: Padding(
                padding: column == 0
                    ? EdgeInsets.only(left: 20.0.r)
                    : EdgeInsets.only(right: 8.0.r),
                child: Align(
                  alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        columnNames[column],
                        style: kBebasNormal.copyWith(
                          fontSize: 14.0.r,
                        ),
                      ),
                      if (_sortedColumnIndex == column)
                        Icon(
                          _isAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 14.0.r,
                          color: Colors.white,
                        ),
                    ],
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
            color: const Color(0xFF202020),
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

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamHome(
                  teamId: contracts.keys.toList()[row],
                ),
              ),
            );
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: EdgeInsets.only(right: 8.0.r),
              child: getContent(contracts.entries.toList(), row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(List contracts, int row, int column, BuildContext context) {
    dynamic team = contracts[row];

    String formatCurrency(int number) {
      double million = number / 1000000;
      String formattedNumber = NumberFormat("#,##0.0").format(million);
      return '\$${formattedNumber}M';
    }

    switch (column) {
      case 0:
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  (row + 1).toString(),
                  style: kBebasNormal.copyWith(
                    fontSize: 12.0.r,
                    color: Colors.grey,
                  ),
                ),
              ),
              Spacer(),
              Expanded(
                flex: 3,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 25.0.r, maxWidth: 25.0.r),
                  child: Image.asset('images/NBA_Logos/${team.key}.png'),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: CapSheetText(
                      text: kTeamIdToName[team.key][1], alignment: Alignment.center)),
            ],
          ),
        );
      case 1:
        String yearKey = '2024';
        return CapSheetText(
          text: team.value['years'][yearKey]['age'],
          color: Colors.white,
        );
      case 2:
        String yearKey = '2024';
        int capHit = team.value['years'][yearKey]['capHit'];
        return CapSheetText(
          text: formatCurrency(capHit),
          color: capHit < 0 ? Colors.red.shade400 : Colors.white,
        );
      case 3:
        String yearKey = '2024';
        int capHitDiff = team.value['years'][yearKey]['capHitDiff'];
        return CapSheetText(
          text: formatCurrency(capHitDiff),
          color: capHitDiff < 0 ? Colors.red.shade400 : Colors.white,
        );
      case 4:
        String yearKey = '2024';
        int capHitDiff = team.value['years'][yearKey]['firstApronDiff'];
        return CapSheetText(
          text: formatCurrency(capHitDiff),
          color: capHitDiff < 0 ? Colors.red.shade400 : Colors.white,
        );
      case 5:
        String yearKey = '2024';
        int capHitDiff = team.value['years'][yearKey]['secondApronDiff'];
        return CapSheetText(
          text: formatCurrency(capHitDiff),
          color: capHitDiff < 0 ? Colors.red.shade400 : Colors.white,
        );
      default:
        return const CapSheetText(
          text: '-',
          color: Colors.white,
        );
    }
  }
}

class CapSheetText extends StatelessWidget {
  const CapSheetText({super.key, required this.text, this.alignment, this.color});

  final Alignment? alignment;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: Text(
        text,
        style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color ?? Colors.white),
      ),
    );
  }
}
