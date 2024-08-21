import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splash/screens/player/profile/player_awards.dart';
import 'package:splash/screens/player/profile/player_contract.dart';
import 'package:splash/utilities/constants.dart';

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
    var key =
        widget.team['TEAM_ID'] == 0 ? 'Last Played' : convertDate(widget.player['BIRTHDATE']);
    var value = widget.team['TEAM_ID'] == 0
        ? widget.player['TO_YEAR'].toString()
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
                'Measure': '$heightFinal | ${widget.player['WEIGHT']} lb',
                'Experience': widget.player['SEASON_EXP'] == 0
                    ? 'Rookie'
                    : widget.player['SEASON_EXP'].toString(),
                key: value, // Last Played or Age/DOB
                'Prev. Affiliate': widget.player['SCHOOL'],
                'Draft': (widget.player['DRAFT_YEAR'] == 'Undrafted' ||
                        widget.player['DRAFT_ROUND'] == null ||
                        widget.player['DRAFT_ROUND'] == '0')
                    ? (widget.player['DRAFT_YEAR'] == 'Undrafted' ||
                            widget.player['DRAFT_YEAR'] == null)
                        ? 'UDFA (${widget.player['FROM_YEAR']})'
                        : 'UDFA (${widget.player['DRAFT_YEAR']})'
                    : 'R${widget.player['DRAFT_ROUND']}:${widget.player['DRAFT_NUMBER']} (${widget.player['DRAFT_YEAR']})',
                'Country': widget.player['COUNTRY'],
              },
            ),
            PlayerAwards(
              playerAwards: widget.player['AWARDS'],
            ),
            PlayerContract(
              playerContract: widget.player['CONTRACTS'][0],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final Map<String, String> info;

  const InfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, String>> entries = info.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
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
                          style: kBebasNormal.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
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
                                style: kBebasNormal.copyWith(fontSize: 18),
                              ),
                            ),
                            if (entry.key == 'Country') const SizedBox(width: 5.0),
                            if (entry.key == 'Country')
                              CircleAvatar(
                                radius: 8.0,
                                backgroundImage: AssetImage(
                                    'images/flags/${kCountryCodes[entry.value]?.toLowerCase()}.png'),
                              )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
