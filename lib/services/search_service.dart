// import 'package:get/get.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:saru/graphql/queries/predictive_search.dart';
// import 'package:saru/graphql/queries/product_queries.dart';
// import 'package:saru/models/Search_Suggestions.dart';
// import 'package:saru/models/product.dart';
// import 'package:saru/services/language.dart';
// import 'package:saru/services/shopify_client.dart';

// class PredictiveSearchController extends GetxController {
//   RxList<SearchSuggestions> predictiveSearchResults = <SearchSuggestions>[].obs;
//   RxList<Product> searchedProducts = <Product>[].obs;

//   Future<void> fetchPredictiveSearchResults(String query) async {
//     try {
//       searchedProducts.clear();
//       predictiveSearchResults.clear();

//       final result;

//       // run the query to get search suggestions
//       if (Get.find<LanguageController>().currentLocale.value.languageCode == "ar") {

//       } else {
//         result = await client.query(
//           QueryOptions(
//             document: gql(getPredictiveSearch(Get.find<LanguageController>().currentLocale.value.languageCode)),
//             fetchPolicy: FetchPolicy.networkOnly, // Bypass cache
//             variables: {"query": query},
//           ),
//         );
//       }

//       // process the results
//       final suggestions = result.data?['predictiveSearch']['queries'] as List<dynamic>;
//       final products = result.data?['predictiveSearch']['products'] as List<dynamic>;

//       // map suggestions to the reactive list
//       predictiveSearchResults.value = suggestions.map((edge) {
//         final node = edge['text'];
//         return SearchSuggestions.fromJson(node);
//       }).toList();

//       // fetch full product details for each suggested product
//       if (products.isNotEmpty) {
//         final productQueries = products
//             .map(
//               (p) => client.query(
//                 QueryOptions(
//                   document: gql(
//                     getProductById(
//                       Get.find<LanguageController>().currentLocale.value.languageCode,
//                     ),
//                   ),
//                   fetchPolicy: FetchPolicy.networkOnly, // Bypass cache
//                   variables: {"id": p['id']},
//                 ),
//               ),
//             )
//             .toList();

//         final results = await Future.wait(productQueries);

//         final fetchedProducts = <Product>[];
//         for (var result in results) {
//           final productJson = result.data?['product'];
//           if (productJson != null) {
//             fetchedProducts.add(Product.fromJson(productJson));
//           }
//         }

//         searchedProducts.value = fetchedProducts;
//       }

//       print(predictiveSearchResults);
//       print(searchedProducts);
//     } catch (e) {
//       print("Error fetching products: $e");
//     }
//   }
// }

import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/queries/predictive_search_queries.dart';
import 'package:saru/graphql/queries/product_queries.dart';
import 'package:saru/models/Search_Suggestions.dart';
import 'package:saru/models/product.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';
import 'package:string_similarity/string_similarity.dart';

class PredictiveSearchController extends GetxController {
  RxList<SearchSuggestions> predictiveSearchResults = <SearchSuggestions>[].obs;
  RxList<Product> searchedProducts = <Product>[].obs;

  Future<void> fetchPredictiveSearchResults(String query) async {
    try {
      searchedProducts.clear();
      predictiveSearchResults.clear();

      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

      QueryResult result;

      // run the query to get search suggestions
      // Special handling for Arabic due to backend limitations
      if (languageCode == "ar") {
        result = await client.query(
          QueryOptions(
            document: gql(getProductSearch(languageCode)),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        );

        if (result.data?['products']?['edges'] != null) {
          final allProducts = result.data!['products']['edges'] as List<dynamic>;

          final filteredProducts = allProducts.where((edge) {
            final title = edge['node']['title'].toString().toLowerCase();
            return title.contains(query.toLowerCase());
          }).toList();

          final productTitles = filteredProducts.map((edge) => edge['node']['title'] as String).toList();

          final suggestions = getSuggestions(query, productTitles);
          predictiveSearchResults.value = suggestions.map((title) => SearchSuggestions.fromJson(title)).toList();

          result.data!['products']['edges'] = filteredProducts;
        }
      } else {
        result = await client.query(
          QueryOptions(
            document: gql(getPredictiveSearch(languageCode)),
            fetchPolicy: FetchPolicy.networkOnly,
            variables: {"query": query},
          ),
        );
      }

      // handle errors
      if (result.hasException) {
        print('GraphQL Exception: ${result.exception.toString()}');
        if (result.exception?.graphqlErrors != null) {
          for (var error in result.exception!.graphqlErrors) {
            print('GraphQL Error: ${error.message}');
          }
        }
        if (result.exception?.linkException != null) {
          print('Link Exception: ${result.exception!.linkException.toString()}');
        }
        return;
      }

      // ensure data is present
      if (result.data == null) {
        print('No data returned from search query');
        return;
      }

      // process the results
      // for Arabic, products are under products(query:), for others under predictiveSearch
      if (languageCode == "ar") {
        // Arabic → products(query:)
        final productsData = result.data?['products'];

        if (productsData != null && productsData['edges'] != null) {
          final products = productsData['edges'] as List<dynamic>;

          try {
            searchedProducts.value = products.map((edge) {
              final node = edge['node'] as Map<String, dynamic>;

              return Product.fromJson(node);
            }).toList();
          } catch (mappingError) {
            print('Error mapping Arabic products: $mappingError');
          }
        } else {
          print('No products data or edges found for Arabic');
        }
      } else {
        final predictiveSearchData = result.data?['predictiveSearch'];
        if (predictiveSearchData != null) {
          final suggestions = (predictiveSearchData['queries'] as List<dynamic>?) ?? [];
          final products = (predictiveSearchData['products'] as List<dynamic>?) ?? [];

          predictiveSearchResults.value = suggestions.map((edge) {
            final node = edge['text'];
            return SearchSuggestions.fromJson(node);
          }).toList();

          if (products.isNotEmpty) {
            final productQueries = products
                .map(
                  (p) => client.query(
                    QueryOptions(
                      document: gql(
                        getProductById(
                          Get.find<LanguageController>().currentLocale.value.languageCode,
                        ),
                      ),
                      fetchPolicy: FetchPolicy.networkOnly, // Bypass cache
                      variables: {"id": p['id']},
                    ),
                  ),
                )
                .toList();

            final results = await Future.wait(productQueries);

            final fetchedProducts = <Product>[];
            for (var result in results) {
              final productJson = result.data?['product'];
              if (productJson != null) {
                fetchedProducts.add(Product.fromJson(productJson));
              }
            }

            searchedProducts.value = fetchedProducts;
          }
        }
      }
    } catch (e) {
      print("Error fetching search results: $e");
      searchedProducts.clear();
      predictiveSearchResults.clear();
    }
  }

  List<String> getSuggestions(String query, List<String> productTitles) {
    final phrases = <String>{};

    for (var title in productTitles) {
      final words = title.split(' ');

      // Generate 1-word phrases
      phrases.addAll(words);

      // Generate 2-word phrases
      for (var i = 0; i < words.length - 1; i++) {
        phrases.add("${words[i]} ${words[i + 1]}");
      }

      // Generate 3-word phrases
      for (var i = 0; i < words.length - 2; i++) {
        phrases.add("${words[i]} ${words[i + 1]} ${words[i + 2]}");
      }
    }

    // Compare query with all generated phrases
    final matches = phrases.map((phrase) {
      final score = query.similarityTo(phrase);
      return {'phrase': phrase, 'score': score};
    }).toList();

    // Sort by similarity
    matches.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // Take top 5 suggestions
    return matches.take(5).map((m) => m['phrase'] as String).toList();
  }
}
