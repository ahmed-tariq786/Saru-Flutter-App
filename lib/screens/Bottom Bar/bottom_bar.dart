import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/screens/Account/account.dart';
import 'package:saru/screens/Brands/brands_screen.dart';
import 'package:saru/screens/Cart/cart_screen.dart';
import 'package:saru/screens/Categories/categories.dart';
import 'package:saru/screens/Home%20Page/home.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.index = 0});

  final int? index;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.index ?? 0);
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        tabController: _controller,
      ),
      const CategoriesScreen(),
      const BrandsScreen(),
      CartScreen(
        tabController: _controller,
      ),
      AccountScreen(
        tabController: _controller,
      ),
    ];
  }

  String _getTabLabel(String iconName) {
    switch (iconName) {
      case 'home':
        return S.of(context).home;
      case 'Categories':
        return S.of(context).categories;
      case 'Brands':
        return S.of(context).brands;
      case 'Cart':
        return S.of(context).cart;
      case 'Profile':
        return S.of(context).profile;
      default:
        return iconName.capitalizeFirst!;
    }
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    final icons = ['home', 'Categories', 'Brands', 'Cart', 'Profile'];

    return icons.map((name) {
      return PersistentBottomNavBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10.h,
            ), // tighter gap
            SvgPicture.asset(
              'assets/icons/$name.svg',
              height: 22, // smaller for balance
              color: AppColors.black,
            ),
            SizedBox(height: 2.h), // tighter gap
            myText(
              _getTabLabel(name),
              10,
              FontWeight.w400,
              AppColors.black,
              TextAlign.center,
              decoration: TextDecoration.none,
            ),
          ],
        ),
        inactiveIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h), // tighter gap
            SvgPicture.asset(
              'assets/icons/$name.svg',
              height: 22,
              color: AppColors.grey,
            ),
            SizedBox(height: 2.h), // tighter gap
            myText(
              _getTabLabel(name),
              10,
              FontWeight.w400,
              AppColors.grey,
              TextAlign.center,
              decoration: TextDecoration.none,
            ),
          ],
        ),

        activeColorPrimary: AppColors.black,
        inactiveColorPrimary: AppColors.grey,

        // ↓↓ controls the spacing between icon and text
        contentPadding: 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.simple,

      backgroundColor: AppColors.white,
      navBarHeight: 50.h,

      decoration: NavBarDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      confineToSafeArea: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,

      hideNavigationBarWhenKeyboardAppears: false,
    );
  }
}
