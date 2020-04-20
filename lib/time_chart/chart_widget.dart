import 'package:flutter/material.dart';
import 'entity/period_entity.dart';
import 'chart_painter.dart';
import 'entity/ts_entity.dart';

class ChartWidget extends StatefulWidget {
  final List<PeriodEntity> datas;
  final Function(int) isOnDrag;
  final int initIndex;

  ChartWidget({
    Key key,
    this.datas,
    this.isOnDrag,
    this.initIndex,
  }) : super(key: key);

  @override
  ChartWidgetState createState() => ChartWidgetState();
}

class ChartWidgetState extends State<ChartWidget> with TickerProviderStateMixin {
  final Curve flingCurve = Curves.decelerate;
  final double flingRatio = 0.5;
  final int flingTime = 600;

  AnimationController _controller;
  Animation<double> aniX;
  double mScrollX = 0.0;
  double mStartX = 0.0;
  double mSelectX = 0.0;
  bool isDrag = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (details) {
        mStartX = mScrollX;
        print(
            '---------onHorizontalDragDown-------------details:${details.toString()}------------');
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          mScrollX = (details.primaryDelta + mScrollX);
        });

        print('---------onHorizontalDragUpdate : ${details.primaryDelta} : $mScrollX');
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        var velocity = details.velocity.pixelsPerSecond.dx;
        print(
            '---------onHorizontalDragEnd    $velocity    $mScrollX---:${details.primaryVelocity}---');
        _onFling(velocity);
      },
      onHorizontalDragCancel: () {
        print('----------------------onHorizontalDragCancel-------------------------');
      },
      onScaleStart: (_) {
        print('----------------------onScaleStart-------------------------');
      },
      onScaleUpdate: (details) {
        print('----------------------onScaleUpdate-------------------------');
      },
      onScaleEnd: (_) {
        print('----------------------onScaleEnd-------------------------');
      },
      onLongPressStart: (details) {
        print('----------------------onLongPressStart-------------------------');
      },
      onLongPressMoveUpdate: (details) {
        print('----------------------onLongPressMoveUpdate-------------------------');
      },
      onLongPressEnd: (details) {
        print('----------------------onLongPressEnd-------------------------');
      },
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: ChartPainter(
          datas: widget.datas,
          scrollX: mScrollX,
          initIndex: widget.initIndex,
        ),
      ),
    );
  }

  void addPeriod(PeriodEntity period) {
    widget.datas.add(period);
    _onFling(-ChartPainter.screenWidth);
  }

  void addTs(TsEntity ts) {
    List<TsEntity> tss = widget.datas.last.tss;
    if (tss == null) {
      tss = <TsEntity>[];
    }
    tss.add(ts);
    widget.datas.last.tss = tss;
    _notifyChanged();
  }

  void onSelect(int index) {
    _onSelect(index);
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller.isAnimating) {
      _controller.stop();
      if (needNotify) {
        _notifyChanged();
      }
    }
  }

  void _onDragChanged(int index) {
    if (widget.isOnDrag != null) {
      widget.isOnDrag(index);
    }
  }

  void _onFling(double x) {
    var offsetIndex;
    var tempX = x * flingRatio + mScrollX;
    if (mScrollX > mStartX) {
      offsetIndex = (tempX / ChartPainter.screenWidth).ceil();
    } else {
      offsetIndex = (tempX / ChartPainter.screenWidth).floor();
    }
    var index = widget.initIndex - offsetIndex;
    _onSelect(index);
  }

  void _onSelect(int index) {
    var offsetIndex = widget.initIndex - index;
    var maxIndex = widget.initIndex - 1;
    var minIndex = widget.initIndex - (widget.datas.length - 1);
    if (offsetIndex <= minIndex) {
      offsetIndex = minIndex;
    }
    if (offsetIndex >= maxIndex) {
      offsetIndex = maxIndex;
    }
    var currIndex = widget.initIndex - offsetIndex;
    var endX = offsetIndex * ChartPainter.screenWidth;
    _controller = AnimationController(
        duration: Duration(
          milliseconds: flingTime,
        ),
        vsync: this);
    aniX = null;
    aniX = Tween<double>(
      begin: mScrollX,
      end: endX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: flingCurve,
    ));

    aniX.addListener(() {
      mScrollX = aniX.value;
      var minScrollX = minIndex * ChartPainter.screenWidth;
      var maxScrollX = maxIndex * ChartPainter.screenWidth;
      if (mScrollX < minScrollX) {
        mScrollX = minScrollX;
        _stopAnimation();
      } else if (mScrollX > maxScrollX) {
        mScrollX = maxScrollX;
        _stopAnimation();
      }
      _notifyChanged();
    });
    aniX.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _onDragChanged(currIndex);
        _notifyChanged();
      }
    });
    _controller.forward();
  }

  void _notifyChanged() => setState(() {});
}
