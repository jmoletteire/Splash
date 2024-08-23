import 'package:flutter/material.dart';

import 'cap_sheet_table.dart';

class TeamCapSheet extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamCapSheet({super.key, required this.team});

  @override
  State<TeamCapSheet> createState() => _TeamCapSheetState();
}

class _TeamCapSheetState extends State<TeamCapSheet> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CapSheet(
          team: widget.team['CAP_SHEET'],
        ),
      ],
    );
  }
}
