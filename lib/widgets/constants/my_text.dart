import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Text myText(
  String title,
  double fontSize,
  FontWeight fontWeight,
  Color color,
  TextAlign align, {
  TextOverflow? overflow,
  int? maxLines,
  TextDecoration? decoration,
}) {
  // Convert absolute alignments to semantic alignments for RTL support
  TextAlign semanticAlign = align;
  if (align == TextAlign.left) {
    semanticAlign = TextAlign.start;
  } else if (align == TextAlign.right) {
    semanticAlign = TextAlign.end;
  }

  return Text(
    title,
    textAlign: semanticAlign,
    overflow: overflow,
    maxLines: maxLines,

    style: TextStyle(
      fontFamily: 'Arial',
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      letterSpacing: 0.5,

      color: color,
      decoration: decoration,
      decorationColor: color,
      decorationThickness: 2,
    ),
  );
}
