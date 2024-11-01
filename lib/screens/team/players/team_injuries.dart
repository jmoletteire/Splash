import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/player/player_home.dart';
import 'package:splash/utilities/constants.dart';

class TeamInjuries extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamInjuries({super.key, required this.team});

  @override
  State<TeamInjuries> createState() => _TeamInjuriesState();
}

class _TeamInjuriesState extends State<TeamInjuries> with AutomaticKeepAliveClientMixin {
  List<dynamic> players = [];
  bool _isLoading = true;
  String sortedBy = 'Status';
  String sortOrder = 'ASC';

  @override
  bool get wantKeepAlive => true;

  void setPlayers(String sortBy, String order) {
    try {
      if (_isLoading == false) _isLoading = true;
      // Convert the map to a list of entries
      var entries = widget.team['seasons'][kCurrentSeason]['ROSTER'].entries
          .toList()
          .where((e) => e.value['Injured'] == 'YES')
          .toList();

      // Helper function to get the last name
      String getLastName(String fullName) {
        var parts = fullName.split(' ');
        return parts.isNotEmpty ? parts.toList()[1] : '';
      }

      switch (sortBy) {
        case 'Name':
          order == 'ASC'
              // Sort the entries by last name
              ? entries.sort((a, b) =>
                  getLastName(a.value['PLAYER']).compareTo(getLastName(b.value['PLAYER'])))
              // Sort the entries by last name in reverse order
              : entries.sort((a, b) =>
                  getLastName(b.value['PLAYER']).compareTo(getLastName(a.value['PLAYER'])));
          break;
        case 'Status':
          order == 'ASC'
              ? entries.sort((a, b) {
                  // Check if either entry has 'OFS' status
                  if (a.value['Injured_Status'] == 'OFS') return 1;
                  if (b.value['Injured_Status'] == 'OFS') return -1;

                  int statusComparison = a.value['Injured_Status']
                      .toString()
                      .compareTo(b.value['Injured_Status'].toString());
                  if (statusComparison != 0) return statusComparison;

                  // Secondary sort by EST_RETURN if Injured_Status is the same
                  return DateFormat("M/d/yyyy")
                      .parse(a.value['EST_RETURN'].toString())
                      .compareTo(
                          DateFormat("M/d/yyyy").parse(b.value['EST_RETURN'].toString()));
                })
              : entries.sort((a, b) {
                  // Check if either entry has 'OFS' status
                  if (a.value['Injured_Status'] == 'OFS') return 1;
                  if (b.value['Injured_Status'] == 'OFS') return -1;

                  int statusComparison = b.value['Injured_Status']
                      .toString()
                      .compareTo(a.value['Injured_Status'].toString());
                  if (statusComparison != 0) return statusComparison;

                  // Secondary sort by EST_RETURN if Injured_Status is the same
                  return DateFormat("M/d/yyyy")
                      .parse(b.value['EST_RETURN'].toString())
                      .compareTo(
                          DateFormat("M/d/yyyy").parse(a.value['EST_RETURN'].toString()));
                });
          break;
        case 'Injury':
          order == 'ASC'
              // Sort the entries by position
              ? entries.sort((a, b) => (a.value['Injury_Type'].toString())
                  .compareTo(b.value['Injury_Type'].toString()))
              // Sort the entries by position in reverse order
              : entries.sort((a, b) => (b.value['Injury_Type'].toString())
                  .compareTo(a.value['Injury_Type'].toString()));
          break;
        case 'ETA':
          order == 'ASC'
              // Sort the entries by position
              ? entries.sort((a, b) => DateFormat("M/d/yyyy")
                  .parse(a.value['EST_RETURN'].toString())
                  .compareTo(DateFormat("M/d/yyyy").parse(b.value['EST_RETURN'].toString())))
              // Sort the entries by position in reverse order
              : entries.sort((a, b) => DateFormat("M/d/yyyy")
                  .parse(b.value['EST_RETURN'].toString())
                  .compareTo(DateFormat("M/d/yyyy").parse(a.value['EST_RETURN'].toString())));
          break;
      }

      // Extract the sorted keys
      List<dynamic> fetchedPlayers = entries.map((e) => e.key).toList();

      setState(() {
        players = fetchedPlayers;
        sortedBy = sortBy;
        sortOrder = order;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in setPlayers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setPlayers('Status', 'ASC');
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);
    return _isLoading
        ? Center(
            child: SpinningIcon(
              color: teamColor,
            ),
          )
        : players.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_basketball,
                      color: Colors.white38,
                      size: 38.0.r,
                    ),
                    SizedBox(height: 15.0.r),
                    Text(
                      'No Injuries',
                      style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  MultiSliver(
                    pushPinnedChildren: true,
                    children: [
                      SliverPinnedHeader(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(20.0.r, 6.0.r, 14.0.r, 6.0.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFF303030),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white30,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 11,
                                    child: GestureDetector(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Player',
                                            style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                          ),
                                          if (sortedBy == 'Name')
                                            Icon(
                                              sortOrder == 'ASC'
                                                  ? Icons.arrow_drop_down
                                                  : Icons.arrow_drop_up,
                                              size: 14.0.r,
                                              color: Colors.white,
                                            ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          (sortedBy == 'Name' && sortOrder == 'ASC')
                                              ? setPlayers('Name', 'DESC')
                                              : setPlayers('Name', 'ASC');
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Status',
                                            style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                          ),
                                          if (sortedBy == 'Status')
                                            Icon(
                                              sortOrder == 'ASC'
                                                  ? Icons.arrow_drop_down
                                                  : Icons.arrow_drop_up,
                                              size: 14.0.r,
                                              color: Colors.white,
                                            ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          (sortedBy == 'Status' && sortOrder == 'ASC')
                                              ? setPlayers('Status', 'DESC')
                                              : setPlayers('Status', 'ASC');
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: GestureDetector(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Injury',
                                            style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                          ),
                                          if (sortedBy == 'Injury')
                                            Icon(
                                              sortOrder == 'ASC'
                                                  ? Icons.arrow_drop_down
                                                  : Icons.arrow_drop_up,
                                              size: 14.0.r,
                                              color: Colors.white,
                                            ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          (sortedBy == 'Injury' && sortOrder == 'ASC')
                                              ? setPlayers('Injury', 'DESC')
                                              : setPlayers('Injury', 'ASC');
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'ETA',
                                            style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                          ),
                                          if (sortedBy == 'ETA')
                                            Icon(
                                              sortOrder == 'ASC'
                                                  ? Icons.arrow_drop_down
                                                  : Icons.arrow_drop_up,
                                              size: 14.0.r,
                                              color: Colors.white,
                                            ),
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          (sortedBy == 'ETA' && sortOrder == 'ASC')
                                              ? setPlayers('ETA', 'DESC')
                                              : setPlayers('ETA', 'ASC');
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerHome(
                                      playerId: players[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 14.0.r, vertical: 6.0.r),
                                height: MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                    color: widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                    ?[players[index]]?['Injured_Status'] ==
                                                'OUT' ||
                                            widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                    ?[players[index]]?['Injured_Status'] ==
                                                'OFS'
                                        ? Colors.redAccent.withOpacity(0.1)
                                        : widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                    ?[players[index]]?['Injured_Status'] ==
                                                'GTD'
                                            ? Colors.orangeAccent.withOpacity(0.1)
                                            : Colors.grey.shade900,
                                    border: const Border(
                                        bottom:
                                            BorderSide(color: Colors.white54, width: 0.125))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 11,
                                      child: Row(
                                        children: [
                                          PlayerAvatar(
                                            radius: 14.0.r,
                                            backgroundColor: Colors.white12,
                                            playerImageUrl:
                                                'https://cdn.nba.com/headshots/nba/latest/1040x760/${players[index]}.png',
                                          ),
                                          SizedBox(
                                            width: 15.0.r,
                                          ),
                                          Text(
                                            widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                    ?[players[index]]?['PLAYER'] ??
                                                '-',
                                            style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        (widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                        ?[players[index]]?['Injured_Status'] ??
                                                    '') ==
                                                'GTD'
                                            ? 'DTD'
                                            : widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                    ?[players[index]]?['Injured_Status'] ??
                                                '',
                                        style: kBebasNormal.copyWith(
                                          fontSize: 14.0.r,
                                          color: widget.team['seasons'][kCurrentSeason]
                                                              ['ROSTER']?[players[index]]
                                                          ?['Injured_Status'] ==
                                                      'OUT' ||
                                                  widget.team['seasons'][kCurrentSeason]
                                                              ['ROSTER']?[players[index]]
                                                          ?['Injured_Status'] ==
                                                      'OFS'
                                              ? Colors.redAccent
                                              : Colors.orangeAccent,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: AutoSizeText(
                                        widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                ?[players[index]]?['Injury_Type'] ??
                                            '',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: AutoSizeText(
                                        widget.team['seasons'][kCurrentSeason]['ROSTER']
                                                ?[players[index]]?['EST_RETURN'] ??
                                            '',
                                        textAlign: TextAlign.end,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: players.length,
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: MediaQuery.sizeOf(context).height / 10),
                          Icon(
                            Icons.sports_basketball,
                            color: Colors.white38,
                            size: 38.0.r,
                          ),
                          SizedBox(height: MediaQuery.sizeOf(context).height / 10),
                        ],
                      ),
                    ],
                  ),
                ],
              );
  }
}
