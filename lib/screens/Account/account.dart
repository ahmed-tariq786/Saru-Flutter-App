import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/screens/Account/Addresses/addresses_screen.dart';
import 'package:saru/screens/Account/favorites.dart';
import 'package:saru/screens/Account/login/login_screen.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/services/language.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final LanguageController languageController = Get.find<LanguageController>();

  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: myText(
          S.of(context).account,
          18,
          FontWeight.w600,
          Colors.black,
          TextAlign.start,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Obx(
                () => Column(
                  children: [
                    if (!accountController.isLoggedIn.value)
                      // Account
                      ListTile(
                        minTileHeight: 0,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        leading: Icon(
                          Icons.person,
                          color: AppColors.darkGrey.withOpacity(0.9),
                        ),
                        title: myText(
                          S.of(context).loginRegister,
                          14,
                          FontWeight.w500,
                          Colors.black,
                          TextAlign.start,
                        ),

                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.darkGrey.withOpacity(0.7),
                        ),
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: LoginRegisterScreen(),
                            withNavBar: true, // <--- keeps the bottom bar visible
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                      ),

                    // Addresses
                    if (accountController.isLoggedIn.value)
                      ListTile(
                        minTileHeight: 0,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        leading: Icon(
                          Icons.location_on_outlined,
                          color: AppColors.darkGrey.withOpacity(0.9),
                        ),
                        title: myText(
                          S.of(context).addresses,
                          14,
                          FontWeight.w500,
                          Colors.black,
                          TextAlign.start,
                        ),

                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.darkGrey.withOpacity(0.7),
                        ),
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: AddressesScreen(),
                            withNavBar: true, // <--- keeps the bottom bar visible
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                      ),

                    Divider(
                      color: Colors.grey.withOpacity(0.2),
                      height: 1,
                    ),

                    // Favorites
                    ListTile(
                      minTileHeight: 0,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      leading: SvgPicture.asset(
                        "assets/icons/Fav.svg",
                      ),
                      title: myText(
                        S.of(context).favorites,
                        14,
                        FontWeight.w500,
                        Colors.black,
                        TextAlign.start,
                      ),

                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.darkGrey.withOpacity(0.7),
                      ),
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: FavoritesScreen(),
                          withNavBar: true, // <--- keeps the bottom bar visible
                          pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        );
                      },
                    ),

                    Divider(
                      color: Colors.grey.withOpacity(0.2),
                      height: 1,
                    ),

                    // Language
                    ListTile(
                      minTileHeight: 0,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      leading: Icon(
                        Icons.language,
                        color: AppColors.darkGrey.withOpacity(0.9),
                      ),
                      title: myText(
                        S.of(context).language,
                        14,
                        FontWeight.w500,
                        Colors.black,
                        TextAlign.start,
                      ),

                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.darkGrey.withOpacity(0.7),
                      ),
                      onTap: () => _showLanguageDialog(context),
                    ),

                    Divider(
                      color: Colors.grey.withOpacity(0.2),
                      height: 1,
                    ),

                    // About Saru
                    ListTile(
                      minTileHeight: 0,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.darkGrey.withOpacity(0.9),
                      ),
                      title: myText(
                        S.of(context).aboutSaru,
                        14,
                        FontWeight.w500,
                        Colors.black,
                        TextAlign.start,
                      ),

                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.darkGrey.withOpacity(0.7),
                      ),
                      onTap: () => _showLanguageDialog(context),
                    ),

                    Divider(
                      color: Colors.grey.withOpacity(0.2),
                      height: 1,
                    ),

                    // Logout
                    if (accountController.isLoggedIn.value)
                      ListTile(
                        minTileHeight: 0,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        leading: Icon(
                          Icons.logout,
                          color: AppColors.sale,
                        ),
                        title: myText(
                          S.of(context).logout,
                          14,
                          FontWeight.w500,
                          AppColors.sale,
                          TextAlign.start,
                        ),

                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.darkGrey.withOpacity(0.7),
                        ),
                        onTap: () {
                          // accountController.logout();
                          showLogoutDialog(context);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  SizedBox(height: 8),

                  myText(S.of(context).logout, 24, FontWeight.w800, Color.fromARGB(255, 0, 0, 0), TextAlign.center),
                  SizedBox(height: 10),
                  myText(
                    S.of(context).areYouSureYouWantToLogout,
                    14,
                    FontWeight.w300,
                    Color(0xff212121),
                    TextAlign.center,
                  ),
                ],
              ),
              actions: [
                Column(
                  children: [
                    RoundButton(
                      textcolor: AppColors.black,
                      isheading: true,

                      text: S.of(context).no,
                      align: TextAlign.center,

                      backgroundColor: AppColors.white,
                      borderColor: AppColors.black,
                      height: 50,
                      width: MediaQuery.sizeOf(context).width,
                      radius: 42,
                      onClick: () {
                        Get.back();
                      },
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RoundButton(
                      textcolor: AppColors.white,
                      isheading: true,

                      text: S.of(context).yesLogout,
                      align: TextAlign.center,

                      backgroundColor: AppColors.black,
                      borderColor: AppColors.black,
                      height: 50,
                      width: MediaQuery.sizeOf(context).width,
                      radius: 42,
                      onClick: () async {
                        await accountController.logout();
                        Get.back();
                      },
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
              contentPadding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.bg,

        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  myText(
                    S.of(context).selectLanguage,
                    16,
                    FontWeight.w800,
                    Colors.black,
                    TextAlign.start,
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: AppColors.darkGrey.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ListTile(
                minTileHeight: 0,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                leading: myText('🇺🇸', 20, FontWeight.w400, Colors.black, TextAlign.start),
                title: myText('English', 14, FontWeight.w400, Colors.black, TextAlign.start),
                onTap: () {
                  Navigator.pop(context);
                  languageController.changeLanguage('en');
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.3),
                height: 1,
              ),
              ListTile(
                minTileHeight: 0,
                contentPadding: EdgeInsets.only(top: 12),
                leading: myText('🇸🇦', 20, FontWeight.w400, Colors.black, TextAlign.start),
                title: myText('العربية', 14, FontWeight.w400, Colors.black, TextAlign.start),
                onTap: () {
                  Navigator.pop(context);
                  languageController.changeLanguage('ar');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
