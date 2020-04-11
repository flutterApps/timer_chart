import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  final double mScrollX;
  ChartPainter({this.mScrollX=0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint selectPointPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..color = Colors.black;

    Path path = new Path();
    path.moveTo(mScrollX+0, 0);
    path.lineTo(mScrollX+20, 20);
    path.lineTo(mScrollX+30, 30);
    path.lineTo(mScrollX+80, 80);
    path.lineTo(mScrollX+100, 150);
    path.close();

    canvas.drawPath(path, selectPointPaint);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return true;
  }
}


class Mode{
  int ts;
  double value;
}