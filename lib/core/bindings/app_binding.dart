import 'package:get/get.dart';

import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/home/appdrawer/drawer_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 🔥 Core controllers first
    Get.put(AuthController(), permanent: true);
    Get.put(LanguageController(), permanent: true);
    Get.put(LocationController(), permanent: true);
    Get.put(DrawerControllerX(), permanent: true);

    // 🛒 Cart last (important if it depends on others)
    Get.put(CartController(), permanent: true);
  }
}