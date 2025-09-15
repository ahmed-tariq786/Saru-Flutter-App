class ProductFilter {
  final String id;
  final String label;
  final String type;
  final List<FilterValue> values;

  ProductFilter({
    required this.id,
    required this.label,
    required this.type,
    this.values = const [],
  });

  factory ProductFilter.fromJson(Map<String, dynamic> json) {
    final valuesList = json['values'] as List? ?? [];

    return ProductFilter(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      values: valuesList.map((v) => FilterValue.fromJson(v)).toList(),
    );
  }
}

class FilterValue {
  final String id;
  final String label;
  final int count;
  final Map<String, dynamic> input;

  FilterValue({
    required this.id,
    required this.label,
    required this.count,
    required this.input,
  });

  factory FilterValue.fromJson(dynamic json) {
    if (json is String) {
      // When value is just a string (e.g., PRICE_RANGE)
      return FilterValue(
        id: json,
        label: json,
        count: 0,
        input: {},
      );
    } else if (json is Map<String, dynamic>) {
      // Normal object
      Map<String, dynamic> inputMap = {};
      if (json['input'] != null && json['input'] is Map) {
        inputMap = Map<String, dynamic>.from(json['input']);
      }

      return FilterValue(
        id: json['id'] ?? '',
        label: json['label'] ?? '',
        count: json['count'] ?? 0,
        input: inputMap,
      );
    } else {
      // Unexpected type fallback
      return FilterValue(
        id: '',
        label: '',
        count: 0,
        input: {},
      );
    }
  }
}
