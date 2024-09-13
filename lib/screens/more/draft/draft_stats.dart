import 'package:flutter/material.dart';
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
            const Text('Players', style: kBebasNormal),
            Text(':  ${widget.draftStats['TOTAL']}', style: kBebasNormal)
          ],
        ),
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hall of Famers', style: kBebasNormal.copyWith(color: Colors.deepOrange)),
            Text(':  ${widget.draftStats['HOF']}', style: kBebasNormal),
            Text(
                '  (${(100 * widget.draftStats['HOF']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MVPs', style: kBebasNormal.copyWith(color: Colors.yellow.shade800)),
            Text(':  ${widget.draftStats['MVP']}', style: kBebasNormal),
            Text(
                '  (${(100 * widget.draftStats['MVP']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('All-NBA Selections',
                style: kBebasNormal.copyWith(color: Colors.blueGrey.shade200)),
            Text(':  ${widget.draftStats['ALL_NBA']}', style: kBebasNormal),
            Text(
                '  (${(100 * widget.draftStats['ALL_NBA']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('All-Star Selections', style: kBebasNormal.copyWith(color: Colors.blueGrey)),
            Text(':  ${widget.draftStats['ALL_STAR']}', style: kBebasNormal),
            Text(
                '  (${(100 * widget.draftStats['ALL_STAR']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                style: kBebasNormal)
          ],
        ),
        if (widget.draftStats.containsKey('ROTY'))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Rookie of the Year', style: kBebasNormal),
              Text(':  ${widget.draftStats['ROTY']}', style: kBebasNormal),
              Text(
                  '  (${(100 * widget.draftStats['ROTY']! / widget.draftStats['TOTAL']!).toStringAsFixed(1)}%)',
                  style: kBebasNormal)
            ],
          ),
      ],
    );
  }
}
