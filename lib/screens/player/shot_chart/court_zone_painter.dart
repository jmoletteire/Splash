import 'package:flutter/material.dart';

class ZonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final zonePaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final restrictedAreaRadius = size.width * (4 / 50);
    final threePointLineRadius = size.height * (23.75 / 47);
    final keyWidth = size.width * (12 / 50);
    final outerKeyWidth = size.width * (16 / 50);
    final freeThrowLine = size.height * (18.87 / 47);

    // AB3 LEFT
    Path aboveBreakThreeLeft = Path();
    aboveBreakThreeLeft.moveTo(0, 0);
    aboveBreakThreeLeft.lineTo(size.width / 3, 0);
    aboveBreakThreeLeft.lineTo(size.width / 3, size.height - size.height * (27.25 / 47));
    aboveBreakThreeLeft.arcToPoint(
      Offset(size.width * (3 / 50), size.height - size.height * (14 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: false,
    );
    aboveBreakThreeLeft.lineTo(0, size.height - size.height * (14 / 47));
    canvas.drawPath(aboveBreakThreeLeft, zonePaint);

    // AB3 RIGHT
    Path aboveBreakThreeRight = Path();
    aboveBreakThreeRight.moveTo(size.width, 0);
    aboveBreakThreeRight.lineTo(size.width - size.width / 3, 0);
    aboveBreakThreeRight.lineTo(
        size.width - size.width / 3, size.height - size.height * (27.25 / 47));
    aboveBreakThreeRight.arcToPoint(
      Offset(size.width - size.width * (3 / 50), size.height - size.height * (14 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: true,
    );
    aboveBreakThreeRight.lineTo(size.width, size.height - size.height * (14 / 47));

    canvas.drawPath(aboveBreakThreeRight, zonePaint);

    // AB3 CENTER
    Path aboveBreakThreeCenter = Path();
    aboveBreakThreeCenter.moveTo(size.width / 3, 0);
    aboveBreakThreeCenter.lineTo(size.width - size.width / 3, 0);
    aboveBreakThreeCenter.lineTo(
        size.width - size.width / 3, size.height - size.height * (27.25 / 47));
    aboveBreakThreeCenter.arcToPoint(
      Offset(size.width / 3, size.height - size.height * (27.25 / 47)),
      radius: Radius.circular(threePointLineRadius),
      clockwise: false,
    );

    canvas.drawPath(aboveBreakThreeCenter, zonePaint);

    // C3 LEFT
    Path cornerThreeLeft = Path();
    cornerThreeLeft.addRect(Rect.fromLTWH(
      0,
      size.height - size.height * (14 / 47),
      size.width * (3 / 50),
      size.height * (14 / 47),
    ));
    canvas.drawPath(cornerThreeLeft, zonePaint);

    // C3 RIGHT
    Path cornerThreeRight = Path();
    cornerThreeRight.addRect(Rect.fromLTWH(
      size.width - (size.width * 3 / 50),
      size.height - size.height * (14 / 47),
      size.width * (3 / 50),
      size.height * (14 / 47),
    ));
    canvas.drawPath(cornerThreeRight, zonePaint);

    // RESTRICTED AREA
    Path restrictedArea = Path();
    restrictedArea.moveTo((size.width / 2) - (size.width * 7 / 50), size.height);
    restrictedArea.arcToPoint(
      Offset((size.width / 2) + (size.width * 7 / 50), size.height),
      radius: Radius.circular(size.width * (8 / 50)),
      largeArc: true,
    );
    /*
    restrictedArea.addArc(
      Rect.fromCircle(
        center: Offset((size.width / 2), size.height - (size.height * (4 / 47))),
        radius: size.width * (8 / 50),
      ),
      pi,
      -pi,
    );

     */
    canvas.drawPath(restrictedArea, zonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
