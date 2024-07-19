import 'package:flutter/material.dart';

class ScrollControllerNotifier extends ChangeNotifier {
  final Set<ScrollController> _controllers = {};

  void addController(ScrollController controller) {
    _controllers.add(controller);
  }

  void removeController(ScrollController controller) {
    _controllers.remove(controller);
  }

  void scrollToTop() {
    for (var controller in _controllers) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
