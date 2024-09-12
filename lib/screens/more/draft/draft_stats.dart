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
            Text('Hall of Famers', style: kBebasNormal.copyWith(color: Colors.deepOrange)),
            Text(': ${widget.draftStats['HOF']}', style: kBebasNormal)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MVPs', style: kBebasNormal.copyWith(color: Colors.yellow.shade800)),
            Text(': ${widget.draftStats['MVP']}', style: kBebasNormal)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('All-NBA Selections',
                style: kBebasNormal.copyWith(color: Colors.blueGrey.shade200)),
            Text(': ${widget.draftStats['ALL_NBA']}', style: kBebasNormal)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('All-Star Selections', style: kBebasNormal.copyWith(color: Colors.blueGrey)),
            Text(': ${widget.draftStats['ALL_STAR']}', style: kBebasNormal)
          ],
        ),
      ],
    );
  }
}
