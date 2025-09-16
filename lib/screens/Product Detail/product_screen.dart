import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/models/product.dart';
import 'package:saru/models/variant.dart';
import 'package:saru/screens/Product%20Detail/image_viewer.dart';
import 'package:saru/screens/Vendor/vendor_screen.dart';
import 'package:saru/services/cart_service.dart';
import 'package:saru/services/favorites_service.dart';
import 'package:saru/services/product_service.dart';
import 'package:saru/widgets/Product/badge.dart';
import 'package:saru/widgets/Product/recommended_product_card.dart';
import 'package:saru/widgets/Product/sale.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/html.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/rtl_svg.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _currentImageIndex = 0;
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  final favoritesController = Get.find<FavoritesController>();
  bool _showTitleInAppBar = false;
  final GlobalKey _titleKey = GlobalKey();

  final RxInt _selectedQuantity = 1.obs;

  final RxInt _selectedTabIndex = 0.obs; // Add this for custom tab handling

  final RxBool _seeMore = false.obs;
  final RxDouble _contentHeight = 200.0.obs;

  final productsController = Get.find<ProductsController>();
  final cartController = Get.find<CartController>();

  RxBool isRecommendedLoading = false.obs;

  RxBool isAtcLoading = false.obs;

  @override
  void initState() {
    _loadData();

    super.initState();
  }

  void _loadData() async {
    _currentImageIndex = 0;
    _pageController = PageController(initialPage: 0);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize with first variant if available
    if (widget.product.variants.isNotEmpty) {
      // Initialize selectedOptions with first variant's options
      final firstVariant = widget.product.variants.first;
      firstVariant.selectedOptions.forEach((key, value) {
        selectedOptions[key] = value;
      });
    }

    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isRecommendedLoading.value = true;
      await productsController.fetchRecommendedProducts(widget.product.id);
      isRecommendedLoading.value = false;
    });

    // Start auto-scroll timer if there are multiple images
    if (widget.product.images.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && widget.product.images.isNotEmpty) {
        final nextIndex = (_currentImageIndex + 1) % widget.product.images.length;
        _pageController.animateToPage(
          nextIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Get the position of the title widget
    final RenderBox? titleBox = _titleKey.currentContext?.findRenderObject() as RenderBox?;
    if (titleBox != null) {
      final titlePosition = titleBox.localToGlobal(Offset.zero);
      final titleBottom = titlePosition.dy + titleBox.size.height;

      // Check if title is going off screen (considering AppBar height)
      final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top - 5;

      setState(() {
        _showTitleInAppBar = titleBottom < appBarHeight;
      });
    }
  }

  final RxMap<String, String> selectedOptions = <String, String>{}.obs;

  bool get hasMultipleVariants => widget.product.variants.length > 1;

  Variant? get selectedVariant {
    if (!hasMultipleVariants) {
      return widget.product.variants.first;
    }

    try {
      return widget.product.variants.firstWhere(
        (v) => v.selectedOptions.entries.every(
          (e) => selectedOptions[e.key] == e.value, // 🔑 use .value
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _showTitleInAppBar ? AppColors.white.withOpacity(1.0) : AppColors.white.withOpacity(0.0),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.light,
            ),
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: InkWell(
                  onTap: () {
                    PersistentNavBarNavigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Center(
                    child: directionalSvg(
                      'assets/icons/Back.svg',
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ),

            title: AnimatedOpacity(
              opacity: _showTitleInAppBar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedSlide(
                offset: _showTitleInAppBar ? const Offset(0, 0) : const Offset(0, 0.5),
                duration: const Duration(milliseconds: 200),
                child: myText(
                  widget.product.title,
                  16,
                  FontWeight.w600,
                  AppColors.black,
                  TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            actions: [
              Opacity(
                opacity: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: directionalSvg(
                    'assets/icons/Back.svg',
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SizedBox(
        height: Get.height,
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      //Image Carousel
                      Container(
                        foregroundDecoration: BoxDecoration(
                          color: AppColors.prForeground,
                        ),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                        ),
                        child: SizedBox(
                          height: Get.width * 0.9,
                          child: PageView.builder(
                            controller: _pageController,
                            physics: widget.product.images.length > 1 ? null : NeverScrollableScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index % widget.product.images.length;
                              });
                            },
                            itemBuilder: (context, index) {
                              final imageIndex = index % widget.product.images.length;
                              final imageUrl = widget.product.images[imageIndex];
                              return Container(
                                alignment: Alignment.bottomCenter,
                                child: CacheImage(
                                  pic: imageUrl,
                                  width: Get.width * 0.9,
                                  height: Get.width,
                                  radius: 0,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Image Dots
                      if (widget.product.images.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                              child: DotsIndicator(
                                dotsCount: widget.product.images.length,
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

                      // Enlarge Button
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            _openFullScreenImageViewer(_currentImageIndex, widget.product.images);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              "assets/icons/enlarge.svg",
                              width: 12,
                            ),
                          ),
                        ),
                      ),

                      //Tag
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 10,
                        child: tags(widget.product.tags),
                      ),
                    ],
                  ),

                  //Product Top
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //vendor and fav
                        if (widget.product.vendor.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigate to vendor screen
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: VendorScreen(
                                      vendor: widget.product.vendor,
                                      title: widget.product.vendor,
                                    ),
                                    withNavBar: true, // <--- keeps the bottom bar visible
                                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                  );
                                },
                                child: myText(
                                  widget.product.vendor,
                                  14,
                                  FontWeight.w800,
                                  AppColors.black,
                                  TextAlign.left,
                                ),
                              ),
                              Obx(
                                () => favoritesController.isFavorited(widget.product.id)
                                    ? GestureDetector(
                                        onTap: () {
                                          favoritesController.toggleFavorite(widget.product.id);
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/Fav_select.svg",
                                          width: 22.w,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          favoritesController.toggleFavorite(widget.product.id);
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/Fav.svg",
                                          width: 22.w,
                                        ),
                                      ),
                              ),
                            ],
                          ),

                        // Title and Fav
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                key: _titleKey,
                                child: myText(
                                  widget.product.title,
                                  18,
                                  FontWeight.w500,
                                  AppColors.black,
                                  TextAlign.left,
                                ),
                              ),
                            ),
                            if (widget.product.vendor.isEmpty)
                              Obx(
                                () => favoritesController.isFavorited(widget.product.id)
                                    ? GestureDetector(
                                        onTap: () {
                                          favoritesController.toggleFavorite(widget.product.id);
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/Fav_select.svg",
                                          width: 22.w,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          favoritesController.toggleFavorite(widget.product.id);
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/Fav.svg",
                                          width: 22.w,
                                        ),
                                      ),
                              ),
                          ],
                        ),

                        // variant options
                        if (hasMultipleVariants)
                          Obx(
                            () => Column(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._groupOptions(widget.product.variants).entries.map((entry) {
                                  final optionName = entry.key;
                                  final values = entry.value.toList();

                                  return Column(
                                    spacing: 0,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          myText(
                                            optionName.toUpperCase(),
                                            12,
                                            FontWeight.w600,
                                            AppColors.black,
                                            TextAlign.left,
                                          ),
                                          myText(
                                            selectedVariant!.selectedOptions[optionName] != null
                                                ? ": ${selectedVariant!.selectedOptions[optionName]!.capitalizeFirst!}"
                                                : "",
                                            14,
                                            FontWeight.w500,
                                            AppColors.black,
                                            TextAlign.left,
                                          ),
                                        ],
                                      ),

                                      Wrap(
                                        spacing: 8,
                                        children: values.map((options) {
                                          final isSelected = selectedOptions[optionName] == options;

                                          return ChoiceChip(
                                            backgroundColor: AppColors.white,
                                            selectedColor: AppColors.black,
                                            pressElevation: 0,
                                            surfaceTintColor: Colors.transparent,
                                            showCheckmark: false,
                                            side: BorderSide(
                                              color: isSelected ? AppColors.black : AppColors.grey,
                                            ),
                                            label: myText(
                                              options.capitalizeFirst!,
                                              14,
                                              FontWeight.w500,
                                              isSelected ? AppColors.white : AppColors.black,
                                              TextAlign.left,
                                            ),
                                            selected: isSelected,
                                            onSelected: (_) {
                                              selectedOptions[optionName] = options;
                                              // Find the variant’s image URL
                                              final variantImageUrl = selectedVariant?.image;

                                              if (variantImageUrl != null && widget.product.images.isNotEmpty) {
                                                // Find index of the image in product images
                                                final index = widget.product.images.indexWhere(
                                                  (img) => img == variantImageUrl,
                                                );

                                                if (index != -1) {
                                                  setState(() {
                                                    _currentImageIndex = index;
                                                  });
                                                  _pageController.jumpToPage(index);
                                                }
                                              }

                                              if (selectedVariant!.quantityAvailable < _selectedQuantity.value &&
                                                  selectedVariant!.quantityAvailable > 0) {
                                                _selectedQuantity.value = 1;
                                              }
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),

                        // Price Section
                        Obx(
                          () => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedVariant!.compareAtPrice != null)
                                myText(
                                  "${selectedVariant!.compareAtPrice!.toStringAsFixed(3)} ${selectedVariant!.currency}",

                                  14,
                                  FontWeight.w800,
                                  AppColors.darkGrey.withOpacity(0.5),
                                  TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      myText(
                                        "${selectedVariant!.price!.toStringAsFixed(3)} ${selectedVariant!.currency}",
                                        18,
                                        FontWeight.w800,
                                        Colors.black,
                                        TextAlign.left,
                                      ),
                                      if (selectedVariant!.compareAtPrice != null)
                                        sale(selectedVariant!.price!, selectedVariant!.compareAtPrice!),
                                    ],
                                  ),

                                  if (selectedVariant!.quantityAvailable != 0)
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
                                        spacing: 8,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (_selectedQuantity.value > 1) {
                                                _selectedQuantity.value--;
                                              }
                                            },
                                            child: Container(
                                              width: 30,

                                              height: 30,
                                              alignment: Alignment.center,
                                              child: SvgPicture.asset(
                                                "assets/icons/minus.svg",
                                              ),
                                            ),
                                          ),

                                          myText(
                                            _selectedQuantity.value.toString(),
                                            14,
                                            FontWeight.w800,
                                            Colors.black,
                                            TextAlign.left,
                                          ),

                                          GestureDetector(
                                            onTap: () {
                                              if (_selectedQuantity.value < selectedVariant!.quantityAvailable) {
                                                _selectedQuantity.value++;
                                              }
                                            },
                                            child: Opacity(
                                              opacity: _selectedQuantity.value < selectedVariant!.quantityAvailable
                                                  ? 1.0
                                                  : 0.3,
                                              child: Container(
                                                width: 30,

                                                height: 30,
                                                alignment: Alignment.center,
                                                child: SvgPicture.asset(
                                                  "assets/icons/plus.svg",
                                                ),
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
                  ),

                  Container(
                    height: 10,
                    color: AppColors.white,
                  ),
                  Divider(
                    color: AppColors.lightGrey.withOpacity(0.4),
                    height: 1,
                    thickness: 3,
                  ),

                  // Custom Tab Bar
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.lightGrey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: Get.width * 0.5,
                                child: GestureDetector(
                                  onTap: () {
                                    _selectedTabIndex.value = 0;
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                      child: Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontFamily: "Arial",
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTabIndex.value == 0 ? AppColors.black : AppColors.grey,
                                          ),
                                          child: Text(S.of(context).Description),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.product.specifications.isNotEmpty)
                                SizedBox(
                                  width: Get.width * 0.5,
                                  child: GestureDetector(
                                    onTap: () {
                                      _selectedTabIndex.value = 1;
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: Duration(milliseconds: 200),
                                            style: TextStyle(
                                              fontFamily: "Arial",
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: _selectedTabIndex.value == 1 ? AppColors.black : AppColors.grey,
                                            ),
                                            child: Text(S.of(context).Specifications),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Animated bottom border indicator
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            bottom: 0,
                            left: Directionality.of(context) == TextDirection.rtl
                                ? (_selectedTabIndex.value == 0 ? MediaQuery.of(context).size.width * 0.5 : 0)
                                : (_selectedTabIndex.value == 0 ? 0 : MediaQuery.of(context).size.width * 0.5),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: 1,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Custom Tab Content
                  Obx(
                    () => Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.only(
                        left: 6.0,
                        right: 6.0,
                      ),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_selectedTabIndex.value),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: child,
                          );
                        },
                        child: _selectedTabIndex.value == 0
                            ? Stack(
                                children: [
                                  SizedBox(
                                    key: ValueKey('Description'),
                                    width: double.infinity,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 600),
                                          curve: Curves.easeInOut,
                                          height: _seeMore.value ? _contentHeight.value : 200,
                                          child: ClipRect(
                                            child: SingleChildScrollView(
                                              physics: NeverScrollableScrollPhysics(),
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  // Measure content height after build
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    final RenderBox? renderBox =
                                                        context.findRenderObject() as RenderBox?;
                                                    if (renderBox != null) {
                                                      final height = renderBox.size.height;
                                                      if (_contentHeight.value != height && height > 200) {
                                                        _contentHeight.value = height;
                                                      }
                                                    }
                                                  });
                                                  return html(widget.product.description);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (!_seeMore.value && widget.product.description.length > 300)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              AppColors.white,
                                              AppColors.white.withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                        alignment: Alignment.bottomCenter,
                                      ),
                                    ),
                                ],
                              )
                            : SizedBox(
                                key: ValueKey('Specifications'),

                                child: html(widget.product.specifications),
                              ),
                      ),
                    ),
                  ),

                  // see more
                  Obx(() {
                    if (_selectedTabIndex.value == 0) {
                      return Container(
                        color: AppColors.white,
                        child: GestureDetector(
                          onTap: () {
                            _seeMore.value = !_seeMore.value;
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              myText(
                                _seeMore.value ? S.of(context).seeLess : S.of(context).seeMore,
                                14,
                                FontWeight.w500,
                                AppColors.secondary,
                                TextAlign.center,
                              ),
                              Icon(
                                _seeMore.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: 20,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox.shrink();
                  }),

                  Container(
                    height: 10,
                    color: AppColors.white,
                  ),

                  Divider(
                    color: AppColors.lightGrey.withOpacity(0.4),
                    height: 1,
                    thickness: 3,
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  // Recommended Products
                  Obx(
                    () => isRecommendedLoading.value
                        ? loader(context)
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                myText(
                                  S.of(context).recommendedProducts,
                                  14,
                                  FontWeight.w800,
                                  AppColors.black,
                                  TextAlign.left,
                                ),

                                SizedBox(
                                  height: 10,
                                ),

                                Obx(
                                  () => Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: productsController.recommendedProducts
                                        .map(
                                          (product) => RecommendedProductCard(
                                            product: product,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  SizedBox(height: 80),
                ],
              ),
            ),

            // Fixed bottom button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(
                () {
                  // Force GetX to track selectedOptions by accessing it
                  // ignore: invalid_use_of_protected_member
                  selectedOptions.value;
                  final variant = selectedVariant;

                  return Obx(
                    () => Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(12.0),
                      child: variant != null && variant.quantityAvailable != 0
                          ? RoundButton(
                              text: S.of(context).atc,
                              backgroundColor: AppColors.black,
                              borderColor: AppColors.black,
                              height: 45,
                              loading: isAtcLoading.value,
                              width: Get.width,
                              icon: SvgPicture.asset(
                                "assets/icons/atc_white.svg",
                              ),
                              radius: 10,
                              onClick: () async {
                                isAtcLoading.value = true;

                                if (!cartController.hasExistingCart()) {
                                  await cartController.createCart();
                                }

                                await cartController.addToCart(
                                  cartController.cartId.value,
                                  variant.id,
                                  _selectedQuantity.value,
                                );

                                isAtcLoading.value = false;
                              },
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              textcolor: AppColors.white,
                              align: TextAlign.center,
                              isheading: false,
                            )
                          : Opacity(
                              opacity: 0.5,
                              child: RoundButton(
                                text: S.of(context).outOfStock,
                                backgroundColor: AppColors.black,
                                borderColor: AppColors.black,
                                height: 45,
                                width: Get.width,
                                icon: SvgPicture.asset(
                                  "assets/icons/atc_white.svg",
                                ),
                                radius: 10,
                                onClick: () {},
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                textcolor: AppColors.white,
                                align: TextAlign.center,
                                isheading: false,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Set<String>> _groupOptions(List<Variant> variants) {
    final Map<String, Set<String>> grouped = {};

    for (final variant in variants) {
      variant.selectedOptions.forEach((key, value) {
        grouped.putIfAbsent(key, () => <String>{}).add(value);
      });
    }

    return grouped;
  }

  void _openFullScreenImageViewer(int initialIndex, List<dynamic> images) {
    final List<String> imageUrls = images.map((image) => image.toString()).toList();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) {
        return FullScreenImageViewer(
          initialIndex: initialIndex,
          images: imageUrls,
        );
      },
    );
  }
}
