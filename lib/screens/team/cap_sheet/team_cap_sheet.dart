import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

import 'cap_sheet_table.dart';

class TeamCapSheet extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamCapSheet({super.key, required this.team});

  @override
  State<TeamCapSheet> createState() => _TeamCapSheetState();
}

class _TeamCapSheetState extends State<TeamCapSheet> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CapSheet(
          team: widget.team['CAP_SHEET'],
        ),
        if (widget.team['CAP_SHEET']['isHardCapped'])
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(15.0),
                margin: const EdgeInsets.symmetric(vertical: 11.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                        ),
                      ),
                      child: Text(
                        'Notes',
                        style: kBebasBold.copyWith(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${widget.team['CITY']} is hard capped for $kCurrentSeason:',
                      style: kBebasNormal.copyWith(fontSize: 18.0),
                    ),
                    for (var note in widget.team['CAP_SHEET']['hardCapReasons'])
                      Text(
                        '• $note',
                        style: kBebasNormal.copyWith(fontSize: 16.0, color: Color(0xCFFFFFFF)),
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
