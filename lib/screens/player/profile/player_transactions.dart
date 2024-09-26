import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../utilities/constants.dart';

class PlayerTransactions extends StatefulWidget {
  final List playerTransactions;
  const PlayerTransactions({super.key, required this.playerTransactions});

  @override
  State<PlayerTransactions> createState() => _PlayerTransactionsState();
}

class _PlayerTransactionsState extends State<PlayerTransactions> {
  Map<String, String> fanspoTeamIds = {
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

  @override
  void initState() {
    super.initState();
    widget.playerTransactions.sort((a, b) {
      // Check if either transactionType is "drafted"
      if (a['transactionType'] == "drafted" && b['transactionType'] != "drafted") {
        return 1; // a comes after b
      } else if (a['transactionType'] != "drafted" && b['transactionType'] == "drafted") {
        return -1; // b comes after a
      } else {
        // If neither or both are "drafted", sort by date
        return b['date'].compareTo(a['date']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(String date) {
      // Parse the string to a DateTime object
      DateTime dateTime = DateTime.parse(date);

      // Create a DateFormat for the month and date
      DateFormat monthDateFormat = DateFormat('MMM d, yyyy');
      String monthDate = monthDateFormat.format(dateTime);

      return monthDate;
    }

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
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
              ),
            ),
            child: Text(
              'Transactions',
              style: kBebasBold.copyWith(fontSize: 18.0.r, color: Colors.white),
            ),
          ),
          if (widget.playerTransactions.isEmpty)
            Row(
              children: [
                Text(
                  'No Transactions',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r),
                ),
              ],
            ),
          for (var transaction in widget.playerTransactions)
            if (!['fined', 'suspended'].contains(transaction['transactionType'])) ...[
              SizedBox(height: 20.0.r),
              Wrap(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'images/NBA_Logos/${kTeamAbbrToId[fanspoTeamIds[transaction['teamId']]] ?? 0}.png',
                        width: 30.0.r,
                        height: 30.0.r,
                      ),
                      SizedBox(width: 10.0.r),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction['description'],
                              style: kBebasNormal.copyWith(fontSize: 14.0.r),
                            ),
                            Text(
                              formatDate(transaction['date']),
                              style: kBebasNormal.copyWith(
                                  fontSize: 12.0.r, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}
