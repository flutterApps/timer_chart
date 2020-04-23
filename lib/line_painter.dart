import 'package:flutter/material.dart';

import 'utils/date_format_util.dart';
import 'entity/ts_entity.dart';

class LinePainter extends CustomPainter {
  static double pointWidth = 10;

  List<TsEntity> datas;
  int screenLen;
  double leftWidth;

  Rect _chartRect;
  double _maxValue = 0.0;
  double _minValue = 0.0;
  double _scaleY = 0.0;

  final int gridRows = 2;
  final int gridColumns = 0;
  final double fontSize = 12.0;
  final Color textColor = Color(0xFF000000);
  final Color primaryColor = Color(0xFF00A2AE);
  final Color antiColor = Color(0xFFFF5918);
  final List<String> dateFormats = [HH, ':', nn];

  LinePainter({
    this.datas,
    this.screenLen = 60,
    this.leftWidth = 60,
  });

  @override
  void paint(Canvas canvas, Size size) {
    pointWidth = (size.width - leftWidth) / (screenLen-1);
    _chartRect = Rect.fromLTRB(leftWidth, 0, size.width, size.height);
    calculateValue();

    drawBg(canvas, size);
    drawGrid(canvas);
    drawGridText(canvas);
    if (datas != null && datas.isNotEmpty) {
      drawChart(canvas);
    }
  }

  void calculateValue() {
    double maxValue = 0.0;
    double minValue = 0.0;
    for (int i = 0; i < datas.length; i++) {
      if (i == 0 || maxValue < datas[i].value) {
        maxValue = datas[i].value;
      }
      if (i == 0 || minValue > datas[i].value) {
        minValue = datas[i].value;
      }
    }

    double gridValue = (maxValue - minValue) / gridRows / 2;
    maxValue = maxValue + gridValue;
    minValue = minValue - gridValue;
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    if (maxValue - minValue == 0) {
      _scaleY = 0;
    } else {
      _scaleY = _chartRect.height / (maxValue - minValue);
    }
    _maxValue = maxValue;
    _minValue = minValue;
  }

  //画背景
  void drawBg(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(
      0,
      _chartRect.top,
      _chartRect.right,
      _chartRect.bottom,
    );
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }

  //画网格
  void drawGrid(Canvas canvas) {
    Paint gridPaint = Paint()
      ..strokeWidth = 0.5
      ..color = Color(0xFF999999)
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    double rowSpace = _chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(
        Offset(leftWidth, rowSpace * i),
        Offset(_chartRect.right, rowSpace * i),
        gridPaint,
      );
    }
    if (gridColumns > 0) {
      double columnSpace = _chartRect.width / gridColumns;
      for (int i = 0; i <= columnSpace; i++) {
        canvas.drawLine(
          Offset(columnSpace * i+leftWidth, 0),
          Offset(columnSpace * i+leftWidth, _chartRect.bottom),
          gridPaint,
        );
      }
    }
  }

  //画刻度值
  void drawGridText(canvas) {
    var painter;
    var gridVal = (_maxValue - _minValue) / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      painter = TextPainter(
        text: TextSpan(
          text: (_maxValue - gridVal * i).toStringAsFixed(4),
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      var valueDy = _chartRect.top + _chartRect.height / gridRows * i;
      if (i == gridRows) {
        valueDy -= fontSize * 1.2;
      } else if (i > 0) {
        valueDy -= fontSize * 0.5;
      } else if (i == 0) {
        valueDy += fontSize * 0.2;
      }
      painter.layout(minWidth: leftWidth, maxWidth: leftWidth);
      painter.paint(canvas, Offset(0, valueDy));
    }
  }

  //画折线
  void drawChart(Canvas canvas) {
    Offset startPoint;
    Offset endPoint;

    final path = Path();
    for (int i = 0; i < datas.length; i++) {
      double x = leftWidth + i * pointWidth;
      double y = (_maxValue - datas[i].value) * _scaleY;
      if (i == 0) {
        startPoint = Offset(x, y);
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      if (i == datas.length - 1) {
        endPoint = Offset(x, y);
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..strokeWidth = 1.0
      ..color = antiColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = true ? StrokeJoin.miter : StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPath = Path()..addPath(path, Offset.zero);
    fillPath.relativeLineTo(0, 0.0);
    fillPath.lineTo(endPoint.dx, _chartRect.height);
    fillPath.lineTo(leftWidth, _chartRect.height);
    fillPath.lineTo(startPoint.dx, startPoint.dy);
    fillPath.close();

    final fillPaint = Paint()
      ..strokeWidth = 0.0
      ..color = antiColor
      ..style = PaintingStyle.fill;

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [antiColor, Colors.white70],
    );

    final fillRect = Rect.fromLTWH(0, 0, datas.length * pointWidth, _chartRect.height);
    fillPaint.shader = fillGradient.createShader(fillRect);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }



  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.datas != datas ||
        oldDelegate.datas?.length != datas?.length ||
        oldDelegate.screenLen != screenLen ||
        oldDelegate.leftWidth != leftWidth;
  }
}
