import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'td-utils.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDBroadcaster<T> {

  final _broadcast = BehaviorSubject<T>();

  TextEditingController textEditingController;

//  Function(T) get update => _broadcast.sink.add;
//  Observable<T> get stream => _broadcast.stream;
  Stream<T> get stream {
    if (!_disposed)
      return _broadcast.stream;
    return null;
  }

  T get value => _broadcast.value;
  bool _disposed = false;



  TDBroadcaster({T initValue, bool withTextEditingController = false}) {
    if (initValue != null) {
      update(initValue);
      if (initValue is String && withTextEditingController) {
        textEditingController = TextEditingController(text: initValue);
      }
    }
  }



  T update(T obj) {
    if (!_disposed) {
      _broadcast.sink.add(obj);
      return obj;
    }
    return null;
  }

  Widget onUpdate(Widget Function(T data) listener) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: value,
      builder: (context, snap) => listener(snap.data),
    );
  }

  void subscribe(void listener(T event)) {
    _broadcast.listen(listener);
  }


  void changeText(String text) {
    if (textEditingController != null) {
      textEditingController
        ..text = text
        ..selection = TextSelection.collapsed(offset: text.length);
      if (isTypeOf<T, String>()) {
        update(text as T);
      }
    }
  }

  void close() => dispose();
  void dispose() {
    _broadcast.close();
    _disposed = true;
  }
}
