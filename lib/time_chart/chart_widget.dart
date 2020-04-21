import 'package:flutter/material.dart';
import 'entity/period_entity.dart';
import 'chart_painter.dart';
import 'entity/ts_entity.dart';

class ChartWidget extends StatefulWidget {
  final List<PeriodEntity> datas;
  final Function(int) onDrag;
  final int initIndex;

  ChartWidget({
    Key key,
    this.datas,
    this.onDrag,
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
  Animation<double> _aniX;
  double _scrollX;
  double _startX;
  int _currIndex;
  bool isDrag;

  @override
  void initState() {
    super.initState();
    if (_scrollX == null) {
      _scrollX = 0.0;
    }
    if (_currIndex == null) {
      _currIndex = widget.datas.length - 1;
    }
    isDrag = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (details) {
        _startX = _scrollX;
        print('------onHorizontalDragDown------details:${details.toString()}------');
      },
      onHorizontalDragUpdate: (details) {
        if (mounted) {
          setState(() {
            _scrollX = (details.primaryDelta + _scrollX);
          });
        }

        print('-----onHorizontalDragUpdate : ${details.primaryDelta} : $_scrollX');
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        var velocity = details.velocity.pixelsPerSecond.dx;
        print('-------onHorizontalDragEnd  $velocity  $_scrollX---:${details.primaryVelocity}---');
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
          scrollX: _scrollX,
          initIndex: widget.initIndex,
        ),
      ),
    );
  }

  void addPeriod(PeriodEntity period) {
    if (period.openTime > widget.datas.last.openTime) {
      widget.datas.add(period);
    }
    _onSelect(_currIndex + 1, false);
  }

  void setPeriod(int index, PeriodEntity period) {
    if (period.openTime == widget.datas.last.openTime) {
      widget.datas[index] = period;
      _notifyChanged();
    }
  }

  void onSelect(int index) {
    _onSelect(index, false);
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller.isAnimating) {
      _controller.stop();
      if (needNotify) {
        _notifyChanged();
      }
    }
  }

  void _onDragChanged(int index, bool callback) {
    if (callback) {
      if (widget.onDrag != null) {
        widget.onDrag(index);
      }
    }
  }

  void _onFling(double x) {
    int offsetIndex;
    double tempWidth = x * flingRatio + _scrollX;
    if (_scrollX > _startX) {
      offsetIndex = (tempWidth / ChartPainter.screenWidth).ceil();
    } else {
      offsetIndex = (tempWidth / ChartPainter.screenWidth).floor();
    }
    int index = widget.initIndex - offsetIndex;
    _onSelect(index, true);
  }

  void _onSelect(int index, bool callback) {
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
    _aniX = null;
    _aniX = Tween<double>(
      begin: _scrollX,
      end: endX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: flingCurve,
    ));

    _aniX.addListener(() {
      _scrollX = _aniX.value;
      var minScrollX = minIndex * ChartPainter.screenWidth;
      var maxScrollX = maxIndex * ChartPainter.screenWidth;
      if (_scrollX < minScrollX) {
        _scrollX = minScrollX;
        _stopAnimation();
      } else if (_scrollX > maxScrollX) {
        _scrollX = maxScrollX;
        _stopAnimation();
      }
      _notifyChanged();
    });
    _aniX.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _currIndex = currIndex;
        _onDragChanged(currIndex, callback);
        _notifyChanged();
      }
    });
    _controller.forward();
  }

  void _notifyChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
