import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/queries/product_queries.dart';
import 'package:saru/graphql/queries/recommended_queries.dart';
import 'package:saru/models/filters.dart';
import 'package:saru/models/product.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';

class ProductsController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<Product> recommendedProducts = <Product>[].obs;

  RxList<Product> homePage1 = <Product>[].obs;
  RxList<Product> homePage2 = <Product>[].obs;

  RxList<ProductFilter> filters1 = <ProductFilter>[].obs;
  RxMap<String, dynamic> pageInfo1 = <String, dynamic>{}.obs;

  RxList<ProductFilter> filters2 = <ProductFilter>[].obs;
  RxMap<String, dynamic> pageInfo2 = <String, dynamic>{}.obs;

  Future<void> fetchProducts() async {
    try {
      products.clear();

      final result = await client.query(
        QueryOptions(
          document: gql(getLocalizedProducts(Get.find<LanguageController>().currentLocale.value.languageCode)),
          fetchPolicy: FetchPolicy.networkOnly, // Bypass cache
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final edges = result.data?['products']['edges'] as List<dynamic>;

      products.value = edges.map((edge) {
        final node = edge['node'];
        return Product.fromJson(node);
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> fetchRecommendedProducts(String productId) async {
    try {
      recommendedProducts.clear();

      final result = await client.query(
        QueryOptions(
          document: gql(
            getRecommendedProducts(
              Get.find<LanguageController>().currentLocale.value.languageCode,
              productId,
            ),
          ),
          fetchPolicy: FetchPolicy.networkOnly, // Bypass cache
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final recommendations = result.data?['productRecommendations'] as List<dynamic>;

      recommendedProducts.value = recommendations.map((product) {
        return Product.fromJson(product as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
    }
  }
}
