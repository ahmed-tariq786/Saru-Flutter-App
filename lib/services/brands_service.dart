import 'package:get/get.dart';
import 'package:saru/models/menus.dart';
import 'package:saru/services/menu_service.dart';

class BrandsController extends GetxController {
  final menusController = Get.find<MenusController>();

  Rx<Menus?> brandMenu = Rx<Menus?>(null);

  Future<void> fetchBrandsMenu() async {
    final menu = await menusController.fetchMenu('brands');

    // Sort items alphabetically by title
    if (menu!.items.isNotEmpty) {
      menu.items.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    brandMenu.value = menu;
  }
}
