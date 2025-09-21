// Result classes for better error handling and data management

class CustomerCreationResult {
  final bool success;
  final String? errorMessage;
  final CustomerErrorType? errorType;
  final CustomerData? customer;

  CustomerCreationResult({
    required this.success,
    this.errorMessage,
    this.errorType,
    this.customer,
  });
}

class CustomerUpdateResult {
  final bool success;
  final String? errorMessage;

  CustomerUpdateResult({
    required this.success,
    this.errorMessage,
  });
}

class CustomerData {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  CustomerData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });
}

enum CustomerErrorType {
  validation, // Frontend validation errors
  network, // Network/connection errors
  shopify, // Shopify-specific errors
  unknown, // Unexpected errors
}

class Customer {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool acceptsMarketing;
  final List<String> tags;

  Customer({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.acceptsMarketing = false,
    this.tags = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      acceptsMarketing: json['acceptsMarketing'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],

      // metafields:
      //     (json['metafields']?['edges'] as List<dynamic>?)?.map((e) => Metafield.fromJson(e['node'])).toList() ?? [],
      // orders:
      //     (json['orders']?['edges'] as List<dynamic>?)?.map((e) => CustomerOrder.fromJson(e['node'])).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'acceptsMarketing': acceptsMarketing,
      'tags': tags,
      // 'addresses': addresses.map((a) => a.toJson()).toList(),
      // 'defaultAddress': defaultAddress?.toJson(),
      // 'metafields': metafields.map((m) => m.toJson()).toList(),
      // 'orders': orders.map((o) => o.toJson()).toList(),
    };
  }
}
