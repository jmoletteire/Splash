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

  List<String> splitOutsideParenthesesAndBrackets(String input) {
    List<String> result = [];
    StringBuffer currentSegment = StringBuffer();
    int parenthesesDepth = 0;
    int bracketsDepth = 0;

    for (int i = 0; i < input.length; i++) {
      String char = input[i];

      // Adjust the depth counters for parentheses and brackets
      if (char == '(') {
        parenthesesDepth++;
      } else if (char == ')') {
        parenthesesDepth--;
      } else if (char == '[') {
        bracketsDepth++;
      } else if (char == ']') {
        bracketsDepth--;
      }

      // Detect ' and ' outside of parentheses or brackets
      if (parenthesesDepth == 0 && bracketsDepth == 0 && input.startsWith(' and ', i)) {
        // Add the current segment to the result and clear the buffer
        result.add(currentSegment.toString());
        currentSegment.clear();
        // Skip the ' and ' part in the input
        i += 4; // Length of ' and ' is 5 characters
      } else {
        currentSegment.write(char);
      }
    }

    // Add the last segment
    if (currentSegment.isNotEmpty) {
      result.add(currentSegment.toString());
    }

    return result;
  }

  String parseTrade(String trade) {
    // Split by team names followed by "traded"
    List<String> tradeFull = trade.split(': ');

    if (tradeFull.length < 2) {
      /*
      List<String> details = trade.split(' with ');
      List<String> assets = splitOutsideParenthesesAndBrackets(details[0]);

      String tradeDetails = '${details[0]}:';
      for (String asset in assets) {
        tradeDetails += '\n\t\t - $asset';
      }

       */
      return trade;
    }

    List<String> tradeDetails = tradeFull[1].split('; ');

    List<String> tradeFormatted = [];
    for (String tradePart in tradeDetails) {
      String fromTeam = tradePart.split(' traded ')[0];
      String toTeam = tradePart.split(' to ')[1];
      String assets = tradePart.split(' traded ')[1].split(' to ')[0];
      List<String> assetsList = assets.split(', ');

      // Initialize tradeLeg with fromTeam and toTeam
      String tradeLeg = '\n$fromTeam → $toTeam:';

      // Append each asset as a bullet point
      for (String asset in assetsList) {
        if (asset.contains(' and ')) {
          List<String> splitAsset = asset.split(' and ');
          for (String asset in splitAsset) {
            tradeLeg += '\n\t\t\t - $asset';
          }
        } else {
          tradeLeg += '\n\t\t\t - $asset';
        }
      }

      tradeFormatted.add(tradeLeg);
    }

    tradeFormatted.insert(0, '${tradeFull[0]}:');

    // Join all formatted trades into a single string
    return tradeFormatted.join('\n');
  }

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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/NBA_Logos/${kTeamAbbrToId[fanspoTeamIds[transaction['teamId']]] ?? 0}.png',
                        width: 30.0.r,
                        height: 30.0.r,
                      ),
                      SizedBox(width: 10.0.r),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction['transactionType'] == 'traded'
                                  ? parseTrade(transaction['description'])
                                  : transaction['description'],
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
                      if (transaction['description'].contains('Exhibit 10'))
                        const Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DismissibleTooltip(),
                          ],
                        )),
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

class DismissibleTooltip extends StatefulWidget {
  const DismissibleTooltip({Key? key}) : super(key: key);

  @override
  _DismissibleTooltipState createState() => _DismissibleTooltipState();
}

class _DismissibleTooltipState extends State<DismissibleTooltip> {
  final GlobalKey _tooltipKey = GlobalKey();
  bool _isTooltipVisible = false;

  void _toggleTooltip() {
    setState(() {
      _isTooltipVisible = !_isTooltipVisible;
    });
    if (_isTooltipVisible) {
      final dynamic tooltip = _tooltipKey.currentState;
      tooltip.ensureTooltipVisible();
    } else {
      final dynamic tooltip = _tooltipKey.currentState;
      tooltip.deactivate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTooltip,
      child: Tooltip(
        key: _tooltipKey,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10.0),
        ),
        triggerMode: TooltipTriggerMode.manual,
        showDuration: const Duration(minutes: 2),
        richMessage: TextSpan(
          children: [
            TextSpan(
              text: 'Exhibit 10\n\n',
              style: TextStyle(
                color: Colors.white,
                height: 0.9,
                letterSpacing: -1,
                fontSize: 12.0.r,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text:
                  'An Exhibit 10 contract is a one-year, non-guaranteed deal at the league minimum salary, which allows a player to join a team\'s Summer League and/or Training Camp roster. These contracts do not count against the cap unless the player remains on the roster when the regular season begins and has not been converted to a Two-Way deal.',
              style: TextStyle(
                color: const Color(0xFFCCCCCC),
                letterSpacing: -0.8,
                fontSize: 12.0.r,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        child: Icon(
          Icons.info_outline,
          color: Colors.white70,
          size: 18.0.r,
        ),
      ),
    );
  }
}
