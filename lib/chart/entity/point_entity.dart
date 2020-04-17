import 'dart:ui';

class PointEntity {
  int time;
  double value;
  Offset offset;

  PointEntity({
    this.time,
    this.value,
    this.offset,
  });

  @override
  String toString() {
    return '{offset:${offset.toString()},value:$value}';
  }
}
