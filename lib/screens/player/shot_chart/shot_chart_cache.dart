import 'package:flutter/material.dart';

class PlayerShotChartCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getPlayer(String playerId) {
    return _cache[playerId];
  }

  void addPlayer(String playerId, Map<String, dynamic> playerData) {
    _cache[playerId] = playerData;
    notifyListeners();
  }

  bool containsPlayer(String playerId, String season, String seasonType) {
    if (_cache.containsKey(playerId)) {
      if (_cache[playerId]!.containsKey(season)) {
        if (_cache[playerId]![season].containsKey(seasonType)) {
          return true;
        }
      }
    }
    return false;
  }
}
