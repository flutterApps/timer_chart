import 'package:flutter/material.dart';

import 'entity/period_entity.dart';

class PointWidget extends StatefulWidget {
  final List<PeriodEntity> datas;
  final Function(int) onTap;
  final double showWidth;
  final int showLen;
  PointWidget({
    Key key,
    this.datas,
    this.onTap,
    this.showLen = 16,
    this.showWidth = 20,
  }) : super(key: key);

  @override
  PointWidgetState createState() => PointWidgetState();
}

class PointWidgetState extends State<PointWidget> {
  final Color primaryColor = Color(0xFF00A2AE);
  final Color antiColor = Color(0xFFFF5918);
  ScrollController _controller;
  double _periodWidth;
  int _startIndex;
  int _currIndex;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_startIndex == null) {
      _startIndex = 0;
    }
    if (_currIndex == null) {
      _currIndex = widget.datas.length - 1;
    }
    _periodWidth = widget.showWidth / widget.showLen;

    return SizedBox(
      height: _periodWidth + 2,
      child: ListView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        children: widget.datas.map((v) {
          final index = widget.datas.indexOf(v);
          return InkWell(
            child: Container(
              width: _periodWidth,
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _currIndex == index ? Colors.black12 : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: _currIndex == index ? primaryColor : Colors.white,
                  ),
                ),
              ),
              child: _iconView(v.type),
            ),
            onTap: () {
              if (_currIndex != index) {
                widget.onTap(index);
                if (mounted) {
                  setState(() {
                    _currIndex = index;
                  });
                }
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _iconView(int type) {
    if (type == 0) {
      return ClipOval(child: Container(color: antiColor));
    }
    if (type == 1) {
      return ClipOval(child: Container(color: primaryColor));
    }
    if (type == 2) {
      return ClipOval(child: Container(color: Colors.grey));
    }
    if (type == 10) {
      return Icon(Icons.close);
    }
    if (type == 11) {
      return Icon(Icons.timer_10); //购买中
    }
    if (type == 12) {
      return Icon(Icons.timelapse); //进行中
    }
    if (type == 13) {
      return Icon(Icons.slow_motion_video); //交割中
    }
    return Icon(Icons.cached);
  }

  void setPeriod(int index,PeriodEntity period) {
    if (period.openTime == widget.datas.last.openTime) {
      widget.datas[index] = period;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void addPeriod(PeriodEntity period) {
    if (period.openTime > widget.datas.last.openTime) {
      widget.datas.add(period);
    }
    onSelect(_currIndex + 1);
  }

  void onSelect(int index) {
    if (mounted) {
      setState(() {
        _currIndex = index;
      });
    }
    var offsetIndex;
    var offsetWidth;
    var endIndex = _startIndex + widget.showLen - 1;

    if (_currIndex > endIndex) {
      offsetIndex = _currIndex - endIndex;
      offsetWidth = offsetIndex * _periodWidth;
      _startIndex += offsetIndex;
    }
    if (_currIndex < _startIndex) {
      offsetIndex = _currIndex - _startIndex;
      offsetWidth = offsetIndex * _periodWidth;
      _startIndex += offsetIndex;
    }
    if (offsetWidth != null) {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.offset + offsetWidth,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        );
      }
    }
  }
}
