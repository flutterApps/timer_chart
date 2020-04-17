import 'package:flutter/material.dart';

import 'entity/period_entity.dart';
import 'chart_painter.dart';

class ChartWidget extends StatefulWidget {
  final List<PeriodEntity> datas;
  final List<String> timeFormat;
  //当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool) onLoadMore;
  final List<Color> bgColor;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool) isOnDrag;

  ChartWidget({
    Key key,
    this.datas,
    this.timeFormat,
    this.onLoadMore,
    this.bgColor,
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
  }) : super(key: key);

  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> aniX;
  double mScrollX = 0.0;
  double mSelectX = 0.0;
  double mWidth = 0;
  bool isDrag = false;
  bool isLongPress = false;

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
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: ChartPainter(
              datas: widget.datas,
              scrollX: mScrollX,
            ),
          ),
          Text('test chart'),
        ],
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
    var tempX = x * widget.flingRatio + mScrollX;

    _controller = AnimationController(
        duration: Duration(
          milliseconds: widget.flingTime,
        ),
        vsync: this);
    aniX = null;
    aniX = Tween<double>(
      begin: mScrollX,
      end: x * widget.flingRatio + mScrollX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.flingCurve,
    ));

    print('---22-----------${x * widget.flingRatio + mScrollX}--------------------------');
    aniX.addListener(() {
      mScrollX = aniX.value;

      print('---_onFling-----1111-----------$mScrollX---------------');
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
      print('---_onFling-----2222-----------$mScrollX-------${ChartPainter.maxScrollX}--------');
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
