import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utilities/constants.dart';

class TeamRecentTransactions extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamRecentTransactions({super.key, required this.team});

  @override
  State<TeamRecentTransactions> createState() => _TeamRecentTransactionsState();
}

class _TeamRecentTransactionsState extends State<TeamRecentTransactions> {
  late List<Map<String, String>> transactions;

  List<Map<String, String>> sortByDate(Map<String, Map<String, String>> data) {
    List<Map<String, String>> sortedData = data.values.toList();

    sortedData.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']!);
      DateTime dateB = DateTime.parse(b['date']!);
      return dateB.compareTo(dateA);
    });

    return sortedData;
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('MMM d').format(dateTime);
  }

  List<Map<String, String>> getTransactions() {
    List<Map<String, String>> trans = [];

    if (widget.team.containsKey('RECENT_TRANSACTIONS')) {
      Map<String, dynamic> rawTransactions = widget.team['RECENT_TRANSACTIONS'];

      // Convert Map<String, dynamic> to List<Map<String, String>>
      trans = rawTransactions.entries.map((entry) {
        return {
          'date': entry.value['date'].toString(),
          'transaction': entry.value['transaction'].toString()
        };
      }).toList();

      trans = sortByDate(
          Map.fromIterable(trans, key: (e) => e['date'], value: (e) => e));
    }
    return trans;
  }

  List<TextSpan> highlightPlayerNames(String transaction) {
    List<String> positions = ['G', 'F', 'C', 'G/F', 'F/G', 'F/C', 'C/F'];
    List<TextSpan> spans = [];
    List<String> parts = transaction.split(' ');

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i] == '&amp;amp;' ? '&' : parts[i];
      if (positions.contains(part)) {
        /// POSITION
        spans.add(TextSpan(
          text: '$part ',
          style: kBebasNormal.copyWith(fontSize: 16.0, color: Colors.white),
          /*
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerHome(
                    teamId: widget.team["TEAM_ID"].toString(),
                    playerId: players[index],
                  ),
                ),
              );
            },
           */
        ));

        /// FIRST NAME
        if (i + 1 < parts.length) {
          String firstName = parts[i + 1];
          spans.add(
            TextSpan(
              text: '$firstName ',
              style: kBebasNormal.copyWith(fontSize: 16.0, color: Colors.white),
            ),
          );

          /// LAST NAME
          if (i + 2 < parts.length) {
            String lastName = parts[i + 2];
            spans.add(
              TextSpan(
                text: '$lastName ',
                style:
                    kBebasNormal.copyWith(fontSize: 16.0, color: Colors.white),
              ),
            );
            i += 2; // Skip the next two parts as they are processed
          } else {
            i++;
          }
        }
      } else {
        spans.add(TextSpan(
            text: '$part ',
            style:
                kBebasNormal.copyWith(fontSize: 16.0, color: Colors.white60)));
      }
    }
    return spans;
  }

  @override
  void initState() {
    super.initState();
    transactions = getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(11.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    //'Franchise',
                    'Recent Transactions',
                    style: kBebasBold.copyWith(
                        fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    'No Transactions',
                    style: kBebasNormal.copyWith(
                      fontSize: 18.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            if (transactions.isNotEmpty)
              for (Map<String, String> trans in transactions)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          formatDate(trans['date']!),
                          style: kBebasNormal.copyWith(
                              fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                          width:
                              10), // Add spacing between date and transaction text
                      Expanded(
                        flex: 7,
                        child: RichText(
                          text: TextSpan(
                            children:
                                highlightPlayerNames(trans['transaction']!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
