import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:splash/screens/more/draft/selections_table.dart';

import '../../../utilities/constants.dart';

class DraftRound extends StatelessWidget {
  final List<dynamic> round;
  final int roundNum;
  final bool isFinalRound;

  DraftRound({required this.round, required this.roundNum, required this.isFinalRound});

  Map<String, String> positionMap = {
    'Guard': 'G',
    'Guard-Forward': 'G-F',
    'Forward': 'F',
    'Forward-Guard': 'F-G',
    'Forward-Center': 'F-C',
    'Center': 'C',
    'Center-Forward': 'C-F',
  };

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        DraftSelections(selections: round),
        if (!isFinalRound)
          SliverPinnedHeader(
            child: Container(
              color: Colors.grey.shade800,
              height: MediaQuery.sizeOf(context).height * 0.035,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Row(
                  children: [
                    Text(
                      'Round ${roundNum + 1}',
                      style: kBebasNormal.copyWith(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
