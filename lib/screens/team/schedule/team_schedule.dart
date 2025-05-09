import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/team/schedule/team_games.dart';
import 'package:splash/utilities/constants.dart';

class TeamSchedule extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamSchedule({super.key, required this.team});

  @override
  State<TeamSchedule> createState() => _TeamScheduleState();
}

class _TeamScheduleState extends State<TeamSchedule> with AutomaticKeepAliveClientMixin {
  late Map<String, dynamic> schedule;
  late List<String> seasons;
  late String selectedSeason;
  late String selectedSeasonType;
  late String selectedMonth;
  late String selectedOpp;
  late int oppId;
  late TeamGames games;

  List<String> months = [
    'All',
    'October',
    'November',
    'December',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
  ];

  Map<String, String> teamAbbr = {
    'ALL': '0',
    'TOP NET': '1',
    'TOP OFF': '2',
    'TOP DEF': '3',
    'ATL': '1610612737',
    'BOS': '1610612738',
    'BKN': '1610612751',
    'CHA': '1610612766',
    'CHI': '1610612741',
    'CLE': '1610612739',
    'DAL': '1610612742',
    'DEN': '1610612743',
    'DET': '1610612765',
    'GSW': '1610612744',
    'HOU': '1610612745',
    'IND': '1610612754',
    'LAC': '1610612746',
    'LAL': '1610612747',
    'MEM': '1610612763',
    'MIA': '1610612748',
    'MIL': '1610612749',
    'MIN': '1610612750',
    'NOP': '1610612740',
    'NYK': '1610612752',
    'OKC': '1610612760',
    'ORL': '1610612753',
    'PHI': '1610612755',
    'PHX': '1610612756',
    'POR': '1610612757',
    'SAC': '1610612758',
    'SAS': '1610612759',
    'TOR': '1610612761',
    'UTA': '1610612762',
    'WAS': '1610612764',
  };

  late Map<String, String> seasonTypes;

