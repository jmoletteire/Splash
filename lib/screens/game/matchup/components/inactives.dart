import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

class Inactives extends StatefulWidget {
  final Map<String, dynamic> inactivePlayers;
  final String homeAbbr;
  final String awayAbbr;

  const Inactives({
    super.key,
    required this.inactivePlayers,
    required this.homeAbbr,
    required this.awayAbbr,
  });

  @override
  State<Inactives> createState() => _InactivesState();
}

class _InactivesState extends State<Inactives> {
  @override
  Widget build(BuildContext context) {
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
                Text(
                    widget.inactivePlayers['away'].isEmpty
                        ? 'None'
                        : widget.inactivePlayers['away'],
                    style: kBebasNormal.copyWith(fontSize: 14.0.r))
              ],
            ),
            SizedBox(height: 8.0.r),
            Wrap(
              children: [
                Text('${widget.homeAbbr}:', style: kBebasBold.copyWith(fontSize: 14.0.r)),
                SizedBox(width: 5.0.r),
                Text(
                    widget.inactivePlayers['home'].isEmpty
                        ? 'None'
                        : widget.inactivePlayers['home'],
                    style: kBebasNormal.copyWith(fontSize: 14.0.r))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
