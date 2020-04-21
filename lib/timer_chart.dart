import 'package:flutter/material.dart';
import 'entity/period_entity.dart';
import 'point_widget.dart';
import 'chart_widget.dart';

class TimerChart extends StatefulWidget {
  final List<PeriodEntity> datas;
  final double showWidth;
  final int initIndex;
  final int showLen;
  final int screenLen;
  final Function(int) onChange;

  TimerChart({
    Key key,
    this.datas,
    this.showLen,
    this.showWidth,
    this.initIndex,
    this.screenLen,
    this.onChange,
  }) : super(key: key);

  @override
  TimerChartState createState() => TimerChartState();
}

class TimerChartState extends State<TimerChart> {
  final GlobalKey<ChartWidgetState> _chartKey = GlobalKey<ChartWidgetState>();
  final GlobalKey<PointWidgetState> _pointKey = GlobalKey<PointWidgetState>();

  @override
  Widget build(BuildContext context) {
    double showWidth = widget.showWidth;
    if (showWidth == null) {
      showWidth = MediaQuery.of(context).size.width;
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: ChartWidget(
            key: _chartKey,
            datas: widget.datas,
            initIndex: widget.initIndex,
            screenLen: widget.screenLen,
            onDrag: (int index) {
              _pointKey.currentState.onSelect(index);
              if (widget.onChange != null) {
                widget.onChange(index);
              }
            },
          ),
        ),
        PointWidget(
          key: _pointKey,
          datas: widget.datas,
          showLen: widget.showLen,
          showWidth: showWidth,
          onTap: (int index) {
            _chartKey.currentState.onSelect(index);
            if (widget.onChange != null) {
              widget.onChange(index);
            }
          },
        ),
      ],
    );
  }

  void addPeriod(PeriodEntity period) {
    widget.datas.add(period);
    _chartKey.currentState.addPeriod(period);
    _pointKey.currentState.addPeriod(period);
  }

  void setPeriod(int index, PeriodEntity period) {
    widget.datas[index] = period;
    _chartKey.currentState.setPeriod(index, period);
    _pointKey.currentState.setPeriod(index, period);
  }
}
