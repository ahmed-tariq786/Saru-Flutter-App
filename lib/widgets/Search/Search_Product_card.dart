import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/models/product.dart';
import 'package:saru/screens/Product%20Detail/product_screen.dart';
import 'package:saru/widgets/Product/sale.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';

InkWell searchProductCard(BuildContext context, Product product) {
  return InkWell(
    onTap: () {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: ProductScreen(product: product),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkGrey.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CacheImage(
            pic: product.images[0],
            width: 50.w,
            height: 50.w,
            radius: 0,
          ),

          Expanded(
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: Get.width * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.vendor.isNotEmpty)
                        myText(
                          product.vendor,
                          11,
                          FontWeight.w700,
                          AppColors.darkGrey.withOpacity(0.7),
                          TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      myText(
                        product.title,
                        12,
                        FontWeight.w400,
                        Colors.black,
                        TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Column(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (product.variants[0].compareAtPrice != null)
                      myText(
                        "${product.variants[0].compareAtPrice!.toStringAsFixed(3)} ${product.variants[0].currency}",
                        11,
                        FontWeight.w800,
                        AppColors.darkGrey.withOpacity(0.5),
                        TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        decoration: TextDecoration.lineThrough,
                      ),
                    Row(
                      spacing: 8,
                      children: [
                        myText(
                          "${product.variants[0].price!.toStringAsFixed(3)} ${product.variants[0].currency}",
                          12,
                          FontWeight.w800,
                          Colors.black,
                          TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),

                        sale(
                          product.variants[0].price,
                          product.variants[0].compareAtPrice,
                          size: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
