import 'package:flutter/material.dart';

import 'scroll_controller_notifier.dart';
import 'scroll_controller_provider.dart';

class TapStatusBarToScroll extends StatelessWidget {
  final Widget child;

  const TapStatusBarToScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ScrollControllerNotifier notifier = ScrollControllerNotifier();

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) {
            if (details.globalPosition.dy <= MediaQuery.of(context).padding.top + 20) {
              notifier.scrollToTop();
            }
          },
          child: ScrollControllerProvider(
            notifier: notifier,
            child: child,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).padding.top,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              notifier.scrollToTop();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
