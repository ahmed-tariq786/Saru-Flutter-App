import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/screens/Account/Reset/reset_screen.dart';
import 'package:saru/screens/Account/login/register_screen.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/services/cart_service.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/text_style.dart';
import 'package:saru/widgets/constants/toast.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final accountController = Get.find<AccountController>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();

  final cartController = Get.find<CartController>();

  RxBool isHidden = true.obs;

  RxBool isLoading = false.obs;

  @override
  void initState() {
    // Check if user is logged in and has customer data

    super.initState();
    // Auto-focus email field when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();

    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).pleaseEnterYourEmail;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return S.of(context).pleaseEnterAValidEmailAddress;
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).pleaseEnterYourPassword;
    }

    return null;
  }

  Future<void> _handleLogin() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      final result = await accountController.loginCustomer(
        emailController.text.trim(),
        passwordController.text,
      );
      isLoading.value = false;

      if (result.errorMessage != null) {
        print(result.errorMessage);
        ShowToast().showErrorToast(result.errorMessage!);
      } else {
        if (cartController.cartId.value.isNotEmpty && accountController.customerAccessToken.value.isNotEmpty) {
          var result = await cartController.attachCartToCustomer(
            cartController.cartId.value,
            accountController.customerAccessToken.value,
          );

          if (!result) {
            ShowToast().showErrorToast(S.of(context).anErrorOccurredPleaseTryAgain);
            return;
          }
        }

        ShowToast().showSuccessToast(S.of(context).loggedInSuccessfully);
        PersistentNavBarNavigator.pop(context);
      }
    }
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
          scrolledUnderElevation: 0,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                backButton(context),
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: Get.width * 0.2,
                ),
                Opacity(
                  opacity: 0,
                  child: backButton(context),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                      ),

                      myText(S.of(context).login, 32, FontWeight.w800, AppColors.black, TextAlign.left),
                      myText(
                        S.of(context).pleaseEnterYourCredentials,
                        14,
                        FontWeight.w300,
                        AppColors.darkGrey,
                        TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      // Email
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: emailController,
                          focusNode: emailFocusNode,
                          validator: _validateEmail,
                          style: textstyle(
                            15,
                            AppColors.black,
                            FontWeight.w400,
                          ),
                          keyboardType: TextInputType.emailAddress,

                          decoration: InputDecoration(
                            fillColor: AppColors.white,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.email,
                              color: AppColors.darkGrey.withOpacity(0.5),
                              size: 20,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 1,
                                color: const Color.fromARGB(255, 198, 21, 9),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 1,
                                color: const Color.fromARGB(255, 198, 21, 9),
                              ),
                            ),

                            labelText: S.of(context).email,
                            labelStyle: textstyle(
                              13,
                              AppColors.darkGrey.withOpacity(1),
                              FontWeight.w500,
                            ),

                            hintText: S.of(context).email,
                            hintStyle: textstyle(
                              15,
                              AppColors.darkGrey.withOpacity(0.5),
                              FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      // Password
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Obx(
                          () => TextFormField(
                            controller: passwordController,
                            validator: _validatePassword,
                            style: textstyle(
                              15,
                              AppColors.black,
                              FontWeight.w400,
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: isHidden.value,

                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  isHidden.value = !isHidden.value;
                                },
                                child: Icon(
                                  isHidden.value ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.darkGrey.withOpacity(0.5),
                                  size: 20,
                                ),
                              ),

                              fillColor: AppColors.white,
                              filled: true,
                              prefixIcon: Icon(
                                Icons.password,
                                color: AppColors.darkGrey.withOpacity(0.5),
                                size: 20,
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: AppColors.darkGrey.withOpacity(0.2)),

                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: const Color.fromARGB(255, 198, 21, 9),
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: const Color.fromARGB(255, 198, 21, 9),
                                ),
                              ),

                              labelText: S.of(context).password,
                              labelStyle: textstyle(
                                13,
                                AppColors.darkGrey.withOpacity(1),
                                FontWeight.w500,
                              ),

                              hintText: S.of(context).password,
                              hintStyle: textstyle(
                                15,
                                AppColors.darkGrey.withOpacity(0.5),
                                FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      // Login Button
                      Obx(
                        () => RoundButton(
                          text: S.of(context).login,
                          backgroundColor: AppColors.black,
                          borderColor: AppColors.black,
                          height: 45,
                          width: Get.width,
                          loading: isLoading.value,

                          radius: 10,
                          onClick: () async {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            await _handleLogin();
                          },
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          textcolor: AppColors.white,
                          align: TextAlign.center,
                          isheading: false,
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      // Register and Recover Password Links
                      Row(
                        children: [
                          myText(
                            S.of(context).newCustomer,
                            12,
                            FontWeight.w400,
                            AppColors.black,
                            TextAlign.center,
                          ),
                          GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: RegisterScreen(),
                                withNavBar: false, // <--- keeps the bottom bar visible
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              );
                            },
                            child: myText(
                              S.of(context).createYourAccountHere,
                              12,
                              FontWeight.w700,
                              AppColors.black,
                              TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      // Lost Password
                      Row(
                        children: [
                          myText(
                            S.of(context).lostPassword,
                            12,
                            FontWeight.w400,
                            AppColors.black,
                            TextAlign.center,
                          ),
                          GestureDetector(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: ResetScreen(),
                                withNavBar: false, // <--- keeps the bottom bar visible
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              );
                            },
                            child: myText(
                              S.of(context).recoverPassword,
                              12,
                              FontWeight.w700,
                              AppColors.black,
                              TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
