import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:splash/screens/player/profile/player_awards.dart';
import 'package:splash/screens/player/profile/player_contract.dart';
import 'package:splash/screens/player/profile/player_transactions.dart';
import 'package:splash/utilities/constants.dart';

import '../../more/draft/draft.dart';

class PlayerProfile extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerProfile({super.key, required this.team, required this.player});

  @override
  State<PlayerProfile> createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {
  String convertDate(String date) {
    String formattedDate = DateFormat('MMM d, y').format(DateTime.parse(date));
    return formattedDate;
  }

  String calculateAge(String birthDate) {
    int age = DateTime.now().year -
        DateTime.parse(birthDate).year -
        (DateTime.now().month < DateTime.parse(birthDate).month ||
                (DateTime.now().month == DateTime.parse(birthDate).month &&
                    DateTime.now().day < DateTime.parse(birthDate).day)
            ? 1
            : 0);

    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    var key = widget.player['ROSTERSTATUS'] == 'Inactive' || widget.player['BIRTHDATE'] == null
        ? 'Last Played'
        : convertDate(widget.player['BIRTHDATE']);
    var value =
        widget.player['ROSTERSTATUS'] == "Inactive" || widget.player['BIRTHDATE'] == null
            ? ((widget.player['TO_YEAR'] ?? widget.player['FROM_YEAR'] ?? 0) + 1).toString()
            : '${calculateAge(widget.player['BIRTHDATE'])} yrs';

    var height = widget.player['HEIGHT'].toString().split('-');
    var heightFinal = widget.player['HEIGHT'] == "" ? "" : '${height[0]}\'${height[1]}\"';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            if (widget.player.containsKey('PlayerRotowires'))
              if (widget.player['PlayerRotowires'][0]['Injured'] == 'YES')
                InjuryCard(
                  injuryDetails: widget.player['PlayerRotowires'][0],
                  teamAbbr: widget.player['TEAM_ABBREVIATION'],
                ),
            InfoCard(
              info: {
                'Measure': '$heightFinal | ${widget.player['WEIGHT'] ?? '-'} lb',
                'Experience': widget.player['SEASON_EXP'] == 0
                    ? 'Rookie'
                    : widget.player['SEASON_EXP'].toString(),
                key: value == '1' ? '-' : value, // Last Played or Age/DOB
                'Prev. Affiliate': widget.player['SCHOOL'] ?? '-',
                'Draft': (widget.player['DRAFT_YEAR'] == 'Undrafted' ||
                        widget.player['DRAFT_ROUND'] == null ||
                        widget.player['DRAFT_ROUND'] == '0')
                    ? (widget.player['DRAFT_YEAR'] == 'Undrafted' ||
                            widget.player['DRAFT_YEAR'] == null)
                        ? 'UDFA (${widget.player['FROM_YEAR']})'
                        : 'UDFA (${widget.player['DRAFT_YEAR']})'
                    : 'R${widget.player['DRAFT_ROUND']}:${widget.player['DRAFT_NUMBER']} (${widget.player['DRAFT_YEAR']})',
                'Country': widget.player['COUNTRY'] ?? '-',
              },
            ),
            PlayerAwards(
              playerAwards: widget.player['AWARDS'],
            ),
            if (widget.player['CONTRACTS'].isNotEmpty)
              PlayerContract(
                playerContracts: widget.player['CONTRACTS'],
              ),
            if (widget.player['TRANSACTIONS'].isNotEmpty)
              PlayerTransactions(
                playerTransactions: widget.player['TRANSACTIONS'],
              ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatefulWidget {
  final Map<String, String> info;

  const InfoCard({required this.info});

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, String>> entries = widget.info.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Column(
          children: [
            Row(
              children: entries.sublist(0, 3).map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          entry.value,
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(fontSize: 16.0.r),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            Row(
              children: entries.sublist(3).map((entry) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (entry.key == 'Draft') {
                        String value = entry.value.split('(')[1].split(')')[0];
                        String year = '$value-${int.parse(value.substring(2)) + 1}';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Draft(
                              season: year,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: AutoSizeText(
                                  entry.value,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                                ),
                              ),
                              if (entry.key == 'Country') const SizedBox(width: 5.0),
                              if (entry.key == 'Country')
                                CircleAvatar(
                                  radius: 7.0.r,
                                  backgroundImage: AssetImage(
                                      'images/flags/${kCountryCodes[entry.value]?.toLowerCase()}.png'),
                                )
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0.r,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class InjuryCard extends StatefulWidget {
  final Map<String, dynamic> injuryDetails;
  final String teamAbbr;
  const InjuryCard({super.key, required this.injuryDetails, required this.teamAbbr});

  @override
  State<InjuryCard> createState() => _InjuryCardState();
}

class _InjuryCardState extends State<InjuryCard> {
  bool _isExpanded = false;

  Color getColor(String status) {
    if (status == 'OUT' || status == 'OFS') {
      return Colors.redAccent;
    } else if (status == 'GTD' || status == 'DTD') {
      return Colors.orangeAccent;
    } else {
      return Colors.white;
    }
  }

  String timeAgo(String dateTimeString) {
    final inputFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
    final DateTime givenDateTime = inputFormat.parse(dateTimeString);
    // Convert current time to GST (GMT+4)
    final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final Duration difference = now.difference(givenDateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 2) {
      return '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final outputFormat = DateFormat('MMM d');
      return outputFormat.format(givenDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getColor(widget.injuryDetails['Injured_Status']).withOpacity(0.2),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(bottom: 11.0.r),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.injuryDetails['Injured_Status'] == 'OFS'
                            ? 'Out for Season'
                            : widget.injuryDetails['Injured_Status'] == 'GTD' ||
                                    widget.injuryDetails['Injured_Status'] == 'DTD'
                                ? 'Day-To-Day'
                                : widget.injuryDetails['Injured_Status'],
                        style: kBebasNormal.copyWith(
                            fontSize: 16.0.r,
                            color: getColor(widget.injuryDetails['Injured_Status'])),
                      ),
                      Text(
                        ' - ${widget.injuryDetails['Injury_Side'] == 'Not Specified' || widget.injuryDetails['Injury_Side'] == '' ? '' : '${widget.injuryDetails['Injury_Side']} '}${widget.injuryDetails['Injury_Type']}',
                        style: kBebasNormal.copyWith(fontSize: 16.0.r),
                      ),
                      if (widget.injuryDetails['Injury_Detail'] != '')
                        Text(
                          ' (${widget.injuryDetails['Injury_Detail']})',
                          style: kBebasNormal.copyWith(fontSize: 16.0.r),
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Est. Return', style: kBebasNormal.copyWith(fontSize: 11.0.r)),
                      Text(widget.injuryDetails['EST_RETURN'] ?? 'TBD',
                          style: kBebasNormal.copyWith(fontSize: 14.0.r))
                    ],
                  )
                ],
              )
            ],
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white70,
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.0.r, 6.0.r, 12.0.r, 12.0.r),
              child: Column(
                children: [
                  RichText(
                      text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.injuryDetails['ListItemShort'].toString() ?? '',
                        style: TextStyle(
                          color: const Color(0xFFEEEEEE),
                          letterSpacing: -0.8,
                          fontSize: 13.0.r,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  )),
                  SizedBox(height: 5.0.r),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'images/rotowire.svg',
                        height: 17.0.r,
                        width: 20.0.r,
                      ),
                      SizedBox(width: 5.0.r),
                      Text(
                        timeAgo(widget.injuryDetails['ListItemPubDate']),
                        style: kBebasNormal.copyWith(fontSize: 12.0.r, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0.r),
                  Stack(
                    children: [
                      // Colored bar extending to the height of RichText
                      Positioned.fill(
                        left: 0, // Position the bar on the left side
                        child: Row(
                          children: [
                            Container(
                              width: 3.0.r, // Width of the colored bar
                              color: kTeamColors.containsKey(widget.teamAbbr)
                                  ? kDarkPrimaryColors.contains(widget.teamAbbr)
                                      ? kTeamColors[widget.teamAbbr]!['secondaryColor']
                                      : kTeamColors[widget.teamAbbr]!['primaryColor']
                                  : Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10.0.r), // Space between bar and RichText
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Analysis: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: -0.8,
                                  fontSize: 12.0.r,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: widget.injuryDetails['ListItemDescription'],
                                style: TextStyle(
                                  color: const Color(0xFFCCCCCC),
                                  letterSpacing: -0.8,
                                  fontSize: 12.0.r,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
