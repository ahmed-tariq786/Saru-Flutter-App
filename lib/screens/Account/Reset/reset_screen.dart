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

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key});

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  FocusNode emailFocusNode = FocusNode();
  RxBool isLoading = false.obs;
  final accountController = Get.find<AccountController>();
  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
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
                      myText(S.of(context).resetPassword, 32, FontWeight.w800, AppColors.black, TextAlign.left),
                      myText(
                        S.of(context).lostYourPasswordPleaseEnterYourEmailAddressYouWill,
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

                      Obx(
                        () => RoundButton(
                          text: S.of(context).resetPassword,
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

                            if (_formKey.currentState!.validate()) {
                              isLoading.value = true;
                              bool success = await accountController.recoverCustomer(emailController.text.trim());

                              if (success) {
                                ShowToast().showSuccessToast(S.of(context).pleaseCheckYourEmailForResetInstructions);
                                isLoading.value = false;
                                PersistentNavBarNavigator.pop(context);
                                return;
                              } else {
                                ShowToast().showErrorToast(S.of(context).failedToSendResetPasswordEmailPleaseTryAgain);
                                return;
                              }
                            }
                          },
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          textcolor: AppColors.white,
                          align: TextAlign.center,
                          isheading: false,
                        ),
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
}
