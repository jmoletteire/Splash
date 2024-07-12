import 'dart:math';

import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

class PolarAreaChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;
  final double maxPossibleValue;
  final Animation<double> animationValue; // Add animation value

  PolarAreaChartPainter({
    required this.values,
    required this.colors,
    required this.labels,
    required this.maxPossibleValue,
    required this.animationValue,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double maxRadius = min(centerX, centerY);
    final double maxChartRadius =
        (maxPossibleValue / maxPossibleValue) * maxRadius;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    final Paint sliceBorderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint outerBorderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3; // Adjust the thickness as needed

    final int numberOfSegments = values.length;
    final double anglePerSegment = 2 * pi / numberOfSegments;

    for (int i = 0; i < numberOfSegments; i++) {
      final double animatedRadius =
          (values[i] / maxPossibleValue) * maxRadius * animationValue.value;
      final Path path = Path()
        ..moveTo(centerX, centerY)
        ..lineTo(
          centerX + animatedRadius * cos(i * anglePerSegment),
          centerY + animatedRadius * sin(i * anglePerSegment),
        )
        ..arcToPoint(
          Offset(
            centerX + animatedRadius * cos((i + 1) * anglePerSegment),
            centerY + animatedRadius * sin((i + 1) * anglePerSegment),
          ),
          radius: Radius.circular(animatedRadius),
        )
        ..close();

      paint.color = colors[i];
      canvas.drawPath(path, paint);
    }

    // Draw the outer circular border
    canvas.drawCircle(
        Offset(centerX, centerY), maxChartRadius, outerBorderPaint);

    // Draw the borders from center to circumference
    for (int i = 0; i < numberOfSegments; i++) {
      final double angle = i * anglePerSegment;
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(
          centerX + maxChartRadius * cos(angle),
          centerY + maxChartRadius * sin(angle),
        ),
        sliceBorderPaint,
      );
    }

    // Draw the smaller circles
    final Paint smallCirclePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5; // Adjust the thickness as needed

    final double radius1 = maxChartRadius / 3;
    final double radius2 = 2 * maxChartRadius / 3;

    canvas.drawCircle(Offset(centerX, centerY), radius1, smallCirclePaint);
    canvas.drawCircle(Offset(centerX, centerY), radius2, smallCirclePaint);

    // Draw the labels and values
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < numberOfSegments; i++) {
      final double angle = i * anglePerSegment + anglePerSegment / 2;
      final Offset labelOffset = Offset(
        centerX +
            (maxChartRadius + 40) *
                cos(angle), // Position label further outside the chart area
        centerY + (maxChartRadius + 40) * sin(angle),
      );

      // Draw the label
      textPainter.text = TextSpan(
        text: labels[i],
        style: kBebasBold.copyWith(fontSize: 17.0),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - textPainter.width / 2,
          labelOffset.dy -
              textPainter.height / 2 -
              10, // Adjust the vertical position for value
        ),
      );

      // Draw the value below the label
      textPainter.text = TextSpan(
        text: '${(values[i] * 100).toStringAsFixed(0)}%',
        style: kBebasBold.copyWith(fontSize: 16.0, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - textPainter.width / 2,
          labelOffset.dy -
              textPainter.height / 2 +
              10, // Adjust the vertical position for value
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
