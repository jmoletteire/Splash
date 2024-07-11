import 'package:flutter/material.dart';
import 'package:splash/components/custom_icon.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {super.key,
      required this.icon,
      this.color,
      this.size,
      this.label,
      required this.onPressed});

  final IconData icon;
  final Color? color;
  final double? size;
  final String? label;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(15.0),
      icon: CustomIcon(
        icon: icon,
        color: color,
        size: size,
        label: label,
      ),
      onPressed: onPressed,
    );
  }
}
