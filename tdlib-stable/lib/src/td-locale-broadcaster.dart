import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import 'td-app-translations.dart';
import 'td-broadcaster.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDLocaleBroadcaster {

  static final _eventBus = EventBus();

  // final _broadcaster = _TDOneWayBroadcaster<String>();
  final _broadcaster = TDBroadcaster<String>();

  StreamSubscription _eventSubscription;

  TDLocaleBroadcaster() {
    if (TDAppTranslations.currentLocale != null) {
      _broadcaster.update(TDAppTranslations.currentLanguage);
    }
    _eventSubscription = _eventBus.on<_LocaleEvent>().listen((event) {
      _broadcaster.update(event.lang);
    });
  }

  Widget onUpdate(Widget Function(String data) listener) => _broadcaster.onUpdate(listener);

  String get value => _broadcaster.value;

  void close() {
    _broadcaster.close();
    _eventSubscription.cancel();
  }



  static void fire(String lang) => _eventBus.fire(_LocaleEvent(lang));

}



class _LocaleEvent {
  String lang;
  _LocaleEvent(this.lang);
}
