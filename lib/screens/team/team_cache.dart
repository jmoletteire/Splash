import 'package:flutter/material.dart';

class TeamCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getTeam(String teamId) {
    return _cache[teamId];
  }

  /*
  void addTeam(String teamId, Map<String, dynamic> teamData) {
    if (_cache.length >= 5) {
      // Remove the oldest entry when the cache exceeds 5 entries
      String oldestTeamId = _cache.keys.first;
      _cache.remove(oldestTeamId);
    }
    _cache[teamId] = teamData;
    notifyListeners();
  }

   */

  void addTeam(String teamId, Map<String, dynamic> teamData) {
    _cache[teamId] = teamData;
    notifyListeners();
  }

  bool containsTeam(String teamId) {
    return _cache.containsKey(teamId);
  }

  // Getter to access the cache
  Map<String, Map<String, dynamic>> get cache => _cache;
}
