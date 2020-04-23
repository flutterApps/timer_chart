import 'package:flutter/material.dart';

import 'utils/date_format_util.dart';
import 'entity/ts_entity.dart';
import 'line_painter.dart';

class LineWidget extends StatefulWidget {
  final List<TsEntity> datas;
  final int screenLen;
  final double leftWidth;

  LineWidget({
    Key key,
    this.datas,
    this.screenLen = 60,
    this.leftWidth = 60,
  }) : super(key: key);

  @override
  LineWidgetState createState() => LineWidgetState();
}

class LineWidgetState extends State<LineWidget> with TickerProviderStateMixin {
  TsEntity _ts = TsEntity();
  bool _hide = true;
  int _index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas != null && widget.datas.isNotEmpty) {
      if (_index > 0 && _index < widget.datas.length) {
        _ts = widget.datas[_index];
      }
    }

    return GestureDetector(
      onHorizontalDragDown: (details) {},
      onHorizontalDragUpdate: (details) {},
      onHorizontalDragEnd: (DragEndDetails details) {},
      onHorizontalDragCancel: () {},
      onScaleStart: (_) {},
      onScaleUpdate: (details) {},
      onScaleEnd: (_) {},
      onLongPressStart: (details) {
        double selectX = details.localPosition.dx - widget.leftWidth;
        if (mounted) {
          setState(() {
            _hide = false;
            _index = selectX ~/ LinePainter.pointWidth;
          });
        }
      },
      onLongPressMoveUpdate: (details) {
        double selectX = details.localPosition.dx - widget.leftWidth;
        if (mounted) {
          setState(() {
            _index = selectX ~/ LinePainter.pointWidth;
          });
        }
      },
      onLongPressEnd: (details) {
        if (mounted) {
          setState(() {
            _hide = true;
          });
        }
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: LinePainter(
              datas: widget.datas,
              screenLen: widget.screenLen,
            ),
          ),
          Offstage(
            offstage: _hide,
            child: Container(
              padding: EdgeInsets.only(left: widget.leftWidth),
              alignment:
                  _index * 2 < widget.screenLen ? Alignment.topRight : Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.all(6),
                color: Color(0xDDDDDDDD),
                child: Wrap(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Text('Price: ${_ts.value}'),
                    Text('Time: ${_formatTime(_ts.time)}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int time) {
    return dateFormat(
      DateTime.fromMillisecondsSinceEpoch((time ?? 0) * 1000),
      [mm, '/', dd, ' ', HH, ':', nn],
    );
  }
}
