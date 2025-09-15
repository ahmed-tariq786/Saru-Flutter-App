import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:saru/services/language.dart';

/// A widget that automatically flips SVG icons for RTL languages
class RtlSvg extends StatelessWidget {
  final String assetPath;
  final Color? color;
  final double? width;
  final double? height;
  final bool shouldFlip; // Whether this icon should flip in RTL

  const RtlSvg({
    super.key,
    required this.assetPath,
    this.color,
    this.width,
    this.height,
    this.shouldFlip = true, // Default to true for directional icons
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final isArabic = languageController.currentLocale.value.languageCode == 'ar';

    Widget svgWidget = SvgPicture.asset(
      assetPath,
      color: color,
      width: width,
      height: height,
    );

    // Only apply transform if shouldFlip is true and we're in Arabic
    if (shouldFlip && isArabic) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159), // π radians = 180 degrees horizontal flip
        child: svgWidget,
      );
    }

    return svgWidget;
  }
}

/// Helper function for quick directional SVG usage
Widget directionalSvg(
  String assetPath, {
  Color? color,
  double? width,
  double? height,
}) {
  return RtlSvg(
    assetPath: assetPath,
    color: color,
    width: width,
    height: height,
    shouldFlip: true,
  );
}

/// Helper function for non-directional SVG usage (won't flip)
Widget nonDirectionalSvg(
  String assetPath, {
  Color? color,
  double? width,
  double? height,
}) {
  return RtlSvg(
    assetPath: assetPath,
    color: color,
    width: width,
    height: height,
    shouldFlip: false,
  );
}
