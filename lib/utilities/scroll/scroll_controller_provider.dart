import 'package:flutter/material.dart';

import 'scroll_controller_notifier.dart';

class ScrollControllerProvider extends InheritedNotifier<ScrollControllerNotifier> {
  final ScrollControllerNotifier notifier;

  ScrollControllerProvider({
    Key? key,
    required this.notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static ScrollControllerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScrollControllerProvider>();
  }
}
