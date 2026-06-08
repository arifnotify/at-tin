import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/services/order_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';


class OrderController
    extends GetxController {

  final service =
      OrderService();

  RxBool isLoading =
      false.obs;

Future<void> placeOrder(String addressId) async {

  try {

    isLoading.value = true;

    await service.createOrder(addressId);

    await Get.find<CartController>().clearCart();

    Get.offAllNamed(
      AppRoutes.ordersuccess,
    );

  } catch (e) {

    Get.snackbar("Error", e.toString());

  } finally {

    isLoading.value = false;
  }
}
}