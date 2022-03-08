import 'dart:io';

import 'package:flutter/material.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDImageView {

  static Widget asset({@required String path, BoxFit fit = BoxFit.contain}) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: fit,
          image: AssetImage(path),
        ),
      ),
    );
  }

  static Widget filePath({@required String filePath, BoxFit fit = BoxFit.contain}) {
    return Image.file(
      File(filePath),
      width: double.infinity,
      height: double.infinity,
      fit: fit,
    );
  }

}