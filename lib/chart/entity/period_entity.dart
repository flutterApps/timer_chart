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

class PeriodEntity {
  int openTime;
  int closeTime;
  List<TsEntity> tss = [];


  PeriodEntity({
    this.openTime,
    this.closeTime,
    this.tss,
  });

  @override
  String toString() {
    return '{openTime:$openTime,closeTime:$closeTime,tss:${tss.toString()}}';
  }

}
