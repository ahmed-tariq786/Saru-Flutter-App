import 'package:saru/models/address.dart';

// Get orders result model
class GetOrdersResult {
  final bool success;
  final String? errorMessage;
  final List<OrderSummary> orders;
  final PageInfo pageInfo;

  GetOrdersResult({
    required this.success,
    this.errorMessage,
    required this.orders,
    required this.pageInfo,
  });
}

// Order summary model
class OrderSummary {
  final String id;
  final String name;
  final int orderNumber;
  final DateTime processedAt;
  final String? financialStatus;
  final String fulfillmentStatus;
  final Price currentTotalPrice;
  final Price currentTotalShippingPrice;
  final Price currentSubtotalPrice;
  final Price totalRefunded;
  final Address? shippingAddress;
  final Address? billingAddress;
  final String statusUrl;
  final List<OrderLineItem> lineItems;
  final List<DiscountApplication> discountApplications; // 👈 New

  OrderSummary({
    required this.id,
    required this.name,
    required this.orderNumber,
    required this.processedAt,
    this.financialStatus,
    required this.fulfillmentStatus,
    required this.currentTotalPrice,
    required this.currentTotalShippingPrice,
    required this.currentSubtotalPrice,
    required this.totalRefunded,
    required this.statusUrl,
    this.shippingAddress,
    this.billingAddress,
    required this.lineItems,
    required this.discountApplications,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'],
      name: json['name'],
      statusUrl: json['statusUrl'],
      orderNumber: json['orderNumber'],
      processedAt: DateTime.parse(json['processedAt']),
      financialStatus: json['financialStatus'],
      fulfillmentStatus: json['fulfillmentStatus'],
      currentTotalPrice: Price.fromJson(json['currentTotalPrice']),
      currentTotalShippingPrice: Price.fromJson(json['currentTotalShippingPrice']),
      currentSubtotalPrice: Price.fromJson(json['currentSubtotalPrice']),
      totalRefunded: Price.fromJson(json['totalRefunded']),
      shippingAddress: json['shippingAddress'] != null ? Address.fromJson(json['shippingAddress']) : null,
      billingAddress: json['billingAddress'] != null ? Address.fromJson(json['billingAddress']) : null,
      lineItems: (json['lineItems']?['edges'] as List? ?? [])
          .map((edge) => OrderLineItem.fromJson(edge['node']))
          .toList(),
      discountApplications: (json['discountApplications']?['edges'] as List? ?? [])
          .map((e) => DiscountApplication.fromJson(e['node']))
          .toList(),
    );
  }
}

// Money model for orders
class Price {
  final String amount;
  final String currencyCode;

  Price({required this.amount, required this.currencyCode});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      amount: json['amount'],
      currencyCode: json['currencyCode'],
    );
  }
}

// Order line item model for orders
class OrderLineItem {
  final String title;
  final int quantity;
  final Money originalTotalPrice;
  final Money discountedTotalPrice;
  final ProductVariant? variant;
  final List<DiscountAllocation> discountAllocations; // 👈 Fix

  OrderLineItem({
    required this.title,
    required this.quantity,
    required this.originalTotalPrice,
    required this.discountedTotalPrice,
    this.variant,
    required this.discountAllocations,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      title: json['title'],
      quantity: json['quantity'],
      originalTotalPrice: Money.fromJson(json['originalTotalPrice']),
      discountedTotalPrice: Money.fromJson(json['discountedTotalPrice']),
      variant: json['variant'] != null ? ProductVariant.fromJson(json['variant']) : null,
      discountAllocations: (json['discountAllocations'] as List? ?? [])
          .map((d) => DiscountAllocation.fromJson(d))
          .toList(),
    );
  }
}

// Discount allocation model for order line items
class DiscountAllocation {
  final Price allocatedAmount;
  final DiscountApplication discountApplication;

  DiscountAllocation({
    required this.allocatedAmount,
    required this.discountApplication,
  });

