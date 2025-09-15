import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';

Widget sale(double? price, double? compareAtPrice, {double size = 11}) {
  if (price != null && compareAtPrice != null && price < compareAtPrice) {
    final discount = ((compareAtPrice - price) / compareAtPrice) * 100;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),

      decoration: BoxDecoration(
        color: AppColors.saleBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: myText(
        '-${discount.floor()}%',
        size,
        FontWeight.w500,
        AppColors.sale,
        TextAlign.left,
      ),
    );
  }
  return SizedBox();
}
