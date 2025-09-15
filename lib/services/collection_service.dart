import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/queries/collection_queries.dart';
import 'package:saru/models/filters.dart';
import 'package:saru/models/product.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';

class CollectionController extends GetxController {
  Future<CollectionResult> fetchProductsByCollectionId(
    String id, {
    List<Map<String, dynamic>> selectedFilters = const [],
    String? after,
    Map<String, dynamic>? selectedSortOption,
  }) async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(
            getProductsByCollectionId(
              Get.find<LanguageController>().currentLocale.value.languageCode,
            ),
          ),
          fetchPolicy: FetchPolicy.networkOnly, // Bypass cache
          variables: {
            "id": id,
            "filters": selectedFilters,
            "first": 52,
            if (after != null && after.isNotEmpty) "after": after,
            if (selectedSortOption != null) "sortKey": selectedSortOption['sortKey'],
            if (selectedSortOption != null) "reverse": selectedSortOption['reverse'],
          },
        ),
      );

      if (result.hasException) {
        print('GraphQL Exception: ${result.exception.toString()}');
        throw Exception(result.exception.toString());
      }

      final productsData = result.data?['collection']?['products'];
      final edges = productsData?['edges'] as List? ?? [];
      final filtersData = productsData?['filters'] as List? ?? [];

      final pageInfo = productsData?['pageInfo'];

      final products = edges.map((edge) {
        final node = edge['node'];
        return Product.fromJson(node);
      }).toList();

      final filters = filtersData.map((f) {
        return ProductFilter.fromJson(f);
      }).toList();

      // Provide default pageInfo if null
      final safePageInfo =
          pageInfo ??
          {
            'hasNextPage': false,
            'hasPreviousPage': false,
            'startCursor': null,
            'endCursor': null,
          };

      return CollectionResult(products: products, filters: filters, pageInfo: safePageInfo);
    } catch (e) {
      print("Error fetching products: $e");
      return CollectionResult();
    }
  }
}

class CollectionResult {
  final List<Product> products;
  final List<ProductFilter> filters;
  final Map<String, dynamic>? pageInfo;

  CollectionResult({
    this.products = const [],
    this.filters = const [],
    this.pageInfo,
  });
}
