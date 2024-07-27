import 'package:flutter/material.dart';
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
    // Best-of-7 every round (post-2003)
    if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 2003) {
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
    else {
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
    }
    return '-';
  }

  Color getColor(dynamic teamSeason) {
    // Best-of-7 every round (post-2003)
    if (int.parse(teamSeason['YEAR'].substring(0, 4)) >= 2003) {
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
    else {
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

    return CustomScrollView(
      slivers: [
        SliverPinnedHeader(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.5),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white70,
                      width: 1,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Season-by-Season', style: kBebasOffWhite),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.75),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.white70,
                      width: 1,
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child:
                            Text('YEAR', textAlign: TextAlign.start, style: kBebasOffWhite)),
                    Expanded(
                        flex: 3,
                        child: Text('RECORD',
                            textAlign: TextAlign.center, style: kBebasOffWhite)),
                    Expanded(
                        flex: 1,
                        child:
                            Text('CONF', textAlign: TextAlign.center, style: kBebasOffWhite)),
                    Expanded(
                        flex: 3,
                        child: Text('PLAYOFFS',
                            textAlign: TextAlign.center, style: kBebasOffWhite)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                height: MediaQuery.sizeOf(context).height * 0.06,
                decoration: BoxDecoration(
                    color: getColor(seasons[seasonIndex[index]]),
                    border:
                        const Border(bottom: BorderSide(color: Colors.white70, width: 0.5))),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: FittedBox(
                        child: Text(
                          seasons[seasonIndex[index]]['YEAR'],
                          textAlign: TextAlign.center,
                          style: kBebasOffWhite.copyWith(fontSize: 18.0),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${seasons[seasonIndex[index]]['WINS']!.toString()}-${seasons[seasonIndex[index]]['LOSSES']!.toString()} (${seasons[seasonIndex[index]]['WIN_PCT']!.toStringAsFixed(3)})',
                        textAlign: TextAlign.center,
                        style: kBebasOffWhite.copyWith(fontSize: 17.0),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        getStanding(seasons[seasonIndex[index]]['CONF_RANK']!),
                        textAlign: TextAlign.center,
                        style: kBebasOffWhite.copyWith(fontSize: 17.0),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        getPlayoffs(seasons[seasonIndex[index]]!),
                        textAlign: TextAlign.center,
                        style: kBebasOffWhite.copyWith(fontSize: 17.0),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: seasonIndex.length,
          ),
        ),
      ],
    );
  }
}
