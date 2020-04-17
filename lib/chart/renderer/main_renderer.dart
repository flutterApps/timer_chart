import 'package:flutter/material.dart';

import 'base_chart_renderer.dart';
import '../entity/candle_entity.dart';
import '../entity/ts_entity.dart';

class MainRenderer extends BaseChartRenderer<TsEntity> {
  double mCandleWidth = ChartStyle.candleWidth;
  double mCandleLineWidth = ChartStyle.candleLineWidth;
  bool isLine;
  //绘制的内容区域
  Rect _contentRect;
  double _contentPadding = 5.0;
  List<int> maDayList;

  MainRenderer(Rect mainRect, double maxValue, double minValue,
      double topPadding,  this.isLine, int fixedLength,
      [this.maDayList = const [5, 10, 20]])
      : super(
      chartRect: mainRect,
      maxValue: maxValue,
      minValue: minValue,
      topPadding: topPadding,
      fixedLength: fixedLength) {
    _contentRect = Rect.fromLTRB(
        chartRect.left,
        chartRect.top + _contentPadding,
        chartRect.right,
        chartRect.bottom - _contentPadding);
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  @override
  void drawText(Canvas canvas, TsEntity data, double x) {
    if (isLine == true) return;

  }



  @override
  void drawChart(TsEntity lastPoint, TsEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {

      drawPolyline(lastPoint.value, curPoint.value, canvas, lastX, curX);
  
  }

  Shader mLineFillShader;
  Path mLinePath, mLineFillPath;
  Paint mLinePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..color = ChartColors.kLineColor;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  //画折线图
  drawPolyline(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX) {
//    drawLine(lastPrice + 100, curPrice + 100, canvas, lastX, curX, ChartColors.kLineColor);
    mLinePath ??= Path();

//    if (lastX == curX) {
//      mLinePath.moveTo(lastX, getY(lastPrice));
//    } else {
////      mLinePath.lineTo(curX, getY(curPrice));
//      mLinePath.cubicTo(
//          (lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
//    }
    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath.moveTo(lastX, getY(lastPrice));
    mLinePath.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

//    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [ChartColors.lineFillColor, Colors.transparent],
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath.lineTo(lastX, getY(lastPrice));
    mLineFillPath.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath.close();

    canvas.drawPath(mLineFillPath, mLineFillPaint);
    mLineFillPath.reset();

    canvas.drawPath(mLinePath, mLinePaint);
    mLinePath.reset();
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    for (int i = 0; i < curPoint.maValueList.length; i++) {
      if (i == 3) {
        break;
      }
      if (lastPoint.maValueList[i] != 0) {
        drawLine(lastPoint.maValueList[i], curPoint.maValueList[i], canvas,
            lastX, curX, ChartColors.getMAColor(i));
      }
    }
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX) {
    if (lastPoint.up != 0) {
      drawLine(lastPoint.up, curPoint.up, canvas, lastX, curX,
          ChartColors.ma10Color);
    }
    if (lastPoint.mb != 0) {
      drawLine(
          lastPoint.mb, curPoint.mb, canvas, lastX, curX, ChartColors.ma5Color);
    }
    if (lastPoint.dn != 0) {
      drawLine(lastPoint.dn, curPoint.dn, canvas, lastX, curX,
          ChartColors.ma30Color);
    }
  }

  void drawCandle(TsEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.value);
    var low = getY(curPoint.value);
    var open = getY(curPoint.value);
    var close = getY(curPoint.value);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;
    if (open > close) {
      chartPaint.color = ChartColors.upColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else if (close > open) {
      chartPaint.color = ChartColors.dnColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, open, curX + r, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else {
      chartPaint.color = ChartColors.upColor;
      canvas.drawLine(
          Offset(curX - r, open), Offset(curX + r, open), chartPaint);
      if (high != low) {
        canvas.drawRect(
            Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
      }
    }
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double value = (gridRows - i) * rowSpace / scaleY + minValue;
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp =
      TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      if (i == 0) {
        tp.paint(canvas, Offset(chartRect.width - tp.width, topPadding));
      } else {
        tp.paint(
            canvas,
            Offset(chartRect.width - tp.width,
                rowSpace * i - tp.height + topPadding));
      }
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
//    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i + topPadding),
          Offset(chartRect.width, rowSpace * i + topPadding), gridPaint);
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, topPadding / 3),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }

  @override
  double getY(double y) {
    return (maxValue - y) * scaleY + _contentRect.top;
  }
}
