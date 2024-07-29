import 'package:flutter/material.dart';

class DraftCache extends ChangeNotifier {
  final Map<String, List<dynamic>> _cache = {};

  List? getDraft(String draftYear) {
    return _cache[draftYear];
  }

  void addDraft(String draftYear, List<dynamic> draftData) {
    _cache[draftYear] = draftData;
    notifyListeners();
  }

  bool containsDraft(String draftYear) {
    return _cache.containsKey(draftYear);
  }
}
