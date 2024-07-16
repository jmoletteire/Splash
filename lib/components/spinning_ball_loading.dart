import 'package:flutter/material.dart';

class SpinningIcon extends StatefulWidget {
  final Color? color;
  const SpinningIcon({super.key, this.color});

  @override
  _SpinningIconState createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.sports_basketball,
        color: widget.color ?? Colors.deepOrange,
        size: 48.0,
      ),
    );
  }
}
