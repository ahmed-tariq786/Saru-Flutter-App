import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/models/filters.dart';
import 'package:saru/models/product.dart';
import 'package:saru/screens/Categories/filter_bottomseet.dart';
import 'package:saru/services/collection_service.dart';
import 'package:saru/services/menu_service.dart';
import 'package:saru/widgets/Product/collection_product_card.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/rtl_svg.dart';

class MainCategoryScreen extends StatefulWidget {
  const MainCategoryScreen({
    super.key,
    required this.menuLvl1,
    required this.menuLvl2,
    required this.menuLvl3,
    required this.selectedTab,
  });

  final String menuLvl1;
  final String menuLvl2;
  final String menuLvl3;
  final String selectedTab;

  @override
  State<MainCategoryScreen> createState() => _MainCategoryScreenState();
}

class _MainCategoryScreenState extends State<MainCategoryScreen> {
  // ==================== CONTROLLERS & SERVICES ====================
  final menusController = Get.find<MenusController>();
  final collectionController = Get.find<CollectionController>();

  // ==================== STATE VARIABLES ====================
  // UI State
  final ScrollController _scrollController = ScrollController();
  final PageController pageController = PageController();
  final RxString selectedTab = "".obs;
  final RxMap<String, dynamic> selectedCategoryData = RxMap<String, dynamic>();
  bool _showCollapsedTitle = false;

  // Tab Management
  List<String> tabTitles = [];
  List<dynamic> tabData = [];

  // Data Management
  final RxMap<String, List<Product>> categoryProductData = RxMap<String, List<Product>>();
  final RxMap<String, List<ProductFilter>> categoryFilterData = RxMap<String, List<ProductFilter>>();
  final RxMap<String, Map<String, dynamic>?> categoryPageData = RxMap<String, Map<String, dynamic>?>();

  // Loading States
  final RxMap<String, bool> categoryLoadingState = <String, bool>{}.obs;
  final RxMap<String, bool> _isLoadingMore = <String, bool>{}.obs;

  // Filter & Sort Management
  final RxMap<String, Map<String, List<String>>> appliedFilterSelections = RxMap<String, Map<String, List<String>>>();
  final RxMap<String, Map<String, dynamic>> appliedSelectedSortOption = RxMap<String, Map<String, dynamic>>();

  // ==================== LIFECYCLE METHODS ====================
  @override
  void initState() {
    super.initState();
    selectedTab.value = widget.selectedTab.isNotEmpty ? widget.selectedTab : "All products";
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  // ==================== BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    if (tabTitles.isEmpty) {
      selectedTab.value = widget.selectedTab.isNotEmpty ? widget.selectedTab : S.of(context).allProducts;
      _initializeTabData();
      _fetchInitialTabData();
    }

