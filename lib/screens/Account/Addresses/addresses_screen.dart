import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/models/address.dart';
import 'package:saru/screens/Account/Addresses/add_address.dart';
import 'package:saru/screens/Account/Addresses/edit_address.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/services/address_service.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/toast.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final accountController = Get.find<AccountController>();
  final addressServiceController = Get.put(AddressController());

  RxString defaultAddressid = "".obs;

  RxBool isAddressesLoading = false.obs;

  final ScrollController _scrollController = ScrollController();

  Rx<PageInfo> pageInfo = PageInfo(
    hasNextPage: false,
    hasPreviousPage: false,
    startCursor: "",
    endCursor: "",
  ).obs;

  RxBool isLoadingMore = false.obs;

  @override
  void initState() {
    _loadData();

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
    super.initState();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    try {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreAddresses();
      }
    } catch (e) {
      print('Scroll listener error: $e');
    }
  }

  void _loadData() async {
    isAddressesLoading.value = true;

    final result = await addressServiceController.getAddresses(
      accountController.currentAccessToken ?? "",
    );

    if (result.defaultAddress != null) {
      addressServiceController.defaultAddress.value = result.defaultAddress;
    }

    if (result.pageInfo.hasNextPage) {
      pageInfo.value = result.pageInfo;
    }

    addressServiceController.addresses.value = result.addresses;

    isAddressesLoading.value = false;
  }

  Future<void> _loadMoreAddresses() async {
    if (isLoadingMore.value == true || pageInfo.value.hasNextPage == false) return;

    isLoadingMore.value = true;

    try {
      final result = await addressServiceController.getAddresses(
        accountController.currentAccessToken ?? "",
        afterCursor: pageInfo.value.endCursor,
      );

      if (result.defaultAddress != null) {
        addressServiceController.defaultAddress.value = result.defaultAddress;
      }
      addressServiceController.addresses.addAll(result.addresses);

      pageInfo.value = result.pageInfo;
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: myText(
          S.of(context).addresses,
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
      body: Obx(
        () => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(
            children: [
              if (isAddressesLoading.value)
                Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: Center(
                    child: loader(context),
                  ),
                )
              else if (addressServiceController.addresses.isEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightGrey.withOpacity(0.5),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 12,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 80,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      Column(
                        spacing: 6,
                        children: [
                          myText(
                            S.of(context).noAddressesAdded,
                            18,
                            FontWeight.w900,
                            AppColors.darkGrey,
                            TextAlign.center,
                          ),
                          myText(
                            S.of(context).youHaventAddedAnyAddressesYetAddANewAddress,
                            14,
                            FontWeight.w500,
                            AppColors.grey,
                            TextAlign.center,
                          ),
                        ],
                      ),

                      RoundButton(
                        text: S.of(context).addANewAddress,
                        backgroundColor: AppColors.black,
                        borderColor: AppColors.black,
                        height: 45,
                        width: Get.width,
                        radius: 10,
                        onClick: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: AddAddressScreen(),
                            withNavBar: true, // <--- keeps the bottom bar visible
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        textcolor: AppColors.white,
                        align: TextAlign.center,
                        isheading: false,
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 12,
                    children: [
                      ...addressServiceController.addresses.map(
                        (element) {
                          return addressCard(element, context);
                        },
                      ),

                      if (isLoadingMore.value) ...[
                        loader(
                          context,
                        ),
                      ],

                      RoundButton(
                        text: S.of(context).addANewAddress,
                        backgroundColor: AppColors.black,
                        borderColor: AppColors.black,
                        height: 45,
                        width: Get.width,
                        radius: 10,
                        onClick: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: AddAddressScreen(),
                            withNavBar: false, // <--- hides the bottom bar

                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        textcolor: AppColors.white,
                        align: TextAlign.center,
                        isheading: false,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Container addressCard(CustomerAddress element, BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: addressServiceController.defaultAddress.value?.id == element.id
              ? AppColors.black
              : AppColors.darkGrey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on,
            size: 20,
            color: AppColors.black,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    myText(
                      "${element.firstName} ${element.lastName}",
                      14,
                      FontWeight.w600,
                      AppColors.black,
                      TextAlign.start,
                    ),

                    Row(
                      spacing: 6,
                      children: [
                        GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: EditAddressScreen(
                                firstName: element.firstName,
                                lastName: element.lastName,
                                company: element.company ?? "",
                                address: element.address1,
                                apartment: element.address2 ?? "",
                                city: element.city,
                                country: element.country,
                                postalCode: element.zip,
                                phone: element.phone ?? "",
                                id: element.id,
                              ),
                              withNavBar: false, // <--- keeps the bottom bar visible
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.black,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            showDeleteAddressDialog(context, element.id);
                          },
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Single formatted address line
                myText(
                  [
                    element.address1,
                    element.address2,
                    element.city,
                    element.zip,
                    element.country,
                  ].where((part) => part != null && part.toString().isNotEmpty).join(", "),
                  13,
                  FontWeight.w400,
                  AppColors.black,
                  TextAlign.start,
                ),

                // Phone (optional)
                myText(
                  "📞 ${element.phone}",
                  13,
                  FontWeight.w400,
                  AppColors.black,
                  TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteAddressDialog(BuildContext context, String addressId) {
    RxBool isLoading = false.obs;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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

                  myText(
                    S.of(context).deleteAddress,
                    24,
                    FontWeight.w800,
                    Color.fromARGB(255, 0, 0, 0),
                    TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  myText(
                    S.of(context).areYouSureYouWantToDeleteThisAddress,
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
                    Obx(
                      () => RoundButton(
                        textcolor: AppColors.white,
                        isheading: true,

                        text: S.of(context).yesDelete,
                        align: TextAlign.center,

                        backgroundColor: AppColors.black,
                        borderColor: AppColors.black,
                        height: 50,
                        loading: isLoading.value,
                        width: MediaQuery.sizeOf(context).width,
                        radius: 42,
                        onClick: () async {
                          isLoading.value = true;
                          var result = await addressServiceController.deleteAddress(
                            token: accountController.currentAccessToken ?? "",
                            addressId: addressId,
                          );

                          if (result.success) {
                            ShowToast().showSuccessToast(S.of(context).addressDeletedSuccessfully);
                            isLoading.value = false;
                            _loadData();
                            Get.back();
                          } else {
                            ShowToast().showErrorToast(
                              result.errorMessage ?? S.of(context).anErrorOccurredWhileDeletingTheAddressPleaseTryAgain,
                            );
                            isLoading.value = false;
                          }

                          isLoading.value = false;
                          Get.back();
                        },
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
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
}
