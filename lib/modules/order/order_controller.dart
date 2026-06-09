import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/services/order_service.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';


class OrderController
    extends GetxController {

  final service =
      OrderService();

  RxBool isLoading =
      false.obs;

Future<void> placeOrder(String addressId) async {

  final cart = Get.find<CartController>();

  /// 🔥 IMPORTANT: force sync latest cart
  if (Get.find<AuthController>().isLoggedIn.value) {
    await cart.loadServerCart();
  }

  try {

    isLoading.value = true;

    await service.createOrder(addressId);

    await cart.clearCart();

    Get.offAllNamed(AppRoutes.ordersuccess);

  } finally {
    isLoading.value = false;
  }
}
}