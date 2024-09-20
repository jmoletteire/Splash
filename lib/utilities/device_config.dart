import 'package:flutter/material.dart';

class DeviceConfig {
  static double? deviceWidth;
  static double? deviceHeight;

  static void init(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
  }
}
