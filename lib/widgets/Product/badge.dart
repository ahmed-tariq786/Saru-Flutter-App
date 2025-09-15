import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:get/get.dart';

Widget tags(List<String> tags) {
  if (tags.isNotEmpty && tags.any((tag) => tag.contains("badge_"))) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),

      decoration: BoxDecoration(
        color: AppColors.tag,
        borderRadius: BorderRadius.circular(100),
      ),
      child: myText(
        tags.firstWhere((tag) => tag.contains("badge_")).replaceFirst("badge_", "").toString().capitalize!,
        11,
        FontWeight.w500,
        AppColors.white,
        TextAlign.left,
      ),
    );
  }
  return SizedBox();
}
