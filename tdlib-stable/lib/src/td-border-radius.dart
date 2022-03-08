import 'package:flutter/material.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDBorderRadius {
  static BorderRadius circularOnly({topLeft: 0.0, topRight: 0.0, bottomLeft: 0.0, bottomRight: 0.0}) =>
      BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      );
}
