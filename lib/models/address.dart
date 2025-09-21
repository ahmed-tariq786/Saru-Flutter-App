class AddressCreationResult {
  final bool success;
  final String? errorMessage;
  final CustomerAddress? address;

  AddressCreationResult({
    required this.success,
    this.errorMessage,
    this.address,
  });
}

class AddressDeletionResult {
  final bool success;
  final String? errorMessage;

  AddressDeletionResult({
    required this.success,
    this.errorMessage,
  });
}

class AddressUpdateResult {
  final bool success;
  final String? errorMessage;
  final CustomerAddress? defaultAddress;

  AddressUpdateResult({
    required this.success,
    this.errorMessage,
    this.defaultAddress,
  });
}

class GetAddressResult {
  final bool success;
  final String? errorMessage;
  final List<CustomerAddress> addresses;
  final PageInfo pageInfo;
  final CustomerAddress? defaultAddress; // <-- nullable now

  GetAddressResult({
    required this.success,
    this.errorMessage,
    required this.addresses,
    required this.pageInfo,
    required this.defaultAddress,
  });
}

class CustomerAddress {
  final String id;
  final String firstName;
  final String lastName;
  final String? company;
  final String address1;
  final String? address2;
  final String city;
  final String country;
  final String zip;
  final String? phone;

  final String? province;

  CustomerAddress({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.company,
    required this.address1,
    this.address2,
    required this.city,
    required this.country,
    required this.zip,
    this.phone,

    this.province,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      company: json['company'] as String?,
      address1: json['address1'] as String? ?? '',
      address2: json['address2'] as String?,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      zip: json['zip'] as String? ?? '',
      phone: json['phone'] as String?,

      province: json['province'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
      'address1': address1,
      'address2': address2,
      'city': city,
      'country': country,
      'zip': zip,
      'phone': phone,

      'province': province,
    };
  }

  @override
  String toString() {
    return '$firstName $lastName, $address1, ${address2 ?? ''}, $city, $country, $zip';
  }
}

class PageInfo {
  final bool hasNextPage;
  final bool hasPreviousPage;
  final String? startCursor;
  final String? endCursor;

  PageInfo({
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.startCursor,
    this.endCursor,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      startCursor: json['startCursor'] as String?,
      endCursor: json['endCursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
      'startCursor': startCursor,
      'endCursor': endCursor,
    };
  }
}
