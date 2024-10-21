import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:splash/utilities/constants.dart';

class TeamHistory extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamHistory({super.key, required this.team});

  @override
  State<TeamHistory> createState() => _TeamHistoryState();
}

class _TeamHistoryState extends State<TeamHistory> {
  late Map<String, dynamic> seasons;

  String getStanding(int confRank) {
    switch (confRank) {
      case 0:
        return '-';
      case 1:
        return '${confRank}st';
      case 2:
        return '${confRank}nd';
      case 3:
        return '${confRank}rd';
      case 21:
        return '${confRank}st';
      case 22:
        return '${confRank}nd';
      case 23:
        return '${confRank}rd';
      default:
        return '${confRank}th';
    }
  }

  String getPlayoffs(dynamic teamSeason) {
    if (teamSeason['CONF_RANK'] == 0 &&
        int.parse(teamSeason['YEAR'].substring(0, 4)) >= 1970) {
      return '-';
    }

    // Best-of-7 every round (post-2003)
    if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 2002) {
      // Play-In (post-2019)
      if (teamSeason['CONF_RANK'] > 10 &&
          int.parse(teamSeason['YEAR'].substring(0, 4)) >= 2019) {
        return '-';
      } else if (teamSeason['CONF_RANK'] > 8) {
        return '-';
      } else if (teamSeason['PO_WINS'] < 4) {
        return 'Lost 1st Round';
      } else if (teamSeason['PO_WINS'] < 8) {
        return 'Lost Conf Semis';
      } else if (teamSeason['PO_WINS'] < 12) {
        return 'Lost Conf Finals';
      } else if (teamSeason['PO_WINS'] < 16) {
        return 'Lost NBA Finals';
      } else if (teamSeason['PO_WINS'] == 16) {
        return 'Won NBA Finals';
      } else {
        return '-';
      }
    }
    // Best-of-5 first round (pre-2003)
    else if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 1983) {
      if (teamSeason['CONF_RANK'] > 8) {
        return '-';
      } else if (teamSeason['PO_WINS'] < 3) {
        return 'Lost 1st Round';
      } else if (teamSeason['PO_WINS'] < 7) {
        return 'Lost Conf Semis';
      } else if (teamSeason['PO_WINS'] < 11) {
        return 'Lost Conf Finals';
      } else if (teamSeason['PO_WINS'] < 15) {
        return 'Lost NBA Finals';
      } else if (teamSeason['PO_WINS'] == 15) {
        return 'Won NBA Finals';
      }
    }
    // Top 2 seeds first round byes (pre-1983)
    else if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 1970) {
      if (teamSeason['CONF_RANK'] > 8) {
        return '-';
      } else if (teamSeason['CONF_RANK'] <= 2) {
        if (teamSeason['PO_WINS'] < 4) {
          return 'Lost Conf Semis';
        } else if (teamSeason['PO_WINS'] < 8) {
          return 'Lost Conf Finals';
        } else if (teamSeason['PO_WINS'] < 12) {
          return 'Lost NBA Finals';
        } else if (teamSeason['PO_WINS'] == 12) {
          return 'Won NBA Finals';
        }
      } else {
        if (teamSeason['PO_WINS'] < 3) {
          return 'Lost 1st Round';
        } else if (teamSeason['PO_WINS'] < 7) {
          return 'Lost Conf Semis';
        } else if (teamSeason['PO_WINS'] < 11) {
          return 'Lost Conf Finals';
        } else if (teamSeason['PO_WINS'] < 15) {
          return 'Lost NBA Finals';
        } else if (teamSeason['PO_WINS'] == 15) {
          return 'Won NBA Finals';
        }
      }
    } else {
      if (teamSeason['NBA_FINALS_APPEARANCE'] == 'LEAGUE CHAMPION') {
        return 'Won NBA Finals';
      } else if (teamSeason['NBA_FINALS_APPEARANCE'] == 'FINALS APPEARANCE') {
        return 'Lost NBA Finals';
      }
    }
    return '-';
  }

  Color getColor(dynamic teamSeason) {
    // Best-of-7 every round (post-2003)
    if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 2002) {
      // Play-In (post-2019)
      if (teamSeason['CONF_RANK'] > 10 &&
          int.parse(teamSeason['YEAR'].substring(0, 4)) >= 2019) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 4) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 8) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 12) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 16) {
        return Colors.blueGrey.withOpacity(0.5);
      } else if (teamSeason['PO_WINS'] == 16) {
        return Colors.yellow.shade900.withOpacity(0.4);
      } else {
        return Colors.grey.shade900;
      }
    }
    // Best-of-5 first round (pre-2003)
    else if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 1983) {
      if (teamSeason['CONF_RANK'] > 8) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 3) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 7) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 11) {
        return Colors.grey.shade900;
      } else if (teamSeason['PO_WINS'] < 15) {
        return Colors.blueGrey.withOpacity(0.5);
      } else if (teamSeason['PO_WINS'] == 15) {
        return Colors.yellow.shade900.withOpacity(0.4);
      }
    }
    // Top 2 seeds first round byes (pre-1983)
    else if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 1970) {
      if (teamSeason['CONF_RANK'] > 8) {
        return Colors.grey.shade900;
      } else if (teamSeason['CONF_RANK'] <= 2) {
        if (teamSeason['PO_WINS'] < 4) {
          return Colors.grey.shade900;
        } else if (teamSeason['PO_WINS'] < 8) {
          return Colors.grey.shade900;
        } else if (teamSeason['PO_WINS'] < 12) {
          return Colors.blueGrey.withOpacity(0.5);
        } else if (teamSeason['PO_WINS'] == 12) {
          return Colors.yellow.shade900.withOpacity(0.4);
        }
      } else {
        if (teamSeason['PO_WINS'] < 3) {
          return Colors.grey.shade900;
        } else if (teamSeason['PO_WINS'] < 7) {
          return Colors.grey.shade900;
        } else if (teamSeason['PO_WINS'] < 11) {
          return Colors.grey.shade900;
        } else if (teamSeason['PO_WINS'] < 15) {
          return Colors.blueGrey.withOpacity(0.5);
        } else if (teamSeason['PO_WINS'] == 15) {
          return Colors.yellow.shade900.withOpacity(0.4);
        }
      }
    } else {
      if (teamSeason['NBA_FINALS_APPEARANCE'] == 'LEAGUE CHAMPION') {
        return Colors.yellow.shade900.withOpacity(0.4);
      } else if (teamSeason['NBA_FINALS_APPEARANCE'] == 'FINALS APPEARANCE') {
        return Colors.blueGrey.withOpacity(0.5);
      }
    }
    return Colors.grey.shade900;
  }

  @override
  void initState() {
    super.initState();
    seasons = widget.team['seasons'];
  }

  @override
  Widget build(BuildContext context) {
    // Convert the map to a list of entries
    var entries = seasons.entries.toList().reversed.toList();

    // Extract the sorted keys
    var seasonIndex = entries.map((e) => e.key).toList();

    TextStyle teamHistoryStyle = kBebasOffWhite.copyWith(fontSize: 14.0.r);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ExpandableCard(team: widget.team),
        ),
        SliverPinnedHeader(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white30,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Season-by-Season', style: teamHistoryStyle),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
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
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text('YEAR',
                            textAlign: TextAlign.center, style: teamHistoryStyle)),
                    Expanded(
                        flex: 3,
                        child: Text('RECORD',
                            textAlign: TextAlign.center, style: teamHistoryStyle)),
                    Expanded(
                        flex: 1,
                        child: Text('CONF',
                            textAlign: TextAlign.center, style: teamHistoryStyle)),
                    Expanded(
                        flex: 3,
                        child: Text('PLAYOFFS',
                            textAlign: TextAlign.center, style: teamHistoryStyle)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              String city = seasons[seasonIndex[index]]?['TEAM_CITY'] ?? widget.team['CITY'];
              String name =
                  seasons[seasonIndex[index]]?['TEAM_NAME'] ?? widget.team['NICKNAME'];

              // List to hold the widgets to be returned
              List<Widget> widgets = [];

              // Check if we need to add the season separator
              if (index == 0 ||
                  city !=
                      (seasons[seasonIndex[index - 1]]?['TEAM_CITY'] ?? widget.team['CITY']) ||
                  name !=
                      (seasons[seasonIndex[index - 1]]?['TEAM_NAME'] ??
                          widget.team['NICKNAME'])) {
                var startYearList = widget.team['team_history']
                    .where((e) =>
                        e['TEAM_CITY'] ==
                            (seasons[seasonIndex[index]]?['TEAM_CITY'] ??
                                widget.team['CITY']) &&
                        e['TEAM_NAME'] ==
                            (seasons[seasonIndex[index]]?['TEAM_NAME'] ??
                                widget.team['NICKNAME']))
                    .toList();

                var startYear = startYearList.length > 1
                    ? startYearList[1]['START_YEAR']
                    : startYearList.isNotEmpty
                        ? startYearList[0]['START_YEAR']
                        : null;
                var endYear = index == 0
                    ? kCurrentSeason.substring(0, 4)
                    : startYearList.length > 1
                        ? startYearList[1]['END_YEAR']
                        : startYearList.isNotEmpty
                            ? startYearList[0]['END_YEAR']
                            : null;

                widgets.add(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$city $name   ($startYear - $endYear)',
                      style: kBebasNormal.copyWith(fontSize: 13.0.r),
                    ),
                  ),
                );
              }

              Widget seasonContainer = Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                height: MediaQuery.sizeOf(context).height * 0.06,
                decoration: BoxDecoration(
                    color: getColor(seasons[seasonIndex[index]]),
                    border:
                        const Border(bottom: BorderSide(color: Colors.white54, width: 0.25))),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          seasons[seasonIndex[index]]['YEAR'],
                          textAlign: TextAlign.center,
                          style: kBebasOffWhite.copyWith(fontSize: 16.0.r),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${seasons[seasonIndex[index]]['WINS']!.toString()}-${seasons[seasonIndex[index]]['LOSSES']!.toString()} (${seasons[seasonIndex[index]]['WIN_PCT']!.toStringAsFixed(3)})',
                        textAlign: TextAlign.center,
                        style: kBebasOffWhite.copyWith(fontSize: 15.0.r),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        getStanding(int.parse(seasonIndex[index].substring(0, 4)) <= 1969
                            ? seasons[seasonIndex[index]]['DIV_RANK']!
                            : seasons[seasonIndex[index]]['CONF_RANK']!),
                        textAlign: TextAlign.center,
                        style: kBebasOffWhite.copyWith(fontSize: 15.0.r),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        getPlayoffs(seasons[seasonIndex[index]]!),
                        textAlign: TextAlign.center,
                        style: kBebasOffWhite.copyWith(fontSize: 15.0.r),
                      ),
                    ),
                  ],
                ),
              );

              widgets.add(seasonContainer);

              return Column(
                children: widgets,
              );
            },
            childCount: seasonIndex.length,
          ),
        ),
      ],
    );
  }
}

