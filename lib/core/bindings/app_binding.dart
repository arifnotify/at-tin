import 'package:get/get.dart';
import 'package:tin/core/constants/network_controller.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/home/category/category_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/home/appdrawer/drawer_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/order/order_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart';
import 'package:tin/modules/payment/payment_settings_controller.dart';
import 'package:tin/modules/reward/reward_controller.dart'; 
import 'package:tin/modules/home/home_controller.dart';     
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 🌐 Network Controller First
    Get.put(NetworkController(), permanent: true); // 🌐 Added

    // 🔥 Core controllers
    Get.put(AuthController(), permanent: true);
    Get.put(LanguageController(), permanent: true);
    Get.put(LocationController(), permanent: true);
    Get.put(DrawerControllerX(), permanent: true);

    // 🛒 Cart & Home & Reward
    Get.put(CartController(), permanent: true);
    Get.put(RewardController(), permanent: true);
    Get.put(HomeController(), permanent: true); 
    Get.put(CategoryController(), permanent: true);

    // 🚚 Order Controller
    Get.put(OrderController(), permanent: true);
    Get.put(OrderTrackingController(), permanent: true);

    //payment controller
    Get.put(PaymentSettingsController(), permanent: true);

  }
}