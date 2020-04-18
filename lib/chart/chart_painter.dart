import 'package:flutter/material.dart';
import 'package:flutterapp/chart/entity/period_entity.dart';
import 'package:flutterapp/chart/entity/point_entity.dart';
import 'package:flutterapp/chart/entity/ts_entity.dart';
import 'package:flutterapp/chart/utils/date_format_util.dart';

class ChartPainter extends CustomPainter {
  static int minIndex = 0;
  static int maxIndex = 0;
  static double screenWidth; // 每屏滚动宽度

  List<PeriodEntity> datas;
  double scrollX;
  int initIndex;
  int screenDataLen; // 每屏点数量
  double rightWidth;
  double dateHeight;
  double offsetRatio;

  Rect chartRect;
  int showDataLen; // 显示点数量
  double pointWidth; // 数据点宽度
  double offsetWidth; // 默认偏移宽度

  int _startNum = 0; //周期分割线
  int _startTime = 0;
  int _startIndex = 0;
  List<TsEntity> _oneTss;
  List<TsEntity> _twoTss;
  List<TsEntity> _threeTss;
  double _maxValue = 0.0;
  double _minValue = 0.0;
  double _scaleY = 0.0;

  final int gridRows = 3;
  final int gridColumns = 0;
  final double fontSize = 12.0;
  final Color textColor = Color(0xFF000000);
  final Color primaryColor = Color(0xFF00A2AE);
  final Color antiColor = Color(0xFFFF5918);
  final List<String> dateFormats = [HH, ':', nn];
  final List<PointEntity> openPoints = [];

