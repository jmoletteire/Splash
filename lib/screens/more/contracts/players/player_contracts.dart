import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../../components/player_avatar.dart';
import '../../../../utilities/constants.dart';
import '../../../player/player_home.dart';

class PlayerContracts extends StatefulWidget {
  final Map<String, dynamic> teams;

  const PlayerContracts({
    super.key,
    required this.teams,
  });

  @override
  State<PlayerContracts> createState() => _PlayerContractsState();
}

class _PlayerContractsState extends State<PlayerContracts> {
  late Map<String, dynamic> contracts;
  int _sortedColumnIndex = 5; // Default to sorting by '24-25' cap hit
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
    '30': 'WAS',
    '0': 'FA',
  };

  List columnNames = [
    'PLAYER',
    'TEAM',
    'POS',
    'AGE',
    'YRS',
    '\'24-25',
    '\'25-26',
    '\'26-27',
    '\'27-28',
    '\'28-29',
    '\'29-30',
  ];

  @override
  void initState() {
    super.initState();
    contracts = {};
    for (var team in widget.teams.entries) {
      for (var contract in team.value) {
        if (contract['player']['id'] != 'total' &&
            contract['player']['firstName'] != '' &&
            contract['player']['id'] != null) {
          contracts[contract['player']['id']] = contract;
        }
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

          if (columnIndex >= 5) {
            String yearKey = '20${columnNames[columnIndex].substring(1, 3)}';
            aValue = a.value['years'][yearKey]?['capHit'] ?? 0;
            bValue = b.value['years'][yearKey]?['capHit'] ?? 0;
          } else if (columnIndex == 1) {
            aValue = contractTeamIds[
                a.value['years']?[kCurrentSeason.substring(0, 4)]?['teamId'] ?? '0'];
            bValue = contractTeamIds[
                b.value['years']?[kCurrentSeason.substring(0, 4)]?['teamId'] ?? '0'];
          } else if (columnIndex == 2) {
            if (a.value['position'] != null && a.value['position'] != '') {
              aValue = a.value['position'];
            } else {
              aValue = 'Z';
            }
            if (b.value['position'] != null && b.value['position'] != '') {
              bValue = b.value['position'];
            } else {
              bValue = 'Z';
            }
          } else if (columnIndex == 3) {
            aValue = int.tryParse(
                    a.value['years']?[kCurrentSeason.substring(0, 4)]?['age'] ?? '0') ??
                0;
            bValue = int.tryParse(
                    b.value['years']?[kCurrentSeason.substring(0, 4)]?['age'] ?? '0') ??
                0;
          } else if (columnIndex == 4) {
            aValue = a.value['years'].length;
            bValue = b.value['years'].length;
          } else {
            aValue = a.value['player']['lastName'];
            bValue = b.value['player']['lastName'];
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
        /// PLAYER
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.15
              : MediaQuery.of(context).size.width * 0.35,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.12,
        ),

        /// POSITION
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// AGE
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.05
              : MediaQuery.of(context).size.width * 0.1,
        ),

        /// YEARS
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.05
                : MediaQuery.of(context).size.width * 0.1),

        /// '24-25
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.16),

        /// '25-26
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.16),

        /// '26-27
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.16),

        /// '27-28
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.16),

        /// '28-29
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.16),

        /// '29-30
        TableColumn(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.125
                : MediaQuery.of(context).size.width * 0.16)
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
                builder: (context) => PlayerHome(
                  playerId: contracts.keys.toList()[row],
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
    dynamic player = contracts[row].value;

    // Identify the last year of the player's contract
    List<String> contractYears = player['years'].keys.toList();
    contractYears.sort(); // Sort the years to get the last one
    int yearsRemaining =
        (int.parse(contractYears.last) + 1) - int.parse(kCurrentSeason.substring(0, 4));

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

    switch (column) {
      /// PLAYER
      case 0:
        try {
          return Padding(
            padding: EdgeInsets.only(left: 8.0.r),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    (row + 1).toString(),
                    style: kBebasNormal.copyWith(
                      fontSize: 12.0.r,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: PlayerAvatar(
                    radius: 12.0.r,
                    backgroundColor: Colors.white70,
                    playerImageUrl:
                        'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['player']['id']}.png',
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: Text(
                    '${player['player']['firstName'].toString().substring(0, 1)}. ${player['player']['lastName']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBebasNormal.copyWith(fontSize: 15.0.r),
                  ),
                ),
              ],
            ),
          );
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// TEAM
      case 1:
        try {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 30.0.r, maxWidth: 30.0.r),
                child: Image.asset(
                  'images/NBA_Logos/${kTeamAbbrToId[contractTeamIds[player['years']?[kCurrentSeason.substring(0, 4)]?['teamId'] ?? '0']]}.png',
                ),
              ),
            ],
          );
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// POSITION
      case 2:
        try {
          return CapSheetText(text: player['position']);
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// AGE
      case 3:
        try {
          return CapSheetText(text: player['years']['2024']['age']);
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// YRS REMAINING
      case 4:
        try {
          return CapSheetText(text: '${yearsRemaining}Y');
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 24-25
      case 5:
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
      case 6:
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
                  player['years']['2026']['capHit'],
                ),
                color: getColor(player['years']['2026']));
          }
        } catch (stack) {
          return const CapSheetText(text: '-');
        }

      /// 27-28
      case 8:
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
      case 9:
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
      case 10:
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
        style: kBebasNormal.copyWith(fontSize: 16.0.r, color: color ?? Colors.white),
      ),
    );
  }
}
