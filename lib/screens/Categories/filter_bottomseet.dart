import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/models/filters.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/checkbox.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';

class FilterBottomsheet extends StatefulWidget {
  const FilterBottomsheet({
    super.key,
    required this.filters,
    this.appliedFilters,
    this.appliedSortOption,
  });

  final List<ProductFilter> filters;
  final Map<String, List<String>>? appliedFilters; // Previously applied filters
  final Map<String, dynamic>? appliedSortOption; // Previously applied sort option

  @override
  State<FilterBottomsheet> createState() => _FilterBottomsheetState();
}

class _FilterBottomsheetState extends State<FilterBottomsheet> {
  var selectedFilters = <String, List<String>>{}.obs;

  final selectedSortOption = {"sortKey": "", "reverse": false}.obs;

  final expandedSubCategory = RxnString();

  // Define sort options as a method to access localized strings
  Map<String, Map<String, dynamic>> get sortOptions => {
    S.of(context).bestSelling: {
      "sortKey": "BEST_SELLING",
      "reverse": false,
    },
    S.of(context).featured: {
      "sortKey": "MANUAL",
      "reverse": false,
    },
    S.of(context).newProducts: {
      "sortKey": "CREATED",
      "reverse": true,
    },
    S.of(context).lowToHigh: {
      "sortKey": "PRICE",
      "reverse": false,
    },
    S.of(context).highToLow: {
      "sortKey": "PRICE",
      "reverse": true,
    },
  };

