import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utilities/constants.dart';
import '../game_home.dart';

class LastMeeting extends StatefulWidget {
  final Map<String, dynamic> lastMeeting;
  final String homeId;
  final String awayId;
  const LastMeeting(
      {super.key, required this.lastMeeting, required this.homeId, required this.awayId});

  @override
  State<LastMeeting> createState() => _LastMeetingState();
}

class _LastMeetingState extends State<LastMeeting> {
  late List<String> gameDate;

  List<String> formatDate(String date) {
    // Parse the string to a DateTime object
    DateTime dateTime = DateTime.parse(date);

    // Create a DateFormat for the abbreviated day of the week
    DateFormat dayOfWeekFormat = DateFormat('E');
    String dayOfWeek = dayOfWeekFormat.format(dateTime);

    // Create a DateFormat for the month and date
    DateFormat monthDateFormat = DateFormat('M/d');
    String monthDate = monthDateFormat.format(dateTime);

    return [dayOfWeek, monthDate];
  }

  @override
  void initState() {
    super.initState();
    gameDate = formatDate(widget.lastMeeting['LAST_GAME_DATE_EST']);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameHome(
              gameId: widget.lastMeeting['GAME_ID'],
              homeId: widget.lastMeeting['LAST_GAME_HOME_TEAM_ID'].toString(),
              awayId: widget.lastMeeting['LAST_GAME_VISITOR_TEAM_ID'].toString(),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 0.0),
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Last Meeting',
                    style: kBebasBold.copyWith(fontSize: 18.0),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gameDate[0],
                          style: kBebasNormal.copyWith(fontSize: 13.0, color: Colors.white70),
                        ),
                        Text(
                          gameDate[1],
                          style: kBebasNormal.copyWith(fontSize: 13.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 15.0),
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: widget.lastMeeting['LAST_GAME_VISITOR_TEAM_ID'] == null
                              ? const Text('')
                              : Image.asset(
                                  'images/NBA_Logos/${widget.lastMeeting['LAST_GAME_VISITOR_TEAM_ID']}.png',
                                  fit: BoxFit.contain,
                                  width: 16.0,
                                  height: 16.0,
                                ),
                        ),
                        Text(
                            widget.lastMeeting['LAST_GAME_VISITOR_TEAM_POINTS']
                                .toStringAsFixed(0),
                            style: kBebasNormal),
                        Text(
                          '@',
                          style: kBebasBold.copyWith(fontSize: 14.0),
                        ),
                        Text(
                            widget.lastMeeting['LAST_GAME_HOME_TEAM_POINTS']
                                .toStringAsFixed(0),
                            style: kBebasNormal),
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: widget.lastMeeting['LAST_GAME_HOME_TEAM_ID'] == null
                              ? const Text('')
                              : Image.asset(
                                  'images/NBA_Logos/${widget.lastMeeting['LAST_GAME_HOME_TEAM_ID']}.png',
                                  fit: BoxFit.contain,
                                  width: 16.0,
                                  height: 16.0,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
