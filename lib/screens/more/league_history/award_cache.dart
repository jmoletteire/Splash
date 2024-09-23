import 'package:flutter/material.dart';

class AwardsCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getYear(String season) {
    return _cache[season];
  }

  void addYear(String season, Map<String, dynamic> awardData) {
    _cache[season] = awardData;
    notifyListeners();
  }

  bool containsYear(String season) {
    return _cache.containsKey(season);
  }
}
