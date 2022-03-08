import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/* ====================================================
	Created by andy pangaribuan on 2020/06/04
	Copyright CT Corp Digital. All rights reserved.
===================================================== */
class TDTextField extends StatelessWidget {

  static const __colorGrey300 = Color(0xFFE0E0E0);

  final width;
  final height;
  final margin;
  final padding;
  final enabled;
  final backgroundColor;
  final borderRadius;
  final Text hintText;
  final keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final TextAlign textAlign;
  final FocusNode focusNode;
  final maxLength;

  final onChanged;
  final TextEditingController textEditingController;


  TDTextField({
    this.width = double.infinity,
    this.height,
    this.margin = const EdgeInsets.only(),
    this.padding = const EdgeInsets.only(),
    this.enabled = true,
    this.backgroundColor = __colorGrey300,
    this.borderRadius = const BorderRadius.only(),
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.maxLength,
    this.onChanged,
    this.textEditingController,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: TextField(
        enabled: enabled,
        textAlign: textAlign,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLength: maxLength,
        controller: textEditingController,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText?.data,
          hintStyle: hintText?.style,
          counterText: maxLength != null ? '' : null,
        ),
      ),
    );
  }

}
