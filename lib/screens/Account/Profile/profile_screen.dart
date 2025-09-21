import 'package:flutter/material.dart';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  TextEditingController phoneController = TextEditingController();
  RxBool isLoading = false.obs;

  final accountController = Get.find<AccountController>();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    accountController.currentCustomer.value != null
        ? firstNameController.text = accountController.currentCustomer.value!.firstName
        : firstNameController.text = '';

    accountController.currentCustomer.value != null
        ? lastNameController.text = accountController.currentCustomer.value!.lastName
        : lastNameController.text = '';

    accountController.currentCustomer.value != null
        ? phoneController.text = accountController.currentCustomer.value!.phone ?? ""
        : phoneController.text = '';
    super.initState();
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
          title: myText(
            S.of(context).profile,
            18,
            FontWeight.w600,
            Colors.black,
            TextAlign.start,
          ),
          leading: backButton(context),
          backgroundColor: AppColors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              spacing: 12,
              children: [
                // name
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: textField(
                        context,
                        firstNameController,

                        (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).pleaseEnterYourFirstName;
                          }
                          return null;
                        },
                        S.of(context).firstName,
                        false,
                      ),
                    ),
                    Expanded(
                      child: textField(
                        context,
                        lastNameController,

                        (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).pleaseEnterYourLastName;
                          }
                          return null;
                        },
                        S.of(context).lastName,
                        false,
                      ),
                    ),
                  ],
                ),

                // phone
                textField(
                  context,
                  phoneController,

                  (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                  S.of(context).phoneNumber,
                  true,
                ),

                Obx(
                  () => RoundButton(
                    text: S.of(context).save,
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
                        var result = await accountController.updateCustomer(
                          firstNameController.text,
                          lastNameController.text,
                          phoneController.text,
                        );

                        if (result.success) {
                          ShowToast().showSuccessToast(S.of(context).profileUpdatedSuccessfully);
                          PersistentNavBarNavigator.pop(context);
                        } else {
                          String errorMessage =
                              result.errorMessage ?? S.of(context).anUnexpectedErrorOccurredPleaseTryAgainLater;
                          ShowToast().showErrorToast(errorMessage);
                        }

                        isLoading.value = false;
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
    );
  }

  Container textField(
    BuildContext context,
    TextEditingController controller,
    Function validator,
    String hintText,
    bool isEmailField,
  ) {
    return Container(
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
        controller: controller,

        validator: (value) => validator(value),
        style: textstyle(
          15,
          AppColors.black,
          FontWeight.w400,
        ),
        keyboardType: isEmailField ? TextInputType.emailAddress : TextInputType.text,

        decoration: InputDecoration(
          fillColor: AppColors.white,
          filled: true,

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

          labelText: hintText,
          labelStyle: textstyle(
            13,
            AppColors.darkGrey.withOpacity(1),
            FontWeight.w500,
          ),

          hintText: hintText,
          hintStyle: textstyle(
            15,
            AppColors.darkGrey.withOpacity(0.5),
            FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
