import 'package:flutter/material.dart';
import 'package:flutterapp/chart/entity/period_entity.dart';
import 'package:flutterapp/chart/entity/ts_entity.dart';

import 'utils/date_format_util.dart';


class BaseChartPainter extends CustomPainter {
  static double minScrollX = 0.0;
  static double maxScrollX = 0.0;
  static int currIndex = 0;
  List<PeriodEntity> datas;
  double scrollX;
  double rightWidth;
  double bottomHeight;
  double leftRatio;
  int initIndex;

  //3块区域大小与位置
  Rect mMainRect, mVolRect, mSecondaryRect;
  double mDisplayHeight, mWidth;
  double mTopPadding = 30.0, mBottomPadding = 20.0, mChildPadding = 12.0;
  final int mGridRows = 4, mGridColumns = 4;
  int mStartIndex = 0, mStopIndex = 0;
  double mMainMaxValue = double.minPositive, mMainMinValue = double.maxFinite;
  double mVolMaxValue = double.minPositive, mVolMinValue = double.maxFinite;
  double mSecondaryMaxValue = double.minPositive, mSecondaryMinValue = double.maxFinite;
  double mTranslateX = double.minPositive;
  int mMainMaxIndex = 0, mMainMinIndex = 0;
  double mMainHighMaxValue = double.minPositive, mMainLowMinValue = double.maxFinite;
  int mItemCount = 0;
  double mDataLen = 0.0; //数据占屏幕总长度

  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]; //格式化时间

  BaseChartPainter({
    this.datas,
    this.scrollX,
    this.rightWidth,
    this.bottomHeight,
    this.leftRatio,
    this.initIndex,
  }) : assert(leftRatio < 1 && leftRatio > 0);

  double leftWidth;
  double offsetWidth;
  double scrollWidth; // 每屏滚动宽度
  double mPointWidth; // 每价格点宽度
  List<TsEntity> tss;

  @override
  void paint(Canvas canvas, Size size) {
    scrollWidth = (size.width - rightWidth) / (1 + leftRatio);
    leftWidth = (size.width - rightWidth) - scrollWidth;
    mDisplayHeight = size.height - mTopPadding - mBottomPadding;
    mWidth = size.width;

    initRect(size);
    calculateValue();

    canvas.save();
    drawBg(canvas, size);
    drawGrid(canvas);
    if (datas != null && datas.isNotEmpty) {
      drawChart(canvas, size);
      drawRightText(canvas);
      drawDate(canvas, size);
    }
    canvas.restore();
  }


  void initRect(Size size) {
    mMainRect = Rect.fromLTRB(0, 0, mWidth, size.height - bottomHeight);
  }

  calculateValue() {
    if (datas == null || datas.isEmpty) return;
    if (initIndex == 0) {
      initIndex = currIndex = datas.length - 1;
    }

    maxScrollX = initIndex * scrollWidth;
    minScrollX = (initIndex - (datas.length - 1)) * scrollWidth;

    //周期数量长度
    var periodLen = datas.last.closeTime - datas.last.openTime;
    mPointWidth = scrollWidth / periodLen;

    var num = ((scrollX + leftWidth) ~/ scrollWidth).abs();
    offsetWidth = (scrollX + leftWidth - scrollWidth * num).abs();

    if (scrollX > 0) {
      currIndex = initIndex - num;
    } else {
      currIndex = initIndex + num;
    }

    var maxOffset = (initIndex - currIndex + 1) * scrollWidth;
    var minOffset = (initIndex - currIndex - 1) * scrollWidth;

    List<TsEntity> tempTss = [];
    if (currIndex - 1 >= 0 && currIndex - 1 < datas.length) {
      var leftIndex = (periodLen * (1 - offsetWidth / scrollWidth)).toInt();
      if (leftIndex > 0) {
        var leftTss = datas[currIndex - 1].tss?.sublist(leftIndex);
        if (leftTss != null) {
          tempTss.addAll(leftTss);
        }
      }
    }
    if (currIndex >= 0 && currIndex < datas.length && offsetWidth <= leftWidth) {
      var middleTss = datas[currIndex].tss;
      if (middleTss != null) {
        tempTss.addAll(middleTss);
      }
    }
    if (currIndex + 1 >= 0 && currIndex + 1 < datas.length) {
      var rightIndex = (periodLen * (offsetWidth / scrollWidth)).toInt();
      var rightTss = datas[currIndex + 1].tss?.sublist(0, rightIndex);
      if (rightTss != null) {
        tempTss.addAll(rightTss);
      }
    }
    tss = tempTss;

    print('currIndex---$currIndex-------${tempTss?.length}-------${tempTss.toString()}---------');
  }



  //画背景
  void drawBg(Canvas canvas, Size size) {}

  //画网格
  void drawGrid(canvas) {
    Paint gridPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 0.5
      ..color = Color(0xff4c5c74);
    double rowSpace = mMainRect.height / mGridRows;
    for (int i = 0; i <= mGridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i), Offset(mMainRect.width, rowSpace * i), gridPaint);
    }
    double columnSpace = mMainRect.width / mGridRows;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
          Offset(columnSpace * i, 0), Offset(columnSpace * i, mMainRect.bottom), gridPaint);
    }
  }

  //画图表
  void drawChart(Canvas canvas, Size size) {}

  //画右边值
  void drawRightText(canvas) {}

  //画时间
  void drawDate(Canvas canvas, Size size) {}


  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
  }
}
