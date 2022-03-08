import 'td-callbacks.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
abstract class TDMuple3<V1, V2, V3> {

  TDMuple3() {
    if (!isV1 && !isV2 && !isV3)
      throw Exception('Should be TDMuple3 V1, V2 or V3.');
  }

  bool get isV1 => this is TDMuple3V1<V1, V2, V3>;
  bool get isV2 => this is TDMuple3V2<V1, V2, V3>;
  bool get isV3 => this is TDMuple3V3<V1, V2, V3>;


  V1 get v1 {
    if (this is TDMuple3V1<V1, V2, V3>)
      return (this as TDMuple3V1<V1, V2, V3>).value;
    else
      throw Exception('Illegal use. You should isV1() check before calling');
  }

  V2 get v2 {
    if (this is TDMuple3V2<V1, V2, V3>)
      return (this as TDMuple3V2<V1, V2, V3>).value;
    else
      throw Exception('Illegal use. You should isV2() check before calling');
  }

  V3 get v3 {
    if (this is TDMuple3V3<V1, V2, V3>)
      return (this as TDMuple3V3<V1, V2, V3>).value;
    else
      throw Exception('Illegal use. You should isV3() check before calling');
  }



  Future<void> func(TDMuple3Callback<V1> fnV1, TDMuple3Callback<V2> fnV2, TDMuple3Callback<V3> fnV3) async {
    if (isV1) {
      final v = this as TDMuple3V1<V1, V2, V3>;
      await fnV1(v.value);
    }

    if (isV2) {
      final v = this as TDMuple3V2<V1, V2, V3>;
      await fnV2(v.value);
    }

    if (isV3) {
      final v = this as TDMuple3V3<V1, V2, V3>;
      await fnV3(v.value);
    }
  }

}


class TDMuple3V1<V1, V2, V3> extends TDMuple3<V1, V2, V3> {
  final V1 value;

  TDMuple3V1(this.value);
}


class TDMuple3V2<V1, V2, V3> extends TDMuple3<V1, V2, V3> {
  final V2 value;

  TDMuple3V2(this.value);
}


class TDMuple3V3<V1, V2, V3> extends TDMuple3<V1, V2, V3> {
  final V3 value;

  TDMuple3V3(this.value);
}
