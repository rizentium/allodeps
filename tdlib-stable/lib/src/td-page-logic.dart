import 'package:flutter/material.dart';

import 'td-app-translations.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
abstract class TDPageLogic<T> {

  final scaffoldKey = GlobalKey<ScaffoldState>();

  BuildContext get context => scaffoldKey.currentContext;

  T Function() tdPage;
  T get page => tdPage();



  void pageBack({Object result}) => Navigator.of(context).pop(result);

  void pageOpen<T>(Widget page, {void callback(T t)}) => Navigator.push<T>(context, MaterialPageRoute(builder: (context) => page)).then((result) {
    if (callback != null) {
      callback(result);
    }
  });

  void pageOpenAndRemovePrevious(Widget page) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => page), ModalRoute.withName(''));


  String locale(String key) => TDAppTranslations.text(key);


  void dispose();

}
