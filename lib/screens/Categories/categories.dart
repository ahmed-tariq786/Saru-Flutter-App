import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/screens/Categories/main_category.dart';
import 'package:saru/screens/Search/search.dart';
import 'package:saru/services/menu_service.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final menusController = Get.find<MenusController>();
  final selectedMenuHandle = RxnString();
  final expandedSubCategory = RxnString();
  @override
  void initState() {
    super.initState();
    // Set the first menu as selected when menus are available
    if (menusController.menus.keys.first.isNotEmpty) {
      selectedMenuHandle.value = menusController.menus.keys.first;
    }

    // Clear expanded subcategory when main menu changes
    ever(selectedMenuHandle, (String? menuHandle) {
      expandedSubCategory.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
                color: AppColors.lightGrey.withOpacity(0.6),
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
                    S.of(context).searchTheProducts,
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

        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body: Column(
        children: [
          Obx(
            () {
              if (menusController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 200.0),
                    child: loader(context),
                  ),
                );
              } else {
                final menu = menusController.menus["makeup-mobile-app"];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display main categories (first level)
                    Container(
                      width: Get.width,
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
                      padding: EdgeInsets.only(
                        left: 16,
                        bottom: 12,
                        right: 16,
                      ),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...menusController.menus.entries.map(
                              (entry) {
                                final menuHandle = entry.key;
                                final menu = entry.value;

                                return Obx(
                                  () {
                                    final isSelected = selectedMenuHandle.value == menuHandle;

                                    return GestureDetector(
                                      onTap: () {
                                        selectedMenuHandle.value = menuHandle;
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.secondary : AppColors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.secondary
                                                : AppColors.darkGrey.withOpacity(0.6),
                                          ),
                                        ),
                                        child: myText(
                                          menu.items.isNotEmpty
                                              ? (menu.items[0].collectionTitle ?? menu.items[0].title)
                                              : '',
                                          13,
                                          FontWeight.w400,
                                          isSelected ? AppColors.white : AppColors.darkGrey,
                                          TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                    // Display subcategories (second level)
                    Container(
                      margin: const EdgeInsets.all(16.0),

                      child: SingleChildScrollView(
                        child: Obx(() {
                          final selectedMenu = menusController.menus[selectedMenuHandle.value];
                          if (selectedMenu == null || selectedMenu.items.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: myText(
                                  'No subcategories available',
                                  16,
                                  FontWeight.w400,
                                  AppColors.darkGrey,
                                  TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return TweenAnimationBuilder<double>(
                            key: ValueKey(selectedMenuHandle.value),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            builder: (context, opacity, child) {
                              return Opacity(
                                opacity: opacity,
                                child: child,
                              );
                            },
                            child: Container(
                              key: ValueKey(selectedMenuHandle.value), // This key is crucial!

                              child: Column(
                                spacing: 12,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (selectedMenu.items[0].collectionImage != null)
                                    CacheImage(
                                      pic: selectedMenu.items[0].collectionImage ?? "",
                                      width: Get.width,
                                      height: 120,
                                      radius: 12,
                                      fit: BoxFit.cover,
                                    ),
                                  // Display subcategories (second level)
                                  if (selectedMenu.items.isNotEmpty && selectedMenu.items[0].items.isNotEmpty)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                        color: AppColors.white,
                                      ),
                                      padding: EdgeInsets.only(
                                        top: 6,
                                        bottom: 6,
                                        left: 12,
                                        right: 12,
                                      ),

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
                                          ...selectedMenu.items[0].items.map(
                                            (subItem) => Obx(() {
                                              final uniqueKey = "${selectedMenuHandle.value}_${subItem.id}";
                                              final isExpanded = expandedSubCategory.value == uniqueKey;

                                              return Container(
                                                decoration: BoxDecoration(
                                                  border: selectedMenu.items[0].items.last == subItem
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
                                                        if (subItem.items.isNotEmpty) {
                                                          if (isExpanded) {
                                                            // Close the current expanded item
                                                            expandedSubCategory.value = null;
                                                          } else {
                                                            // Open this item (automatically closes others)
                                                            expandedSubCategory.value = uniqueKey;
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        color: Colors.transparent,
                                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            subItem.items.isEmpty
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      if (subItem.items.isEmpty) {
                                                                        PersistentNavBarNavigator.pushNewScreen(
                                                                          context,
                                                                          screen: MainCategoryScreen(
                                                                            menuLvl1: selectedMenuHandle.value!,
                                                                            menuLvl2: subItem.title,
                                                                            menuLvl3: "",
                                                                            selectedTab: subItem.title,
                                                                          ),
                                                                          withNavBar: true,
                                                                          pageTransitionAnimation:
                                                                              PageTransitionAnimation.cupertino,
                                                                        );
                                                                      }
                                                                    },
                                                                    child: myText(
                                                                      subItem.title,
                                                                      13,
                                                                      FontWeight.w600,
                                                                      AppColors.black,
                                                                      TextAlign.start,
                                                                    ),
                                                                  )
                                                                : myText(
                                                                    subItem.title,
                                                                    13,
                                                                    FontWeight.w600,
                                                                    AppColors.black,
                                                                    TextAlign.start,
                                                                  ),
                                                            Row(
                                                              children: [
                                                                if (subItem.items.isNotEmpty)
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      PersistentNavBarNavigator.pushNewScreen(
                                                                        context,
                                                                        screen: MainCategoryScreen(
                                                                          menuLvl1: selectedMenuHandle.value!,
                                                                          menuLvl2: subItem.title,
                                                                          menuLvl3: "",
                                                                          selectedTab: subItem.title,
                                                                        ),
                                                                        withNavBar: true,
                                                                        pageTransitionAnimation:
                                                                            PageTransitionAnimation.cupertino,
                                                                      );
                                                                    },
                                                                    child: AnimatedOpacity(
                                                                      duration: Duration(milliseconds: 300),
                                                                      opacity: isExpanded ? 1.0 : 0.0,
                                                                      child: isExpanded
                                                                          ? myText(
                                                                              S.of(context).viewAll,
                                                                              12,
                                                                              FontWeight.w400,
                                                                              AppColors.darkGrey,
                                                                              TextAlign.start,
                                                                            )
                                                                          : SizedBox.shrink(),
                                                                    ),
                                                                  ),
                                                                if (subItem.items.isNotEmpty)
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    // Animated third level items with smooth slide down
                                                    AnimatedSize(
                                                      key: ValueKey(
                                                        '${selectedMenuHandle.value}_${subItem.id}_animation',
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
                                                                spacing: 12,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  ...subItem.items.map(
                                                                    (subSubItem) => Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal: 4,
                                                                      ),

                                                                      child: GestureDetector(
                                                                        onTap: () {
                                                                          PersistentNavBarNavigator.pushNewScreen(
                                                                            context,
                                                                            screen: MainCategoryScreen(
                                                                              menuLvl1: selectedMenuHandle.value!,
                                                                              menuLvl2: subItem.title,
                                                                              menuLvl3: subSubItem.title,
                                                                              selectedTab: subSubItem.title,
                                                                            ),
                                                                            withNavBar: true,
                                                                            pageTransitionAnimation:
                                                                                PageTransitionAnimation.cupertino,
                                                                          );
                                                                        },
                                                                        child: myText(
                                                                          subSubItem.title,
                                                                          13,
                                                                          FontWeight.w400,
                                                                          AppColors.darkGrey,
                                                                          TextAlign.start,
                                                                        ),
                                                                      ),
                                                                    ),
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
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
