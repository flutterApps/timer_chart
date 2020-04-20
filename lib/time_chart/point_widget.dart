import 'package:flutter/material.dart';

import 'entity/period_entity.dart';



class LinePoint extends StatefulWidget {
  final List<PeriodEntity> datas;
  final Function(int) onTap;
  final int index;
  LinePoint({
    Key key,
    this.datas,
    this.index,
    this.onTap,
  }) : super(key: key);

  @override
  LinePointState createState() => LinePointState();
}

class LinePointState extends State<LinePoint> {
  final int _size = 15;
  ScrollController _controller;
  double _width;
  int _index;


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
    _width = MediaQuery.of(context).size.width / _size;
    return Container(
      height: _width + 2,
      child: _listView(),
    );
  }

  Widget _listView() {
    return ListView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      children: _options.map((v) {
        final index = _options.indexOf(v);
        return InkWell(
          child: Container(
            width: _width,
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _index == index ? Colors.black12 : Colors.white,
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: _index == index ? CssCfg.primaryColor : Colors.white,
                ),
              ),
            ),
            child: _iconView(v.optionType),
          ),
          onTap: () {
            if (_index != index) {
              widget.onTap(v);
              if (mounted) {
                setState(() {
                  _index = index;
                });
              }
            }
          },
        );
      }).toList(),
    );
  }

  Widget _iconView(int type) {
    if (type == 0) {
      return ClipOval(child: Container(color: CssCfg.antiColor));
    }
    if (type == 1) {
      return ClipOval(child: Container(color: CssCfg.primaryColor));
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

  void setOption(OptionMode option) {
    if (option.openTime == _options.last.openTime) {
      if (mounted) {
        setState(() {
          _options.last = option;
        });
      }
    }
  }

  void addOption(OptionMode option) {
    if (option.openTime > _options.last.openTime) {
      if (mounted) {
        setState(() {
          _index += 1;
          _options.add(option);
        });
      }
      if (_controller.hasClients) {
        _controller.animateTo(
          (_options.length - _size) * _width,
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      }
    }
  }
}
