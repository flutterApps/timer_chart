import 'package:flutter/material.dart';
import 'package:flutterapp/chart/base_chart_painter.dart';
import 'package:flutterapp/chart/period_entity.dart';

class ChartPainter extends BaseChartPainter {
  static get minScrollX => BaseChartPainter.minScrollX;
  static get maxScrollX => BaseChartPainter.maxScrollX;
  static get currIndex => BaseChartPainter.currIndex;
  List<Color> bgColor;

  ChartPainter({
    datas,
    scrollX = 0.0,
    rightWidth = 60.0,
    bottomHeight = 30.0,
    leftRatio = 0.1,
    initIndex = 0,
    this.bgColor,
  }) : super(
          datas: datas,
          scrollX: scrollX,
          rightWidth: rightWidth,
          bottomHeight: bottomHeight,
          leftRatio: leftRatio,
          initIndex: initIndex,
        );

  @override
  void drawBg(Canvas canvas, Size size) {

    print('---------------------drawBg-------------------');

    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: bgColor ?? [Color(0xFFDDDDDD), Color(0xFFEEEEEE)],
    );

    Rect dateRect = Rect.fromLTRB(0, 0, size.width, size.height - bottomHeight);
    canvas.drawRect(dateRect, mBgPaint..shader = mBgGradient.createShader(dateRect));
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    Paint selectPointPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..color = Colors.black;

    Path path = new Path();
    path.moveTo(scrollX + 0, 0);
    path.lineTo(scrollX + 20, 20);
    path.lineTo(scrollX + 30, 30);
    path.lineTo(scrollX + 80, 80);
    path.lineTo(scrollX + 100, 150);
    path.close();

    canvas.drawPath(path, selectPointPaint);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    // TODO: implement drawDate
  }

  @override
  void drawGrid(canvas) {
    // TODO: implement drawGrid
  }

  @override
  void drawRightText(canvas) {
    // TODO: implement drawRightText
  }

  @override
  void initChartRenderer() {
    // TODO: implement initChartRenderer
  }
}
