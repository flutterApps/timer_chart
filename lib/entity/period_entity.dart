import 'ts_entity.dart';

class PeriodEntity {
  int id;
  int type;
  int openTime;
  int closeTime;
  List<TsEntity> tss;

  PeriodEntity({
    this.id,
    this.type,
    this.openTime,
    this.closeTime,
    this.tss,
  });



  @override
  String toString() {
    return '{id:$id,type:$type,closeTime:$closeTime,tss:${tss.toString()}}';
  }
}
