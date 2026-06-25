import 'package:get/get.dart';

import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/home/appdrawer/drawer_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/order/order_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart'; // 🔥 ADD THIS

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 🔥 Core controllers first
    Get.put(AuthController(), permanent: true);
    Get.put(LanguageController(), permanent: true);
    Get.put(LocationController(), permanent: true);
    Get.put(DrawerControllerX(), permanent: true);

    // 🛒 Cart
    Get.put(CartController(), permanent: true);

    // 🚚 Order Controller (NEW FIX)
    Get.put(OrderController(), permanent: true);
    Get.put(OrderTrackingController(), permanent: true);
  }
}