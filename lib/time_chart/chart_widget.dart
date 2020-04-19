import 'package:flutter/material.dart';
import 'entity/period_entity.dart';
import 'chart_painter.dart';

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
  final int flingTime = 500;

  AnimationController _controller;
  Animation<double> aniX;
  double mScrollX = 0.0;
  double mSelectX = 0.0;
  double mWidth = 0;
  bool isDrag = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (details) {
        print('---------onHorizontalDragDown-------------------------');
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          mScrollX = (details.primaryDelta + mScrollX);
        });

        print('---------onHorizontalDragUpdate : ${details.primaryDelta} : $mScrollX');
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        var velocity = details.velocity.pixelsPerSecond.dx;
        print('---------onHorizontalDragEnd    $velocity    $mScrollX------');
        _onFling(velocity, flingTime);
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

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller.isAnimating) {
      _controller.stop();
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(int index) {
    if (widget.isOnDrag != null) {
      widget.isOnDrag(index);
    }
  }

  void _onFling(double x, int flingTime) {
    print('---------x---------------- $x ---');
    var currIndex;
    var offsetIndex;
    var tempX = x * flingRatio + mScrollX;
    if (x > 0) {
      offsetIndex = (tempX / ChartPainter.screenWidth).ceil();
    } else {
      offsetIndex = (tempX / ChartPainter.screenWidth).floor();
    }
    if(offsetIndex<=ChartPainter.minIndex){
      offsetIndex = ChartPainter.minIndex;
    }
    if(offsetIndex>=ChartPainter.maxIndex){
      offsetIndex = ChartPainter.maxIndex;
    }
    currIndex = widget.initIndex-offsetIndex;
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
      var minScrollX = ChartPainter.minIndex * ChartPainter.screenWidth;
      var maxScrollX = ChartPainter.maxIndex * ChartPainter.screenWidth;
      if (mScrollX <= minScrollX) {
        mScrollX = minScrollX;
        _stopAnimation();
      } else if (mScrollX >= maxScrollX) {
        mScrollX = maxScrollX;
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _onDragChanged(currIndex);
        notifyChanged();
      }
    });
    _controller.forward();
  }

  void notifyChanged() => setState(() {});
}
