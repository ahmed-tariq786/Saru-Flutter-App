import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/models/filters.dart';
import 'package:saru/models/product.dart';
import 'package:saru/screens/Categories/filter_bottomseet.dart';
import 'package:saru/services/collection_service.dart';
import 'package:saru/widgets/Product/collection_product_card.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key, required this.vendor, required this.title});

  final String vendor;
  final String title;

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final collectionController = Get.find<CollectionController>();

  RxList<Product> products = <Product>[].obs;

  RxList<ProductFilter> filters = <ProductFilter>[].obs;
  RxMap<String, dynamic> pageInfo = <String, dynamic>{}.obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  final RxMap<String, Map<String, List<String>>> appliedFilterSelections = RxMap<String, Map<String, List<String>>>();
  final RxMap<String, Map<String, dynamic>> appliedSelectedSortOption = RxMap<String, Map<String, dynamic>>();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _loadData();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
    super.initState();
  }

  void _loadData() async {
    isLoading.value = true;
    final result = await collectionController.fetchProductsByVendor(widget.vendor);
    products.value = result.products;
    print(products.length);
    filters.value = result.filters;
    pageInfo.value = result.pageInfo!;
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: myText(
          widget.title,
          18,
          FontWeight.w600,
          Colors.black,
          TextAlign.start,
        ),
        scrolledUnderElevation: 0,
        leading: backButton(context),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(
            child: loader(context),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            child: Column(
              children: [
                // Your filter widgets go here
                TweenAnimationBuilder<double>(
                  key: ValueKey(widget.vendor),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductsHeader(products, filters, widget.vendor),
                      _buildAppliedFiltersChips(widget.vendor, filters),
                      _buildProductsGrid(products, products.isEmpty),
                      if (isLoadingMore.value) _buildLoadingMoreIndicator(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: Directionality(textDirection: TextDirection.ltr, child: loader(context)),
      ),
    );
  }

  // ==================== API CALLS ====================

  Future<void> _loadMoreProducts() async {
    final vendorId = widget.vendor;
    final pageInfo = this.pageInfo;

    if (isLoadingMore.value == true || pageInfo['hasNextPage'] == false) return;

    isLoadingMore.value = true;

    try {
      final result = await collectionController.fetchProductsByVendor(
        vendorId,
        selectedFilters: [],
        after: pageInfo['endCursor'],
        selectedSortOption: appliedSelectedSortOption[vendorId],
      );

      final existingProducts = List<Product>.from(products);
      existingProducts.addAll(result.products);

      products.value = existingProducts;
      filters.value = result.filters;
      pageInfo.value = result.pageInfo!;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ==================== EVENT HANDLERS ====================

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    try {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    } catch (e) {
      print('Scroll listener error: $e');
    }
  }

  // ==================== FILTER MANAGEMENT ====================

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
        ? _convertSelectionsToShopifyFormat(currentFilters, filters)
        : <Map<String, dynamic>>[];

    try {
      isLoading.value = true;

      final result = await collectionController.fetchProductsByVendor(
        collectionId,
        selectedFilters: shopifyFilters,
        selectedSortOption: null, // No sort option
      );

      products.value = result.products;
      filters.value = result.filters;
      pageInfo.value = result.pageInfo!;
    } catch (e) {
      print("Error removing sort option: $e");
    } finally {
      isLoading.value = false;
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
    if (sortChanged) pageInfo.remove(collectionId);

    try {
      isLoading.value = true;

      final result = await collectionController.fetchProductsByVendor(
        collectionId,
        selectedFilters: shopifyFilters,
        selectedSortOption: sortOption ?? {"sortKey": "BEST_SELLING", "reverse": false}, // Default if null
      );

      products.value = result.products;
      filters.value = result.filters;
      pageInfo.value = result.pageInfo!;
    } catch (e) {
      print("Error applying filters: $e");
    } finally {
      isLoading.value = false;
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
      isLoading.value = true;

      final result = await collectionController.fetchProductsByVendor(
        collectionId,
        selectedFilters: shopifyFilters,
      );

      products.value = result.products;
      this.filters.value = result.filters;
      pageInfo.value = result.pageInfo!;
    } catch (e) {
      print("Error removing filter: $e");
    } finally {
      isLoading.value = false;
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
}
