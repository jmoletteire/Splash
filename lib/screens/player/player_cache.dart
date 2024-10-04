import 'package:flutter/material.dart';

class PlayerCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getPlayer(String playerId) {
    return _cache[playerId];
  }

  void addPlayer(String playerId, Map<String, dynamic> playerData) {
    if (_cache.length >= 5) {
      // Remove the oldest entry when the cache exceeds 5 entries
      String oldestPlayerId = _cache.keys.first;
      _cache.remove(oldestPlayerId);
    }
    _cache[playerId] = playerData;
    notifyListeners();
  }

  bool containsPlayer(String playerId) {
    return _cache.containsKey(playerId);
  }
}