  @override
  void initState() {
    super.initState();

    // Initialize with previously applied filters if provided
    if (widget.appliedFilters != null) {
      selectedFilters.addAll(widget.appliedFilters!);
    }

    // Initialize with previously applied sort option if provided
    if (widget.appliedSortOption != null) {
      selectedSortOption['sortKey'] = widget.appliedSortOption!['sortKey'] ?? "";
      selectedSortOption['reverse'] = widget.appliedSortOption!['reverse'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 50),
      child: Column(
        children: [
          // Fixed header section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 45,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              myText(
                S.of(context).filterBy,
                18,
                FontWeight.w700,
                AppColors.black,
                TextAlign.left,
              ),
              const SizedBox(height: 2),
            ],
          ),

          // Scrollable filter options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Sort options
                  Obx(
                    () {
                      final isExpanded = expandedSubCategory.value == "sortOption";
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.lightGrey.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isExpanded) {
                                  // Close the current expanded item

                                  expandedSubCategory.value = null;
                                } else {
                                  // Open this item (automatically closes others)
                                  expandedSubCategory.value = "sortOption";
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    myText(
                                      S.of(context).sortBy,
                                      13,
                                      FontWeight.w600,
                                      AppColors.black,
                                      TextAlign.left,
                                    ),

                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0.0,
                                      duration: Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: AppColors.darkGrey,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            AnimatedSize(
                              key: ValueKey(
                                "sortOption",
                              ),
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,

                              child: ClipRect(
                                child: AnimatedOpacity(
                                  opacity: isExpanded ? 1.0 : 0.0,

                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: AnimatedAlign(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    heightFactor: isExpanded ? 1.0 : 0.0,

                                    alignment: Directionality.of(context) == TextDirection.rtl
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Column(
                                        children: [
                                          ...sortOptions.map((key, value) {
                                            return MapEntry(
                                              key,
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                  horizontal: 4,
                                                ),
                                                child: Row(
                                                  spacing: 8,
                                                  children: [
                                                    Obx(
                                                      () => CustomCheckbox(
                                                        value:
                                                            selectedSortOption['sortKey'] ==
                                                                sortOptions[key]!['sortKey'] &&
                                                            selectedSortOption['reverse'] ==
                                                                sortOptions[key]!['reverse'],
                                                        activeColor: AppColors.black,
                                                        borderColor: AppColors.darkGrey,
                                                        onChanged: (checked) {
                                                          if (checked) {
                                                            selectedSortOption['sortKey'] =
                                                                sortOptions[key]!['sortKey'];
                                                            selectedSortOption['reverse'] =
                                                                sortOptions[key]!['reverse'];
                                                          } else {
                                                            selectedSortOption['sortKey'] = "";
                                                            selectedSortOption['reverse'] = false;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    myText(
                                                      key,
                                                      12,
                                                      FontWeight.w400,
                                                      AppColors.darkGrey,
                                                      TextAlign.left,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).values,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Filter options
                  ...widget.filters.map(
                    (filter) {
                      return Obx(
                        () {
                          final uniqueKey = filter.id;

                          final isExpanded = expandedSubCategory.value == uniqueKey;
                          return Container(
                            decoration: BoxDecoration(
                              border: filter.label == widget.filters.last.label
                                  ? null
                                  : Border(
                                      bottom: BorderSide(
                                        color: AppColors.lightGrey.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isExpanded) {
                                      // Close the current expanded item

                                      expandedSubCategory.value = null;
                                    } else {
                                      // Open this item (automatically closes others)
                                      expandedSubCategory.value = uniqueKey;
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        myText(
                                          filter.label,
                                          13,
                                          FontWeight.w600,
                                          AppColors.black,
                                          TextAlign.left,
                                        ),
                                        AnimatedRotation(
                                          turns: isExpanded ? 0.5 : 0.0,

                                          duration: Duration(milliseconds: 300),
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: AppColors.darkGrey,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedSize(
                                  key: ValueKey(
                                    filter.id,
                                  ),
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: ClipRect(
                                    child: AnimatedOpacity(
                                      opacity: isExpanded ? 1.0 : 0.0,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,

                                      child: AnimatedAlign(
                                        alignment: Directionality.of(context) == TextDirection.rtl
                                            ? Alignment.topRight
                                            : Alignment.topLeft,

                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        heightFactor: isExpanded ? 1.0 : 0.0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: Column(
                                            children: [
                                              ...filter.values.map(
                                                (option) {
                                                  return Obx(
                                                    () => GestureDetector(
                                                      onTap: () {
                                                        final key = filter.id;
                                                        final valueId = option.id; // Use the actual ID from API
                                                        final label = option.label;

                                                        // For availability filters, use the actual ID logic
                                                        if (key == "filter.v.availability") {
                                                          // Single select → overwrite
                                                          selectedFilters[key] = [valueId];
                                                        } else {
                                                          // Multi select → toggle vendors, offers, etc.
                                                          if (selectedFilters[key]?.contains(valueId) == true) {
                                                            selectedFilters[key]!.remove(valueId);
                                                            if (selectedFilters[key]!.isEmpty) {
                                                              selectedFilters.remove(key);
                                                            }
                                                          } else {
                                                            selectedFilters[key] = [
                                                              ...?selectedFilters[key],
                                                              valueId,
                                                            ];
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        color: Colors.transparent,
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 8,
                                                          horizontal: 4,
                                                        ),
                                                        child: Row(
                                                          spacing: 8,
                                                          children: [
                                                            CustomCheckbox(
                                                              value:
                                                                  selectedFilters[filter.id]?.contains(
                                                                    option.id, // Use option ID instead of label
                                                                  ) ??
                                                                  false,
                                                              activeColor: AppColors.black,
                                                              borderColor: AppColors.darkGrey,
                                                              onChanged: (checked) {
                                                                final key = filter.id;
                                                                final valueId =
                                                                    option.id; // Use option ID instead of label

                                                                if (key == "filter.v.availability") {
                                                                  // Single-select filter
                                                                  if (checked) {
                                                                    selectedFilters[key] = [valueId];
                                                                  } else {
                                                                    selectedFilters.remove(key);
                                                                  }
                                                                } else {
                                                                  // Multi-select filter
                                                                  final current = List<String>.from(
                                                                    selectedFilters[key] ?? [],
                                                                  );

                                                                  if (checked) {
                                                                    // Add value
                                                                    if (!current.contains(valueId)) {
                                                                      current.add(valueId);
                                                                    }
                                                                  } else {
                                                                    // Remove value
                                                                    current.remove(valueId);
                                                                  }

                                                                  if (current.isEmpty) {
                                                                    selectedFilters.remove(key);
                                                                  } else {
                                                                    selectedFilters[key] = current;
                                                                  }
                                                                }

                                                                // ✅ Ensure GetX reactive map rebuilds UI
                                                                selectedFilters.refresh();
                                                              },
                                                            ),
                                                            myText(
                                                              filter.id == "filter.v.availability"
                                                                  ? '${getTranslatedAvailabilityLabel(option.label)} (${option.count.toString()})'
                                                                  : '${option.label} (${option.count.toString()})',
                                                              12,
                                                              FontWeight.w400,
                                                              AppColors.darkGrey,
                                                              TextAlign.left,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sticky action buttons at bottom
          Container(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              spacing: 8,
              children: [
                RoundButton(
                  text: S.of(context).reset,
                  backgroundColor: AppColors.white,
                  borderColor: AppColors.black,
                  height: 45,
                  width: (Get.width - 68) * 0.5,
                  radius: 10,
                  onClick: () {
                    // Clear all selected filters
                    selectedFilters.clear();

                    // Clear sort option
                    selectedSortOption['sortKey'] = "";
                    selectedSortOption['reverse'] = false;

                    // Return empty result to indicate reset - no sort option at all
                    var result = {
                      'rawSelections': <String, List<String>>{},
                      'shopifyFilters': <Map<String, dynamic>>[],
                      'sortOption': null, // Return null to indicate no sort applied
                    };

                    Navigator.pop(context, result);
                  },
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  textcolor: AppColors.black,
                  align: TextAlign.center,
                  isheading: false,
                ),
                RoundButton(
                  text: S.of(context).apply,
                  backgroundColor: AppColors.black,
                  borderColor: AppColors.black,
                  height: 45,
                  width: (Get.width - 68) * 0.5,
                  icon: SizedBox.shrink(),
                  radius: 10,
                  onClick: () {
                    var shopifyFilters = buildShopifyFilters(selectedFilters);

                    // Prepare sort option - if empty, send null
                    Map<String, dynamic>? sortOption;
                    if (selectedSortOption['sortKey'] != "") {
                      sortOption = Map<String, dynamic>.from(selectedSortOption);
                    }

                    // Return both raw selections and shopify filters
                    var result = {
                      'rawSelections': selectedFilters,
                      'shopifyFilters': shopifyFilters,
                      'sortOption': sortOption, // null if no sort selected
                    };

                    Navigator.pop(context, result);
                  },
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  textcolor: AppColors.white,
                  align: TextAlign.center,
                  isheading: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to translate availability labels
  String getTranslatedAvailabilityLabel(String originalLabel) {
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

  List<Map<String, dynamic>> buildShopifyFilters(Map<String, List<String>> selectedFilters) {
    final filters = <Map<String, dynamic>>[];

    selectedFilters.forEach((key, values) {
      if (key == "filter.p.m.custom.brand") {
        for (var valueId in values) {
          // Find the actual brand name from the filter values
          final brandFilter = widget.filters.firstWhere((f) => f.id == key);
          final brandValue = brandFilter.values.firstWhere((v) => v.id == valueId);
          filters.add({
            "productMetafield": {
              "namespace": "custom",
              "key": "brand",
              "value": brandValue.label,
            },
          });
        }
      }

      if (key == "filter.p.vendor") {
        for (var valueId in values) {
          // Find the actual vendor name from the filter values
          final vendorFilter = widget.filters.firstWhere((f) => f.id == key);
          final vendorValue = vendorFilter.values.firstWhere((v) => v.id == valueId);
          filters.add({"productVendor": vendorValue.label});
        }
      }

      if (key == "filter.v.availability") {
        for (var valueId in values) {
          // Find the availability filter and convert ID to boolean
          final availabilityFilter = widget.filters.firstWhere((f) => f.id == key);
          final availabilityValue = availabilityFilter.values.firstWhere((v) => v.id == valueId);

          // Check if this represents "available" or "out of stock" based on the ID
          bool isAvailable =
              valueId.toLowerCase().contains("1") ||
              valueId.toLowerCase().contains("true") ||
              valueId.toLowerCase().contains("available");

          filters.add({"available": isAvailable});
        }
      }

      if (key == "filter.p.m.custom.offers") {
        for (var valueId in values) {
          // Find the actual offer value from the filter values
          final offersFilter = widget.filters.firstWhere((f) => f.id == key);
          final offerValue = offersFilter.values.firstWhere((v) => v.id == valueId);
          filters.add({
            "productMetafield": {
              "namespace": "custom",
              "key": "offers",
              "value": offerValue.label,
            },
          });
        }
      }
    });

    return filters;
  }
}
