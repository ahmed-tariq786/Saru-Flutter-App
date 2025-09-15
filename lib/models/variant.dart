class Variant {
  final String id;
  final String title;
  final String? sku;
  final String? image; // Single image URL for variant
  final bool available;
  final double? price;
  final double? compareAtPrice;
  final int quantityAvailable;
  final String? currency;
  final Map<String, String> selectedOptions;

  Variant({
    required this.id,
    required this.title,
    this.image, // Changed from images to image
    this.sku,
    this.available = true,
    this.quantityAvailable = 0,
    this.price,
    this.compareAtPrice,
    this.currency,
    this.selectedOptions = const {},
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    final options = <String, String>{};
    if (json['selectedOptions'] != null) {
      for (var opt in json['selectedOptions']) {
        options[opt['name']] = opt['value'];
      }
    }

    return Variant(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] != null ? json['image']['url'] : null, // Parse single image
      sku: json['sku'],
      available: json['availableForSale'] ?? true,
      price: json['price'] != null ? double.tryParse(json['price']['amount']) : null,
      compareAtPrice: json['compareAtPrice'] != null ? double.tryParse(json['compareAtPrice']['amount']) : null,
      currency: json['price'] != null ? json['price']['currencyCode'] : null,
      selectedOptions: options,
      quantityAvailable: json['quantityAvailable'] ?? 0,
    );
  }
}
