import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';

class PlayerContract extends StatefulWidget {
  final Map<String, dynamic> playerContract;
  const PlayerContract({super.key, required this.playerContract});

  @override
  State<PlayerContract> createState() => _PlayerContractState();
}

class _PlayerContractState extends State<PlayerContract> {
  String formatCurrency(int number) {
    double million = number / 1000000;
    String formattedNumber = NumberFormat("#,##0.0").format(million);
    return '\$${formattedNumber}M';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.only(bottom: 11.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                  ),
                ),
                child: Text(
                  'Contract',
                  style: kBebasBold.copyWith(fontSize: 20.0, color: Colors.white),
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
                    '${widget.playerContract['yearsTotal']} yr(s) / ${formatCurrency(widget.playerContract['amountTotal'])}',
                    style: kBebasNormal.copyWith(fontSize: 18.0),
                  ),
                  Text(
                    'Terms',
                    style: kBebasNormal.copyWith(fontSize: 15.0, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    formatCurrency(widget.playerContract['averageSalary']),
                    style: kBebasNormal.copyWith(fontSize: 18.0),
                  ),
                  Text(
                    'AAV',
                    style: kBebasNormal.copyWith(fontSize: 15.0, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${widget.playerContract['freeAgentYear']} / ${widget.playerContract['freeAgentType']}',
                    style: kBebasNormal.copyWith(fontSize: 18.0),
                  ),
                  Text(
                    'FA',
                    style: kBebasNormal.copyWith(fontSize: 15.0, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          Card(
            color: Colors.white10,
            margin: const EdgeInsets.only(top: 11.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white12,
                          width: 1.25,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Year',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(fontSize: 18.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Age',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(fontSize: 18.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Cap Hit',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(fontSize: 18.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Cap %',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                  for (var year in widget.playerContract['years'])
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white12,
                            width: 1,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '${year['fromYear']}-${year['toYear'].toString().substring(2)}',
                            textAlign: TextAlign.center,
                            style: kBebasNormal.copyWith(fontSize: 16.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            year['age'].toString(),
                            textAlign: TextAlign.center,
                            style: kBebasNormal.copyWith(fontSize: 16.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            formatCurrency(year['capHit']),
                            textAlign: TextAlign.center,
                            style: kBebasNormal.copyWith(fontSize: 16.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '${(100 * year['capHit'] / kLeagueSalaryCap).toStringAsFixed(1)}%',
                            textAlign: TextAlign.center,
                            style: kBebasNormal.copyWith(fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: kBebasNormal.copyWith(fontSize: 14.0, color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    );
  }
}
