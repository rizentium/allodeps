import 'package:flutter/material.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
abstract class TDPage extends StatefulWidget {

  final pageFunc = _TDPageFunctions();

  BuildContext get context => pageFunc.getObject == null ? null : pageFunc.getObject(1);

  @override
  State<StatefulWidget> createState() => _TDState();

  @protected
  void initState(){}

  @protected
  void layoutLoaded(){}

  @protected
  void dispose();

  @protected
  Widget buildLayout(BuildContext context);

}



class _TDState<T extends StatefulWidget> extends State<TDPage> {

  @override
  void initState() {
    super.initState();
    widget.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.layoutLoaded());
  }

  @override
  Widget build(BuildContext context) {
    widget.pageFunc.getObject = (index) {
      switch (index) {
        case 1: return context;
        default: return null;
      }
    };
    return widget.buildLayout(context);
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}



class _TDPageFunctions {
  Object Function(int) getObject;
}
