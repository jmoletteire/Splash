import 'package:flutter/material.dart';

class TeamLeaders extends StatefulWidget {
  final String season;
  final String homeId;
  final String awayId;
  const TeamLeaders(
      {super.key, required this.season, required this.homeId, required this.awayId});

  @override
  State<TeamLeaders> createState() => _TeamLeadersState();
}

class _TeamLeadersState extends State<TeamLeaders> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(),
    );
  }
}
