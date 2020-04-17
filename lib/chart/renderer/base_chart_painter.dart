import 'package:flutter/material.dart';
import 'package:flutterapp/chart/entity/point_entity.dart';
import 'package:flutterapp/chart/entity/ts_entity.dart';
import 'package:flutterapp/chart/utils/date_format_util.dart';

abstract class BaseChartPainter extends CustomPainter {
  List<TsEntity> oneTss;
  List<TsEntity> twoTss;
  List<TsEntity> threeTss;
  double maxValue = 0.0;
  double minValue = 0.0;
  double scaleY = 0.0;
  int startNum = 0; //周期分割线

  double rightWidth;
  double dateHeight;
  double offsetRatio;
  int screenDataLen; // 每屏点数量

  Rect chartRect;
  int showDataLen; // 显示点数量
  double pointWidth; // 数据点宽度
  double screenWidth; // 每屏滚动宽度
  double offsetWidth; // 默认偏移宽度

  final int gridRows = 4;
  final int gridColumns = 1;
  final double fontSize = 12.0;
  final Color primaryColor = Color(0xFF00A2AE);
  final Color antiColor = Color(0xFFFF5918);
  final List<String> dateFormats = [HH, ':', nn]; //格式化时间
  final List<PointEntity> openPoints = [];

  BaseChartPainter({
    this.rightWidth,
    this.dateHeight,
    this.offsetRatio,
    this.screenDataLen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width - rightWidth;
    double height = size.height - dateHeight;
    screenWidth = width / (1 + offsetRatio);
    offsetWidth = width - screenWidth;
    showDataLen = (screenDataLen * (1 + offsetRatio)).toInt();
    pointWidth = width / showDataLen;
    chartRect = Rect.fromLTRB(0, 0, width, height);

    calculateData();
    calculateValue();

    //canvas.save();
    drawBg(canvas, size);
    drawGrid(canvas);
    drawGridText(canvas);
    if (oneTss != null && oneTss.isNotEmpty) {
      drawChart(canvas, oneTss, 0);
    }
    if (twoTss != null && twoTss.isNotEmpty) {
      final startX = (screenDataLen - startNum) * pointWidth;
      drawChart(canvas, twoTss, startX);
      dragGap(canvas, startX);
    }
    if (threeTss != null && threeTss.isNotEmpty) {
      final startX = (screenDataLen * 2 - startNum) * pointWidth;
      drawChart(canvas, threeTss, startX);
      dragGap(canvas, startX);
    }

    openPoints.forEach((point) {
      drawPoint(canvas, point.value, point.offset);

      drawDate(canvas, point);
    });

    //canvas.restore();
  }

  void calculateData();

  void calculateValue() {
    List<TsEntity> tss = [];
    if (oneTss != null) {
      tss.addAll(oneTss);
    }
    if (twoTss != null) {
      tss.addAll(twoTss);
    }
    if (threeTss != null) {
      tss.addAll(threeTss);
    }
    tss.forEach((ts) {
      if (maxValue == null || maxValue < ts.value) {
        maxValue = ts.value;
      }
      if (minValue == null || minValue > ts.value) {
        minValue = ts.value;
      }
    });
    maxValue += 200;
    minValue -= 100;
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = chartRect.height / (maxValue - minValue);
  }

  //画背景
  void drawBg(Canvas canvas, Size size) {}

  //画网格
  void drawGrid(Canvas canvas) {
    Paint gridPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = 0.5
      ..color = Color(0xff4c5c74);
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(
        Offset(0, rowSpace * i),
        Offset(chartRect.width, rowSpace * i),
        gridPaint,
      );
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, 0),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }

  //画刻度值
  void drawGridText(canvas) {
    var painter;
    var gridVal = (maxValue - minValue) / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      painter = TextPainter(
        text: TextSpan(
          text: (maxValue - gridVal * i).toString(),
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      var valueDy = chartRect.top + chartRect.height / gridRows * i;
      if (i == gridRows) {
        valueDy -= fontSize;
      } else if (i > 0) {
        valueDy -= fontSize / 2;
      }
      painter.layout();
      painter.paint(canvas, Offset(chartRect.right + 5, valueDy));
    }
  }

  //画周期
  void dragGap(Canvas canvas, double startX) {
    final Rect rect = Rect.fromLTRB(startX, chartRect.top, startX + 20, chartRect.bottom);
    final Paint rectPaint = Paint()
      ..strokeWidth = 1.0
      ..color = antiColor
      ..style = PaintingStyle.fill;
    final LinearGradient fillGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0x99666666), Color(0x00FFFFFF)],
    );
    final Rect fillRect = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height);
    rectPaint.shader = fillGradient.createShader(fillRect);
    canvas.drawRect(rect, rectPaint);
  }

  //画时间
  void drawDate(Canvas canvas, PointEntity point) {
    (screenDataLen * 2 - startNum) * pointWidth;

    final textPainter = TextPainter(
      text: TextSpan(
        text: point.time.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(point.offset.dx, point.offset.dy));
  }

  //画折线
  void drawChart(Canvas canvas, List<TsEntity> tss, double startX) {
    Offset startPoint;
    Offset endPoint;
    final path = Path();
    for (int i = 0; i < tss.length; i++) {
      double x = startX + i * pointWidth;
      double y = (maxValue - tss[i].value) * scaleY;
      if (i == 0) {
        startPoint = Offset(x, y);
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      if (i == tss.length - 1) {
        endPoint = Offset(x, y);
        path.lineTo(x, y);
      }
      if (i == 0 && tss[i].time % 60 == 0) {
        openPoints.add(PointEntity(
          time: tss[i].time,
          value: tss[i].value,
          offset: Offset(x, y),
        ));
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
    fillPath.lineTo(endPoint.dx, chartRect.height);
    fillPath.lineTo(startX, chartRect.height);
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

    final fillRect = Rect.fromLTWH(0.0, 0.0, tss.length * pointWidth, chartRect.height);
    fillPaint.shader = fillGradient.createShader(fillRect);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final line = Paint()
      ..color = antiColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    Offset center = Offset(50, chartRect.height); //  坐标中心
    double radius = 10; //  半径
    canvas.drawCircle(center, radius, line);
  }

  //画开盘点
  void drawPoint(Canvas canvas, double value, Offset offset) {
    Color showColor = primaryColor;
    double w = fontSize * 6 / 1.6;
    double h = fontSize * 1.6;

    final circlePaint = Paint()
      ..strokeWidth = 1
      ..color = showColor;
    canvas.drawCircle(offset, fontSize / 4 + 2, circlePaint);
    circlePaint..color = Colors.white;
    canvas.drawCircle(offset, fontSize / 4 + 1, circlePaint);
    circlePaint..color = showColor;
    canvas.drawCircle(offset, fontSize / 4, circlePaint);

    /*
      final linePaint = Paint()
        ..color = showColor;
      canvas.drawLine(point, Offset(chartRect.width-point.dx, point.dy), linePaint);
       */

    final path = Path()..moveTo(offset.dx + fontSize / 2, offset.dy);
    path.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy - h / 6);
    path.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy - h / 2);
    path.lineTo(offset.dx + fontSize / 2 + h / 6 + w, offset.dy - h / 2);
    path.lineTo(offset.dx + fontSize / 2 + h / 6 + w, offset.dy + h / 2);
    path.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy + h / 2);
    path.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy + h / 6);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = showColor;
    canvas.drawPath(path, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx + h/1.5, offset.dy - h / 2.6));
  }



  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
  }
}
