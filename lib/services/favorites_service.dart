import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/queries/product_id_queries.dart';
import 'package:saru/models/product.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesController extends GetxController {
  static const _favoritesKey = "favorite_product_ids";

  RxList<Product> products = <Product>[].obs;

  // Store IDs in memory (reactive list)
  var favoriteIds = <String>[].obs;

  RxBool isLoading = true.obs;

  Future<void> fetchProductsByIds(List<String> ids) async {
    try {
      products.clear();

      final locale = Get.find<LanguageController>().currentLocale.value.languageCode;

      final result = await client.query(
        QueryOptions(
          document: gql(getProductsByIds(locale)),
          variables: {
            "ids": ids,
          },
          fetchPolicy: FetchPolicy.networkOnly, // always fetch latest
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final nodes = result.data?['nodes'] as List<dynamic>?;

      if (nodes == null) return;

      products.value = nodes.map((node) {
        return Product.fromJson(node);
      }).toList();
    } catch (e) {
      print("❌ Error fetching products by ids: $e");
    }
  }

  /// Load favorites from SharedPreferences (call this in Splash)
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favoritesKey) ?? [];
    favoriteIds.assignAll(ids);
    print("✅ Favorites loaded: $favoriteIds");
  }

  /// Toggle favorite (add/remove) and persist
  Future<void> toggleFavorite(String productId) async {
    final prefs = await SharedPreferences.getInstance();

    if (favoriteIds.contains(productId)) {
      favoriteIds.remove(productId);
    } else {
      favoriteIds.add(productId);
    }

    // Save updated list
    await prefs.setStringList(_favoritesKey, favoriteIds);
    print("✅ Favorites updated: $favoriteIds");
  }

  /// Helper to check if a product is favorited
  bool isFavorited(String productId) => favoriteIds.contains(productId);
}
