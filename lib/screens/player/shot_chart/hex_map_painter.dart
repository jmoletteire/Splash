import 'dart:math';

import 'package:flutter/material.dart';

class HexMapPainter extends CustomPainter {
  final List<HexagonData> hexagons;

  HexMapPainter({required this.hexagons});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    for (var hex in hexagons) {
      paint.color = hex.color;
      _drawHexagon(canvas, paint, hex.x, hex.y, hex.size);
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, double x, double y, double size) {
    var path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i;
      double x_i = x + size * cos(angle);
      double y_i = y + size * sin(angle);
      if (i == 0) {
        path.moveTo(x_i, y_i);
      } else {
        path.lineTo(x_i, y_i);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HexagonData {
  final double x;
  final double y;
  final double size;
  final Color color;

  HexagonData({required this.x, required this.y, required this.size, required this.color});
}
