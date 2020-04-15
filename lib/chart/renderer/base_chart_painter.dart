import 'package:flutter/material.dart';
import 'package:flutterapp/chart/period_entity.dart';

abstract class BaseChartPainter extends CustomPainter {
  static double minScrollX = 0.0;
  static double maxScrollX = 0.0;
  static int currIndex = 0;
  List<PeriodEntity> datas;
  double scrollX;
  double rightWidth;
  double bottomHeight;
  double leftRatio;
  int initIndex;

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
  List<TsEntity> leftTss;
  List<TsEntity> middleTss;
  List<TsEntity> rightTss;

  @override
  void paint(Canvas canvas, Size size) {
    scrollWidth = (size.width - rightWidth) / (1 + leftRatio);
    leftWidth = (size.width - rightWidth) - scrollWidth;

    calculateValue();
    //initChartRenderer();

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

  void initChartRenderer();

  //画背景
  void drawBg(Canvas canvas, Size size);

  //画网格
  void drawGrid(canvas);

  //画图表
  void drawChart(Canvas canvas, Size size);

  //画右边值
  void drawRightText(canvas);

  //画时间
  void drawDate(Canvas canvas, Size size);

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

    var maxOffset = (initIndex-currIndex+1)*scrollWidth;
    var minOffset = (initIndex-currIndex-1)*scrollWidth;

    print('---------maxOffset:$maxOffset----------------minOffset:$minOffset---------------');

    var _leftTss,_middleTss,_rightTss;
    if (currIndex - 1 >= 0 && currIndex - 1 < datas.length) {
      final leftIndex = (periodLen * (1 - offsetWidth / scrollWidth)).toInt();
      if(leftIndex>0){
        _leftTss = datas[currIndex - 1].tss.sublist(leftIndex);
      }
    }
    if (currIndex >= 0 && currIndex < datas.length && offsetWidth <= leftWidth) {
      _middleTss = datas[currIndex].tss;
    }
    if (currIndex + 1 >= 0 && currIndex + 1 < datas.length) {
      final rightIndex = (periodLen * (offsetWidth / scrollWidth)).toInt();
      _rightTss = datas[currIndex + 1].tss.sublist(0, rightIndex);
    }
    leftTss = _leftTss;
    middleTss = _middleTss;
    rightTss = _rightTss;

    print('currIndex---$currIndex-------${leftTss.length}-------${middleTss.length}---------');

    print(leftTss);
    print(middleTss);
    print(rightTss);
  }

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
  }
}
