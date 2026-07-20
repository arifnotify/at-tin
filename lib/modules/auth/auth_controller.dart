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

  /// 🔥 USER DATA STORE
  RxMap<String, dynamic> user = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  // =========================
  // CHECK LOGIN (UPDATED)
  // =========================
  Future<void> checkLogin() async {
    final token = box.read("token");
    final savedUser = box.read("user_data"); // লোকাল স্টোরেজ থেকে ইউজার ডাটা রিড করা হচ্ছে

    isLoggedIn.value = token != null;

    if (isLoggedIn.value) {
      // যদি লোকাল স্টোরেজে ইউজার ডাটা থাকে, তবে তা RAM-এ লোড করা হচ্ছে
      if (savedUser != null) {
        user.value = Map<String, dynamic>.from(savedUser);
      }

      await Get.find<CartController>().loadServerCart();

      if (Get.isRegistered<OrderController>()) {
        final orderCtrl = Get.find<OrderController>();
        await orderCtrl.loadActiveOrders();
        await orderCtrl.loadRewardWallet(); // ওয়ালেট ও অর্ডার ডাটা রিফ্রেশ করা হচ্ছে
      }
    }
  }

  // =========================
  // SEND OTP
  // =========================
  Future<void> sendOtp(String phone) async {
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
  // VERIFY OTP (UPDATED)
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

      /// 🔥 TOKEN SAVE
      box.write(
        "token",
        data["token"] ?? data["access_token"],
      );

      /// 🔥 USER SAVE (IMPORTANT CHANGE)
      final userData = data["user"] ?? {};
      user.value = userData;
      box.write("user_data", userData); // ইউজার ডাটা লোকাল স্টোরেজে পার্মানেন্টলি সেভ করা হলো

      isLoggedIn.value = true;

      /// 🔥 CART SYNC
      final cartController = Get.find<CartController>();
      await cartController.syncCartAfterLogin();

      /// 🔥 LOAD ACTIVE ORDERS
      if (Get.isRegistered<OrderController>()) {
        final orderCtrl = Get.find<OrderController>();
        await orderCtrl.loadActiveOrders();
        await orderCtrl.loadRewardWallet();
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
  // LOGOUT (UPDATED)
  // =========================
  void logout() {
    /// TOKEN & USER DATA REMOVE
    box.remove("token");
    box.remove("user_data"); // লগআউটের সময় লোকাল স্টোরেজের ইউজার ডাটা মুছে ফেলা হলো

    /// USER CLEAR
    user.clear();

    /// CART CLEAR
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clearCart();
    }

    /// ORDER RESET
    if (Get.isRegistered<OrderController>()) {
      final order = Get.find<OrderController>();

      order.activeOrders.clear();
      order.selectedOrderId.value = "";
      order.hasActiveOrder.value = false;
      order.trackingEnabled.value = false;
      order.showTrackingBar.value = false;
      order.activeOrderStatus = null;
      order.trackingProgress.value = 0;
      order.isTrackingMinimized.value = true;
    }

    /// TRACKING RESET
    if (Get.isRegistered<OrderTrackingController>()) {
      final tracking = Get.find<OrderTrackingController>();

      tracking.stopTracking();
      tracking.status.value = "";
      tracking.trackingEnabled.value = false;
      tracking.isLoading.value = false;
      tracking.etaText.value = "-- min";
      tracking.riderLat.value = 0;
      tracking.riderLng.value = 0;
      tracking.destLat.value = 0;
      tracking.destLng.value = 0;
      tracking.progress.value = 0;
    }

    /// LOGIN STATE
    isLoggedIn.value = false;

    /// HOME
    Get.offAllNamed("/home");
  }
}