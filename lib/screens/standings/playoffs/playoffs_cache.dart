import 'package:flutter/material.dart';

class PlayoffCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getPlayoffs(String season) {
    return _cache[season];
  }

  void addPlayoffs(String season, Map<String, dynamic> playoffData) {
    _cache[season] = playoffData;
    notifyListeners();
  }

  bool containsPlayoffs(String season) {
    return _cache.containsKey(season);
  }
}
