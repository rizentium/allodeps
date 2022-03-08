import 'package:flutter/material.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDListView extends StatefulWidget {
  final _DoubleHolder offset = _DoubleHolder();

  final shrinkWrap;
  final itemCount;
  final IndexedWidgetBuilder itemBuilder;

  TDListView({this.shrinkWrap = false, @required this.itemCount, @required this.itemBuilder});

  @override
  State<StatefulWidget> createState() => _TDListViewState();
}



class _TDListViewState extends State<TDListView> {
  ScrollController _scrollController;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.offset.value,
    );
  }
  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: widget.shrinkWrap,
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
      ),
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          widget.offset.value = notification.metrics.pixels;
        }
        return false;
      },
    );
  }

}



class _DoubleHolder {
  double value = 0.0;
}
