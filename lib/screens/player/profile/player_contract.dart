import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';

class PlayerContract extends StatefulWidget {
  final List<dynamic> playerContracts;
  const PlayerContract({super.key, required this.playerContracts});

  @override
  State<PlayerContract> createState() => _PlayerContractState();
}

class _PlayerContractState extends State<PlayerContract> {
  late int selectedIndex;
  int currentContractIndex = 0; // Index of player's contract for kCurrentSeason

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

  String formatCurrency(int number) {
    double million = number / 1000000;
    String formattedNumber = NumberFormat("#,##0.0").format(million);
    return '\$${formattedNumber}M';
  }

  void _nextContract() {
    setState(() {
      selectedIndex = (selectedIndex + 1) % widget.playerContracts.length;
    });
  }

  void _previousContract() {
    setState(() {
      selectedIndex =
          (selectedIndex - 1 + widget.playerContracts.length) % widget.playerContracts.length;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;

    int currentYear = int.parse(kCurrentSeason.substring(0, 4));
    for (var contract in widget.playerContracts) {
      int endYear =
          contract['freeAgentYear'] == 0 || (contract['freeAgentYear'] == null ?? true)
              ? contract['startYear'] + contract['yearsTotal']
              : contract['freeAgentYear'];
      if (currentYear >= contract['startYear'] && currentYear < endYear) {
        selectedIndex = currentContractIndex;
      } else {
        currentContractIndex++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentContract = widget.playerContracts[selectedIndex];
    int endYear =
        (currentContract['contractType'] == 'dead') || currentContract['freeAgentYear'] == 0
            ? currentContract['startYear'] + currentContract['yearsTotal']
            : currentContract['freeAgentYear'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.only(bottom: 11.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (selectedIndex != widget.playerContracts.length - 1)
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: _nextContract,
                  ),
                ),
              if (selectedIndex == widget.playerContracts.length - 1) const Spacer(),
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'Contract (\'${currentContract['startYear'].toString().substring(2)}-${endYear.toString().substring(2)})',
                    style: kBebasBold.copyWith(fontSize: 18.0.r, color: Colors.white),
                  ),
                ),
              ),
              if (selectedIndex == 0) const Spacer(),
              if (selectedIndex != 0)
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: _previousContract,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${currentContract['yearsTotal']} yr(s) / ${formatCurrency(currentContract['amountTotal'])}',
                    style: kBebasNormal.copyWith(fontSize: 16.0.r),
                  ),
                  Text(
                    'Terms',
                    style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    formatCurrency(currentContract['averageSalary']),
                    style: kBebasNormal.copyWith(fontSize: 16.0.r),
                  ),
                  Text(
                    'AAV',
                    style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '$endYear / ${currentContract['freeAgentType'] == "" ? 'RFA' : currentContract['freeAgentType'] ?? 'UFA'}',
                    style: kBebasNormal.copyWith(fontSize: 16.0.r),
                  ),
                  Text(
                    'FA',
                    style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          Card(
            color: Colors.white10,
            margin: const EdgeInsets.only(top: 15.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white54,
                          width: 2.0,
                        ),
                      ),
                    ),
                    children: [
                      tableHeader('Year'),
                      tableHeader('Age'),
                      tableHeader('Cap Hit'),
                      tableHeader('Cap %'),
                      tableHeader('Option'),
                    ],
                  ),
                  for (var year in currentContract['years'])
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white12,
                            width: 1.125,
                          ),
                        ),
                      ),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            tableCell(
                              '\'${year['fromYear'].toString().substring(2)}-${year['toYear'].toString().substring(2)}',
                              year['deadYear'] ?? true
                                  ? Colors.white24
                                  : year['fromYear'].toString() ==
                                          kCurrentSeason.substring(0, 4)
                                      ? Colors.white
                                      : Colors.white70,
                            ),
                            Image.asset(
                              'images/NBA_Logos/${kTeamIds[contractTeamIds[year['teamId']]] ?? 0}.png',
                              width: 18.0.r,
                              height: 18.0.r,
                            )
                          ],
                        ),
                        tableCell(
                          (year['age'] ?? '-').toString(),
                          year['deadYear'] ?? true
                              ? Colors.white24
                              : year['fromYear'].toString() == kCurrentSeason.substring(0, 4)
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                        tableCell(
                          formatCurrency(year['capHit']),
                          year['deadYear'] ?? true
                              ? Colors.white24
                              : year['fromYear'].toString() == kCurrentSeason.substring(0, 4)
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                        tableCell(
                          '${(100 * year['capHit'] / kLeagueSalaryCap['${year['fromYear'].toString()}']!).toStringAsFixed(1)}%',
                          year['deadYear'] ?? true
                              ? Colors.white24
                              : year['fromYear'].toString() == kCurrentSeason.substring(0, 4)
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                        tableCell(
                            year['playerOption'] ?? true
                                ? 'Player'
                                : year['teamOption']
                                    ? 'Team'
                                    : '',
                            year['deadYear'] ?? true
                                ? Colors.white24
                                : year['fromYear'].toString() == kCurrentSeason.substring(0, 4)
                                    ? Colors.white
                                    : Colors.white70),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (currentContract['notes'].isNotEmpty) const SizedBox(height: 15.0),
          if (currentContract['notes'].isNotEmpty)
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade700, width: 1),
                    ),
                  ),
                  child: Text(
                    'Notes',
                    style: kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.white),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6.0),
          for (var note in currentContract['notes'])
            Wrap(
              children: [
                Text(
                  '- $note',
                  style: kBebasNormal.copyWith(fontSize: 12.0.r),
                ),
                const SizedBox(height: 30.0),
              ],
            ),
        ],
      ),
    );
  }

  Widget tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: kBebasNormal.copyWith(fontSize: 16.0.r),
      ),
    );
  }

  Widget tableCell(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: kBebasNormal.copyWith(fontSize: 14.0.r, color: color),
      ),
    );
  }
}
