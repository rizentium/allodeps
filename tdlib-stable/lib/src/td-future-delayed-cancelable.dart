import 'dart:async';

import 'package:flutter/material.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDFutureDelayedCancelable {

  Timer _timer;
  Duration defaultDuration;



  TDFutureDelayedCancelable({this.defaultDuration});



  void delay({Duration duration, @required Function() callback}) {
    cancel();
    duration = duration != null ? duration : defaultDuration;
    if (duration != null) {
      _timer = Timer(duration, callback);
    }
  }

  void cancel() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }


  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

}
