import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget loader(BuildContext context, {Color color = Colors.black, double size = 30}) {
  return Directionality(
    textDirection: TextDirection.ltr, // Force LTR for loader animation
    child: Center(
      child: LoadingAnimationWidget.horizontalRotatingDots(
        color: color,
        size: size,
      ),
    ),
  );
}
