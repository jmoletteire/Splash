import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

class Inactives extends StatefulWidget {
  final List<dynamic> inactivePlayers;
  final String homeId;
  final String awayId;
  final String homeAbbr;
  final String awayAbbr;

  const Inactives({
    super.key,
    required this.inactivePlayers,
    required this.homeId,
    required this.awayId,
    required this.homeAbbr,
    required this.awayAbbr,
  });

  @override
  State<Inactives> createState() => _InactivesState();
}

class _InactivesState extends State<Inactives> {
  List<String> homeInactive = [];
  List<String> awayInactive = [];
  late Widget inactiveCard;

  @override
  void initState() {
    super.initState();
    for (var player in widget.inactivePlayers) {
      if (player['TEAM_ID'].toString() == widget.homeId) {
        homeInactive.add('${player['FIRST_NAME']} ${player['LAST_NAME']}');
      } else {
        awayInactive.add('${player['FIRST_NAME']} ${player['LAST_NAME']}');
      }
    }

    inactiveCard = _buildInactiveCard();
  }

  Widget _buildInactiveCard() {
    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
      color: Colors.grey.shade900,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
                ),
              ),
              child: Text(
                'INACTIVE',
                style: kBebasBold.copyWith(fontSize: 16.0.r),
              ),
            ),
            SizedBox(height: 8.0.r),
            Wrap(
              children: [
                Text('${widget.awayAbbr}:', style: kBebasBold.copyWith(fontSize: 14.0.r)),
                SizedBox(width: 5.0.r),
                ...List.generate(awayInactive.length, (index) {
                  return Text(
                    index != awayInactive.length - 1
                        ? '${awayInactive[index]}, '
                        : awayInactive[index],
                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                  );
                }),
                if (awayInactive.isEmpty)
                  Text('None', style: kBebasNormal.copyWith(fontSize: 14.0.r))
              ],
            ),
            SizedBox(height: 8.0.r),
            Wrap(
              children: [
                Text('${widget.homeAbbr}:', style: kBebasBold.copyWith(fontSize: 14.0.r)),
                SizedBox(width: 5.0.r),
                ...List.generate(homeInactive.length, (index) {
                  return Text(
                    index != homeInactive.length - 1
                        ? '${homeInactive[index]}, '
                        : homeInactive[index],
                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                  );
                }),
                if (homeInactive.isEmpty)
                  Text('None', style: kBebasNormal.copyWith(fontSize: 14.0.r))
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return inactiveCard;
  }
}
