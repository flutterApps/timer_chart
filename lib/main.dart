import 'dart:math';
import 'package:flutter/material.dart';
import 'package:timer_chart/line_widget.dart';
import 'entity/ts_entity.dart';
import 'entity/period_entity.dart';
import 'timer_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatelessWidget {
  final GlobalKey<TimerChartState> _key = GlobalKey<TimerChartState>();
  final String title;
  HomePage({this.title});

  List<PeriodEntity> getDatas(int len) {
    int cycleTime = 60;
    int startTime = 1586427900;
    var list = <PeriodEntity>[];
    for (int i = 0; i < len; i++) {
      var period = PeriodEntity();
      var openTime = startTime + i * cycleTime;
      period.type = 1;
      period.openTime = openTime;
      period.closeTime = openTime + cycleTime;

      var tss = <TsEntity>[];
      for (int n = 0; n <= cycleTime; n++) {
        tss.add(TsEntity(
          time: openTime + n,
          value: randomDouble(4),
        ));
      }
      period.tss = tss;
      list.add(period);
    }
    return list;
  }

  List<TsEntity> getTss(int len) {
    int startTime = 1586427900;
    var list = <TsEntity>[];
    for (int i = 0; i < len; i++) {
      list.add(TsEntity(
        time: startTime + i,
        value: randomDouble(4),
      ));
    }
    return list;
  }

  double randomDouble(int len) {
    String scopeF = '123456789'; //首位
    String scopeC = '0123456789'; //中间
    String result = '';
    for (int i = 0; i < len; i++) {
      if (i == 1) {
        result = scopeF[Random().nextInt(scopeF.length)];
      } else {
        result = result + scopeC[Random().nextInt(scopeC.length)];
      }
    }
    return (double.parse(result) - 500).abs();
  }

  @override
  Widget build(BuildContext context) {
    int len = 16;
    int i = 0;
    int n = 0;
    final datas = getDatas(len);
    final showLen = datas.length > len ? datas.length : len;

    final tss = getTss(60);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 300,
            padding: EdgeInsets.only(top: 10),
            child: TimerChart(
              key: _key,
              datas: datas,
              showLen: showLen,
              showWidth: MediaQuery.of(context).size.width,
              initIndex: datas.length - 1,
              screenLen: 60,
            ),
          ),
          Wrap(
            spacing: 10,
            children: <Widget>[
              FlatButton(
                color: Colors.deepOrange,
                child: Text('add Period', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _key.currentState.addPeriod(
                    PeriodEntity(
                      openTime: 1586427900 + (len + i) * 60,
                      closeTime: 1586427900 + (len + i + 1) * 60,
                    ),
                  );
                  i++;
                },
              ),
              FlatButton(
                color: Colors.deepOrange,
                child: Text('add Ts', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (datas.last.tss == null) {
                    datas.last.tss = <TsEntity>[
                      TsEntity(
                        time: 1586427900 + (len + i - 1) * 60 + n,
                        value: (randomDouble(4) - 500).abs(),
                      )
                    ];
                  } else {
                    datas.last.tss.add(TsEntity(
                      time: 1586427900 + (len + i - 1) * 60 + n,
                      value: (randomDouble(4) - 500).abs(),
                    ));
                  }
                  n++;
                  _key.currentState.setPeriod(
                    datas.length - 1,
                    datas.last,
                  );
                },
              ),
            ],
          ),
          Container(
            height: 100,
            padding: EdgeInsets.only(top: 10),
            child: LineWidget(
              datas: tss,
              screenLen: tss.length,
            ),
          ),
        ],
      ),
    );
  }
}
