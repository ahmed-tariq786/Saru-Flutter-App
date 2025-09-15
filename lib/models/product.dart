import 'package:saru/models/variant.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final String vendor;
  final List<String> tags;
  final List<String> images;
  final List<String> collections;
  final List<Variant> variants;
  final String specifications;

  Product({
    required this.id,
    required this.title,
    required this.description,
    this.vendor = '',
    this.tags = const [],
    this.images = const [],
    this.collections = const [],
    this.variants = const [],
    this.specifications = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageEdges = json['images']?['edges'] as List? ?? [];
    final collectionEdges = json['collections']?['edges'] as List? ?? [];
    final variantEdges = json['variants']?['edges'] as List? ?? [];

    final specifications = json['specifications']?['value'] ?? '';

    return Product(
      id: json['id'] ?? '',
      vendor: json['vendor'] ?? '',
      title: json['title'] ?? '',
      description: json['descriptionHtml'] ?? '',
      specifications: specifications,

      tags: List<String>.from(json['tags'] ?? []),
      images: imageEdges.map((e) => e['node']['url'] as String).toList(),
      collections: collectionEdges.map((e) => e['node']['title'] as String).toList(),
      variants: variantEdges.map((e) => Variant.fromJson(e['node'])).toList(),
    );
  }
}
