import 'package:flutter/material.dart';

class ScrollControllerNotifier extends ChangeNotifier {
  final Map<String, ScrollController> _controllers = {};

  void addController(String key, ScrollController controller) {
    _controllers[key] = controller;
  }

  void removeController(String key) {
    _controllers.remove(key);
  }

  void scrollToTop() {
    for (var key in _controllers.keys) {
      _controllers[key]?.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
