import 'package:flutter/material.dart';

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
        Text('Hall of Famers: ${widget.draftStats['HOF']}'),
        Text('MVPs: ${widget.draftStats['MVP']}'),
        Text('All-NBA Selections: ${widget.draftStats['ALL_NBA']}'),
        Text('All-Star Selections: ${widget.draftStats['ALL_STAR']}'),
      ],
    );
  }
}
