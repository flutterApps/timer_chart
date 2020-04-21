import 'ts_entity.dart';

class PeriodEntity {
  int type;
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
