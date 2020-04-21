class TsEntity {
  int time;
  double value;

  TsEntity({
    this.time,
    this.value,
  });

  @override
  String toString() {
    return '{time:$time,value:$value}';
  }
}
