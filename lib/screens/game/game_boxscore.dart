import 'package:flutter/material.dart';

class GameBoxScore extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const GameBoxScore(
      {super.key, required this.game, required this.homeId, required this.awayId});

  @override
  State<GameBoxScore> createState() => _GameBoxScoreState();
}

class _GameBoxScoreState extends State<GameBoxScore> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
