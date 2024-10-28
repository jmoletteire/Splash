import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/player_avatar.dart';
import '../../player/player_home.dart';

class DraftStats extends StatefulWidget {
  final Map<String, dynamic> draftStats;
  final bool byPick;
  const DraftStats({super.key, required this.draftStats, required this.byPick});

  @override
  State<DraftStats> createState() => _DraftStatsState();
}

class _DraftStatsState extends State<DraftStats> {
  late Map<int, List<String>> keyIndexMap;
  List<bool> _isExpandedList = []; // Track expanded state for each item

  final Map<int, Color> colorIndexMap = {
    0: Colors.white,
    1: Colors.deepOrange,
    2: Colors.yellow.shade800,
    3: Colors.blueGrey.shade200,
    4: Colors.blueGrey,
    5: Colors.white,
    6: Colors.white
  };

  @override
  void initState() {
    super.initState();
    // Initialize the expanded state for each item to false
    _isExpandedList = List<bool>.filled(widget.draftStats.length, false);
    if (widget.byPick) {
      keyIndexMap = {
        0: ['TOTAL', 'Players'],
        1: ['HOF', 'Hall of Famers'],
        2: ['MVP', 'MVPs'],
        3: ['ALL_NBA', 'All-NBA Selections'],
        4: ['ALL_STAR', 'All-Star Selections'],
        5: ['ROTY', 'Rookie of the Year'],
        6: ['STARTERS', 'Starters']
      };
    } else {
      keyIndexMap = {
        0: ['TOTAL', 'Players'],
        1: ['HOF', 'Hall of Famers'],
        2: ['MVP', 'MVPs'],
        3: ['ALL_NBA', 'All-NBA Selections'],
        4: ['ALL_STAR', 'All-Star Selections'],
        5: ['STARTERS', 'Starters']
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.draftStats.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 12.0.r, vertical: 10.0.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(keyIndexMap[index]?[1] ?? '',
                    style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white)),
                Text(':  ${widget.draftStats['TOTAL']}',
                    style: kBebasNormal.copyWith(fontSize: 18.0.r)),
              ],
            ),
          );
        }
        final draftStats = widget.draftStats[keyIndexMap[index]?[0]];
        return Card(
          color: colorIndexMap[index]?.withOpacity(0.2),
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.symmetric(horizontal: 12.0.r, vertical: 5.0.r),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(keyIndexMap[index]?[1] ?? '',
                      style: kBebasNormal.copyWith(
                          fontSize: 18.0.r, color: colorIndexMap[index])),
                  Text(':  ${draftStats['NUM']}',
                      style: kBebasNormal.copyWith(fontSize: 18.0.r)),
                  Text(
                      '  (${(100 * draftStats['NUM']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                      style: kBebasNormal.copyWith(fontSize: 18.0.r))
                ],
              ),
              trailing: Icon(
                _isExpandedList[index] ? Icons.expand_less : Icons.expand_more,
                color: Colors.white70,
              ),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _isExpandedList[index] = expanded;
                });
              },
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: draftStats['PLAYERS'].length,
                  itemBuilder: (BuildContext context, int i) {
                    String teamId = kEastConfTeamIds
                                .contains(draftStats['PLAYERS'][i]['TEAM_ID'].toString()) ||
                            kWestConfTeamIds
                                .contains(draftStats['PLAYERS'][i]['TEAM_ID'].toString())
                        ? draftStats['PLAYERS'][i]['TEAM_ID'].toString()
                        : '0';
                    return InkWell(
                      onTap: () {
                        if (draftStats['PLAYERS'][i]['PLAYER_PROFILE_FLAG'] == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerHome(
                                playerId: draftStats['PLAYERS'][i]['PERSON_ID'].toString(),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 6.0.r, vertical: 8.0.r),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: i < draftStats['PLAYERS'].length - 1
                                        ? Colors.grey.shade700
                                        : Colors.transparent,
                                    width: 0.5))),
                        child: Row(
                          children: [
                            if (!widget.byPick)
                              Expanded(
                                child: Center(
                                  child: AutoSizeText(
                                    (draftStats['PLAYERS'][i]['ROUND_NUMBER'] ?? (i + 1))
                                        .toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: kBebasNormal.copyWith(
                                        color: Colors.grey, fontSize: 14.0.r),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Center(
                                child: AutoSizeText(
                                  (widget.byPick
                                          ? draftStats['PLAYERS'][i]['SEASON'] ?? (i + 1)
                                          : (draftStats['PLAYERS'][i]['OVERALL_PICK'] ??
                                              (i + 1)))
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kBebasNormal.copyWith(
                                      color: Colors.grey, fontSize: 14.0.r),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0.r),
                            Expanded(
                              flex: widget.byPick ? 10 : 12,
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 20.0.r,
                                    width: 20.0.r,
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxHeight: 20.0.r, maxWidth: 20.0.r),
                                      child: Image.asset('images/NBA_Logos/$teamId.png'),
                                    ),
                                  ),
                                  SizedBox(width: 15.0.r),
                                  PlayerAvatar(
                                    radius: 12.0.r,
                                    backgroundColor: Colors.white70,
                                    playerImageUrl:
                                        'https://cdn.nba.com/headshots/nba/latest/1040x760/${draftStats['PLAYERS'][i]['PERSON_ID']}.png',
                                    //'https://www.basketball-reference.com/req/202106291/images/headshots/$lastSub${firstName.substring(0, 2).toLowerCase()}01.jpg'
                                  ),
                                  SizedBox(width: 8.0.r),
                                  Expanded(
                                    flex: 7,
                                    child: AutoSizeText(
                                      draftStats['PLAYERS'][i]['ROTY'] == 1
                                          ? '${draftStats['PLAYERS'][i]['PLAYER_NAME'] ?? '-'}*, ${kPositionMap[draftStats['PLAYERS'][i]['POSITION']]}'
                                          : '${draftStats['PLAYERS'][i]['PLAYER_NAME'] ?? '-'}, ${kPositionMap[draftStats['PLAYERS'][i]['POSITION']]}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                    ),
                                  ),
                                  if (draftStats['PLAYERS'][i]['HOF'] == 1)
                                    Image.asset(
                                      'images/hof.png',
                                      height: 25.0.r,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