class ExpandableCard extends StatefulWidget {
  final Map<String, dynamic> team;

  const ExpandableCard({Key? key, required this.team}) : super(key: key);

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool isExpanded = false;
  late Map<String, dynamic> seasons;
  List<String> leagueTitleYears = [];
  List<String> confTitleYears = [];
  List<String> divTitleYears = [];
  List<String> playoffYears = [];

  @override
  void initState() {
    super.initState();
    seasons = widget.team['seasons'];

    for (var season in seasons.entries) {
      String key = '';
      if (season.key == kCurrentSeason) {
        continue;
      } else {
        key = int.parse(season.key.toString().substring(0, 4)) < 1999
            ? '19${season.key.toString().substring(5)}'
            : '20${season.key.toString().substring(5)}';
      }

      if (season.value['NBA_FINALS_APPEARANCE'] == 'LEAGUE CHAMPION') {
        leagueTitleYears.add(key);
        confTitleYears.add(key);
      } else if (season.value['NBA_FINALS_APPEARANCE'] == 'FINALS APPEARANCE') {
        confTitleYears.add(key);
      }

      if ((season.value?['STANDINGS']?['DivisionRank'] ?? season.value['DIV_RANK']) == 1) {
        divTitleYears.add(key);
      }

      if (season.value['PO_WINS'] > 0 || season.value['PO_LOSSES'] > 0) {
        playoffYears.add(key);
      }
    }
  }

