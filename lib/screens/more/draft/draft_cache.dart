import 'package:flutter/material.dart';

class DraftCache extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cache = {};

  Map<String, dynamic>? getDraft(String draftYear) {
    return _cache[draftYear];
  }

  void addDraft(String draftYear, Map<String, dynamic> draftData) {
    _cache[draftYear] = draftData;
    notifyListeners();
  }

  bool containsDraft(String draftYear) {
    return _cache.containsKey(draftYear);
  }
}
