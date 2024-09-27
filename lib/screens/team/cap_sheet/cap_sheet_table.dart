import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:material_table_view/default_animated_switcher_transition_builder.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../components/player_avatar.dart';
import '../../../utilities/constants.dart';
import '../../player/player_home.dart';

class CapSheet extends StatefulWidget {
  final Map<String, dynamic> team;

  const CapSheet({
    super.key,
    required this.team,
  });

  @override
  State<CapSheet> createState() => _CapSheetState();
}

class _CapSheetState extends State<CapSheet> {
  late List contracts;
  int _sortedColumnIndex = 3; // Default to sorting by '24-25' cap hit
  bool _isAscending = false; // Default sort direction

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
    'PLAYER',
    'AGE',
    'YRS',
    '\'24-25',
    '\'25-26',
    '\'26-27',
    '\'27-28',
    '\'28-29',
    '\'29-30',
  ];

  List _mergeContracts(List contracts) {
    Map<String, Map<String, dynamic>> mergedContracts = {};

    for (var contract in contracts) {
      String playerId = contract['player']['id'];
      String contractType = contract['contractType'];

      if (mergedContracts.containsKey(playerId)) {
        // Merge the contracts by year
        for (var year in contract['years']) {
          String startYear = year['fromYear'].toString();

          // Check if the year already exists
          if (mergedContracts[playerId]!['years'].containsKey(startYear)) {
            // If the year already exists, keep the upcoming contract's year data
            if (contractType == 'upcoming') {
              mergedContracts[playerId]!['years'][startYear] = year;
            }
          } else {
            // If the year doesn't exist, add it to the map
            mergedContracts[playerId]!['years'][startYear] = year;
          }
        }

        // Update the contractType if it's an upcoming contract
        if (contractType == 'upcoming') {
          mergedContracts[playerId]!['contractType'] = 'upcoming';
        }
      } else {
        // First time adding this player's contract
        mergedContracts[playerId] = Map.from(contract);
        // Convert years to a map
        mergedContracts[playerId]!['years'] = {
          for (var year in contract['years']) year['fromYear'].toString(): year
        };
      }
    }

    // Convert the merged contracts map back to a list
    return mergedContracts.values.toList();
  }

  @override
  void initState() {
    super.initState();
    contracts = _mergeContracts(widget.team['contracts']);
    _addTotalsRow();
    _sortContracts(_sortedColumnIndex, _isAscending);
  }

  void _addTotalsRow() {
    Map<String, dynamic> totalsRow = {
      'player': {'id': 'totals', 'firstName': '', 'lastName': 'Total'},
      'years': {
        for (var year in columnNames.sublist(3))
          '20${year.substring(1, 3)}': {'capHit': 0, 'age': '0'}
      }
    };

    Map<String, double> ageSums = {}; // To store the sum of ages for each year
    Map<String, int> playerCounts = {}; // To store the count of players for each year

    // Iterate over each contract and sum the cap hits and ages
    for (var contract in contracts) {
      for (var yearKey in totalsRow['years'].keys) {
        if (contract['years'].containsKey(yearKey)) {
          totalsRow['years'][yearKey]['capHit'] += contract['years'][yearKey]['capHit'];

          // Parse the age string and count the players for calculating the average age
          String ageString = contract['years'][yearKey]['age'] ?? '';
          if (ageString.isNotEmpty) {
            double age = double.parse(ageString);
            if (age > 0) {
              ageSums[yearKey] = (ageSums[yearKey] ?? 0) + age;
              playerCounts[yearKey] = (playerCounts[yearKey] ?? 0) + 1;
            }
          }
        }
      }
    }

    // Calculate the average age for each year and round to one decimal place
    for (var yearKey in totalsRow['years'].keys) {
      if (playerCounts.containsKey(yearKey) && playerCounts[yearKey]! > 0) {
        double averageAge = ageSums[yearKey]! / playerCounts[yearKey]!;
        totalsRow['years'][yearKey]['age'] =
            averageAge.toStringAsFixed(1); // Assign the String value
      } else {
        totalsRow['years'][yearKey]['age'] = 0;
      }
    }

    // Add the totals row to the contracts list
    contracts.add(totalsRow);
    _addSalaryCapDifferenceRow(totalsRow);
  }

  void _addSalaryCapDifferenceRow(Map<String, dynamic> totalsRow) {
    Map<String, dynamic> differenceRow = {
      'player': {'id': 'salary_cap_diff', 'firstName': '', 'lastName': 'Cap Space'},
      'years': {
        for (var year in columnNames.sublist(3)) '20${year.substring(1, 3)}': {'capHitDiff': 0}
      }
    };

    for (var yearKey in differenceRow['years'].keys) {
      int leagueCap = kLeagueSalaryCap[yearKey]!;
      int totalCapHit = totalsRow['years'][yearKey]['capHit'];
      differenceRow['years'][yearKey]['capHitDiff'] = leagueCap - totalCapHit;
    }

    // Add the salary cap difference row to the contracts list
    contracts.add(differenceRow);
    _addFirstApronDifferenceRow(totalsRow);
  }

  void _addFirstApronDifferenceRow(Map<String, dynamic> totalsRow) {
    Map<String, dynamic> differenceRow = {
      'player': {'id': 'salary_cap_diff', 'firstName': '', 'lastName': 'First Apron'},
      'years': {
        for (var year in columnNames.sublist(3)) '20${year.substring(1, 3)}': {'capHitDiff': 0}
      }
    };

    for (var yearKey in differenceRow['years'].keys) {
      int leagueCap = kLeagueFirstApron[yearKey]!;
      int totalCapHit = totalsRow['years'][yearKey]['capHit'];
      differenceRow['years'][yearKey]['capHitDiff'] = leagueCap - totalCapHit;
    }

    // Add the salary cap difference row to the contracts list
    contracts.add(differenceRow);
    _addSecondApronDifferenceRow(totalsRow);
  }

  void _addSecondApronDifferenceRow(Map<String, dynamic> totalsRow) {
    Map<String, dynamic> differenceRow = {
      'player': {'id': 'salary_cap_diff', 'firstName': '', 'lastName': 'Second Apron'},
      'years': {
        for (var year in columnNames.sublist(3)) '20${year.substring(1, 3)}': {'capHitDiff': 0}
      }
    };

    for (var yearKey in differenceRow['years'].keys) {
      int leagueCap = kLeagueSecondApron[yearKey]!;
      int totalCapHit = totalsRow['years'][yearKey]['capHit'];
      differenceRow['years'][yearKey]['capHitDiff'] = leagueCap - totalCapHit;
    }

    // Add the salary cap difference row to the contracts list
    contracts.add(differenceRow);
  }

  void _sortContracts(int columnIndex, bool ascending) {
    setState(() {
      _sortedColumnIndex = columnIndex;
      _isAscending = ascending;

      // Separate the Total and Salary Cap Difference rows
      var totalRow = contracts[contracts.length - 4];
      var salaryCapDiffRow = contracts[contracts.length - 3];
      var firstApronDiffRow = contracts[contracts.length - 2];
      var secondApronDiffRow = contracts[contracts.length - 1];

      // Remove these rows from the list before sorting
      contracts.removeWhere((contract) =>
          contract['player']['id'] == 'totals' ||
          contract['player']['id'] == 'salary_cap_diff');

      // Sort the remaining contracts
      contracts.sort((a, b) {
        var aValue, bValue;

        if (columnIndex >= 3) {
          String yearKey = '20${columnNames[columnIndex].substring(1, 3)}';
          aValue = a['years'][yearKey]?['capHit'] ?? 0;
          bValue = b['years'][yearKey]?['capHit'] ?? 0;
        } else if (columnIndex == 1) {
          aValue = a['years']['2024']['age'];
          bValue = b['years']['2024']['age'];
        } else {
          aValue = a['player']['lastName'];
          bValue = b['player']['lastName'];
        }

        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });

      // Add the Total and Salary Cap Difference rows back to the end of the list
      if (totalRow != null) contracts.add(totalRow);
      if (salaryCapDiffRow != null) contracts.add(salaryCapDiffRow);
      if (firstApronDiffRow != null) contracts.add(firstApronDiffRow);
      if (secondApronDiffRow != null) contracts.add(secondApronDiffRow);
    });
  }

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
      rowCount: contracts.length,
      rowHeight: MediaQuery.of(context).size.height * 0.055,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// PLAYER
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.35,
          freezePriority: 1,
        ),

        /// AGE
        TableColumn(
          width: MediaQuery.of(context).size.width * 0.1,
        ),

        /// POS
        TableColumn(width: MediaQuery.of(context).size.width * 0.1),

        /// '24-25
        TableColumn(width: MediaQuery.of(context).size.width * 0.16),

        /// '25-26
        TableColumn(width: MediaQuery.of(context).size.width * 0.16),

        /// '26-27
        TableColumn(width: MediaQuery.of(context).size.width * 0.16),

        /// '27-28
        TableColumn(width: MediaQuery.of(context).size.width * 0.16),

        /// '28-29
        TableColumn(width: MediaQuery.of(context).size.width * 0.16),

        /// '29-30
        TableColumn(width: MediaQuery.of(context).size.width * 0.16)
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
              bool ascending = _sortedColumnIndex == column ? !_isAscending : false;
              _sortContracts(column, ascending);
            },
            child: Material(
              color: const Color(0xFF303030),
              child: Padding(
                padding: column == 0
                    ? const EdgeInsets.only(left: 20.0)
                    : const EdgeInsets.only(right: 8.0),
                child: Align(
                  alignment: column == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        columnNames[column],
                        style: kBebasNormal.copyWith(
                          fontSize: 14.0,
                        ),
                      ),
                      if (_sortedColumnIndex == column)
                        Icon(
                          _isAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 14.0,
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
            color: ['totals', 'salary_cap_diff'].contains(contracts[index]['player']['id'])
                ? contracts[index]['player']['lastName'] == 'First Apron'
                    ? const Color(0xFF212121) //Color(0xFF7EB8EA)
                    : contracts[index]['player']['lastName'] == 'Second Apron'
                        ? const Color(0xFF111111) //Color(0xFF0F3665)
                        : const Color(0xFF303030)
                : Colors.grey.shade900,
            border: contracts[index]['player']['id'] == 'totals' ||
                    contracts[index]['player']['id'] == 'salary_cap_diff'
                ? Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                      width: contracts[index]['player']['id'] == 'salary_cap_diff' ? 0.5 : 1,
                    ),
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 0.5,
                    ))
                : Border(
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
            if (contracts[row]['player']['id'] != 'totals' &&
                contracts[row]['player']['id'] != 'salary_cap_diff') {
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerHome(
                      playerId: contracts[row]['playerId'],
                      teamId:
                          kTeamAbbrToId[contractTeamIds[contracts[row]['player']['teamId']]],
                    ),
                  ),
                );
              });
            }
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: getContent(contracts, row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(List contracts, int row, int column, BuildContext context) {
    Map<String, dynamic> player = contracts[row];

    // Identify the last year of the player's contract
    List<String> contractYears = player['years'].keys.toList();
    contractYears.sort(); // Sort the years to get the last one
    int yearsRemaining =
        int.parse(contractYears.last) - int.parse(kCurrentSeason.substring(0, 4));

    String freeAgentYear = contractYears.isNotEmpty
        ? '\'${(int.parse(contractYears.last) + 1).toString().substring(2)}-${(int.parse(contractYears.last) + 2).toString().substring(2)}'
        : '';

    bool isFreeAgentYear = columnNames[column] == freeAgentYear;

    String formatCurrency(int number) {
      double million = number / 1000000;
      String formattedNumber = NumberFormat("#,##0.0").format(million);
      return '\$${formattedNumber}M';
    }

    Color getColor(Map<String, dynamic> year) {
      Color color = year['playerOption']
          ? Colors.lightBlueAccent
          : year['teamOption']
              ? Colors.lightGreenAccent
              : year['qualifyingOffer']
                  ? Colors.orangeAccent
                  : year['nonGuaranteed']
                      ? Colors.blueGrey
                      : Colors.white;

      return color;
    }

    if (player['player']['id'] == 'totals') {
      switch (column) {
        case 0:
          return const CapSheetText(text: 'Total', alignment: Alignment.center);
        case 1:
          return CapSheetText(text: player['years']['2024']['age']);
        case 2:
          return const CapSheetText(text: '-');
        default:
          String yearKey = '20${columnNames[column].substring(1, 3)}';
          return CapSheetText(
            text: formatCurrency(player['years'][yearKey]['capHit']),
          );
      }
    }

    if (player['player']['id'] == 'salary_cap_diff') {
      switch (column) {
        case 0:
          return CapSheetText(text: player['player']['lastName'], alignment: Alignment.center);
        case 1:
        case 2:
          return const CapSheetText(text: '-');
        default:
          String yearKey = '20${columnNames[column].substring(1, 3)}';
          int capHitDiff = player['years'][yearKey]['capHitDiff'];
          return CapSheetText(
            text: formatCurrency(capHitDiff),
            color: capHitDiff < 0 ? Colors.red.shade400 : Colors.white,
          );
      }
    }

    switch (column) {
      /// PLAYER
      case 0:
        try {
          return Row(
            children: [
              SizedBox(width: 8.0.r),
              PlayerAvatar(
                radius: 12.0.r,
                backgroundColor: Colors.white70,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['player']['id']}.png',
              ),
              SizedBox(width: 8.0.r),
              Expanded(
                flex: 5,
                child: Text(
                  '${player['player']['firstName'].toString().substring(0, 1)}. ${player['player']['lastName']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
              ),
            ],
          );
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// AGE
      case 1:
        try {
          return CapSheetText(text: player['years']['2024']['age']);
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// YRS REMAINING
      case 2:
        try {
          return CapSheetText(text: '${yearsRemaining}Y');
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 24-25
      case 3:
        try {
          return CapSheetText(
              text: player['years']['2024']['capHit'] == 0
                  ? 'TW'
                  : formatCurrency(
                      player['years']['2024']['capHit'],
                    ),
              color: getColor(player['years']['2024']));
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 25-26
      case 4:
        try {
          if (isFreeAgentYear) {
            int year = int.parse('20${columnNames[column].substring(4)}');
            bool restrictedFreeAgent = player['signedUsing'] == 'rookie-scale-exception' ||
                year - player['player']['fromYear'] < 3;
            return Padding(
              padding: EdgeInsets.fromLTRB(8.0.r, 8.0.r, 0.0, 8.0.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: restrictedFreeAgent ? Colors.red.shade900 : Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  restrictedFreeAgent ? 'RFA' : 'UFA',
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
              ),
            );
          } else {
            return CapSheetText(
                text: formatCurrency(
                  player['years']['2025']['capHit'],
                ),
                color: getColor(player['years']['2025']));
          }
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 26-27
      case 5:
        try {
          if (isFreeAgentYear) {
            int year = int.parse('20${columnNames[column].substring(4)}');
            bool restrictedFreeAgent = player['signedUsing'] == 'rookie-scale-exception' ||
                year - player['player']['fromYear'] < 3;
            return Padding(
              padding: EdgeInsets.fromLTRB(8.0.r, 8.0.r, 0.0, 8.0.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: restrictedFreeAgent ? Colors.red.shade900 : Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  restrictedFreeAgent ? 'RFA' : 'UFA',
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
              ),
            );
          } else {
            return CapSheetText(
                text: formatCurrency(
                  player['years']['2026']['capHit'],
                ),
                color: getColor(player['years']['2026']));
          }
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 27-28
      case 6:
        try {
          if (isFreeAgentYear) {
            int year = int.parse('20${columnNames[column].substring(4)}');
            bool restrictedFreeAgent = player['signedUsing'] == 'rookie-scale-exception' ||
                year - player['player']['fromYear'] < 3;
            return Padding(
              padding: EdgeInsets.fromLTRB(8.0.r, 8.0.r, 0.0, 8.0.r),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: restrictedFreeAgent ? Colors.red.shade900 : Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  restrictedFreeAgent ? 'RFA' : 'UFA',
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
              ),
            );
          } else {
            return CapSheetText(
                text: formatCurrency(
                  player['years']['2027']['capHit'],
                ),
                color: getColor(player['years']['2027']));
          }
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 28-29
      case 7:
        try {
          if (isFreeAgentYear) {
            int year = int.parse('20${columnNames[column].substring(4)}');
            bool restrictedFreeAgent = player['signedUsing'] == 'rookie-scale-exception' ||
                year - player['player']['fromYear'] < 3;
            return Padding(
              padding: EdgeInsets.fromLTRB(8.0.r, 8.0.r, 0.0, 8.0.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: restrictedFreeAgent ? Colors.red.shade900 : Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  restrictedFreeAgent ? 'RFA' : 'UFA',
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
              ),
            );
          } else {
            return CapSheetText(
                text: formatCurrency(
                  player['years']['2028']['capHit'],
                ),
                color: getColor(player['years']['2028']));
          }
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 29-30
      case 8:
        try {
          if (isFreeAgentYear) {
            int year = int.parse('20${columnNames[column].substring(4)}');
            bool restrictedFreeAgent = player['signedUsing'] == 'rookie-scale-exception' ||
                year - player['player']['fromYear'] <= 3;
            return Padding(
              padding: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 0.0, 11.0.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 11.0.r),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: restrictedFreeAgent ? Colors.red.shade900 : Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  restrictedFreeAgent ? 'RFA' : 'UFA',
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
              ),
            );
          } else {
            return CapSheetText(
                text: formatCurrency(
                  player['years']['2029']['capHit'],
                ),
                color: getColor(player['years']['2029']));
          }
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      default:
        return const Text('-');
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
        style: kBebasNormal.copyWith(fontSize: 17.0.r, color: color ?? Colors.white),
      ),
    );
  }
}
