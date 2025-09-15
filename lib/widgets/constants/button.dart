import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saru/widgets/constants/loader.dart';

class RoundButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final double height;
  final double width;
  final double radius;
  final VoidCallback onClick;
  final bool loading;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textcolor;
  final Widget icon;

  final TextAlign align;
  final bool isheading;
  const RoundButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.height,
    required this.width,
    required this.radius,
    required this.onClick,
    this.loading = false,
    required this.fontSize,
    required this.fontWeight,
    required this.textcolor,
    required this.align,
    required this.isheading,
    this.icon = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: loading ? null : onClick,
        child: Center(
          child: loading
              ? loader(
                  context,
                  color: textcolor,
                  size: 30,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon is! SizedBox) icon,
                    if (icon is! SizedBox)
                      SizedBox(
                        width: 8.w,
                      ),
                    Text(
                      text,
                      textAlign: align,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: fontSize.sp,
                        fontWeight: fontWeight,
                        letterSpacing: 0,
                        color: textcolor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class RoundButton1 extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final double height;
  final double width;
  final double radius;
  final VoidCallback onClick;
  final bool loading;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textcolor;
  final Widget icon;

  final TextAlign align;
  final bool isheading;
  const RoundButton1({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.height,
    required this.width,
    required this.radius,
    required this.onClick,
    this.loading = false,
    required this.fontSize,
    required this.fontWeight,
    required this.textcolor,
    required this.align,
    required this.isheading,
    this.icon = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: loading ? null : onClick,
        child: Center(
          child: loading
              ? loader(
                  context,
                  color: textcolor,
                  size: 30,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      textAlign: align,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: fontSize.sp,
                        fontWeight: fontWeight,
                        letterSpacing: 0,
                        color: textcolor,
                      ),
                    ),
                    if (icon is! SizedBox)
                      SizedBox(
                        width: 8.w,
                      ),
                    if (icon is! SizedBox) icon,
                  ],
                ),
        ),
      ),
    );
  }
}
