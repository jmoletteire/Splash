import 'package:flutter/material.dart';

class PlayerContract extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerContract({super.key, required this.team, required this.player});

  @override
  State<PlayerContract> createState() => _PlayerContractState();
}

class _PlayerContractState extends State<PlayerContract> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
