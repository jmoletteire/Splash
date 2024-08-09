import 'package:flutter/cupertino.dart';

class ExpandableCardController {
  final ValueNotifier<bool> isExpandedNotifier;

  ExpandableCardController(bool initialIsExpanded)
      : isExpandedNotifier = ValueNotifier<bool>(initialIsExpanded);

  void toggle() {
    isExpandedNotifier.value = !isExpandedNotifier.value;
  }
}