  factory DiscountAllocation.fromJson(Map<String, dynamic> json) {
    return DiscountAllocation(
      allocatedAmount: Price.fromJson(json['allocatedAmount']),
      discountApplication: DiscountApplication.fromJson(json['discountApplication']),
    );
  }
}

// Product variant model for order line items
class ProductVariant {
  final String id;
  final String title;
  final String? sku;
  final bool availableForSale;
  final int? quantityAvailable;
  final Money price;
  final Money? compareAtPrice;
  final ProductImage? image;
  final List<SelectedOption> selectedOptions;
  final Product? product;

  ProductVariant({
    required this.id,
    required this.title,
    this.sku,
    required this.availableForSale,
    this.quantityAvailable,
    required this.price,
    this.compareAtPrice,
    this.image,
    required this.selectedOptions,
    this.product,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      title: json['title'],
      sku: json['sku'],
      availableForSale: json['availableForSale'],
      quantityAvailable: json['quantityAvailable'],
      price: Money.fromJson(json['price']),
      compareAtPrice: json['compareAtPrice'] != null ? Money.fromJson(json['compareAtPrice']) : null,
      image: json['image'] != null ? ProductImage.fromJson(json['image']) : null,
      selectedOptions: (json['selectedOptions'] as List<dynamic>? ?? [])
          .map((e) => SelectedOption.fromJson(e))
          .toList(),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

// Product model for order line items
class Product {
  final String id;
  final String title;
  final String vendor;
  final List<String> tags;
  final String descriptionHtml;
  final List<ProductImage> images;
  final List<String> collections;
  final String? specifications;

  Product({
    required this.id,
    required this.title,
    required this.vendor,
    required this.tags,
    required this.descriptionHtml,
    required this.images,
    required this.collections,
    this.specifications,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      vendor: json['vendor'],
      tags: List<String>.from(json['tags'] ?? []),
      descriptionHtml: json['descriptionHtml'] ?? "",
      images: (json['images']?['edges'] as List<dynamic>? ?? []).map((e) => ProductImage.fromJson(e['node'])).toList(),
      collections: (json['collections']?['edges'] as List<dynamic>? ?? [])
          .map((e) => e['node']['title'] as String)
          .toList(),
      specifications: json['specifications']?['value'],
    );
  }
}

// Address model for shipping and billing addresses
class Address {
  final String? firstName;
  final String? lastName;
  final String? address1;
  final String? city;
  final String? country;
  final String? zip;
  final String? address2;
  final String? phone;

  Address({
    this.firstName,
    this.lastName,
    this.address1,
    this.city,
    this.country,
    this.zip,
    this.address2,
    this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      firstName: json['firstName'],
      lastName: json['lastName'],
      address1: json['address1'],
      address2: json['address2'],
      phone: json['phone'],
      city: json['city'],
      country: json['country'],
      zip: json['zip'],
    );
  }
}

// Money
class Money {
  final String amount;
  final String currencyCode;

  Money({required this.amount, required this.currencyCode});

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amount: json['amount'],
      currencyCode: json['currencyCode'],
    );
  }
}

// Product image
class ProductImage {
  final String url;
  final String? altText;

  ProductImage({required this.url, this.altText});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'],
      altText: json['altText'],
    );
  }
}

// Selected option for product variant
class SelectedOption {
  final String name;
  final String value;

  SelectedOption({required this.name, required this.value});

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name'],
      value: json['value'],
    );
  }
}

// order level discount application
class DiscountApplication {
  final String type; // DiscountCodeApplication, AutomaticDiscountApplication, etc.
  final String? code;
  final String? title;
  final bool? applicable;

  DiscountApplication({
    required this.type,
    this.code,
    this.title,
    this.applicable,
  });

  factory DiscountApplication.fromJson(Map<String, dynamic> json) {
    final type = json['__typename'];
    if (type == "DiscountCodeApplication") {
      return DiscountApplication(
        type: type,
        code: json['code'],
        applicable: json['applicable'],
      );
    } else {
      return DiscountApplication(
        type: type,
        title: json['title'],
      );
    }
  }
}