  void filterSeasonTypes(List<String> scheduleKeys) {
    seasonTypes = {
      'All': '*',
      'Pre-Season': '1',
      'Regular Season': '2',
      'Playoffs': '4',
      'Play-In': '5',
      'NBA Cup': '6',
    };

    // Iterate over a copy of the map to avoid modification during iteration
    seasonTypes.keys.toList().forEach((seasonType) {
      String value = seasonTypes[seasonType]!;

      // Skip the 'All' entry and continue
      if (seasonType == 'All') {
        return;
      }

      // Check if any key from scheduleKeys has a matching substring
      bool matchFound = scheduleKeys.any((key) => key.substring(2, 3) == value);

      // If no match is found, remove the seasonType entry
      if (!matchFound) {
        seasonTypes.remove(seasonType);
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    seasons = widget.team['SEASONS'].keys.toList().reversed.toList();
    seasons = seasons.where((e) => int.parse(e.substring(0, 4)) >= 2017).toList();
    selectedSeason = seasons.first;
    schedule = widget.team['SEASONS'][selectedSeason]['GAMES'];

    filterSeasonTypes(schedule.keys.toList());
    selectedSeasonType = 'All';

    selectedMonth = months.first;
    selectedOpp = 'ALL';
    oppId = 0;
    games = TeamGames(
        team: widget.team,
        schedule: schedule,
        selectedSeason: selectedSeason,
        selectedSeasonType: selectedSeasonType,
        selectedMonth: selectedMonth,
        opponent: oppId);
  }

  @override
  Widget build(BuildContext context) {
    Color teamColor = kDarkPrimaryColors.contains(widget.team['ABBREVIATION'])
        ? (kTeamColors[widget.team['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.team['ABBREVIATION']]!['primaryColor']!);

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      children: [
        games,
        Positioned(
          bottom: kBottomNavigationBarHeight - kToolbarHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(
                top: BorderSide(color: Colors.grey.shade800, width: 0.75),
                bottom: BorderSide(color: Colors.grey.shade800, width: 0.2),
              ),
            ),
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              mainAxisAlignment:
                  isLandscape ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border.all(color: teamColor),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: const EdgeInsets.fromLTRB(11.0, 11.0, 0.0, 11.0),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        constraints:
                            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        backgroundColor: Colors.grey.shade900,
                        scrollControlDisabledMaxHeightRatio: 0.25,
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setModalState) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: teamColor,
                                    onPrimary: Colors.white,
                                    secondary: Colors.white,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Filter',
                                            style: kBebasBold.copyWith(fontSize: 20.0.r),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Done',
                                              style: kBebasNormal.copyWith(
                                                  fontSize: 18.0.r, color: teamColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0.r),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade900,
                                                border: Border.all(color: teamColor),
                                                borderRadius: BorderRadius.circular(10.0)),
                                            child: DropdownButton<String>(
                                              padding:
                                                  const EdgeInsets.symmetric(horizontal: 15.0),
                                              borderRadius: BorderRadius.circular(10.0),
                                              menuMaxHeight: 300.0.r,
                                              dropdownColor: Colors.grey.shade900,
                                              isExpanded: false,
                                              underline: Container(),
                                              value: selectedSeason,
                                              items: seasons.map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 16.0.r),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? value) {
                                                /// Updates displayed values in bottom sheet
                                                setModalState(() {
                                                  selectedSeason = value!;
                                                });

                                                /// Updates displayed values in schedule view
                                                setState(() {
                                                  selectedSeason = value!;
                                                  schedule =
                                                      widget.team['SEASONS'][value]['GAMES'];
                                                  filterSeasonTypes(schedule.keys.toList());
                                                  games = TeamGames(
                                                    team: widget.team,
                                                    schedule: schedule,
                                                    selectedSeason: value,
                                                    selectedSeasonType: selectedSeasonType,
                                                    selectedMonth: selectedMonth,
                                                    opponent: oppId,
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade900,
                                                border: Border.all(color: teamColor),
                                                borderRadius: BorderRadius.circular(10.0)),
                                            child: DropdownButton<String>(
                                              padding:
                                                  const EdgeInsets.symmetric(horizontal: 15.0),
                                              borderRadius: BorderRadius.circular(10.0),
                                              menuMaxHeight: 300.0.r,
                                              dropdownColor: Colors.grey.shade900,
                                              isExpanded: false,
                                              underline: Container(),
                                              value: selectedSeasonType,
                                              items: seasonTypes.keys
                                                  .map<DropdownMenuItem<String>>(
                                                      (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: kBebasNormal.copyWith(
                                                        fontSize: 16.0.r),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? value) {
                                                /// Updates displayed values in bottom sheet
                                                setModalState(() {
                                                  selectedSeasonType = value!;
                                                });

                                                /// Updates displayed values in schedule view
                                                setState(() {
                                                  selectedSeasonType = value!;
                                                  games = TeamGames(
                                                    team: widget.team,
                                                    schedule: schedule,
                                                    selectedSeason: selectedSeason,
                                                    selectedSeasonType: value,
                                                    selectedMonth: selectedMonth,
                                                    opponent: oppId,
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Text(
                            selectedSeason,
                            style: kBebasNormal.copyWith(fontSize: 16.0.r),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLandscape) SizedBox(width: 100.0.r),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(color: teamColor),
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.fromLTRB(0.0, 11.0, 0.0, 11.0),
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    borderRadius: BorderRadius.circular(10.0),
                    menuMaxHeight: 300.0.r,
                    dropdownColor: Colors.grey.shade900,
                    isExpanded: false,
                    underline: Container(),
                    value: selectedMonth,
                    items: months.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: kBebasNormal.copyWith(fontSize: 16.0.r),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedMonth = value!;
                        games = TeamGames(
                          team: widget.team,
                          schedule: schedule,
                          selectedSeason: selectedSeason,
                          selectedSeasonType: selectedSeasonType,
                          selectedMonth: value,
                          opponent: oppId,
                        );
                      });
                    },
                  ),
                ),
                if (isLandscape) SizedBox(width: 100.0.r),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(color: teamColor),
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.fromLTRB(0.0, 11.0, 11.0, 11.0),
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    borderRadius: BorderRadius.circular(10.0),
                    menuMaxHeight: 300.0.r,
                    dropdownColor: Colors.grey.shade900,
                    isExpanded: false,
                    underline: Container(),
                    value: selectedOpp,
                    items: teamAbbr.keys
                        .where((String value) => value != widget.team['ABBREVIATION'])
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 20.0.r),
                              child: Image.asset(
                                teamAbbr[value]! == '1' ||
                                        teamAbbr[value]! == '2' ||
                                        teamAbbr[value]! == '3'
                                    ? 'images/NBA_Logos/0.png'
                                    : 'images/NBA_Logos/${teamAbbr[value]!}.png',
                                fit: BoxFit.contain,
                                width: 20.0.r,
                                height: 20.0.r,
                              ),
                            ),
                            SizedBox(width: 8.0.r),
                            Text(
                              value,
                              style: kBebasNormal.copyWith(fontSize: 16.0.r),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedOpp = value!;
                        oppId = int.parse(teamAbbr[selectedOpp]!);
                        games = TeamGames(
                          team: widget.team,
                          schedule: schedule,
                          selectedSeason: selectedSeason,
                          selectedSeasonType: selectedSeasonType,
                          selectedMonth: selectedMonth,
                          opponent: oppId,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
