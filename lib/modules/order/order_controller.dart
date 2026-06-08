import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/services/order_service.dart';


class OrderController
    extends GetxController {

  final service =
      OrderService();

  RxBool isLoading =
      false.obs;

  Future<void> placeOrder(
    String addressId,
  ) async {

    try {

      isLoading.value =
          true;

      await service
          .createOrder(
        addressId,
      );

      Get.offAllNamed(AppRoutes.ordersuccess);

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value =
          false;
    }
  }
}