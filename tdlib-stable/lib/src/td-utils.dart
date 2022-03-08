import 'dart:async';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';

import 'td-callbacks.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
void printLog(String value) {
  AnsiPen pen = new AnsiPen()..white(bold: true)..rgb(r: 1.0, g: 0.8, b: 0.2);
  print(pen(value));
}

/// param: hex: #RRGGBB
Color hexColor(String hex) => new Color(int.parse(hex.substring(1, 7), radix: 16) + 0xFF000000);


ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, {@required String message, Widget widgetRight}) {
  SnackBar snackBar;

  if (message != null) {
    if (widgetRight == null) {
      snackBar = SnackBar(
        content: Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(message),
        ),
      );
    }
    else {
      snackBar = SnackBar(
        duration: Duration(seconds: 3),
        content: Container(
          margin: EdgeInsets.only(left: 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(message),
              ),
              widgetRight,
            ],
          ),
        ),
      );
    }
  }

  return snackBar == null ? null : scaffoldKey.currentState.showSnackBar(snackBar);
}


Widget noGestureAllowed({@required Widget child}) => GestureDetector(
  onTap: (){},
  onDoubleTap: (){},
  onVerticalDragStart: (_){},
  onHorizontalDragStart: (_){},
  onForcePressStart: (_){},
  onLongPressStart: (_){},
  child: child,
);



T firstOrDefault<T>(List<T> list) => list.length == 0 ? null : list[0];

String strCapitalizeFirstLetter(String s) => s[0].toUpperCase() + s.substring(1);
// String strCapitalizeEachLetter(String s) => strings.Title(s);


bool isTypeOf<ThisType, OfType>() => _IsInstanceTypeOf<ThisType>() is _IsInstanceTypeOf<OfType>;

Future<void> whileTrueAsync(TDWhileTrueAsyncCallback loop) async {
//  final c = Completer<bool>();
//  var doLoop = (again) async {};
//  doLoop = (again) async {
//    await loop(doLoop);
//  };
//  await loop(doLoop);


  final c = Completer();

  var doLoop = (again) async {};
  doLoop = (again) async {
    if (again) {
      await loop(doLoop);
    } else {
      c.complete();
    }
  };

  await loop(doLoop);
  await c.future;
}






double heightOfStatusBar(BuildContext context) {
  if (!_SizeModel.isInitialize)
    _initSizeModel(context);
  return _SizeModel._heightOfStatusBar;
}

double heightOfToolBar(BuildContext context) {
  if (!_SizeModel.isInitialize)
    _initSizeModel(context);
  return _SizeModel._heightOfToolBar;
}

double heightOfAppBar(BuildContext context) {
  if (!_SizeModel.isInitialize)
    _initSizeModel(context);
  return _SizeModel._heightOfAppBar;
}

double heightOfScreen(BuildContext context) {
  if (!_SizeModel.isInitialize)
    _initSizeModel(context);
  return _SizeModel._heightOfScreen;
}

double widthOfScreen(BuildContext context) {
  if (!_SizeModel.isInitialize)
    _initSizeModel(context);
  return _SizeModel._widthOfScreen;
}

void _initSizeModel(BuildContext context) {
  final mq = MediaQuery.of(context);

  _SizeModel._heightOfStatusBar = mq.padding.top;
  _SizeModel._heightOfAppBar = _SizeModel._heightOfStatusBar + _SizeModel._heightOfToolBar;

  _SizeModel._heightOfScreen = mq.size.height;
  _SizeModel._widthOfScreen = mq.size.width;
}


List<List<T>> splitList<T>(List<T> list, int size) {
  final group = List<List<T>>();
  var arr = <T>[];

  final length = list.length;
  for (int i=0; i<length; i++) {
    arr.add(list[i]);

    if (arr.length == size) {
      group.add(arr);
      arr = <T>[];
    }
    if (length == i+1 && arr.length > 0) {
      group.add(arr);
    }
  }
  return group;
}





class _SizeModel {
  static var isInitialize = false;

  static var _heightOfStatusBar = -1.0;
  static final _heightOfToolBar = kToolbarHeight;
  static var _heightOfAppBar = -1.0;

  static var _widthOfScreen = 1.0;
  static var _heightOfScreen = 1.0;
}




class _IsInstanceTypeOf<T> {}
