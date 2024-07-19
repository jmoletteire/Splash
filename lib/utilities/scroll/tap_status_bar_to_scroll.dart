import 'package:flutter/material.dart';

import 'scroll_controller_notifier.dart';
import 'scroll_controller_provider.dart';

class TapStatusBarToScroll extends StatelessWidget {
  final Widget child;

  TapStatusBarToScroll({required this.child});

  @override
  Widget build(BuildContext context) {
    final ScrollControllerNotifier notifier = ScrollControllerNotifier();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        if (details.globalPosition.dy < MediaQuery.of(context).padding.top + kToolbarHeight) {
          notifier.scrollToTop();
        }
      },
      child: ScrollControllerProvider(
        notifier: notifier,
        child: child,
      ),
    );
  }
}
