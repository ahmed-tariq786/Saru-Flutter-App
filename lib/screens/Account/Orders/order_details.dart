import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:saru/generated/l10n.dart';
import 'package:saru/models/orders.dart';
import 'package:saru/services/account_service.dart';
import 'package:saru/widgets/constants/back.dart';
import 'package:saru/widgets/constants/button.dart';
import 'package:saru/widgets/constants/cache_image.dart';
import 'package:saru/widgets/constants/colors.dart';
import 'package:saru/widgets/constants/fulfillment_status.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final OrderSummary order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final accountController = Get.find<AccountController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final finStatus =
        FulfillmentStatusMapper().financialStatusMap[widget.order.financialStatus] ??
        {
          "label": widget.order.financialStatus,
          "color": Colors.black,
        };
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: myText(
          widget.order.name,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 16,
          children: [
            widget.order.lineItems.isEmpty
                ? myText(S.of(context).noItemsInThisOrder, 16, FontWeight.w400, Colors.black, TextAlign.start)
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: Get.height * 0.35,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: widget.order.lineItems.length,
                            itemBuilder: (context, index) {
                              final item = widget.order.lineItems[index];
                              var totalDiscount = 0.0;

                              for (var discount in item.discountAllocations) {
                                totalDiscount += double.parse(discount.allocatedAmount.amount);
                              }

                              var totalPrice = double.parse(item.originalTotalPrice.amount) - totalDiscount;

                              return orderItemsCard(item, context, index, totalPrice);
                            },
                          ),
                        ),
                        orderTotal(context, finStatus),
                      ],
                    ),
                  ),

            orderInformation(context, finStatus),

            RoundButton(
              textcolor: AppColors.white,
              isheading: true,

              text: S.of(context).viewOrderOnline,
              align: TextAlign.center,

              backgroundColor: AppColors.black,
              borderColor: AppColors.black,
              height: 50,
              width: MediaQuery.sizeOf(context).width,
              radius: 42,
              onClick: () {
                launchUrl(
                  Uri.parse(
                    widget.order.statusUrl,
                  ),
                ); // using url_launcher
              },
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Container orderItemsCard(OrderLineItem item, BuildContext context, int index, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: index != widget.order.lineItems.length - 1
            ? Border(
                bottom: BorderSide(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        spacing: 12,
        children: [
          // Image
          Stack(
            children: [
              item.variant!.image != null
                  ? CacheImage(
                      pic: item.variant!.image!.url,
                      width: 70,
                      height: 70,
                      radius: 0,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),

              Positioned(
                left: Directionality.of(context) == TextDirection.rtl ? 0 : null,
                right: Directionality.of(context) == TextDirection.rtl ? null : 0,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: AppColors.black,
                  ),
                  child: myText(
                    widget.order.lineItems[index].quantity.toString(),
                    12,
                    FontWeight.w800,
                    AppColors.white,
                    TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // title and discounts
                Expanded(
                  child: Column(
                    spacing: 6,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      myText(
                        widget.order.lineItems[index].variant!.product!.title,
                        13,
                        FontWeight.w400,
                        Colors.black,
                        TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      // At order summary (bottom)
                      if (widget.order.lineItems[index].discountAllocations.isNotEmpty) ...[
                        for (var discount in widget.order.lineItems[index].discountAllocations)
                          if (discount.allocatedAmount.amount != "0.0")
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 14,
                                  color: AppColors.darkGrey.withOpacity(0.7),
                                ),
                                myText(
                                  discount.discountApplication.type == "ManualDiscountApplication"
                                      ? "DISCOUNT"
                                      : discount.discountApplication.type == "AutomaticDiscountApplication"
                                      ? "AUTOMATIC DISCOUNT"
                                      : (discount.discountApplication.code!.toUpperCase()),
                                  12,
                                  FontWeight.w500,
                                  AppColors.darkGrey.withOpacity(0.7),
                                  TextAlign.start,
                                ),
                                // Amount
                                myText(
                                  "(-${discount.allocatedAmount.amount} ${discount.allocatedAmount.currencyCode}) ",
                                  12,
                                  FontWeight.w500,
                                  AppColors.darkGrey.withOpacity(0.7),
                                  TextAlign.start,
                                ),
                              ],
                            ),
                      ],
                    ],
                  ),
                ),
                // Prices
                Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.discountAllocations.isNotEmpty &&
                        totalPrice < double.parse(item.originalTotalPrice.amount)) ...[
                      myText(
                        "${double.parse(item.originalTotalPrice.amount).toStringAsFixed(3)} ${item.originalTotalPrice.currencyCode}",
                        12,
                        FontWeight.w800,
                        AppColors.darkGrey.withOpacity(0.5),
                        TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        decoration: TextDecoration.lineThrough,
                      ),
                      if (totalPrice > 0)
                        myText(
                          "${totalPrice.toStringAsFixed(3)} ${item.discountedTotalPrice.currencyCode}",
                          14,
                          FontWeight.w800,
                          Colors.black,
                          TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ] else ...[
                      myText(
                        "${item.originalTotalPrice.amount} ${item.originalTotalPrice.currencyCode}",
                        14,
                        FontWeight.w800,
                        Colors.black,
                        TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container orderTotal(BuildContext context, Map<String, dynamic> finStatus) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.lightGrey,
            width: 1,
          ),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -5), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                myText(
                  S.of(context).subtotal,
                  13,
                  FontWeight.w400,
                  Colors.black,
                  TextAlign.start,
                ),
                myText(
                  "${double.parse(widget.order.currentSubtotalPrice.amount).toStringAsFixed(3)} ${widget.order.currentSubtotalPrice.currencyCode}",
                  14,
                  FontWeight.w400,
                  Colors.black,
                  TextAlign.start,
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                myText(
                  S.of(context).shipping,
                  13,
                  FontWeight.w400,
                  Colors.black,
                  TextAlign.start,
                ),
                myText(
                  widget.order.currentTotalShippingPrice.amount == "0.0"
                      ? S.of(context).free
                      : "${double.parse(widget.order.currentTotalShippingPrice.amount).toStringAsFixed(3)} ${widget.order.currentTotalShippingPrice.currencyCode}",
                  14,
                  FontWeight.w400,
                  Colors.black,
                  TextAlign.start,
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                myText(
                  "Total",
                  15,
                  FontWeight.w800,
                  Colors.black,
                  TextAlign.start,
                ),
                myText(
                  "${double.parse(widget.order.currentTotalPrice.amount).toStringAsFixed(3)} ${widget.order.currentTotalPrice.currencyCode}",
                  14,
                  FontWeight.w700,
                  Colors.black,
                  TextAlign.start,
                ),
              ],
            ),

            if (widget.order.totalRefunded.amount != "0.0")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  myText(
                    finStatus["label"],
                    13,
                    FontWeight.w400,
                    finStatus["color"],
                    TextAlign.start,
                  ),
                  myText(
                    "-${double.parse(widget.order.totalRefunded.amount).toStringAsFixed(3)} ${widget.order.totalRefunded.currencyCode}",
                    14,
                    FontWeight.w400,
                    finStatus["color"],
                    TextAlign.start,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Container orderInformation(BuildContext context, Map<String, dynamic> finStatus) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        children: [
          // Contact Information
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // Contact Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    myText(
                      S.of(context).contactInformation,
                      14,
                      FontWeight.w600,
                      Colors.black,
                      TextAlign.start,
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    myText(
                      "${accountController.currentCustomer.value?.firstName.capitalizeFirst ?? ""} ${accountController.currentCustomer.value?.lastName.capitalizeFirst ?? ""}",
                      13,
                      FontWeight.w400,
                      Colors.black,
                      TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    myText(
                      accountController.currentCustomer.value?.email ?? "",
                      13,
                      FontWeight.w400,
                      Colors.black,
                      TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    myText(
                      accountController.currentCustomer.value?.phone ?? "",
                      13,
                      FontWeight.w400,
                      Colors.black,
                      TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Payment Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    myText(
                      S.of(context).payment,
                      14,
                      FontWeight.w600,
                      Colors.black,
                      TextAlign.start,
                    ),
                    SizedBox(
                      height: 8,
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      decoration: BoxDecoration(
                        color: finStatus["color"].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: myText(
                        finStatus["label"],
                        12,
                        FontWeight.w400,
                        finStatus["color"],
                        TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),

                    if (widget.order.totalRefunded.amount == "0.0")
                      myText(
                        "${double.parse(widget.order.currentTotalPrice.amount).toStringAsFixed(3)} ${widget.order.currentTotalPrice.currencyCode}",
                        13,
                        FontWeight.w400,
                        Colors.black,
                        TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    myText(
                      formatShortDate(widget.order.processedAt.toString()),
                      13,
                      FontWeight.w400,
                      Colors.black,
                      TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Shipping & Billing Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // Shipping Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    myText(
                      S.of(context).shippingAddress,
                      14,
                      FontWeight.w600,
                      Colors.black,
                      TextAlign.start,
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    myText(
                      "${widget.order.shippingAddress?.firstName ?? ""} ${widget.order.shippingAddress?.lastName ?? ""}",
                      13,
                      FontWeight.w400,
                      Colors.black,
                      TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    myText(
                      [
                        widget.order.shippingAddress?.address1,
                        widget.order.shippingAddress?.address2,
                        widget.order.shippingAddress?.city,
                        widget.order.shippingAddress?.zip,
                        widget.order.shippingAddress?.province,
                        widget.order.shippingAddress?.country,
                      ].where((part) => part != null && part.toString().isNotEmpty).join(", "),
                      13,
                      FontWeight.w400,
                      AppColors.black,
                      TextAlign.start,
                    ),

                    // Phone (optional)
                    if (widget.order.shippingAddress?.phone != null && widget.order.shippingAddress!.phone!.isNotEmpty)
                      myText(
                        "📞 ${widget.order.shippingAddress?.phone}",
                        13,
                        FontWeight.w400,
                        AppColors.black,
                        TextAlign.start,
                      ),
                  ],
                ),
              ),

              // Billing Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    myText(
                      S.of(context).billingAddress,
                      14,
                      FontWeight.w600,
                      Colors.black,
                      TextAlign.start,
                    ),
                    SizedBox(
                      height: 8,
                    ),

                    myText(
                      "${widget.order.billingAddress?.firstName ?? ""} ${widget.order.billingAddress?.lastName ?? ""}",
                      13,
                      FontWeight.w400,
                      Colors.black,
                      TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    myText(
                      [
                        widget.order.billingAddress?.address1,
                        widget.order.billingAddress?.address2,
                        widget.order.billingAddress?.city,
                        widget.order.billingAddress?.zip,
                        widget.order.billingAddress?.province,
                        widget.order.billingAddress?.country,
                      ].where((part) => part != null && part.toString().isNotEmpty).join(", "),
                      13,
                      FontWeight.w400,
                      AppColors.black,
                      TextAlign.start,
                    ),

                    // Phone (optional)
                    if (widget.order.billingAddress?.phone != null && widget.order.billingAddress!.phone!.isNotEmpty)
                      myText(
                        "📞 ${widget.order.billingAddress?.phone}",
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
        ],
      ),
    );
  }

  String formatShortDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return intl.DateFormat('MMMM d, y').format(date); // Sep 21
  }
}