  Widget awardYears(List<String> seasons) {
    seasons.sort();

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < seasons.length; i++)
          Text(
            '${seasons[i]}${i == seasons.length - 1 ? '' : ', '}',
            style: kBebasNormal.copyWith(
              fontSize: 14.0.r,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(11.0.r),
      color: Colors.grey.shade900,
      child: InkWell(
        radius: MediaQuery.of(context).size.width,
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(15.0.r, 15.0.r, 15.0.r, 5.0.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.team['team_history']?[0]?['LEAGUE_TITLES'] == 0
                          ? '-'
                          : (widget.team['team_history']?[0]?['LEAGUE_TITLES'] ?? 0)
                              .toString(),
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.team['team_history']?[0]?['CONF_TITLES'] == 0
                          ? '-'
                          : (widget.team['team_history']?[0]?['CONF_TITLES'] ?? 0).toString(),
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.team['team_history']?[0]?['DIV_TITLES'] == 0
                          ? '-'
                          : (widget.team['team_history']?[0]?['DIV_TITLES'] ?? 0).toString(),
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.team['team_history']?[0]?['PO_APPEARANCES'] == 0
                          ? '-'
                          : (widget.team['team_history']?[0]?['PO_APPEARANCES'] ?? 0)
                              .toString(),
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 20.0.r),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'LEAGUE TITLES',
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'CONF TITLES',
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'DIV TITLES',
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'PLAYOFFS',
                      textAlign: TextAlign.center,
                      style: kBebasNormal.copyWith(fontSize: 13.0.r, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.0.r),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.white70,
              ),
              if (isExpanded)
                Column(
                  children: [
                    const Divider(color: Colors.white54),
                    if (leagueTitleYears.isNotEmpty) SizedBox(height: 10.0.r),
                    if (leagueTitleYears.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'FINALS',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          awardYears(leagueTitleYears),
                        ],
                      ),
                    if (confTitleYears.isNotEmpty) SizedBox(height: 10.0.r),
                    if (confTitleYears.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'CONFERENCE',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          awardYears(confTitleYears),
                        ],
                      ),
                    if (divTitleYears.isNotEmpty) SizedBox(height: 10.0.r),
                    if (divTitleYears.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'DIVISION',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          awardYears(divTitleYears),
                        ],
                      ),
                    if (playoffYears.isNotEmpty) SizedBox(height: 10.0.r),
                    if (playoffYears.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'PLAYOFFS',
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          ),
                          awardYears(playoffYears),
                          SizedBox(height: 5.0.r),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
