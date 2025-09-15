import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/services/cart_service.dart';
import 'package:saru/services/favorites_service.dart';
import 'package:saru/widgets/Product/collection_product_card.dart';
import 'package:saru/widgets/Product/recommended_product_card.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final favoritesController = Get.find<FavoritesController>();
  final cartController = Get.find<CartController>();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    favoritesController.isLoading.value = true;
    await favoritesController.fetchProductsByIds(favoritesController.favoriteIds);
    favoritesController.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: myText(
          S.of(context).favorites,
          18,
          FontWeight.w600,
          Colors.black,
          TextAlign.start,
        ),
        leading: backButton(context),
        backgroundColor: AppColors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Obx(
        () => favoritesController.isLoading.value
            ? Center(
                child: loader(context),
              )
            : TweenAnimationBuilder<double>(
                key: ValueKey("1"),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: favoritesController.products
                              .map(
                                (product) => CollectionProductCard(
                                  product: product,
                                  isInCollection: false,
                                ),
                              )
                              .toList(),
                        ),
                        Column(
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
                              () => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: cartController.alsoLikeCategory
                                    .map(
                                      (product) => RecommendedProductCard(
                                        product: product,
                                        isInCollection: false,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
