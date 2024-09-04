import 'package:flutter/material.dart';
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
                      height: MediaQuery.of(context).size.height * 0.045,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        border: const Border(
                          bottom: BorderSide(
                            color: Colors.white70,
                            width: 1,
                          ),
                        ),
                      ),
                      child: DropdownButton<String>(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        borderRadius: BorderRadius.circular(10.0),
                        menuMaxHeight: 300.0,
                        dropdownColor: Colors.grey.shade900,
                        isExpanded: true,
                        underline: Container(),
                        value: selectedSeason,
                        items: seasons.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: kBebasOffWhite,
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
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 6.0, 0.0, 6.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        border: const Border(
                          bottom: BorderSide(
                            color: Colors.white70,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 8,
                            child: GestureDetector(
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Player',
                                      style: kBebasOffWhite,
                                    ),
                                    if (sortedBy == 'Name')
                                      Icon(
                                        sortOrder == 'ASC'
                                            ? Icons.arrow_drop_down
                                            : Icons.arrow_drop_up,
                                        size: 16.0,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
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
                            flex: 1,
                            child: GestureDetector(
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '#',
                                      textAlign: TextAlign.end,
                                      style: kBebasOffWhite,
                                    ),
                                    if (sortedBy == 'Number')
                                      Icon(
                                        sortOrder == 'ASC'
                                            ? Icons.arrow_drop_down
                                            : Icons.arrow_drop_up,
                                        size: 16.0,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
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
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pos',
                                      textAlign: TextAlign.start,
                                      style: kBebasOffWhite,
                                    ),
                                    if (sortedBy == 'Position')
                                      Icon(
                                        sortOrder == 'ASC'
                                            ? Icons.arrow_drop_down
                                            : Icons.arrow_drop_up,
                                        size: 16.0,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
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
                              teamId: widget.team["TEAM_ID"].toString(),
                              playerId: players[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                        height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            border: const Border(
                                bottom: BorderSide(color: Colors.white54, width: 0.125))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 11,
                              child: Row(
                                children: [
                                  PlayerAvatar(
                                    radius: 16.0,
                                    backgroundColor: Colors.white12,
                                    playerImageUrl:
                                        'https://cdn.nba.com/headshots/nba/latest/1040x760/${players[index]}.png',
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  Text(
                                    widget.team['seasons'][selectedSeason]['ROSTER']
                                        [players[index]]['PLAYER'],
                                    style: kBebasOffWhite.copyWith(fontSize: 18.0),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.team['seasons'][selectedSeason]['ROSTER']
                                            [players[index]]['NUM'] !=
                                        null
                                    ? '${widget.team['seasons'][selectedSeason]['ROSTER'][players[index]]['NUM']}'
                                    : '',
                                textAlign: TextAlign.center,
                                style: kBebasOffWhite.copyWith(fontSize: 18.0),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                widget.team['seasons'][selectedSeason]['ROSTER']
                                    [players[index]]['POSITION'],
                                textAlign: TextAlign.center,
                                style: kBebasOffWhite.copyWith(fontSize: 18.0),
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
          );
  }
}
