import 'package:flutter/material.dart';

class PlayerShotChartCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  List? getPlayer(String playerId, String season, String seasonType) {
    return _cache[playerId]![season][seasonType];
  }

  void addPlayer(String playerId, String season, String seasonType, List shotData) {
    if (_cache.length >= 5) {
      // Remove the oldest entry when the cache exceeds 5 entries
      String oldestEntry = _cache.keys.first;
      _cache.remove(oldestEntry);
    }

    // Check if the playerId exists in the cache
    if (_cache.containsKey(playerId)) {
      // Check if the season exists for this player
      if (_cache[playerId]!.containsKey(season)) {
        // Check if the seasonType exists for this season
        if (_cache[playerId]![season]!.containsKey(seasonType)) {
          // Update the existing seasonType data
          _cache[playerId]![season]![seasonType] = shotData;
        } else {
          // Create a new seasonType entry
          _cache[playerId]![season]![seasonType] = shotData;
        }
      } else {
        // Create a new season entry with the seasonType
        _cache[playerId]![season] = {
          seasonType: shotData,
        };
      }
    } else {
      // If the playerId doesn't exist, create a new entry with season and seasonType
      _cache[playerId] = {
        season: {
          seasonType: shotData,
        }
      };
    }

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