  ChartPainter({
    this.datas,
    this.scrollX = 0.0,
    this.initIndex = 0,
    this.screenDataLen = 60,
    this.rightWidth = 60.0,
    this.dateHeight = 30.0,
    this.offsetRatio = 0.1,
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

    print('-- scrollX:$scrollX --');
    print('-- initIndex:$initIndex --');
    print('-- screenDataLen:$screenDataLen --');
    print('-- rightWidth:$rightWidth --');
    print('-- dateHeight:$dateHeight --');
    print( '-- offsetRatio:$offsetRatio --');


    print( '-- chartRect:${chartRect.toString()} --');
    print('-- showDataLen:$showDataLen --');
    print( '-- pointWidth:$pointWidth --');
    print( '-- offsetWidth:$offsetWidth --');


    print( '-- _startNum:$_startNum --');
    print( '-- _startTime:$_startTime --');
    print(  '-- _startIndex:$_startIndex --');
    print( '-- _maxValue:$_maxValue --');
    print( '-- _minValue:$_minValue --');
    print( '-- _scaleY:$_scaleY --');
    print( '-- _oneTss:${_oneTss?.length} --');
    print( '-- _twoTss:${_twoTss?.length} --');
    print( '-- _threeTss:${_threeTss?.length} --');
    print( '-------');
    print( '-------');
    print( '-------');



    //canvas.save();
    drawBg(canvas, size);
    drawGrid(canvas);
    drawGridText(canvas);
    if (_oneTss != null && _oneTss.isNotEmpty) {
      drawChart(canvas, _oneTss, 0);
    }
    if (_twoTss != null && _twoTss.isNotEmpty) {
      drawChart(canvas, _twoTss, (screenDataLen - _startNum) * pointWidth);
    }
    if (_threeTss != null && _threeTss.isNotEmpty) {
      drawChart(canvas, _threeTss, (screenDataLen * 2 - _startNum) * pointWidth);
    }
    drawGapDate(canvas);

    openPoints.forEach((point) {
      drawPoint(canvas, point.value, point.offset);
    });
    //canvas.restore();
  }

  calculateData() {
    if (datas == null || datas.isEmpty) return;
    if (initIndex == null || initIndex == 0) {
      initIndex = datas.length - 1;
    }

    maxIndex = initIndex - 1;
    minIndex = initIndex - (datas.length - 1);

    var realX = (initIndex - 1) * screenWidth - scrollX - offsetWidth;
    var startLen = realX * screenDataLen ~/ screenWidth;
    _startNum = startLen % screenDataLen;

    if (realX > 0) {
      _startIndex = (startLen / screenDataLen).ceil();
      if (_startNum == 0) {
        _startIndex += 1;
      }
    } else {
      _startIndex = (startLen / screenDataLen).floor();
    }
    _startTime = datas[initIndex].openTime + (_startIndex - initIndex) * screenDataLen;

    if (_startIndex >= 0 && _startIndex < datas.length) {
      if (_startNum >= 0) {
        _oneTss = datas[_startIndex].tss?.sublist(_startNum);
      }
    }
    var twoIndex = _startIndex + 1;
    if (twoIndex >= 0 && twoIndex < datas.length) {
      if (screenDataLen * 2 - _startNum <= showDataLen) {
        _twoTss = datas[twoIndex].tss;
      } else {
        var endNum = showDataLen - screenDataLen + _startNum;
        if (endNum > 0) {
          _twoTss = datas[twoIndex].tss?.sublist(0, endNum);
        }
      }
    }
    var threeIndex = _startIndex + 2;
    if (threeIndex >= 0 && threeIndex < datas.length) {
      if (screenDataLen * 2 - _startNum < showDataLen) {
        var endNum = showDataLen - screenDataLen * 2 + _startNum;
        if (endNum > 0) {
          _threeTss = datas[threeIndex].tss?.sublist(0, endNum);
        }
      }
    }
  }


  void calculateValue() {
    double maxValue=0;
    double minValue=0;
    List<TsEntity> tss = [];
    if (_oneTss != null) tss.addAll(_oneTss);
    if (_twoTss != null) tss.addAll(_twoTss);
    if (_threeTss != null) tss.addAll(_threeTss);
    for(int i=0;i<tss.length;i++){
      if (i == 0 || maxValue < tss[i].value) {
        maxValue = tss[i].value;
      }
      if (i == 0 || minValue > tss[i].value) {
        minValue = tss[i].value;
      }
    }
    // _maxValue = (_maxValue-_minValue)/gridRows;
    _maxValue = maxValue + 100;
    _minValue = minValue - 100;
    if (_maxValue == _minValue) {
      _maxValue *= 1.5;
      _minValue /= 2;
    }
    _scaleY = chartRect.height / (_maxValue - _minValue);
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
    if (gridColumns > 0) {
      double columnSpace = chartRect.width / gridColumns;
      for (int i = 0; i <= columnSpace; i++) {
        canvas.drawLine(
          Offset(columnSpace * i, 0),
          Offset(columnSpace * i, chartRect.bottom),
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
          text: (_maxValue - gridVal * i).toString(),
          style: TextStyle(
            color: textColor,
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

  //画折线
  void drawChart(Canvas canvas, List<TsEntity> tss, double startX) {
    Offset startPoint;
    Offset endPoint;

    final path = Path();
    for (int i = 0; i < tss.length; i++) {
      double x = startX + i * pointWidth;
      double y = (_maxValue - tss[i].value) * _scaleY;
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

    final bgPath = Path()..moveTo(offset.dx + fontSize / 2, offset.dy);
    bgPath.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy - h / 6);
    bgPath.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy - h / 2);
    bgPath.lineTo(offset.dx + fontSize / 2 + h / 6 + w, offset.dy - h / 2);
    bgPath.lineTo(offset.dx + fontSize / 2 + h / 6 + w, offset.dy + h / 2);
    bgPath.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy + h / 2);
    bgPath.lineTo(offset.dx + fontSize / 2 + h / 6, offset.dy + h / 6);
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = showColor;
    canvas.drawPath(bgPath, bgPaint);

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
    textPainter.paint(canvas, Offset(offset.dx + h / 1.5, offset.dy - h / 2.6));
  }

  //画周期|时间
  void drawGapDate(Canvas canvas) {
    for (int i = 0; i < 5; i++) {
      var num = i * screenDataLen - _startNum;
      if (num <= showDataLen) {
        if (num >= 0) {
          var startX = num * pointWidth;
          dragGap(canvas, startX);
          drawDate(canvas, startX, _startTime + i * screenDataLen);
        }
      }
    }
  }

  //画周期
  void dragGap(Canvas canvas, double startX) {
    final rect = Rect.fromLTRB(startX, chartRect.top, startX + 20, chartRect.bottom);
    final rectPaint = Paint()
      ..strokeWidth = 1.0
      ..color = antiColor
      ..style = PaintingStyle.fill;
    final LinearGradient fillGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0x99666666),
        Color(0x00FFFFFF),
      ],
    );
    final fillRect = Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height);
    rectPaint.shader = fillGradient.createShader(fillRect);
    canvas.drawRect(rect, rectPaint);
  }

  //画时间
  void drawDate(Canvas canvas, double startX, int time) {
    final text = dateFormat(
      DateTime.fromMillisecondsSinceEpoch(time * 1000),
      dateFormats,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(startX - fontSize, chartRect.bottom));
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.datas != datas ||
        oldDelegate.datas?.length != datas?.length ||
        oldDelegate.scrollX != scrollX ||
        oldDelegate.initIndex != initIndex ||
        oldDelegate.screenDataLen != screenDataLen ||
        oldDelegate.rightWidth != rightWidth ||
        oldDelegate.dateHeight != dateHeight ||
        oldDelegate.offsetRatio != offsetRatio;
  }
}
