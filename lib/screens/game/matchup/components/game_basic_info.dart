import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/constants.dart';

class GameBasicInfo extends StatefulWidget {
  const GameBasicInfo({
    super.key,
    required this.game,
    required this.isUpcoming,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  final Map<String, dynamic> game;
  final bool isUpcoming;
  final String homeTeamName;
  final String awayTeamName;

  @override
  State<GameBasicInfo> createState() => _GameBasicInfoState();
}

class _GameBasicInfoState extends State<GameBasicInfo> {
  late int year;
  late String formattedDate;
  late String seasonType;
  String broadcast = '';
  String arena = '';
  List<String> officials = [];

  void setSeasonType() {
    Map<String, String> seasonTypes = {
      '1': 'Pre-Season',
      '2': 'Regular Season',
      '3': 'All-Star Game',
      '4': 'Playoffs',
      '5': 'Play-In',
      '6': 'NBA Cup Final'
    };

    seasonType = seasonTypes[widget.game['gameId'].substring(2, 3)] ?? '-';

    if (widget.game.containsKey('title')) {
      seasonType = '${widget.game['title']}  (Regular Season)';
    }
  }

  @override
  void initState() {
    super.initState();

    year = int.parse((widget.game['date'] ?? '1900-01-01').substring(0, 4));

    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(widget.game['date'] ?? '1900-01-01');

    // Format the DateTime object into the desired string format
    formattedDate = DateFormat('EEEE, MMMM d, y').format(parsedDate).toUpperCase();

    setSeasonType();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: EdgeInsets.all(15.0.r),
        child: Column(
          children: [
            GameBasicInfoRow(
              icon: Icons.calendar_month,
              data: [seasonType],
            ),
            SizedBox(height: 10.0.r),
            GameBasicInfoRow(
              icon: Icons.sports_basketball,
              data: ['${widget.awayTeamName} @ ${widget.homeTeamName}'],
            ),
            SizedBox(height: 10.0.r),

            // ARENA DATA ONLY AVAILABLE SINCE 2021
            if (year < 2021)
              // Date
              GameBasicInfoRow(
                icon: Icons.calendar_month,
                data: [formattedDate],
              ),
            if (year >= 2021)
              // Date
              GameBasicInfoRow(
                icon: Icons.stadium,
                data: [widget.game['matchup']?['location'] ?? ''],
              ),

            SizedBox(height: 10.0.r),
            // Broadcast
            GameBasicInfoRow(
              icon: Icons.tv_sharp,
              data: [widget.game['broadcast'] ?? ''],
            ),
            SizedBox(height: 10.0.r),
            // Officials
            GameBasicInfoRow(
              icon: Icons.sports,
              data: [widget.game['matchup']?['officials'] ?? ''],
            ),
          ],
        ),
      ),
    );
  }
}

class GameBasicInfoRow extends StatelessWidget {
  const GameBasicInfoRow({
    super.key,
    this.icon,
    required this.data,
  });

  final IconData? icon;
  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        children: [
          if (icon != null)
            Icon(
              icon!,
              size: 20.0.r,
            ),
          SizedBox(width: 15.0.r),
          ...List.generate(data.length, (index) {
            return Text(
              index != data.length - 1 ? '${data[index]}, ' : data[index],
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            );
          }),
        ],
      ),
    );
  }
}
