import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/services/product_service.dart';
import 'package:saru/services/search_service.dart';
import 'package:saru/services/shared_preference.dart';
import 'package:saru/widgets/Search/Search_Product_card.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/rtl_svg.dart';
import 'package:saru/widgets/constants/textStyle.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  RxBool issearching = false.obs;
  RxBool isloading = false.obs;

  RxList<String> searchHistory = <String>[].obs;

  final predictiveSearchController = Get.put(PredictiveSearchController());

  final productsController = Get.find<ProductsController>();

  final FocusNode _focusNode = FocusNode();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (query.isNotEmpty) {
        issearching.value = true;
        isloading.value = true;
        await predictiveSearchController.fetchPredictiveSearchResults(query);
        isloading.value = false;
      } else {
        predictiveSearchController.predictiveSearchResults.clear();
        issearching.value = false;
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _loadSearchHistory();
    super.initState();
  }

  void _loadSearchHistory() async {
    isloading.value = true;
    searchHistory.value = await SearchHistoryService.getSearchHistory();
    isloading.value = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,

        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          toolbarHeight: 0,
          scrolledUnderElevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                spacing: 12,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      PersistentNavBarNavigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: directionalSvg(
                        'assets/icons/Back.svg',
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextFormField(
                        controller: searchController,
                        onChanged: _onSearchChanged,
                        style: textstyle(
                          14,
                          AppColors.black,
                          FontWeight.w500,
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,

                        onFieldSubmitted: (value) async {
                          if (value.trim().isNotEmpty) {
                            await SearchHistoryService.saveSearchQuery(value.trim());
                            searchHistory.value = await SearchHistoryService.getSearchHistory();
                          }
                        },

                        focusNode: _focusNode,

                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: Directionality.of(context) == TextDirection.ltr ? 16.0 : 5.0,
                              right: Directionality.of(context) == TextDirection.rtl ? 16.0 : 5.0,
                            ),
                            child: Icon(
                              Icons.search,
                              color: AppColors.darkGrey.withOpacity(0.5),
                              size: 16.sp,
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 20.w, // adjust this
                            minHeight: 20.h,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0.h,
                            horizontal: 0.w,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              width: 1,
                              color: const Color.fromARGB(255, 198, 21, 9),
                            ),
                          ),
                          hintText: S.of(context).search,
                          hintStyle: textstyle(
                            14,
                            AppColors.darkGrey.withOpacity(0.5),
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Obx(
                    () => issearching.value
                        ? GestureDetector(
                            onTap: () {
                              searchController.clear();
                              predictiveSearchController.predictiveSearchResults.clear();

                              issearching.value = false;
                              FocusScope.of(context).unfocus();
                            },
                            child: myText(
                              S.of(context).cancel,
                              12,
                              FontWeight.w500,
                              AppColors.darkGrey.withOpacity(0.5),
                              TextAlign.start,
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
              Obx(
                () => Expanded(
                  child: SingleChildScrollView(
                    child: issearching.value
                        ? isloading.value
                              ? SizedBox(
                                  height: Get.height * 0.7,
                                  child: loader(context),
                                )
                              : Column(
                                  spacing: 0,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    myText(
                                      S.of(context).suggestions,
                                      14,
                                      FontWeight.w800,
                                      AppColors.black,
                                      TextAlign.left,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),

                                    //Suggestions List
                                    if (predictiveSearchController.predictiveSearchResults.isNotEmpty)
                                      ...predictiveSearchController.predictiveSearchResults.map(
                                        (suggestion) {
                                          return GestureDetector(
                                            onTap: () async {
                                              searchController.text = suggestion.text;
                                              isloading.value = true;
                                              await predictiveSearchController.fetchPredictiveSearchResults(
                                                suggestion.text,
                                              );
                                              isloading.value = false;
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
                                                spacing: 8,
                                                children: [
                                                  Icon(
                                                    Icons.search,
                                                    color: AppColors.darkGrey.withOpacity(0.5),
                                                    size: 16.sp,
                                                  ),
                                                  myText(
                                                    suggestion.text,
                                                    14,
                                                    FontWeight.w400,
                                                    AppColors.darkGrey,
                                                    TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                                        child: Center(
                                          child: myText(
                                            S.of(context).noSuggestionsFound,
                                            14,
                                            FontWeight.w400,
                                            AppColors.darkGrey.withOpacity(0.7),
                                            TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    myText(
                                      S.of(context).products,
                                      14,
                                      FontWeight.w800,
                                      AppColors.black,
                                      TextAlign.left,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),

                                    //Products List
                                    if (predictiveSearchController.searchedProducts.isNotEmpty)
                                      ...predictiveSearchController.searchedProducts.map(
                                        (product) {
                                          return searchProductCard(context, product);
                                        },
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                                        child: Center(
                                          child: Column(
                                            spacing: 8,
                                            children: [
                                              Icon(
                                                Icons.inventory_2_outlined,
                                                color: AppColors.darkGrey.withOpacity(0.5),
                                                size: 32,
                                              ),
                                              myText(
                                                S.of(context).noProductsFound,
                                                14,
                                                FontWeight.w400,
                                                AppColors.darkGrey.withOpacity(0.7),
                                                TextAlign.center,
                                              ),
                                              myText(
                                                S.of(context).trySearchingWithDifferentKeywords,
                                                12,
                                                FontWeight.w300,
                                                AppColors.darkGrey.withOpacity(0.5),
                                                TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                        : isloading.value
                        ? SizedBox(
                            height: Get.height * 0.7,
                            child: loader(context),
                          )
                        : Column(
                            spacing: 0,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (searchHistory.isNotEmpty)
                                Column(
                                  spacing: 0,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        myText(
                                          S.of(context).recentlySearched,
                                          14,
                                          FontWeight.w800,
                                          AppColors.black,
                                          TextAlign.left,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await SearchHistoryService.clearHistory();
                                            searchHistory.value = [];
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.grey,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ...searchHistory.map((query) {
                                          return GestureDetector(
                                            onTap: () async {
                                              searchController.text = query;
                                              issearching.value = true;
                                              isloading.value = true;
                                              await predictiveSearchController.fetchPredictiveSearchResults(query);
                                              isloading.value = false;
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: AppColors.black, width: 1),
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              child: myText(
                                                query,
                                                12,
                                                FontWeight.w500,
                                                AppColors.darkGrey,
                                                TextAlign.left,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                ),

                              myText(
                                S.of(context).recommendedProducts,
                                14,
                                FontWeight.w800,
                                AppColors.black,
                                TextAlign.left,
                              ),

                              SizedBox(
                                height: 8,
                              ),

                              ...productsController.products.map(
                                (product) {
                                  return searchProductCard(context, product);
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
