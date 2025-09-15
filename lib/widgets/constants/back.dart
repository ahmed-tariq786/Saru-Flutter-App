import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/rtl_svg.dart';

Widget backButton(context) {
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: () {
      PersistentNavBarNavigator.pop(context);
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: directionalSvg(
        'assets/icons/Back.svg',
        color: AppColors.black,
      ),
    ),
  );
}
