import 'package:flutter/material.dart';

import 'td-page-logic.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
abstract class TDPlusLogic<T extends TDPageLogic> {

  T Function() _parent;

  T get parent => _parent();

  GlobalKey<ScaffoldState> get scaffoldKey => _parent().scaffoldKey;

  BuildContext get context => _parent().context;


  TDPlusLogic(this._parent);


  void pageBack() => _parent().pageBack();

  void pageOpen<R>(Widget page, {Future<R> callback(R)}) => _parent().pageOpen(page, callback: callback);

  void pageOpenAndRemovePrevious(Widget page) => _parent().pageOpenAndRemovePrevious(page);


  String locale(String key) => _parent().locale(key);


  void dispose();

}
