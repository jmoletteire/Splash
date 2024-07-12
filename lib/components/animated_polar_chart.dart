import 'package:flutter/material.dart';
import 'package:splash/components/polar_area_painter.dart';

class AnimatedPolarAreaChart extends StatefulWidget {
  final Key key;
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;
  final double maxPossibleValue;
  final double chartSize;

  AnimatedPolarAreaChart({
    required this.key,
    required this.values,
    required this.colors,
    required this.labels,
    required this.maxPossibleValue,
    this.chartSize = 200,
  });

  @override
  _AnimatedPolarAreaChartState createState() => _AnimatedPolarAreaChartState();
}

class _AnimatedPolarAreaChartState extends State<AnimatedPolarAreaChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedPolarAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.key != widget.key) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.chartSize, widget.chartSize),
      painter: PolarAreaChartPainter(
        values: widget.values,
        colors: widget.colors,
        labels: widget.labels,
        maxPossibleValue: widget.maxPossibleValue,
        animationValue: _controller, // Pass the animation controller
      ),
    );
  }
}
