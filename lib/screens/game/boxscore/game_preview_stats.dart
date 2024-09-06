import 'package:flutter/material.dart';

class GamePreviewStats extends StatefulWidget {
  final Map<String, dynamic> game;
  final String homeId;
  final String awayId;
  const GamePreviewStats({
    super.key,
    required this.game,
    required this.homeId,
    required this.awayId,
  });

  @override
  State<GamePreviewStats> createState() => _GamePreviewStatsState();
}

class _GamePreviewStatsState extends State<GamePreviewStats> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