    return Obx(() {
      final hasImage =
          selectedCategoryData["collectionImage"] != null && selectedCategoryData["collectionImage"].isNotEmpty;

      return Scaffold(
        backgroundColor: AppColors.bg,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(hasImage),
            _buildStickyTabs(),
          ],
          body: PageView.builder(
            controller: pageController,
            onPageChanged: (value) async {
              selectedTab.value = tabTitles[value];
              final data = tabData[value];

              if (data['isAllProducts'] == true) {
                _updateCategoryData(tabTitles[value], isAllProducts: true);
              } else if (data['level2Item'] != null) {
                _updateCategoryData(tabTitles[value], level2Item: data['level2Item']);
              } else if (data['level3Item'] != null) {
                _updateCategoryData(tabTitles[value], level3Item: data['level3Item']);
              }

              final collectionId = _getCollectionIdForIndex(value);
              if (!categoryProductData.containsKey(collectionId)) {
                await _fetchProductsForCollection(collectionId);
              }
            },
            itemCount: tabTitles.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: _buildProductsView(index),
              );
            },
          ),
        ),
      );
    });
  }

  // ==================== UI BUILDERS ====================
  Widget _buildSliverAppBar(bool hasImage) {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      expandedHeight: hasImage ? 150.0 : null,
      floating: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: InkWell(
            onTap: () => PersistentNavBarNavigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: Center(
              child: directionalSvg('assets/icons/Back.svg', color: AppColors.black),
            ),
          ),
        ),
      ),
      title: Obx(
        () => TweenAnimationBuilder<double>(
          key: ValueKey(selectedCategoryData["collectionTitle"]),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, opacity, child) {
            return Opacity(
              opacity: (_showCollapsedTitle || !hasImage) ? opacity : 0.0,
              child: child,
            );
          },
          child: myText(
            selectedCategoryData["collectionTitle"] ?? "",
            18,
            FontWeight.w700,
            AppColors.black,
            TextAlign.center,
          ),
        ),
      ),
      flexibleSpace: hasImage
          ? TweenAnimationBuilder<double>(
              key: ValueKey(selectedCategoryData["collectionImage"]),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
              child: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    CacheImage(
                      pic: selectedCategoryData["collectionImage"],
                      width: Get.width,
                      height: 300,
                      fit: BoxFit.cover,
                      radius: 0,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.black.withOpacity(0.7),
                              AppColors.black.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: Directionality.of(context) == TextDirection.rtl ? 0 : 12,
                      right: Directionality.of(context) == TextDirection.rtl ? 12 : 0,
                      child: myText(
                        selectedCategoryData["collectionTitle"] ?? "Category",
                        26,
                        FontWeight.w700,
                        AppColors.white,
                        TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStickyTabs() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabDelegate(
        height: 60.h,
        child: Container(
          width: Get.width,
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.lightGrey.withOpacity(0.5),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                _buildTab(S.of(context).allProducts, isAllProducts: true),
                _buildTab(widget.menuLvl2, level2Item: level2Data),
                ...level3Data.map((item) => _buildTab(item.title, level3Item: item)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, {bool isAllProducts = false, dynamic level2Item, dynamic level3Item}) {
    return Obx(() {
      final isSelected = selectedTab.value == title;
      return GestureDetector(
        onTap: () {
          selectedTab.value = title;

          int tabIndex = tabTitles.indexOf(title);
          if (tabIndex != -1 && pageController.hasClients) {
            pageController.jumpToPage(tabIndex);
          }

          _updateCategoryData(title, isAllProducts: isAllProducts, level2Item: level2Item, level3Item: level3Item);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.darkGrey.withOpacity(0.6),
            ),
          ),
          child: myText(
            title,
            13,
            FontWeight.w400,
            isSelected ? AppColors.white : AppColors.darkGrey,
            TextAlign.left,
          ),
        ),
      );
    });
  }

  Widget _buildProductsView(int index) {
    final collectionId = _getCollectionIdForIndex(index);

    return Obx(() {
      final products = categoryProductData[collectionId] ?? [];
      final filters = categoryFilterData[collectionId] ?? [];
      final isLoading = categoryLoadingState[collectionId] == true;
      final hasData = categoryProductData.containsKey(collectionId);
      final isLoadingMore = _isLoadingMore[collectionId] == true;

      if ((!hasData && !isLoading && collectionId.isNotEmpty) || isLoading) {
        return _buildLoader();
      }

      return TweenAnimationBuilder<double>(
        key: ValueKey(collectionId),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductsHeader(products, filters, collectionId),
            _buildAppliedFiltersChips(collectionId, filters),
            _buildProductsGrid(products, hasData),
            if (isLoadingMore) _buildLoadingMoreIndicator(),
          ],
        ),
      );
    });
  }

  Widget _buildLoader() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 200.h),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: loader(context),
        ),
      ),
    );
  }

  Widget _buildProductsHeader(List<Product> products, List<ProductFilter> filters, String collectionId) {
    final hasAppliedFilters =
        appliedFilterSelections[collectionId] != null && appliedFilterSelections[collectionId]!.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            myText(S.of(context).showing, 13, FontWeight.w500, Colors.black, TextAlign.left),
            myText(" ${products.length} ", 13, FontWeight.w500, Colors.black, TextAlign.left),
            myText(S.of(context).products, 13, FontWeight.w500, Colors.black, TextAlign.left),
          ],
        ),

        GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet(
              useRootNavigator: true,
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => FilterBottomsheet(
                filters: filters,
                appliedFilters: appliedFilterSelections[collectionId],
                appliedSortOption: appliedSelectedSortOption[collectionId],
              ),
            );

            if (result != null) {
              await _applyFilters(collectionId, result);
            }
          },
          child: Stack(
            children: [
              Icon(Icons.filter_alt_outlined, color: AppColors.darkGrey),
              if (hasAppliedFilters || appliedSelectedSortOption[collectionId] != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppliedFiltersChips(String collectionId, List<ProductFilter> filters) {
    final appliedFilters = appliedFilterSelections[collectionId];
    final appliedSort = appliedSelectedSortOption[collectionId];

    // If no filters and no sort applied, return empty
    if ((appliedFilters == null || appliedFilters.isEmpty) && appliedSort == null) {
      return SizedBox.shrink();
    }

    List<Widget> chips = [];

    // Add sort chip (but not for empty sort key)
    if (appliedSort != null && appliedSort['sortKey'] != null && appliedSort['sortKey'].toString().isNotEmpty) {
      final sortLabel = _getSortLabel(appliedSort);
      chips.add(
        _buildSortChip(
          sortLabel,
          () => _removeSortOption(collectionId),
        ),
      );
    }

    // Add filter chips
    if (appliedFilters != null && appliedFilters.isNotEmpty) {
      final filterChips = appliedFilters.entries.expand((entry) {
        final filterId = entry.key;
        final selectedValues = entry.value;
        final filter = filters.firstWhere(
          (f) => f.id == filterId,
          orElse: () => ProductFilter(id: filterId, label: filterId, type: ''),
        );

        return selectedValues.map((valueId) {
          final filterValue = filter.values.firstWhere(
            (v) => v.id == valueId,
            orElse: () => FilterValue(id: valueId, label: valueId, count: 0, input: {}),
          );

          // Translate availability labels for filter chips
          final displayLabel = filterId == "filter.v.availability"
              ? _getTranslatedAvailabilityLabel(filterValue.label)
              : filterValue.label;

          return _buildFilterChip(
            displayLabel,
            () => _removeFilter(collectionId, filterId, valueId, filters),
          );
        });
      }).toList();

      chips.addAll(filterChips);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          myText(label, 12, FontWeight.w400, AppColors.black, TextAlign.left),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          myText(label, 12, FontWeight.w400, AppColors.black, TextAlign.left),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products, bool hasData) {
    if (hasData && products.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.h),
          child: Column(
            spacing: 8,
            children: [
              myText(
                S.of(context).oopsNothingHereYet,
                18,
                FontWeight.w900,
                AppColors.darkGrey,
                TextAlign.center,
              ),
              myText(
                S.of(context).checkBackLaterOrExploreOtherCategories,
                14,
                FontWeight.w500,
                AppColors.grey,
                TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: products.map((product) => CollectionProductCard(product: product)).toList(),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: Directionality(textDirection: TextDirection.ltr, child: loader(context)),
      ),
    );
  }

  // Helper method to translate availability labels for filter chips
  String _getTranslatedAvailabilityLabel(String originalLabel) {
    final lowerLabel = originalLabel.toLowerCase();

    // Check for "out of stock" patterns first (more specific)
    if (lowerLabel.contains('out of stock') ||
        lowerLabel.contains('out stock') ||
        lowerLabel.contains('إنتهى') ||
        lowerLabel.contains('نفدت') ||
        lowerLabel.contains('غير متوفر')) {
      return S.of(context).outOfStock;
    }
    // Check for "in stock" / available patterns
    else if (lowerLabel.contains('in stock') ||
        lowerLabel.contains('available') ||
        lowerLabel.contains('متوفر') ||
        lowerLabel.contains('موجود')) {
      return S.of(context).inStock;
    }
    return originalLabel; // Return original if no match
  }

  // ==================== EVENT HANDLERS ====================

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    try {
      final offset = _scrollController.offset;
      if (offset > 100 && !_showCollapsedTitle) {
        if (mounted) setState(() => _showCollapsedTitle = true);
      } else if (offset <= 100 && _showCollapsedTitle) {
        if (mounted) setState(() => _showCollapsedTitle = false);
      }

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    } catch (e) {
      print('Scroll listener error: $e');
    }
  }

  // ==================== DATA MANAGEMENT ====================
  void _initializeTabData() {
    tabTitles = [S.of(context).allProducts, widget.menuLvl2];
    tabData = [
      {'isAllProducts': true},
      {'level2Item': level2Data},
    ];

    for (var item in level3Data) {
      tabTitles.add(item.title);
      tabData.add({'level3Item': item});
    }

    int initialIndex = tabTitles.indexOf(selectedTab.value);
    if (initialIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && pageController.hasClients) {
          pageController.jumpToPage(initialIndex);
        }
      });
    }
  }

  void _fetchInitialTabData() {
    if (selectedTab.value == S.of(context).allProducts) {
      _updateCategoryData(selectedTab.value, isAllProducts: true);
    } else if (selectedTab.value == widget.menuLvl2) {
      _updateCategoryData(selectedTab.value, level2Item: level2Data);
    } else {
      try {
        final level3Item = level3Data.firstWhere((item) => item.title == selectedTab.value);
        _updateCategoryData(selectedTab.value, level3Item: level3Item);
      } catch (e) {
        print('No matching Level 3 item found for: $selectedTab');
      }
    }
  }

  void _updateCategoryData(String title, {bool isAllProducts = false, dynamic level2Item, dynamic level3Item}) {
    _scrollToTop();
    selectedCategoryData.clear();

    if (isAllProducts && level1Data?.items.isNotEmpty == true) {
      final item = level1Data!.items[0];
      selectedCategoryData.addAll({
        'collectionId': item.collectionId ?? '',
        'collectionTitle': item.collectionTitle ?? '',
        'collectionImage': item.collectionImage ?? '',
      });
    } else if (level2Item != null) {
      selectedCategoryData.addAll({
        'collectionId': level2Item.collectionId ?? '',
        'collectionTitle': level2Item.collectionTitle ?? '',
        'collectionImage': level2Item.collectionImage ?? '',
      });
    } else if (level3Item != null) {
      selectedCategoryData.addAll({
        'collectionId': level3Item.collectionId ?? '',
        'collectionTitle': level3Item.collectionTitle ?? '',
        'collectionImage': level3Item.collectionImage ?? '',
      });
    }
  }

  String _getCollectionIdForIndex(int index) {
    final data = tabData[index];

    if (data['isAllProducts'] == true && level1Data?.items.isNotEmpty == true) {
      return level1Data!.items[0].collectionId ?? '';
    } else if (data['level2Item'] != null) {
      return data['level2Item'].collectionId ?? '';
    } else if (data['level3Item'] != null) {
      return data['level3Item'].collectionId ?? '';
    }

    return '';
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        try {
          _scrollController.animateTo(0, duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
        } catch (e) {
          print('Scroll animation error: $e');
        }
      }
    });
  }

  // ==================== API CALLS ====================
  Future<void> _fetchProductsForCollection(String collectionId) async {
    if (collectionId.isEmpty || categoryProductData.containsKey(collectionId)) return;

    try {
      categoryLoadingState[collectionId] = true;
      final result = await collectionController.fetchProductsByCollectionId(collectionId);

      categoryProductData[collectionId] = result.products;
      categoryFilterData[collectionId] = result.filters;
      categoryPageData[collectionId] = result.pageInfo;
    } catch (e) {
      print("Error fetching collection $collectionId: $e");
    } finally {
      categoryLoadingState[collectionId] = false;
    }
  }

  Future<void> _loadMoreProducts() async {
    final collectionId = selectedCategoryData['collectionId'];
    final pageInfo = categoryPageData[collectionId];

    if (_isLoadingMore[collectionId] == true || pageInfo == null || pageInfo['hasNextPage'] == false) return;

    _isLoadingMore[collectionId] = true;

    try {
      final result = await collectionController.fetchProductsByCollectionId(
        collectionId,
        selectedFilters: [],
        after: pageInfo['endCursor'],
        selectedSortOption: appliedSelectedSortOption[collectionId],
      );

      final existingProducts = List<Product>.from(categoryProductData[collectionId] ?? []);
      existingProducts.addAll(result.products);

      categoryProductData[collectionId] = existingProducts;
      categoryFilterData[collectionId] = result.filters;
      categoryPageData[collectionId] = result.pageInfo;
    } finally {
      _isLoadingMore[collectionId] = false;
    }
  }

  // ==================== FILTER MANAGEMENT ====================

  String _getSortLabel(Map<String, dynamic> sortOption) {
    final sortKey = sortOption['sortKey'];
    final reverse = sortOption['reverse'] ?? false;

    String baseLabel;
    switch (sortKey) {
      case 'RELEVANCE':
        baseLabel = S.of(context).relevance;
        break;
      case 'BEST_SELLING':
        baseLabel = S.of(context).bestSelling;
        break;
      case 'CREATED':
        baseLabel = Directionality.of(context) == TextDirection.rtl ? "الأحدث" : "New";
        break;
      case 'PRICE':
        baseLabel = reverse ? (S.of(context).highToLow) : (S.of(context).lowToHigh);
        break;
      case 'MANUAL':
        baseLabel = S.of(context).featured;
        break;

      default:
        baseLabel = sortKey ?? 'Custom Sort';
    }

    return baseLabel;
  }

  Future<void> _removeSortOption(String collectionId) async {
    // Remove the sort option
    appliedSelectedSortOption.remove(collectionId);

    // Get current filters to maintain them
    final currentFilters = appliedFilterSelections[collectionId];
    final shopifyFilters = currentFilters != null
        ? _convertSelectionsToShopifyFormat(currentFilters, categoryFilterData[collectionId] ?? [])
        : <Map<String, dynamic>>[];

    try {
      categoryLoadingState[collectionId] = true;

      final result = await collectionController.fetchProductsByCollectionId(
        collectionId,
        selectedFilters: shopifyFilters,
        selectedSortOption: null, // No sort option
      );

      categoryProductData[collectionId] = result.products;
      categoryFilterData[collectionId] = result.filters;
      categoryPageData[collectionId] = result.pageInfo;
    } catch (e) {
      print("Error removing sort option: $e");
    } finally {
      categoryLoadingState[collectionId] = false;
    }
  }

  Future<void> _applyFilters(String collectionId, Map<String, dynamic> filterResult) async {
    final rawSelections = Map<String, List<String>>.from(filterResult['rawSelections'] ?? {});
    final shopifyFilters = List<Map<String, dynamic>>.from(filterResult['shopifyFilters'] ?? []);
    final sortOption = filterResult['sortOption'];

    // Check if sort changed to reset pagination
    final sortChanged =
        appliedSelectedSortOption[collectionId]?['sortKey'] != sortOption?['sortKey'] ||
        appliedSelectedSortOption[collectionId]?['reverse'] != sortOption?['reverse'];

    // Store selections
    appliedFilterSelections[collectionId] = rawSelections;
    if (sortOption != null) {
      appliedSelectedSortOption[collectionId] = sortOption;
    } else {
      // Remove sort option completely when null (reset case)
      appliedSelectedSortOption.remove(collectionId);
    }

    // Reset pagination if sort changed
    if (sortChanged) categoryPageData.remove(collectionId);

    try {
      categoryLoadingState[collectionId] = true;

      final result = await collectionController.fetchProductsByCollectionId(
        collectionId,
        selectedFilters: shopifyFilters,
        selectedSortOption: sortOption ?? {"sortKey": "BEST_SELLING", "reverse": false}, // Default if null
      );

      categoryProductData[collectionId] = result.products;
      categoryFilterData[collectionId] = result.filters;
      categoryPageData[collectionId] = result.pageInfo;
    } catch (e) {
      print("Error applying filters: $e");
    } finally {
      categoryLoadingState[collectionId] = false;
    }
  }

  Future<void> _removeFilter(String collectionId, String filterId, String valueId, List<ProductFilter> filters) async {
    final updatedSelections = Map<String, List<String>>.from(appliedFilterSelections[collectionId] ?? {});

    updatedSelections[filterId]?.remove(valueId);
    if (updatedSelections[filterId]?.isEmpty == true) {
      updatedSelections.remove(filterId);
    }

    appliedFilterSelections[collectionId] = updatedSelections;

    // Convert to Shopify format
    final shopifyFilters = _convertSelectionsToShopifyFormat(updatedSelections, filters);

    try {
      categoryLoadingState[collectionId] = true;

      final result = await collectionController.fetchProductsByCollectionId(
        collectionId,
        selectedFilters: shopifyFilters,
      );

      categoryProductData[collectionId] = result.products;
      categoryFilterData[collectionId] = result.filters;
      categoryPageData[collectionId] = result.pageInfo;
    } catch (e) {
      print("Error removing filter: $e");
    } finally {
      categoryLoadingState[collectionId] = false;
    }
  }

  List<Map<String, dynamic>> _convertSelectionsToShopifyFormat(
    Map<String, List<String>> selections,
    List<ProductFilter> filters,
  ) {
    final shopifyFilters = <Map<String, dynamic>>[];

    selections.forEach((key, values) {
      if (key == "filter.p.vendor") {
        for (var valueId in values) {
          final vendorFilter = filters.firstWhere((f) => f.id == key);
          final vendorValue = vendorFilter.values.firstWhere((v) => v.id == valueId);
          shopifyFilters.add({"productVendor": vendorValue.label});
        }
      }
      if (key == "filter.v.availability") {
        for (var valueId in values) {
          bool isAvailable =
              valueId.toLowerCase().contains("1") ||
              valueId.toLowerCase().contains("true") ||
              valueId.toLowerCase().contains("available");
          shopifyFilters.add({"available": isAvailable});
        }
      }
      if (key == "filter.p.m.custom.offers") {
        for (var valueId in values) {
          final offersFilter = filters.firstWhere((f) => f.id == key);
          final offerValue = offersFilter.values.firstWhere((v) => v.id == valueId);
          shopifyFilters.add({
            "productMetafield": {
              "namespace": "custom",
              "key": "offers",
              "value": offerValue.label,
            },
          });
        }
      }
    });

    return shopifyFilters;
  }

  // ==================== GETTERS ====================
  get level1Data => menusController.menus[widget.menuLvl1];

  get level2Data {
    if (level1Data?.items.isEmpty != false) return null;
    final matchedItems = level1Data!.items[0].items.where((item) => item.title == widget.menuLvl2);
    return matchedItems.isNotEmpty ? matchedItems.first : null;
  }

  get level3Data => level2Data?.items ?? <dynamic>[];
}

// ==================== HELPER CLASSES ====================
class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabDelegate({required this.child, this.height = 80.0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: height, child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is! _StickyTabDelegate || oldDelegate.height != height;
  }
}
