class CartLine {
  final String id;
  final int quantity;
  final CartMerchandise merchandise;

  CartLine({
    required this.id,
    required this.quantity,
    required this.merchandise,
  });

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      id: json['id'] ?? '',
      quantity: json['quantity'] ?? 0,
      merchandise: CartMerchandise.fromJson(json['merchandise']),
    );
  }
}

class CartMerchandise {
  final String id;
  final String title;
  final String? sku;
  final String productId;
  final String productTitle;
  final String productDescription;
  final String vendor;
  final List<String> tags;
  final String imageUrl;
  final List<String> productImages;
  final List<String> collections;
  final String specifications;

  final bool availableForSale;
  final int quantityAvailable;
  final double price;
  final double? compareAtPrice;
  final String currencyCode;
  final List<SelectedOption> selectedOptions;

  CartMerchandise({
    required this.id,
    required this.title,
    this.sku,
    required this.productId,
    required this.productTitle,
    this.productDescription = '',
    required this.vendor,
    this.tags = const [],
    required this.imageUrl,
    this.productImages = const [],
    this.collections = const [],
    this.specifications = '',

    this.availableForSale = true,
    this.quantityAvailable = 0,
    required this.price,
    this.compareAtPrice,
    required this.currencyCode,
    this.selectedOptions = const [],
  });

  factory CartMerchandise.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    final imageEdges = product['images']?['edges'] as List? ?? [];
    final collectionEdges = product['collections']?['edges'] as List? ?? [];

    return CartMerchandise(
      id: json['id'] ?? '',
      title: product['title'] ?? json['title'] ?? '',
      sku: json['sku'],
      productId: product['id'] ?? '',
      productTitle: product['title'] ?? '',
      productDescription: product['descriptionHtml'] ?? '',
      vendor: product['vendor'] ?? '',
      tags: List<String>.from(product['tags'] ?? []),
      imageUrl: json['image']?['url'] ?? '',
      productImages: imageEdges.map((e) => e['node']['url'] as String).toList(),
      collections: collectionEdges.map((e) => e['node']['title'] as String).toList(),
      specifications: product['specifications']?['value'] ?? '',

      availableForSale: json['availableForSale'] ?? true,
      quantityAvailable: json['quantityAvailable'] ?? 0,
      price: double.tryParse(json['price']?['amount'] ?? '0') ?? 0,
      compareAtPrice: double.tryParse(json['compareAtPrice']?['amount'] ?? '0'),
      currencyCode: json['price']?['currencyCode'] ?? 'KWD',
      selectedOptions: (json['selectedOptions'] as List? ?? []).map((o) => SelectedOption.fromJson(o)).toList(),
    );
  }
}

class SelectedOption {
  final String name;
  final String value;

  SelectedOption({
    required this.name,
    required this.value,
  });

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }
}
