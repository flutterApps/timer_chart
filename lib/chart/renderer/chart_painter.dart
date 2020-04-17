import 'package:flutter/material.dart';
import 'package:flutterapp/chart/entity/period_entity.dart';
import 'package:flutterapp/chart/entity/ts_entity.dart';
import 'package:flutterapp/chart/utils/number_util.dart';

import 'base_chart_painter.dart';

class ChartPainter extends BaseChartPainter {
  static double minScrollX = 0.0;
  static double maxScrollX = 0.0;
  static int currIndex;

  List<PeriodEntity> datas;
  double scrollX;
  int initIndex;
  int startIndex;
  List<Color> bgColor;

  ChartPainter({
    this.datas,
    this.scrollX = 0.0,
    this.initIndex,
    this.bgColor,
    rightWidth = 60.0,
    dateHeight = 30.0,
    offsetRatio = 0.1,
    screenDataLen = 60,
  }) : super(
          rightWidth: rightWidth,
          dateHeight: dateHeight,
          offsetRatio: offsetRatio,
          screenDataLen: screenDataLen,
        );

  @override
  calculateData() {
    if (datas == null || datas.isEmpty) return;
    if (initIndex == null) {
      initIndex = datas.length - 1;
    }
    if (currIndex == null) {
      currIndex = datas.length - 1;
    }

    maxScrollX = initIndex * screenWidth;
    minScrollX = (initIndex - (datas.length - 1)) * screenWidth;

    if (scrollX > 0) {
      //currIndex = initIndex - num;
    } else {
      //currIndex = initIndex + num;
    }
    //var maxOffset = (initIndex - currIndex + 1) * screenWidth;
    //var minOffset = (initIndex - currIndex - 1) * screenWidth;

    var realX = (initIndex - 1) * screenWidth - scrollX - offsetWidth;
    var startLen = realX * screenDataLen ~/ screenWidth;
    startNum = startLen % screenDataLen;

    if (realX > 0) {
      startIndex = (startLen / screenDataLen).ceil();
      if (startNum == 0) {
        startIndex += 1;
      }
    } else {
      startIndex = (startLen / screenDataLen).floor();
    }

    if (startIndex >= 0 && startIndex < datas.length) {
      if (startNum >= 0) {
        oneTss = datas[startIndex].tss?.sublist(startNum);
        print('oneTss---$startIndex---${oneTss?.length}---${oneTss.toString()}---');
      }
    }
    var twoIndex = startIndex + 1;
    if (twoIndex >= 0 && twoIndex < datas.length) {
      if (screenDataLen * 2 - startNum <= showDataLen) {
        twoTss = datas[twoIndex].tss;
        print('twoTss1---$twoIndex---${twoTss?.length}---${twoTss.toString()}---');
      } else {
        var endNum = showDataLen - screenDataLen + startNum;
        if (endNum > 0) {
          twoTss = datas[twoIndex].tss.sublist(0, endNum);
          print('twoTss2---$twoIndex---${twoTss?.length}---${twoTss.toString()}---');
        }
      }
    }
    var threeIndex = startIndex + 2;
    if (threeIndex >= 0 && threeIndex < datas.length) {
      if (screenDataLen * 2 - startNum < showDataLen) {
        var endNum = showDataLen - screenDataLen * 2 + startNum;
        if (endNum > 0) {
          threeTss = datas[threeIndex].tss.sublist(0, endNum);
          print('threeTss---$threeIndex---${threeTss?.length}---${threeTss.toString()}---');
        }
      }
    }

    print('scrollX:$scrollX----'
        'startLen:$startLen-----'
        'startNum:$startNum-----'
        'offsetWidth:$offsetWidth-----'
        'screenWidth:$screenWidth------'
        'startIndex:$startIndex---------');
  }
}
