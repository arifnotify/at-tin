import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:tin/data/services/auth_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/order/order_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart';

class AuthController extends GetxController {
  final service = AuthService();

  final box = GetStorage();

  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  // =========================
  // CHECK LOGIN
  // =========================

  Future<void> checkLogin() async {
    final token = box.read("token");

    isLoggedIn.value = token != null;

    if (isLoggedIn.value) {
      await Get.find<CartController>()
          .loadServerCart();

      /// Load Active Order
      if (Get.isRegistered<OrderController>()) {
        await Get.find<OrderController>()
            .loadActiveOrders();
      }
    }
  }

  // =========================
  // SEND OTP
  // =========================

  Future<void> sendOtp(
    String phone,
  ) async {
    try {
      isLoading.value = true;

      await service.sendOtp(phone);

      Get.toNamed(
        "/otp",
        arguments: phone,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // VERIFY OTP
  // =========================

  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      isLoading.value = true;

      final data = await service.verifyOtp(
        phone: phone,
        otp: otp,
      );

      box.write(
        "token",
        data["token"] ??
            data["access_token"],
      );

      isLoggedIn.value = true;

      final cartController =
          Get.find<CartController>();

      await cartController
          .syncCartAfterLogin();

      /// 🔥 Load Active Orders
      if (Get.isRegistered<OrderController>()) {
        await Get.find<OrderController>()
            .loadActiveOrders();
      }

      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOGOUT
  // =========================

  void logout() {
    /// TOKEN REMOVE
    box.remove("token");

    /// CART CLEAR
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>()
          .clearCart();
    }

    /// ORDER CONTROLLER RESET
    if (Get.isRegistered<OrderController>()) {
      final order =
          Get.find<OrderController>();

      order.activeOrders.clear();

      order.selectedOrderId.value = "";

      order.hasActiveOrder.value =
          false;

      order.trackingEnabled.value =
          false;

      order.showTrackingBar.value =
          false;

      order.activeOrderStatus =
          null;

      order.trackingProgress.value =
          0;

      order.isTrackingMinimized.value =
          true;
    }

    /// TRACKING CONTROLLER RESET
    if (Get.isRegistered<
        OrderTrackingController>()) {
      final tracking =
          Get.find<
              OrderTrackingController>();

      tracking.stopTracking();

      tracking.status.value = "";

      tracking.trackingEnabled.value =
          false;

      tracking.isLoading.value = false;

      tracking.etaText.value =
          "-- min";

      tracking.riderLat.value = 0;
      tracking.riderLng.value = 0;

      tracking.destLat.value = 0;
      tracking.destLng.value = 0;

      tracking.progress.value = 0;
    }

    /// LOGIN FALSE
    isLoggedIn.value = false;

    /// HOME
    Get.offAllNamed("/home");
  }
}