import 'package:flutter/material.dart';

import 'ChartPainter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 double mScrollX  =0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onHorizontalDragDown: (details) {
          print(
              '----------------------onHorizontalDragDown-------------------------');
        },
        onHorizontalDragUpdate: (details) {

          setState(() {
            mScrollX = (details.primaryDelta + mScrollX);
          });

          print('----------------------onHorizontalDragUpdate--------${mScrollX}-----------------');
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          var velocity = details.velocity.pixelsPerSecond.dx;
          print(
              '----------------------onHorizontalDragEnd------------$velocity-------------');
        },
        onHorizontalDragCancel: () {
          print(
              '----------------------onHorizontalDragCancel-------------------------');
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
          print(
              '----------------------onLongPressStart-------------------------');
        },
        onLongPressMoveUpdate: (details) {
          print(
              '----------------------onLongPressMoveUpdate-------------------------');
        },
        onLongPressEnd: (details) {
          print(
              '----------------------onLongPressEnd-------------------------');
        },
        child: Stack(
          children: <Widget>[
            CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: ChartPainter(mScrollX:mScrollX),
            ),
            Text('test chart'),
          ],
        ),
      ),
    );
  }
}
