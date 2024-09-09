import 'package:flutter/material.dart';

class ScrollControllerNotifier extends ChangeNotifier {
  final Set<ScrollController> _controllers = {};
  ScrollController? _currentController;

  void addController(ScrollController controller) {
    _controllers.add(controller);
  }

  void removeController(ScrollController controller) {
    _controllers.remove(controller);
    if (_currentController == controller) {
      _currentController = null;
    }
  }

  void setCurrentController(ScrollController controller) {
    _currentController = controller;
  }

  void scrollToTop() {
    if (_currentController != null) {
      _currentController!.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
