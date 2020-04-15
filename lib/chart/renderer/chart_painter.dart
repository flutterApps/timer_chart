import 'package:flutter/material.dart';

import '../entity/period_entity.dart';
import '../utils/number_util.dart';

import 'base_chart_painter.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';

class ChartPainter extends BaseChartPainter {
  static get minScrollX => BaseChartPainter.minScrollX;
  static get maxScrollX => BaseChartPainter.maxScrollX;
  static get currIndex => BaseChartPainter.currIndex;
  BaseChartRenderer mMainRenderer;
  List<Color> bgColor;

  int fixedLength;
  List<int> maDayList;

  ChartPainter({
    datas,
    scrollX = 0.0,
    isLongPass = false,
    rightWidth = 60.0,
    bottomHeight = 30.0,
    leftRatio = 0.1,
    initIndex = 0,
    this.bgColor,
    this.fixedLength,
    this.maDayList= const [5, 10, 20],
  }) : super(
          datas: datas,
          scrollX: scrollX,
          isLongPress: isLongPass,
          rightWidth: rightWidth,
          bottomHeight: bottomHeight,
          leftRatio: leftRatio,
          initIndex: initIndex,
        );

  @override
  void initChartRenderer() {
    if (fixedLength == null) {
      if (datas == null || datas.isEmpty) {
        fixedLength = 2;
      } else {
        var t = datas[0];
        fixedLength = 2;
      }
    }
    mMainRenderer ??= MainRenderer(
        mMainRect, mMainMaxValue, mMainMinValue, mTopPadding, isLine, fixedLength, maDayList);
  }

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
    canvas.save();

    for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      KLineEntity curPoint = datas[i];
      if (curPoint == null) continue;
      KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
    }


    canvas.restore();
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    // TODO: implement drawDate
  }

  @override
  void drawGrid(canvas) {
    mMainRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
  }

  @override
  void drawRightText(canvas) {
    // TODO: implement drawRightText
  }
}
