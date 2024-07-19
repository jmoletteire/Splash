import 'package:flutter/material.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/screens/team/overview/team_last_lineup.dart';
import 'package:splash/screens/team/overview/team_latest_news.dart';
import 'package:splash/screens/team/overview/team_recent_transactions.dart';
import 'package:splash/utilities/constants.dart';

class TeamOverview extends StatefulWidget {
  final Map<String, dynamic> team;
  final ScrollController controller;
  const TeamOverview({super.key, required this.controller, required this.team});

  @override
  State<TeamOverview> createState() => _TeamOverviewState();
}

class _TeamOverviewState extends State<TeamOverview> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TeamLatestNews(team: widget.team),
          TeamLastLineup(team: widget.team),
          TeamRecentTransactions(team: widget.team),
          Card(
            margin: const EdgeInsets.all(11.0),
            color: Colors.grey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                          ),
                        ),
                        child: Text(
                          //'Franchise',
                          '${widget.team['CITY']} ${widget.team['NICKNAME']}',
                          style: kBebasBold.copyWith(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Founded',
                        style: kBebasNormal.copyWith(
                          fontSize: 17.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${widget.team['YEARFOUNDED']}',
                        style: kBebasNormal.copyWith(fontSize: 18.0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Owner',
                        style: kBebasNormal.copyWith(
                          fontSize: 17.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${widget.team['OWNER']}',
                        style: kBebasNormal.copyWith(fontSize: 18.0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'General Manager',
                        style: kBebasNormal.copyWith(
                          fontSize: 17.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${widget.team['GENERALMANAGER']}',
                        style: kBebasNormal.copyWith(fontSize: 18.0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Head Coach',
                        style: kBebasNormal.copyWith(
                          fontSize: 17.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Row(
                        children: [
                          PlayerAvatar(
                            radius: 10.0,
                            backgroundColor: Colors.white24,
                            playerImageUrl:
                                'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.team['coaches'][0]['COACH_ID']}.png',
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            '${widget.team['HEADCOACH']}',
                            style: kBebasNormal.copyWith(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'G-LEAGUE',
                        style: kBebasNormal.copyWith(
                          fontSize: 17.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Row(
                        children: [
                          /*
                          SvgPicture.string(
                            widget.team['DLEAGUEAFFILIATION']['LOGO'][0],
                            width: 18.0,
                            height: 18.0,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),

                           */
                          Text(
                            '${widget.team['DLEAGUEAFFILIATION']['TEAM']}',
                            style: kBebasNormal.copyWith(fontSize: 18.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(11.0),
            color: Colors.grey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                          ),
                        ),
                        child: Text(
                          'Venue',
                          style: kBebasBold.copyWith(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset('images/arenas/${widget.team['TEAM_ID']}.jpg'),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'City',
                        style: kBebasNormal.copyWith(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${widget.team['ARENACITY']}',
                        style: kBebasNormal.copyWith(fontSize: 20.0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Arena',
                        style: kBebasNormal.copyWith(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${widget.team['ARENA']}',
                        style: kBebasNormal.copyWith(fontSize: 20.0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Capacity',
                        style: kBebasNormal.copyWith(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        '${widget.team['ARENACAPACITY']}',
                        style: kBebasNormal.copyWith(fontSize: 20.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
