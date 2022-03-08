

/* ====================================================
	Created by andy pangaribuan on 02/04/2020
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
extension StringExt on String {

  String get capitalCase {
    if (this == null || isEmpty || substring(0,1) == " ")
      return this;
    return "${substring(0,1).toUpperCase()}${length == 1 ? "" : substring(1)}";
  }


  String get titleCase {
    if (this == null)
      return this;

    final arr = <String>[];
    var temp = "";
    var last = "";

    for (var ch in split('')) {
      if (temp == "") {
        temp = ch;
      }
      else if ((last == " " && ch != " ") || (last != " " && ch == " ")) {
        arr.add(temp);
        temp = ch;
      }
      else {
        temp += ch;
      }

      last = ch;
    }

    if (temp != "")
      arr.add(temp);

    return arr.map((e) => e.capitalCase).join();
  }

}



extension IterableExt<E> on Iterable<E> {

  void forEachIndex(void f(int i, E e)) {
    var i = 0;
    this.forEach((e) => f(i++, e));
  }

  Iterable<T> mapIndex<T>(T f(int i, E e)) {
    var i = 0;
    return this.map((e) => f(i++, e));
  }

  E get firstOrNull => this == null || this.isEmpty ? null : first;

}


//region Map Extension
extension MapExt on Map {

  List<List<String>> toListListString(String key) {
    List<List<String>> data;

    List<dynamic> list = this[key];
    if (list != null) {
      data = List<List<String>>();
      for (var e in list) {
        final l = List<String>.from(e);
        data.add(l);
      }
    }

    return data;
  }

  double toDouble(String key) {
    double value;

    final v = this[key];
    if (v != null) {
      value = v is int ? v.toDouble() : v;
    }

    return value;
  }

}
//endregion Map Extension
