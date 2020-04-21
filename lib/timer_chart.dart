import 'package:flutter/material.dart';
import 'time_chart/point_widget.dart';
import 'time_chart/chart_widget.dart';
import 'time_chart/entity/period_entity.dart';

class TimerChart extends StatefulWidget {
  final List<PeriodEntity> datas;
  final double showWidth;
  final int initIndex;
  final int showLen;

  TimerChart({
    Key key,
    this.datas,
    this.showLen,
    this.showWidth,
    this.initIndex,
  }) : super(key: key);

  @override
  TimerChartState createState() => TimerChartState();
}

class TimerChartState extends State<TimerChart> {
  final GlobalKey<ChartWidgetState> _chartKey = GlobalKey<ChartWidgetState>();
  final GlobalKey<PointWidgetState> _pointKey = GlobalKey<PointWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ChartWidget(
            key: _chartKey,
            datas: widget.datas,
            initIndex: widget.initIndex,
            onDrag: (int index) {
              _pointKey.currentState.onSelect(index);
            },
          ),
        ),
        PointWidget(
          key: _pointKey,
          datas: widget.datas,
          showLen: widget.showLen,
          showWidth: widget.showWidth,
          onTap: (int index) {
            _chartKey.currentState.onSelect(index);
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
