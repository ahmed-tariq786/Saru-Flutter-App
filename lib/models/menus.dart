class Menus {
  final String id;
  final String title;
  final List<MenuItem> items;

  Menus({
    required this.id,
    required this.title,
    required this.items,
  });

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      id: json['id'],
      title: json['title'],
      items: (json['items'] as List<dynamic>?)?.map((item) => MenuItem.fromJson(item)).toList() ?? [],
    );
  }
}

class MenuItem {
  final String id;
  final String title;
  final String type;
  final String url;
  final String? collectionId;
  final String? collectionTitle;
  final String? collectionImage;
  final List<MenuItem> items;

  MenuItem({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    this.collectionTitle,
    this.collectionId,
    this.collectionImage,
    required this.items,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final resource = json['resource'] as Map<String, dynamic>?;

    return MenuItem(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      url: json['url'],
      collectionId: resource?['id'],
      collectionTitle: resource?['title'],
      collectionImage: resource?['image']?['url'],
      items: (json['items'] as List<dynamic>?)?.map((item) => MenuItem.fromJson(item)).toList() ?? [],
    );
  }
}
