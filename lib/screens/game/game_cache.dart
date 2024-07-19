import 'package:flutter/material.dart';

class GameCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getGame(String gameId) {
    return _cache[gameId];
  }

  void addGame(String gameId, Map<String, dynamic> gameData) {
    _cache[gameId] = gameData;
    notifyListeners();
  }

  bool containsGame(String gameId) {
    return _cache.containsKey(gameId);
  }
}
