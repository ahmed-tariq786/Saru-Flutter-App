import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:saru/graphql/queries/menu_queries.dart';
import 'package:saru/models/menus.dart';
import 'package:saru/services/language.dart';
import 'package:saru/services/shopify_client.dart';

class MenusController extends GetxController {
  RxMap<String, Menus> menus = <String, Menus>{}.obs;
  RxBool isLoading = false.obs;

  Future<Menus?> fetchMenu(String handle) async {
    isLoading.value = true;
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

      final result = await client.query(
        QueryOptions(
          document: gql(getMenus(languageCode)),
          variables: {"handle": handle},
        ),
      );

      if (result.hasException) {
        print('Error fetching menu $handle: ${result.exception}');
        return null;
      }

      final menuData = result.data?['menu'];
      if (menuData != null) {
        final menu = Menus.fromJson(menuData);
        menus[handle] = menu;
        return menu;
      }
      return null;
    } catch (e) {
      print('Exception fetching menu $handle: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch multiple menus by their handles (using individual requests)
  Future<void> fetchMultipleMenus(List<String> handles) async {
    isLoading.value = true;
    try {
      await Future.wait(
        handles.map((handle) => fetchMenu(handle)),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch multiple menus in a single GraphQL request (more efficient)
  Future<void> fetchMultipleMenusOptimized(List<String> handles) async {
    if (handles.isEmpty) return;

    menus.clear();

    isLoading.value = true;
    try {
      final languageCode = Get.find<LanguageController>().currentLocale.value.languageCode;

      final result = await client.query(
        QueryOptions(
          document: gql(getMultipleMenus(languageCode, handles)),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('Error fetching multiple menus: ${result.exception}');
        return;
      }

      final data = result.data;
      if (data != null) {
        for (int i = 0; i < handles.length; i++) {
          final menuData = data['menu$i'];
          if (menuData != null) {
            final menu = Menus.fromJson(menuData);
            menus[handles[i]] = menu;
          }
        }
      }
    } catch (e) {
      print('Exception fetching multiple menus: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Convenience method for the main app menu (backward compatibility)
  Future<void> fetchMainMenu() async {
    return await fetchMultipleMenusOptimized([
      "makeup-mobile-app",
      "perfume-mobile-app",
    ]);
  }
}
