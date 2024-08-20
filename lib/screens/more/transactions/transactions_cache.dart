import 'package:flutter/material.dart';

class TransactionsCache extends ChangeNotifier {
  late List _cache = [];

  List? getTransactions() {
    return _cache;
  }

  void addTransactions(List transactionData) {
    _cache = transactionData;
    notifyListeners();
  }

  bool containsTransactions() {
    return _cache.isNotEmpty;
  }
}
