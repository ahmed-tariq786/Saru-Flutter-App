import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

TextStyle? textstyle(double fontSize, Color color, FontWeight fontWeight) {
  return TextStyle(
    fontFamily: 'Arial',
    letterSpacing: 0.6,
    fontWeight: fontWeight,

    fontSize: fontSize.sp,
    color: color,
  );
}
