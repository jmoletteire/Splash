import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            padding: EdgeInsets.all(8.0.r),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(15.0.r),
                margin: EdgeInsets.symmetric(vertical: 11.0.r),
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
                        style: kBebasBold.copyWith(fontSize: 18.0.r, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 8.0.r),
                    Text(
                      '${widget.team['CITY']} is hard capped for $kCurrentSeason:',
                      style: kBebasNormal.copyWith(fontSize: 16.0.r),
                    ),
                    for (var note in widget.team['CAP_SHEET']['hardCapReasons'])
                      Text(
                        '• $note',
                        style: kBebasNormal.copyWith(
                            fontSize: 14.0.r, color: const Color(0xCFFFFFFF)),
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
