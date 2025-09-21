import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/text_style.dart';
import 'package:saru/widgets/constants/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final accountController = Get.find<AccountController>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();

  RxBool isHidden = false.obs;

  RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
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

    if (value.length < 8) {
      return S.of(context).passwordMustBeAtLeast8CharactersLong;
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return S.of(context).passwordMustContainAtLeastOneUppercaseLetterOneLowercase;
    }

    return null;
  }

  void _handleLogin() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (_formKey.currentState!.validate()) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      isLoading.value = true;
      final result = await accountController.createCustomer(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
      isLoading.value = false;

      if (result.errorMessage != null) {
        ShowToast().showErrorToast(result.errorMessage!);
      } else {
        ShowToast().showSuccessToast("Account created successfully");
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                        ),

                        Center(
                          child: myText(
                            S.of(context).register,
                            32,
                            FontWeight.w800,
                            AppColors.black,
                            TextAlign.center,
                          ),
                        ),

                        Center(
                          child: myText(
                            S.of(context).pleaseCreateAnAccountWithYourEmailAddress,
                            13,
                            FontWeight.w300,
                            AppColors.darkGrey,
                            TextAlign.center,
                          ),
                        ),

                        SizedBox(
                          height: 30,
                        ),

                        //  First Name
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
                            controller: firstNameController,

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterYourFirstName;
                              }
                              return null;
                            },
                            style: textstyle(
                              15,
                              AppColors.black,
                              FontWeight.w400,
                            ),
                            keyboardType: TextInputType.text,

                            decoration: InputDecoration(
                              fillColor: AppColors.white,
                              filled: true,
                              prefixIcon: Icon(
                                Icons.person,
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

                              labelText: S.of(context).firstName,
                              labelStyle: textstyle(
                                13,
                                AppColors.darkGrey.withOpacity(1),
                                FontWeight.w500,
                              ),

                              hintText: S.of(context).firstName,
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

                        //  Last Name
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
                            controller: lastNameController,

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterYourLastName;
                              }
                              return null;
                            },
                            style: textstyle(
                              15,
                              AppColors.black,
                              FontWeight.w400,
                            ),
                            keyboardType: TextInputType.text,

                            decoration: InputDecoration(
                              fillColor: AppColors.white,
                              filled: true,
                              prefixIcon: Icon(
                                Icons.person,
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

                              labelText: S.of(context).lastName,
                              labelStyle: textstyle(
                                13,
                                AppColors.darkGrey.withOpacity(1),
                                FontWeight.w500,
                              ),
                              hintText: S.of(context).lastName,
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
                          height: 10,
                        ),

                        // TAC and privacy policy
                        Wrap(
                          alignment: WrapAlignment.start,
                          children: [
                            myText(
                              S.of(context).byRegisteringYouAcceptOur,
                              12,
                              FontWeight.w400,
                              AppColors.black,
                              TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri.parse("https://saruu.com/pages/terms-and-conditions"),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: myText(
                                S.of(context).termsAndConditions,
                                12,
                                FontWeight.w700,
                                AppColors.black,
                                TextAlign.center,
                              ),
                            ),
                            myText(
                              S.of(context).and,
                              12,
                              FontWeight.w400,
                              AppColors.black,
                              TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri.parse("https://saruu.com/pages/privacy-policy"),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: myText(
                                S.of(context).privacyPolicy,
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

                        Obx(
                          () => RoundButton(
                            text: S.of(context).register,
                            backgroundColor: AppColors.black,
                            borderColor: AppColors.black,
                            height: 45,
                            width: Get.width,
                            loading: isLoading.value,

                            radius: 10,
                            onClick: () async {
                              _handleLogin();
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

                        Row(
                          children: [
                            myText(
                              S.of(context).alreadyHaveAnAccount,
                              12,
                              FontWeight.w400,
                              AppColors.black,
                              TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () {
                                PersistentNavBarNavigator.pop(context);
                              },
                              child: myText(
                                S.of(context).loginHere,
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
            ),
          ],
        ),
      ),
    );
  }
}
