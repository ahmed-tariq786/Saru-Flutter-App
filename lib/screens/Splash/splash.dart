import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:saru/screens/Bottom%20Bar/bottom_bar.dart';
import 'package:saru/services/cart_service.dart';
import 'package:saru/services/collection_service.dart';
import 'package:saru/services/favorites_service.dart';
import 'package:saru/services/menu_service.dart';
import 'package:saru/services/product_service.dart';
import 'package:saru/widgets/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _firstImageScale;
  late Animation<Offset> _firstImageSlide;

  final productsController = Get.put(ProductsController());
  final menusController = Get.put(MenusController());
  final cartController = Get.put(CartController());
  final collectionController = Get.put(CollectionController());
  final favoritesController = Get.put(FavoritesController());

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // Increased duration for smoother animation
    );
    _initializeAnimations();

    _loadData();

    super.initState();
  }

  Future<void> _loadData() async {
    try {
      Future.delayed(const Duration(milliseconds: 0), () async {
        _controller.forward();
        await productsController.fetchProducts();
        await menusController.fetchMainMenu();

        await cartController.loadExistingCart();

        final result = await collectionController.fetchProductsByCollectionId(
          "gid://shopify/Collection/471830659326",
        );

        await favoritesController.loadFavorites();

        cartController.alsoLikeCategory.value = result.products;

        // await cartController.clearCartData();

        if (cartController.cartId.value.isNotEmpty) {
          await cartController.fetchCart(cartController.cartId.value);
        }

        await Future.delayed(const Duration(milliseconds: 800));

        Get.offAll(
          () => const MainPage(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } catch (e) {
      print("Error during splash initialization: $e");
    }
  }

  void _initializeAnimations() {
    // First image: Smooth entry and graceful exit
    _firstImageScale =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack), // Smoother bounce
          ),
        );

    _firstImageSlide =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-2.0, 0), // Slide further for smoother transition
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.65, curve: Curves.easeInOutCubic), // Smoother slide
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: AppColors.white,
      body: Center(
        child: SizedBox(
          height: Get.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // First image animation - Enhanced with smooth transforms
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _firstImageScale.value,
                        child: Transform.translate(
                          offset: Offset(_firstImageSlide.value.dx, 0),
                          child: Opacity(
                            opacity: 1,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/logo.svg',
                      width: 200,
                    ),
                  ),
                ],
              ),
              Container(
                height: 100.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
