import 'package:flutter/material.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDButton extends StatelessWidget {

  final double width;
  final double height;
  final child;
  final onTap;
  final backgroundColor;
  final splashColor;
  final highlightColor;
  final BorderRadius borderRadius;
  final margin;
  final padding;
  final alignment;
  final boxShadow;
  final double borderWidth;
  final borderColor;
  final bool wrapWidth;


  TDButton({
    this.width,
    this.height = 40.0,
    this.child,
    this.onTap,
    this.backgroundColor = Colors.blue,
    this.splashColor,
    this.highlightColor,
    this.borderRadius = BorderRadius.zero,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(0.0),
    this.alignment,
    this.boxShadow,
    this.borderWidth,
    this.borderColor = Colors.red,
    this.wrapWidth = false,
  });


  @override
  Widget build(BuildContext context) {
    Widget content() => Stack(
      children: [

        borderWidth == null ? Container() : Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: borderRadius,
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.all(borderWidth ?? 0.0),
          child: Material(
            color: backgroundColor,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: padding,
              child: Center(child: child),
            ),
          ),
        ),

        onTap == null ? Container() : Positioned.fill(
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              splashColor: splashColor ?? Theme.of(context).splashColor,
              highlightColor: highlightColor ?? Theme.of(context).highlightColor,
            ),
          ),
        ),

      ],
    );


    Widget buildUI() => Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: !wrapWidth ? content() : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          content(),
        ],
      ),
    );


    return alignment == null ? buildUI() : Align(
      alignment: alignment,
      child: buildUI(),
    );
  }

}
