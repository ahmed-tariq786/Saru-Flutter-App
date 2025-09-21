import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/screens/Account/favorites.dart';
import 'package:saru/services/cart_service.dart';
import 'package:saru/services/discount_service.dart';
import 'package:saru/widgets/Product/recommended_product_card.dart';
import 'package:saru/widgets/Product/sale.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.tabController});

  final PersistentTabController? tabController;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartController = Get.find<CartController>();
  final discountController = Get.find<DiscountController>();
  final couponController = TextEditingController();

  RxBool isLoading = false.obs;

  @override
  void initState() {
    couponController.text = discountController.appliedDiscountCodes.isNotEmpty
        ? discountController.appliedDiscountCodes.first
        : "";
    super.initState();
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.bg,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,

          title: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                myText(
                  S.of(context).bag,
                  16,
                  FontWeight.w900,
                  AppColors.black,
                  TextAlign.start,
                ),
                SizedBox(
                  width: 4,
                ),
                myText(
                  " (${cartController.totalQuantity.toString()} ",
                  14,
                  FontWeight.w500,
                  AppColors.darkGrey,
                  TextAlign.start,
                ),
                myText(
                  S.of(context).items,
                  14,
                  FontWeight.w500,
                  AppColors.darkGrey,
                  TextAlign.start,
                ),
              ],
            ),
          ),
          leadingWidth: 42,
          leading: Opacity(
            opacity: 0,
            child: SvgPicture.asset(
              "assets/icons/Fav.svg",
              width: 20.w,
            ),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
          ),
          actions: [
            GestureDetector(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: FavoritesScreen(),
                  withNavBar: true, // <--- keeps the bottom bar visible
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  "assets/icons/Fav.svg",
                  width: 20.w,
                ),
              ),
            ),
          ],
          titleSpacing: 0,

          centerTitle: true,
        ),
        body: Obx(
          () => Stack(
            children: [
              Column(
                children: [
                  // Free shipping progress bar
                  Obx(
                    () => Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 0),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              if (cartController.subtotal.value.isNotEmpty &&
                                  (double.tryParse(cartController.subtotal.value) ?? 0.0) >= 5.0) ...[
                                myText(
                                  S.of(context).congratulations,
                                  12,
                                  FontWeight.w800,
                                  AppColors.threshold,
                                  TextAlign.start,
                                ),
                                myText(
                                  S.of(context).youveGotFreeShipping,
                                  12,
                                  FontWeight.w500,
                                  AppColors.black,
                                  TextAlign.start,
                                ),
                              ] else ...[
                                myText(
                                  S.of(context).wantFreeShipping,
                                  12,
                                  FontWeight.w800,
                                  AppColors.black,
                                  TextAlign.start,
                                ),
                                myText(
                                  S.of(context).add,
                                  12,
                                  FontWeight.w500,
                                  AppColors.black,
                                  TextAlign.start,
                                ),
                                myText(
                                  "${(5.0 - (double.tryParse(cartController.subtotal.value) ?? 0.0)).toStringAsFixed(3)} KWD ",
                                  12,
                                  FontWeight.w500,
                                  AppColors.black,
                                  TextAlign.start,
                                ),
                                myText(
                                  S.of(context).kdMore,
                                  12,
                                  FontWeight.w500,
                                  AppColors.black,
                                  TextAlign.start,
                                ),
                              ],
                            ],
                          ),

                          Container(
                            margin: EdgeInsets.only(top: 8),
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: cartController.subtotal.value.isNotEmpty
                                  ? (double.tryParse(cartController.subtotal.value) ?? 0.0) / 5.00 > 1.0
                                        ? 1.0
                                        : (double.tryParse(cartController.subtotal.value) ?? 0.0) / 5.00
                                  : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.threshold,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),

                  // Cart items and recommended products
                  Expanded(
                    child: SingleChildScrollView(
                      child: Obx(
                        () => Column(
                          spacing: 6,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cartController.lines.isEmpty
                                // Empty cart message
                                ? emptyCart(context)
                                // Cart items list
                                : Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: Offset(0, 0),
                                          blurRadius: 6,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12),

                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(0),
                                      itemCount: cartController.lines.length,
                                      itemBuilder: (context, index) {
                                        final line = cartController.lines[index];
                                        return Container(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: cartController.lines.length == index + 1
                                                ? null
                                                : Border(
                                                    bottom: BorderSide(
                                                      color: AppColors.lightGrey,
                                                      width: 1,
                                                    ),
                                                  ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            spacing: 8,
                                            children: [
                                              CacheImage(
                                                pic: line.merchandise.imageUrl,
                                                width: 80,
                                                height: 80,
                                                radius: 0,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  spacing: 6,
                                                  crossAxisAlignment: CrossAxisAlignment.start,

                                                  children: [
                                                    if (line.merchandise.vendor.isNotEmpty)
                                                      myText(
                                                        line.merchandise.vendor,
                                                        11,
                                                        FontWeight.w700,
                                                        AppColors.darkGrey.withOpacity(0.7),
                                                        TextAlign.left,
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    myText(
                                                      line.merchandise.title,
                                                      12,
                                                      FontWeight.w400,
                                                      Colors.black,
                                                      TextAlign.left,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                    if (line.merchandise.selectedOptions[0].value != "Default Title")
                                                      myText(
                                                        line.merchandise.selectedOptions
                                                            .map((e) => e.value.capitalize)
                                                            .join(", "),
                                                        12,
                                                        FontWeight.w400,
                                                        AppColors.darkGrey.withOpacity(0.7),
                                                        TextAlign.left,
                                                      ),

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,

                                                      children: [
                                                        // Prices
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,

                                                          children: [
                                                            if (line.merchandise.compareAtPrice != null &&
                                                                line.merchandise.compareAtPrice != 0)
                                                              myText(
                                                                "${line.merchandise.compareAtPrice!.toStringAsFixed(3)} ${line.merchandise.currencyCode}",
                                                                11,
                                                                FontWeight.w800,
                                                                AppColors.darkGrey.withOpacity(0.5),
                                                                TextAlign.left,
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                decoration: TextDecoration.lineThrough,
                                                              ),
                                                            Row(
                                                              spacing: 8,
                                                              children: [
                                                                myText(
                                                                  "${line.merchandise.price.toStringAsFixed(3)} ${line.merchandise.currencyCode}",
                                                                  13,
                                                                  FontWeight.w800,
                                                                  Colors.black,
                                                                  TextAlign.left,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                ),

                                                                sale(
                                                                  line.merchandise.price,
                                                                  line.merchandise.compareAtPrice,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),

                                                        // Quantity controls
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                              color: AppColors.grey,
                                                              width: 1.0,
                                                              style: BorderStyle.solid,
                                                            ),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),

                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              // Decrease quantity or remove
                                                              GestureDetector(
                                                                onTap: () async {
                                                                  if (line.quantity > 1) {
                                                                    isLoading.value = true;
                                                                    await cartController.updateCartLines(
                                                                      cartController.cartId.value,
                                                                      line.id,
                                                                      line.quantity - 1,
                                                                    );
                                                                    isLoading.value = false;
                                                                  } else {
                                                                    isLoading.value = true;
                                                                    await cartController.removeCartLines(
                                                                      cartController.cartId.value,
                                                                      [line.id],
                                                                    );
                                                                    isLoading.value = false;
                                                                  }
                                                                },
                                                                child: Container(
                                                                  width: 30,
                                                                  height: 30,
                                                                  color: Colors.transparent,
                                                                  alignment: Alignment.center,
                                                                  child: line.quantity > 1
                                                                      ? SvgPicture.asset(
                                                                          "assets/icons/minus.svg",
                                                                        )
                                                                      : Icon(
                                                                          Icons.delete_outline,
                                                                          size: 16,
                                                                          color: Colors.black,
                                                                        ),
                                                                ),
                                                              ),
                                                              // Quantity display
                                                              Container(
                                                                width: 30,
                                                                height: 30,
                                                                alignment: Alignment.center,
                                                                child: myText(
                                                                  line.quantity.toString(),
                                                                  14,
                                                                  FontWeight.w800,
                                                                  Colors.black,
                                                                  TextAlign.center,
                                                                ),
                                                              ),
                                                              // Increase quantity
                                                              GestureDetector(
                                                                onTap: () async {
                                                                  isLoading.value = true;
                                                                  await cartController.updateCartLines(
                                                                    cartController.cartId.value,
                                                                    line.id,
                                                                    line.quantity + 1,
                                                                  );
                                                                  isLoading.value = false;
                                                                },
                                                                child: Container(
                                                                  width: 30,
                                                                  color: Colors.transparent,
                                                                  height: 30,
                                                                  alignment: Alignment.center,
                                                                  child: SvgPicture.asset(
                                                                    "assets/icons/plus.svg",
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                            //Apply Promocode
                            if (cartController.lines.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(0, 0),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  spacing: 8,
                                  children: [
                                    Row(
                                      spacing: 8,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/promocode.svg",
                                          width: 16,
                                          color: AppColors.darkGrey,
                                        ),
                                        myText(
                                          S.of(context).couponCode,
                                          14,
                                          FontWeight.w500,
                                          Colors.black,
                                          TextAlign.left,
                                        ),
                                      ],
                                    ),
                                    Obx(
                                      () => TextFormField(
                                        controller: couponController,
                                        style: textstyle(
                                          13,
                                          AppColors.black,
                                          FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                          hintText: S.of(context).couponCode,

                                          hintStyle: textstyle(
                                            13,
                                            discountController.appliedDiscountCodes.isNotEmpty
                                                ? Colors.green
                                                : AppColors.darkGrey,
                                            FontWeight.w400,
                                          ),
                                          fillColor: discountController.appliedDiscountCodes.isNotEmpty
                                              ? Colors.green.withOpacity(0.05)
                                              : discountController.lastDiscountError.value.isNotEmpty
                                              ? Colors.red.withOpacity(0.05)
                                              : AppColors.bg,
                                          filled: true,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: discountController.appliedDiscountCodes.isNotEmpty
                                                  ? Colors.green.withOpacity(0.3)
                                                  : discountController.lastDiscountError.value.isNotEmpty
                                                  ? Colors.red.withOpacity(0.3)
                                                  : const Color(0xFFededed),
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: discountController.appliedDiscountCodes.isNotEmpty
                                                  ? Colors.green.withOpacity(0.3)
                                                  : discountController.lastDiscountError.value.isNotEmpty
                                                  ? Colors.red.withOpacity(0.3)
                                                  : const Color(0xFFededed),
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),

                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: discountController.appliedDiscountCodes.isNotEmpty
                                                  ? Colors.green.withOpacity(0.3)
                                                  : discountController.lastDiscountError.value.isNotEmpty
                                                  ? Colors.red.withOpacity(0.3)
                                                  : const Color(0xFFededed),
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Obx(
                                                  () => GestureDetector(
                                                    onTap: discountController.isApplyingDiscount.value
                                                        ? null
                                                        : () async {
                                                            FocusScope.of(context).unfocus();
                                                            // If discount is already applied, remove it
                                                            if (discountController.appliedDiscountCodes.isNotEmpty) {
                                                              isLoading.value = true;
                                                              final result = await discountController.removeDiscount(
                                                                discountController.appliedDiscountCodes.first,
                                                                cartController.cartId.value,
                                                              );
                                                              if (result != null && result['success'] == true) {
                                                                // Force refresh checkout URL by updating cart item
                                                                await cartController.forceRefreshCheckoutUrl();

                                                                couponController.clear();
                                                              }
                                                              isLoading.value = false;
                                                              return;
                                                            }

                                                            // Apply new discount
                                                            isLoading.value = true;
                                                            final result = await discountController.applyDiscount(
                                                              couponController.text.trim(),
                                                              cartController.cartId.value,
                                                            );

                                                            if (result != null && result['success'] == true) {
                                                              // Force refresh checkout URL by updating cart item
                                                              await cartController.forceRefreshCheckoutUrl();
                                                            } else {
                                                              discountController.lastDiscountError.value =
                                                                  result != null && result['error'] != null
                                                                  ? result['error']
                                                                  : "Failed to apply discount";
                                                            }
                                                            isLoading.value = false;
                                                          },
                                                    child: discountController.isApplyingDiscount.value
                                                        ? SizedBox()
                                                        : myText(
                                                            discountController.appliedDiscountCodes.isNotEmpty
                                                                ? S.of(context).remove
                                                                : S.of(context).apply,
                                                            13,
                                                            FontWeight.w600,
                                                            AppColors.black,
                                                            TextAlign.center,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Recommended products`
                            Container(
                              padding: EdgeInsets.all(12),

                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  myText(
                                    S.of(context).youMayAlsoLike,
                                    16,
                                    FontWeight.bold,
                                    Colors.black,
                                    TextAlign.left,
                                  ),

                                  Obx(
                                    () {
                                      // Get list of product IDs that are already in the cart
                                      final cartProductIds = cartController.lines
                                          .map((line) => line.merchandise.productId)
                                          .toSet();

                                      // Filter out products that are already in the cart
                                      final filteredProducts = cartController.alsoLikeCategory
                                          .where((product) => !cartProductIds.contains(product.id))
                                          .toList();

                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: filteredProducts
                                            .map(
                                              (product) => RecommendedProductCard(
                                                product: product,
                                              ),
                                            )
                                            .toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Checkout section
                  Obx(
                    () {
                      if (cartController.lines.isEmpty) {
                        return SizedBox.shrink();
                      }

                      return Container(
                        width: Get.width,
                        color: AppColors.white,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          spacing: 8,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                myText(
                                  S.of(context).subtotal,
                                  14,
                                  FontWeight.bold,
                                  AppColors.black,
                                  TextAlign.left,
                                ),
                                myText(
                                  "${double.tryParse(cartController.subtotal.value)?.toStringAsFixed(3)} ${cartController.currencyCode.value}",
                                  14,
                                  FontWeight.bold,
                                  AppColors.black,
                                  TextAlign.left,
                                ),
                              ],
                            ),
                            if (discountController.appliedDiscountCodes.isNotEmpty)
                              Row(
                                spacing: 4,
                                children: [
                                  myText(
                                    S.of(context).youSaved,
                                    12,
                                    FontWeight.bold,
                                    AppColors.success,
                                    TextAlign.left,
                                  ),
                                  myText(
                                    "${cartController.totalDiscountAmount.value} ${cartController.currencyCode.value}",
                                    12,
                                    FontWeight.bold,
                                    AppColors.success,
                                    TextAlign.left,
                                  ),
                                ],
                              ),

                            RoundButton1(
                              text: S.of(context).checkout,
                              backgroundColor: AppColors.black,
                              borderColor: AppColors.black,
                              height: 45,

                              width: Get.width,
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.white,
                                size: 14,
                              ),
                              radius: 10,
                              onClick: () async {
                                cartController.checkoutUrl.value.isNotEmpty
                                    ? await launchUrl(
                                        Uri.parse(cartController.checkoutUrl.value),
                                        mode: LaunchMode.externalApplication,
                                      )
                                    : null;
                              },
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              textcolor: AppColors.white,
                              align: TextAlign.center,
                              isheading: false,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              // loader
              if (isLoading.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: Center(
                      child: loader(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Container emptyCart(BuildContext context) {
    return Container(
      color: AppColors.white,
      width: double.infinity,
      height: Get.height * 0.25,

      alignment: Alignment.center,

      padding: const EdgeInsets.all(12.0),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          SvgPicture.asset(
            "assets/icons/empty_cart.svg",
            width: 50,
            color: AppColors.grey.withOpacity(0.5),
          ),
          Column(
            spacing: 6,
            children: [
              myText(
                S.of(context).yourCartIsEmpty,
                18,
                FontWeight.w900,
                AppColors.darkGrey,
                TextAlign.center,
              ),
              myText(
                S.of(context).addSomeProductsToYourCart,
                14,
                FontWeight.w500,
                AppColors.grey,
                TextAlign.center,
              ),
            ],
          ),

          RoundButton(
            text: S.of(context).shopNow,
            backgroundColor: AppColors.black,
            borderColor: AppColors.black,
            height: 45,
            width: Get.width,
            radius: 10,
            onClick: () {
              widget.tabController!.jumpToTab(0); // Adjust index based on your tab structure
            },
            fontSize: 16,
            fontWeight: FontWeight.w800,
            textcolor: AppColors.white,
            align: TextAlign.center,
            isheading: false,
          ),
        ],
      ),
    );
  }
}
