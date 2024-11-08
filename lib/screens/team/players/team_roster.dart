import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/player/player_home.dart';
import 'package:splash/utilities/constants.dart';

class TeamRoster extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamRoster({super.key, required this.team});

  @override
  State<TeamRoster> createState() => _TeamRosterState();
}

class _TeamRosterState extends State<TeamRoster> with AutomaticKeepAliveClientMixin {
  late List<String> seasons;
  late String selectedSeason;
  List<dynamic> players = [];
  bool _isLoading = true;
  String sortedBy = 'Name';
  String sortOrder = 'ASC';

  @override
  bool get wantKeepAlive => true;

  void setPlayers(String sortBy, String order) {
    try {
      if (_isLoading == false) _isLoading = true;
      // Convert the map to a list of entries
      var entries = widget.team['seasons'][selectedSeason]['ROSTER'].entries.toList();

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
        case 'Number':
          order == 'ASC'
              ? entries.sort(
                  (a, b) => int.parse(a.value['NUM']).compareTo(int.parse(b.value['NUM'])))
              : entries.sort(
                  (a, b) => int.parse(b.value['NUM']).compareTo(int.parse(a.value['NUM'])));
          break;
        case 'Position':
          order == 'ASC'
              // Sort the entries by position
              ? entries.sort((a, b) =>
                  (a.value['POSITION'].toString()).compareTo(b.value['POSITION'].toString()))
              // Sort the entries by position in reverse order
              : entries.sort((a, b) =>
                  (b.value['POSITION'].toString()).compareTo(a.value['POSITION'].toString()));
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
    seasons = widget.team['seasons'].keys.toList().reversed.toList();
    selectedSeason = seasons.first;
    setPlayers('Name', 'ASC');
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);
    List coaches = widget.team['seasons'][selectedSeason]['COACHES'] ?? [];
    return _isLoading
        ? Center(
            child: SpinningIcon(
              color: teamColor,
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverPinnedHeader(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        border: const Border(
                          bottom: BorderSide(
                            color: Colors.white30,
                            width: 1,
                          ),
                        ),
                      ),
                      child: DropdownButton<String>(
                        padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 5.0.r),
                        borderRadius: BorderRadius.circular(10.0),
                        menuMaxHeight: 300.0.r,
                        dropdownColor: Colors.grey.shade900,
                        isExpanded: true,
                        underline: Container(),
                        value: selectedSeason,
                        items: seasons.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedSeason = value!;
                            setPlayers(sortedBy, sortOrder);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                                flex: 2,
                                child: GestureDetector(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '#',
                                        style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                      ),
                                      if (sortedBy == 'Number')
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
                                      (sortedBy == 'Number' && sortOrder == 'ASC')
                                          ? setPlayers('Number', 'DESC')
                                          : setPlayers('Number', 'ASC');
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Pos',
                                        style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                      ),
                                      if (sortedBy == 'Position')
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
                                      (sortedBy == 'Position' && sortOrder == 'ASC')
                                          ? setPlayers('Position', 'DESC')
                                          : setPlayers('Position', 'ASC');
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
                            padding: EdgeInsets.symmetric(horizontal: 14.0.r, vertical: 6.0.r),
                            height: MediaQuery.of(context).size.height * 0.05,
                            decoration: BoxDecoration(
                                color: widget.team['seasons'][selectedSeason]['ROSTER']
                                                ?[players[index]]?['Injured_Status'] ==
                                            'OUT' ||
                                        widget.team['seasons'][selectedSeason]['ROSTER']
                                                ?[players[index]]?['Injured_Status'] ==
                                            'OFS'
                                    ? Colors.redAccent.withOpacity(0.1)
                                    : widget.team['seasons'][selectedSeason]['ROSTER']
                                                ?[players[index]]?['Injured_Status'] ==
                                            'GTD'
                                        ? Colors.orangeAccent.withOpacity(0.1)
                                        : Colors.grey.shade900,
                                border: Border(
                                    bottom: BorderSide(
                                  color: Colors.grey.shade800,
                                  width: 0.5,
                                ))),
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
                                        widget.team['seasons'][selectedSeason]['ROSTER']
                                                ?[players[index]]?['PLAYER'] ??
                                            '-',
                                        style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                  (widget.team['seasons'][selectedSeason]['ROSTER']
                                                  ?[players[index]]?['Injured_Status'] ??
                                              '') ==
                                          'GTD'
                                      ? 'DTD'
                                      : widget.team['seasons'][selectedSeason]['ROSTER']
                                              ?[players[index]]?['Injured_Status'] ??
                                          '',
                                  style: kBebasNormal.copyWith(
                                    fontSize: 14.0.r,
                                    color: widget.team['seasons'][selectedSeason]['ROSTER']
                                                    ?[players[index]]?['Injured_Status'] ==
                                                'OUT' ||
                                            widget.team['seasons'][selectedSeason]['ROSTER']
                                                    ?[players[index]]?['Injured_Status'] ==
                                                'OFS'
                                        ? Colors.redAccent
                                        : Colors.orangeAccent,
                                  ),
                                )),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    widget.team['seasons'][selectedSeason]['ROSTER']
                                            ?[players[index]]?['NUM'] ??
                                        '',
                                    textAlign: TextAlign.center,
                                    style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    widget.team['seasons'][selectedSeason]['ROSTER']
                                            ?[players[index]]?['POSITION'] ??
                                        '',
                                    textAlign: TextAlign.center,
                                    style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
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
                ],
              ),
              MultiSliver(
                pushPinnedChildren: true,
                children: [
                  SliverPinnedHeader(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(20.0.r, 6.0.r, 0.0, 6.0.r),
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
                                flex: 5,
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coaches',
                                        style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                      ),
                                    ],
                                  ),
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
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.0.r, vertical: 6.0.r),
                          height: MediaQuery.of(context).size.height * 0.05,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              border: Border(
                                  bottom: BorderSide(
                                color: Colors.grey.shade800,
                                width: 0.5,
                              ))),
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
                                          'https://cdn.nba.com/headshots/nba/latest/1040x760/${coaches[index]['COACH_ID']}.png',
                                    ),
                                    SizedBox(
                                      width: 15.0.r,
                                    ),
                                    Text(
                                      coaches[index]['COACH_NAME'],
                                      style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: AutoSizeText(
                                  coaches[index]['COACH_TYPE'],
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: kBebasOffWhite.copyWith(fontSize: 14.0.r),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: coaches.length,
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
