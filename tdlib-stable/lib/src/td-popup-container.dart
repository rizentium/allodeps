import 'package:flutter/material.dart';

import 'td-utils.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
Future<T> popupContainer<T>({
  @required BuildContext context,
  barrierDismissible: false, //prevent closing on outside touch
  EdgeInsetsGeometry margin,
  Function onWillPop,
  @required Widget child,
  PopupContainerAlignment alignment = PopupContainerAlignment.Center,
}) {
  final alignmentTop = () => <Widget>[
    child,
    Spacer(),
  ];

  final alignmentCenter = () => <Widget>[
    Spacer(),
    child,
    Spacer(),
  ];

  final alignmentBottom = () => <Widget>[
    Spacer(),
    child
  ];

  final buildUI = () {
    switch (alignment) {
      case PopupContainerAlignment.Top: return alignmentTop();
      case PopupContainerAlignment.Center: return alignmentCenter();
      case PopupContainerAlignment.Bottom: return alignmentBottom();
    }
    return <Widget>[];
  };

  Future<bool> willPop() async {
    if (onWillPop != null)
      onWillPop();

    return barrierDismissible;
  }

  void onTapOuter() async {
    if (barrierDismissible) {
      Navigator.pop(context);
      if (onWillPop != null)
        onWillPop();
    }
  }

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: willPop,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapOuter,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            margin: margin,
            child: noGestureAllowed(
              child: Column(
                children: buildUI(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}





enum PopupContainerAlignment {
  Top,
  Center,
  Bottom
}
