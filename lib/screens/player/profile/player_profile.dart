import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            if (widget.player.containsKey('PlayerRotowires'))
              if (widget.player['PlayerRotowires'][0]['Injured'] == 'YES')
                InjuryCard(injuryDetails: widget.player['PlayerRotowires'][0]),
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

class InjuryCard extends StatelessWidget {
  final Map<String, dynamic> injuryDetails;
  const InjuryCard({super.key, required this.injuryDetails});

  Color getColor(String status) {
    if (status == 'OUT') {
      return Colors.redAccent;
    } else if (status == 'GTD' || status == 'DTD') {
      return Colors.orangeAccent;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(15.0),
      margin: EdgeInsets.only(top: 11.0.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
                  ),
                ),
                child: Text(
                  'Injured',
                  style: kBebasBold.copyWith(fontSize: 18.0.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0.r),
          Row(
            children: [
              Text(
                injuryDetails['Injured_Status'],
                style: kBebasNormal.copyWith(
                    fontSize: 16.0.r, color: getColor(injuryDetails['Injured_Status'])),
              ),
              Text(
                ' - ${injuryDetails['Injury_Side']} ${injuryDetails['Injury_Type']}',
                style: kBebasNormal.copyWith(fontSize: 16.0.r),
              ),
              if (injuryDetails['Injury_Detail'] != '')
                Text(
                  ' (${injuryDetails['Injury_Detail']})',
                  style: kBebasNormal.copyWith(fontSize: 16.0.r),
                ),
            ],
          )
        ],
      ),
    );
  }
}
