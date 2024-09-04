import 'package:flutter/material.dart';

class NbaCupCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getNbaCup(String season) {
    return _cache[season];
  }

  void addNbaCup(String season, Map<String, dynamic> nbaCupData) {
    _cache[season] = nbaCupData;
    notifyListeners();
  }

  bool containsNbaCup(String season) {
    return _cache.containsKey(season);
  }
}
