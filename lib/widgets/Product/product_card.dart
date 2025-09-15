import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/models/product.dart';
import 'package:saru/screens/Product%20Detail/product_screen.dart';
import 'package:saru/services/cart_service.dart';
import 'package:saru/services/favorites_service.dart';
import 'package:saru/widgets/Product/badge.dart';
import 'package:saru/widgets/Product/sale.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();

    RxBool isAddingToCart = false.obs;
    final cartController = Get.find<CartController>();
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ProductScreen(
            product: product,
          ),
          withNavBar: true, // <--- keeps the bottom bar visible
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGrey.withOpacity(0.5),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        width: Get.width * 0.38, // Fixed width for each item
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              foregroundDecoration: BoxDecoration(
                color: AppColors.prForeground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CacheImage(
                      pic: product.images[0],
                      width: Get.width * 0.34,
                      height: Get.width * 0.34,
                      radius: 0,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        tags(product.tags),
                        Obx(
                          () => favoritesController.isFavorited(product.id)
                              ? GestureDetector(
                                  onTap: () {
                                    favoritesController.toggleFavorite(product.id);
                                  },
                                  child: SvgPicture.asset(
                                    "assets/icons/Fav_select.svg",
                                    width: 18.w,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    favoritesController.toggleFavorite(product.id);
                                  },
                                  child: SvgPicture.asset(
                                    "assets/icons/Fav.svg",
                                    width: 18.w,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.vendor.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        myText(
                          product.vendor,
                          11,
                          FontWeight.w700,
                          AppColors.darkGrey.withOpacity(0.7),
                          TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Obx(
                          () => GestureDetector(
                            onTap: () async {
                              if (product.variants.length > 1) {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: ProductScreen(
                                    product: product,
                                  ),
                                  withNavBar: true, // <--- keeps the bottom bar visible
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                );
                                return;
                              }

                              isAddingToCart.value = true;
                              await cartController.addToCart(
                                cartController.cartId.value,
                                product.variants[0].id,
                                1,
                              );
                              isAddingToCart.value = false;
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              child: isAddingToCart.value
                                  ? SizedBox(
                                      width: 12.w,
                                      height: 12.w,
                                      child: CircularProgressIndicator(
                                        color: AppColors.black,
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : SvgPicture.asset(
                                      "assets/icons/atc.svg",
                                      width: 20.w,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (product.vendor.isNotEmpty)
                    SizedBox(
                      height: 4.h,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Expanded(
                        child: myText(
                          product.title,
                          12,
                          FontWeight.w400,
                          Colors.black,
                          TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      if (product.vendor.isEmpty)
                        Obx(
                          () => GestureDetector(
                            onTap: () async {
                              if (product.variants.length > 1) {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: ProductScreen(
                                    product: product,
                                  ),
                                  withNavBar: true, // <--- keeps the bottom bar visible
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                );
                                return;
                              }

                              isAddingToCart.value = true;
                              await cartController.addToCart(
                                cartController.cartId.value,
                                product.variants[0].id,
                                1,
                              );
                              isAddingToCart.value = false;
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              child: isAddingToCart.value
                                  ? SizedBox(
                                      width: 12.w,
                                      height: 12.w,
                                      child: CircularProgressIndicator(
                                        color: AppColors.black,
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : SvgPicture.asset(
                                      "assets/icons/atc.svg",
                                      width: 20.w,
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  if (product.variants[0].compareAtPrice != null)
                    myText(
                      "${product.variants[0].compareAtPrice!.toStringAsFixed(3)} ${product.variants[0].currency}",
                      12,
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
                        14,
                        FontWeight.w800,
                        Colors.black,
                        TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),

                      sale(
                        product.variants[0].price,
                        product.variants[0].compareAtPrice,
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
}
