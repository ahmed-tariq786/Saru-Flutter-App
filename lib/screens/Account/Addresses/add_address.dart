import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/services/address_service.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/checkbox.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/text_style.dart';
import 'package:saru/widgets/constants/toast.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final addressServiceController = Get.find<AddressController>();
  final accountController = Get.find<AccountController>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController apartmentController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  RxBool isDefaultAddress = false.obs;

  RxBool isLoading = false.obs;

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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: myText(
            S.of(context).addAddress,
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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                        ),
                      ),
                    ],
                  ),

                  // company
                  textField(
                    context,
                    companyController,

                    (value) {},
                    S.of(context).company,
                  ),

                  // address
                  textField(
                    context,
                    addressController,

                    (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).pleaseEnterYourAddress;
                      }
                      return null;
                    },
                    S.of(context).address,
                  ),

                  // apartment
                  textField(
                    context,
                    apartmentController,

                    (value) {},
                    S.of(context).apartmentSuiteEtc,
                  ),

                  // city, country, postal code, phone
                  textField(
                    context,
                    cityController,

                    (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).pleaseEnterYourCity;
                      }
                      return null;
                    },
                    S.of(context).city,
                  ),

                  // country
                  textField(
                    context,
                    countryController,

                    (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).pleaseEnterYourCountry;
                      }
                      return null;
                    },
                    S.of(context).country,
                  ),

                  // postal code
                  textField(
                    context,
                    postalCodeController,

                    (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).pleaseEnterYourPostalzipCode;
                      }
                      return null;
                    },
                    S.of(context).postalzipCode,
                  ),

                  //phone number
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
                  ),

                  // set as default address
                  Row(
                    spacing: 12,
                    children: [
                      Obx(
                        () => CustomCheckbox(
                          value: isDefaultAddress.value,
                          onChanged: (value) {
                            isDefaultAddress.value = value;
                          },
                        ),
                      ),
                      myText(
                        S.of(context).setAsDefaultAddress,
                        12,
                        FontWeight.w400,
                        AppColors.black,
                        TextAlign.start,
                      ),
                    ],
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
                        if (_formKey.currentState!.validate()) {
                          isLoading.value = true;
                          var result = await addressServiceController.createAddress(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            address1: addressController.text,
                            city: cityController.text,

                            country: countryController.text,

                            zip: postalCodeController.text,
                            token: accountController.currentAccessToken ?? "",
                            address2: apartmentController.text.isNotEmpty ? apartmentController.text : null,
                            company: companyController.text.isNotEmpty ? companyController.text : null,
                            phone: phoneController.text,
                          );

                          if (result.success) {
                            if (isDefaultAddress.value) {
                              var result1 = await addressServiceController.setDefaultAddress(
                                token: accountController.currentAccessToken ?? "",
                                addressId: result.address?.id ?? "",
                              );
                            }

                            await accountController.loadStoredAuthentication();

                            final result3 = await addressServiceController.getAddresses(
                              accountController.currentAccessToken ?? "",
                            );
                            if (result3.defaultAddress != null) {
                              addressServiceController.defaultAddress.value = result3.defaultAddress!;
                            }

                            addressServiceController.addresses.value = result3.addresses;

                            PersistentNavBarNavigator.pop(
                              context,
                            );
                          } else {
                            ShowToast().showErrorToast(result.errorMessage ?? S.of(context).failedToAddAddress);
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
      ),
    );
  }

  Container textField(BuildContext context, TextEditingController controller, Function validator, String hintText) {
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
        keyboardType: TextInputType.text,

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
