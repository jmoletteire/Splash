import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
                child: Stack(children: [
                  Positioned(
                    top: -10,
                    right: 1,
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          constraints:
                              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                          backgroundColor: Colors.grey.shade900,
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Hard Cap',
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 17.0.r,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(
                                        text: '\n\nFirst Apron\n',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            'A team becomes hard-capped at the first tax apron (\$${NumberFormat.decimalPattern().format(kLeagueFirstApron[kCurrentSeason.substring(0, 4)])}) by making any of the following moves:',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '\n\n\t\tBi-Annual Exception',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' - True Shooting %, Unassisted %',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '\n\n\t\tSign-and-Trade',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' - Acquires player via sign-and-trade with another team.',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '\n\n\t\tMid-Level Exception',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' - Offensive Rebound %, Defensive Rebound %, Box Outs per 75, Adjust Rebound Chance %',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '\n\n\t\tPlaymaking',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' - Adjusted Assists per 75, Potential Assists per 75, Adjusted Assist-to-Pass %, Box Creation',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '\n\n\t\tHustle',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' - Pace, Loose Balls Recovered per 75, Screen Assist Points per 75, Charges Drawn',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        CupertinoIcons.question_circle,
                        size: 18.0.r,
                      ),
                    ),
                  ),
                  Column(
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
                ]),
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
                  SizedBox(height: 20.0.r),
                  Wrap(
                    runSpacing: 2.5,
                    children: [
                      Text(
                        'Two-Way (TW) Contract',
                        style: kBebasNormal.copyWith(fontSize: 16.0.r),
                      ),
                      Text(
                        'Players on Two-Way contracts do not count toward the cap. They can only appear in 50 regular season games, and are ineligible for postseason rosters.',
                        style: kBebasNormal.copyWith(
                            color: Colors.grey.shade300, fontSize: 15.0.r),
                      )
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
