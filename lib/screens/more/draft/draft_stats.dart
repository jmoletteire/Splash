import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

class DraftStats extends StatefulWidget {
  final Map<String, int> draftStats;
  const DraftStats({super.key, required this.draftStats});

  @override
  State<DraftStats> createState() => _DraftStatsState();
}

class _DraftStatsState extends State<DraftStats> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Players', style: kBebasNormal.copyWith(fontSize: 18.0.r)),
            Text(':  ${widget.draftStats['TOTAL']}',
                style: kBebasNormal.copyWith(fontSize: 18.0.r))
          ],
        ),
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hall of Famers',
                style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.deepOrange)),
            Text(':  ${widget.draftStats['HOF']}',
                style: kBebasNormal.copyWith(fontSize: 18.0.r)),
            Text(
                '  (${(100 * widget.draftStats['HOF']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal.copyWith(fontSize: 18.0.r))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MVPs',
                style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.yellow.shade800)),
            Text(':  ${widget.draftStats['MVP']}',
                style: kBebasNormal.copyWith(fontSize: 18.0.r)),
            Text(
                '  (${(100 * widget.draftStats['MVP']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal.copyWith(fontSize: 18.0.r))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('All-NBA Selections',
                style:
                    kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.blueGrey.shade200)),
            Text(':  ${widget.draftStats['ALL_NBA']}',
                style: kBebasNormal.copyWith(fontSize: 18.0.r)),
            Text(
                '  (${(100 * widget.draftStats['ALL_NBA']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal.copyWith(fontSize: 18.0.r))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('All-Star Selections',
                style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.blueGrey)),
            Text(':  ${widget.draftStats['ALL_STAR']}',
                style: kBebasNormal.copyWith(fontSize: 18.0.r)),
            Text(
                '  (${(100 * widget.draftStats['ALL_STAR']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal.copyWith(fontSize: 18.0.r))
          ],
        ),
        if (widget.draftStats.containsKey('ROTY'))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rookie of the Year', style: kBebasNormal.copyWith(fontSize: 18.0.r)),
              Text(':  ${widget.draftStats['ROTY']}',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r)),
              Text(
                  '  (${(100 * widget.draftStats['ROTY']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r))
            ],
          ),
      ],
    );
  }
}
