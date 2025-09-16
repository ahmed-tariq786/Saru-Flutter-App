import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/screens/Collection/collection_screen.dart';
import 'package:saru/screens/Search/search.dart';
import 'package:saru/services/product_service.dart';
import 'package:saru/widgets/Product/product_card.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.tabController});

  final PersistentTabController? tabController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List images = [
    "assets/images/banner1.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];
  int _currentImageIndex = 0;
  PageController _pageController = PageController();

  final productsController = Get.find<ProductsController>();

  @override
  void initState() {
    _currentImageIndex = 0;
    _pageController = PageController(initialPage: 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Row(
          spacing: 8,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: SearchScreen(),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  height: 45,

                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.search,
                        color: AppColors.darkGrey.withOpacity(0.5),
                        size: 18,
                      ),
                      myText(
                        S.of(context).search,
                        15,
                        FontWeight.w500,
                        AppColors.darkGrey.withOpacity(0.5),
                        TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                widget.tabController!.jumpToTab(1); // Adjust index based on your tab structure
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  "assets/icons/Categories.svg",

                  fit: BoxFit.scaleDown,
                  color: AppColors.darkGrey.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        excludeHeaderSemantics: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
        ),
      ),

      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Banners
              SizedBox(
                height: Get.height * 0.45,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,

                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        final imageUrl = images[index];
                        return Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        );
                      },
                    ),

                    Positioned(
                      bottom: 10,
                      left: 0,

                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                          child: DotsIndicator(
                            dotsCount: 3,
                            mainAxisSize: MainAxisSize.min,
                            position: _currentImageIndex.toDouble(),
                            decorator: DotsDecorator(
                              size: const Size.square(6.0),
                              activeSize: const Size(14.0, 6.0),
                              spacing: const EdgeInsets.all(3),
                              activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              activeColor: AppColors.black,
                              color: AppColors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Best Sellers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        myText(
                          S.of(context).bestSeller,
                          16,
                          FontWeight.bold,
                          Colors.black,
                          TextAlign.left,
                        ),
                        GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: CollectionScreen(
                                id: "gid://shopify/Collection/471890198782",
                                title: S.of(context).bestSeller,
                              ),
                              withNavBar: true, // <--- keeps the bottom bar visible
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Row(
                            children: [
                              myText(
                                S.of(context).viewAll,
                                13,
                                FontWeight.w400,
                                Colors.black,
                                TextAlign.left,
                              ),

                              SizedBox(
                                width: 5,
                              ),

                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    // Best Sellers List
                    Obx(
                      () => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: productsController.homePage1
                              .map(
                                (product) => Row(
                                  children: [
                                    ProductCard(
                                      product: product,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    // Banner 4
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/banner4.webp",
                        fit: BoxFit.cover,

                        alignment: Alignment.bottomCenter,
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    // Explore Our Products
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        myText(
                          S.of(context).exploreOurProducts,
                          16,
                          FontWeight.bold,
                          Colors.black,
                          TextAlign.left,
                        ),
                        GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: CollectionScreen(
                                id: "gid://shopify/Collection/471890264318",
                                title: S.of(context).exploreOurProducts,
                              ),
                              withNavBar: true, // <--- keeps the bottom bar visible
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Row(
                            children: [
                              myText(
                                S.of(context).viewAll,
                                13,
                                FontWeight.w400,
                                Colors.black,
                                TextAlign.left,
                              ),

                              SizedBox(
                                width: 5,
                              ),

                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    // Explore Our Products List
                    Obx(
                      () => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: productsController.homePage2
                              .map(
                                (product) => Row(
                                  children: [
                                    ProductCard(
                                      product: product,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    // Banner 5
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/banner5.webp",
                        fit: BoxFit.cover,

                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
