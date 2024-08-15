import 'dart:math';

import 'package:flutter/material.dart';

import 'hex_aggregator.dart';

class HexMapPainter extends CustomPainter {
  final List<HexagonData> hexagons;

  HexMapPainter({required this.hexagons});

  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.transparent // Set the border color
      ..strokeWidth = 1.0; // Adjust the stroke width as needed

    for (var hex in hexagons) {
      if (hex.color != Colors.transparent) {
        fillPaint.color = hex.color.withOpacity(hex.opacity);
        _drawHexagon(canvas, fillPaint, borderPaint, hex.x, hex.y, hex.width, hex.height);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint fillPaint, Paint borderPaint, double x, double y,
      double width, double height) {
    var path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i;
      double x_i = x + width * cos(angle);
      double y_i = y + height * sin(angle);
      if (i == 0) {
        path.moveTo(x_i, y_i);
      } else {
        path.lineTo(x_i, y_i);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint); // Draw the filled hexagon
    canvas.drawPath(path, borderPaint); // Draw the border around the hexagon
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
