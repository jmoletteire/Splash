import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  CustomIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
    this.label,
  });

  final IconData icon;
  final Color? color;
  final double? size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color ?? Colors.white,
      size: size ?? 32.0,
      semanticLabel: label ?? 'Icon',
    );
  }
}
