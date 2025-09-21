import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:saru/generated/l10n.dart';
import 'package:saru/models/orders.dart';
import 'package:saru/screens/Account/Orders/order_details.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/services/order_service.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/fulfillment_status.dart';
import 'package:saru/widgets/constants/loader.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:saru/widgets/constants/toast.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, this.tabController});

  final PersistentTabController? tabController;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final orderController = Get.put(OrderController());
  final accountController = Get.find<AccountController>();

  final ScrollController _scrollController = ScrollController();

  RxBool isLoading = false.obs;

  @override
  void initState() {
    _loadData();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
    super.initState();
  }

  void _loadData() async {
    isLoading.value = true;
    final result = await orderController.fetchOrders(
      accountController.currentAccessToken ?? "",
    );

    if (result.success) {
      orderController.orderData.value = {
        "pageInfo": result.pageInfo,
      };

      orderController.orders.value = result.orders;
    } else {
      ShowToast().showErrorToast(result.errorMessage ?? S.of(context).anUnexpectedErrorOccurredPleaseTryAgain);
    }

    isLoading.value = false;
  }

  RxBool isLoadingMore = false.obs;

  Future<void> _loadMoreOrders() async {
    if (isLoadingMore.value == true || orderController.orderData["pageInfo"].hasNextPage == false) return;

    isLoadingMore.value = true;

    try {
      final result = await orderController.fetchOrders(
        accountController.currentAccessToken ?? "",
        afterCursor: orderController.orderData["pageInfo"].endCursor,
      );

      if (result.success) {
        orderController.orderData.value = {
          "pageInfo": result.pageInfo,
        };

        orderController.orders.addAll(result.orders);
      } else {
        ShowToast().showErrorToast(result.errorMessage ?? S.of(context).anUnexpectedErrorOccurredPleaseTryAgain);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    try {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMoreOrders();
      }
    } catch (e) {
      print('Scroll listener error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: myText(
          S.of(context).orders,
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
              // Loading
              if (isLoading.value)
                Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: Center(
                    child: loader(context),
                  ),
                )
              // Empty
              else if (orderController.orders.isEmpty)
                Container(
                  width: double.infinity,
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
                        Icons.receipt_long,
                        size: 80,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      Column(
                        spacing: 6,
                        children: [
                          myText(
                            S.of(context).noOrdersYet,
                            18,
                            FontWeight.w900,
                            AppColors.darkGrey,
                            TextAlign.center,
                          ),
                          myText(
                            S.of(context).youHaventPlacedAnyOrdersYetStartShoppingToSee,
                            14,
                            FontWeight.w500,
                            AppColors.grey,
                            TextAlign.center,
                          ),
                          RoundButton(
                            text: S.of(context).shopNow,
                            backgroundColor: AppColors.black,
                            borderColor: AppColors.black,
                            height: 45,
                            width: Get.width,
                            radius: 10,
                            onClick: () {
                              widget.tabController?.jumpToTab(0);
                            },
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            textcolor: AppColors.white,
                            align: TextAlign.center,
                            isheading: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              // List
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ...orderController.orders.map(
                        (element) {
                          final statusInfo = FulfillmentStatusMapper.mapOrderStatus(
                            financialStatus: element.financialStatus,
                            fulfillmentStatus: element.fulfillmentStatus,
                          );

                          return orderCard(element, statusInfo);
                        },
                      ),

                      if (isLoadingMore.value) ...[
                        loader(
                          context,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderCard(OrderSummary element, Map<String, dynamic> statusInfo) {
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: OrderDetailsScreen(
            order: element,
          ),
          withNavBar: true, // <--- keeps the bottom bar visible
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.all(12),

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

        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1️⃣ Image grid
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 90.w,
                height: 90.w,
                foregroundDecoration: BoxDecoration(
                  color: AppColors.prForeground,
                ),
                padding: const EdgeInsets.all(8),
                child: buildProductGrid(element.lineItems),
              ),
            ),

            SizedBox(width: 12),

            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  myText(
                    "Order #${element.orderNumber}",
                    15,
                    FontWeight.w600,
                    AppColors.black,
                    TextAlign.start,
                  ),
                  myText(
                    formatOrderDate(element.processedAt),
                    13,
                    FontWeight.w400,
                    AppColors.darkGrey,
                    TextAlign.start,
                  ),

                  Row(
                    spacing: 8,
                    children: [
                      if (element.currentSubtotalPrice.amount != "0.0")
                        myText(
                          "${element.currentSubtotalPrice.amount} ${element.currentSubtotalPrice.currencyCode}",
                          13,
                          FontWeight.w600,
                          AppColors.black,
                          TextAlign.start,
                        ),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                        decoration: BoxDecoration(
                          color: statusInfo["color"].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: myText(
                          statusInfo["label"],
                          12,
                          FontWeight.w400,
                          statusInfo["color"],
                          TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_outlined,
              size: 14,
              color: AppColors.darkGrey,
            ),
          ],
        ),
      ),
    );
  }

  String formatOrderDate(DateTime date) {
    final datePart = DateFormat('MMMM d, y').format(date); // September 21, 2025

    return datePart;
  }

  Widget buildProductGrid(List<OrderLineItem> items) {
    final count = items.length;

    if (count == 1) {
      // 🔹 One product → full space
      return CacheImage(
        pic: items[0].variant!.image!.url,
        width: double.infinity,
        height: double.infinity,
        radius: 0,
      );
    } else if (count == 2) {
      // 🔹 Two products → split 50/50 horizontally
      return Row(
        children: items.take(2).map((item) {
          return Expanded(
            child: CacheImage(
              pic: item.variant!.image!.url,
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          );
        }).toList(),
      );
    } else if (count == 3) {
      // 🔹 Three products → 2 stacked left, 1 big right
      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CacheImage(
                    pic: items[0].variant!.image!.url,
                    width: double.infinity,
                    height: double.infinity,
                    radius: 0,
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: CacheImage(
                    pic: items[1].variant!.image!.url,
                    width: double.infinity,
                    height: double.infinity,
                    radius: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: CacheImage(
              pic: items[2].variant!.image!.url,
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          ),
        ],
      );
    } else {
      // 🔹 Four (or more) → 2x2 grid (only first 4 shown)
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: count > 4 ? 4 : count,
        itemBuilder: (context, index) {
          return CacheImage(
            pic: items[index].variant!.image!.url,
            width: double.infinity,
            height: double.infinity,
            radius: 0,
          );
        },
      );
    }
  }
}
