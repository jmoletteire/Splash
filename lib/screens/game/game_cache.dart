import 'package:flutter/material.dart';

class GameCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getGame(String gameId) {
    return _cache[gameId];
  }

  void addGame(String gameId, Map<String, dynamic> gameData) {
    if (_cache.length >= 5) {
      // Remove the oldest entry when the cache exceeds 5 entries
      String oldestGameId = _cache.keys.first;
      _cache.remove(oldestGameId);
    }
    _cache[gameId] = gameData;
    notifyListeners();
  }

  bool containsGame(String gameId) {
    return _cache.containsKey(gameId);
  }
}
