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
                margin: EdgeInsets.only(top: 11.0.r),
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
        SliverPadding(
          padding: EdgeInsets.fromLTRB(8.0.r, 0.0, 8.0.r, 8.0.r),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(15.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10.0.r,
                        height: 10.0.r,
                        color: Colors.lightBlueAccent,
                      ),
                      SizedBox(width: 8.0.r),
                      Text(
                        'Player Option',
                        style: kBebasNormal.copyWith(fontSize: 16.0.r),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10.0.r,
                        height: 10.0.r,
                        color: Colors.lightGreenAccent,
                      ),
                      SizedBox(width: 8.0.r),
                      Text(
                        'Team Option',
                        style: kBebasNormal.copyWith(fontSize: 16.0.r),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10.0.r,
                        height: 10.0.r,
                        color: Colors.orangeAccent,
                      ),
                      SizedBox(width: 8.0.r),
                      Text(
                        'Qualifying Offer',
                        style: kBebasNormal.copyWith(fontSize: 16.0.r),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10.0.r,
                        height: 10.0.r,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 8.0.r),
                      Text(
                        'Non-Guaranteed',
                        style: kBebasNormal.copyWith(fontSize: 16.0.r),
                      ),
                    ],
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
