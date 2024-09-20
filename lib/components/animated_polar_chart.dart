import 'package:flutter/material.dart';
import 'package:splash/components/polar_area_painter.dart';

class AnimatedPolarAreaChart extends StatefulWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;
  final double maxPossibleValue;
  final double chartSize;
  final String selectedSeasonType;

  AnimatedPolarAreaChart({
    required Key key,
    required this.values,
    required this.colors,
    required this.labels,
    required this.maxPossibleValue,
    required this.chartSize,
    required this.selectedSeasonType,
  }) : super(key: key);

  @override
  _AnimatedPolarAreaChartState createState() => _AnimatedPolarAreaChartState();
}

class _AnimatedPolarAreaChartState extends State<AnimatedPolarAreaChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(covariant AnimatedPolarAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSeasonType != widget.selectedSeasonType) {
      _updateAnimations(oldWidget.values, widget.values);
      _controller.forward(from: 0);
    } else if (oldWidget.key != widget.key) {
      _controller.reset();
      _controller.forward();
    }
  }

  void _initializeAnimations() {
    _animations = List<Animation<double>>.generate(
      widget.values.length,
      (index) => Tween<double>(
        begin: widget.values[index],
        end: widget.values[index],
      ).animate(_controller),
    );
  }

  void _updateAnimations(List<double> oldValues, List<double> newValues) {
    for (int i = 0; i < _animations.length; i++) {
      _animations[i] = Tween<double>(
        begin: oldValues[i],
        end: newValues[i],
      ).animate(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.chartSize, widget.chartSize),
          painter: PolarAreaChartPainter(
            values: _animations.map((anim) => anim.value).toList(),
            colors: widget.colors,
            labels: widget.labels,
            maxPossibleValue: widget.maxPossibleValue,
            animationValue: _controller, // Pass the animation controller
          ),
        );
      },
    );
  }
}
