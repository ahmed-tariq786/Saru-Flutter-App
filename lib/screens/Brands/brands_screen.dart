import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/screens/Collection/collection_screen.dart';
import 'package:saru/services/brands_service.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/text_Style.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final brandsController = Get.find<BrandsController>();
  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          toolbarHeight: 0,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),

        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search Bar
              SizedBox(
                height: 45,
                child: TextFormField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  style: textstyle(
                    15,
                    AppColors.black,
                    FontWeight.w400,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    searchQuery.value = value.toLowerCase();
                  },
                  onFieldSubmitted: (value) async {},

                  decoration: InputDecoration(
                    fillColor: AppColors.lightGrey.withOpacity(0.6),
                    filled: true,
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
                      borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0)),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0)),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0)),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0)),
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
                    hintText: S.of(context).searchBrands,
                    hintStyle: textstyle(
                      15,
                      AppColors.darkGrey.withOpacity(0.5),
                      FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Obx(() {
                  final allBrands = brandsController.brandMenu.value?.items ?? [];
                  final filteredBrands = searchQuery.value.isEmpty
                      ? allBrands
                      : allBrands.where((brand) => brand.title.toLowerCase().contains(searchQuery.value)).toList();

                  return GridView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredBrands.length,
                    itemBuilder: (context, index) {
                      final brand = filteredBrands[index];
                      return GestureDetector(
                        onTap: () {
                          if (brand.collectionId == null || brand.collectionId == '') return;

                          // Unfocus the search field before navigation
                          searchFocusNode.unfocus();

                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: CollectionScreen(
                              id: brand.collectionId ?? '',
                              title: brand.title,
                            ),
                            withNavBar: true, // <--- keeps the bottom bar visible
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Center(
                            child: brand.collectionImage == null || brand.collectionImage == ''
                                ? myText(
                                    brand.title,
                                    14,
                                    FontWeight.w500,
                                    AppColors.black,
                                    TextAlign.center,
                                  )
                                : CacheImage(
                                    pic: brand.collectionImage ?? '',
                                    width: double.infinity,
                                    height: double.infinity,
                                    radius: 12,
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
