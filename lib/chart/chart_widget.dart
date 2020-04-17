import 'package:flutter/material.dart';

import 'entity/period_entity.dart';
import 'chart_painter.dart';

class ChartWidget extends StatefulWidget {
  final List<PeriodEntity> datas;
  final Function(bool) onLoadMore;
  final Function(bool) isOnDrag;

  ChartWidget({
    Key key,
    this.datas,
    this.onLoadMore,
    this.isOnDrag,
  }) : super(key: key);

  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> with TickerProviderStateMixin {
  final int flingTime = 600;
  final double flingRatio = 0.5;
  final Curve flingCurve = Curves.decelerate;

  AnimationController _controller;
  Animation<double> aniX;
  double mScrollX = 0.0;
  double mSelectX = 0.0;
  double mWidth = 0;
  bool isDrag = false;

  @override
  Widget build(BuildContext context) {
    print('------------45---------------');

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
        ),
      ),
    );
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller.isAnimating) {
      _controller.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag(isDrag);
    }
  }

  void _onFling(double x) {
    var tempX = x * flingRatio + mScrollX;
    var num = (tempX / ChartPainter.screenWidth).ceil();
    var endX = num * ChartPainter.screenWidth;
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
      if (mScrollX <= ChartPainter.minScrollX) {
        mScrollX = ChartPainter.minScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(true);
        }
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller.forward();
  }

  void notifyChanged() => setState(() {});
}
