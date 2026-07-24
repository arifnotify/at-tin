import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/services/order_service.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart';
import 'package:tin/modules/payment/payment_screen.dart';

class OrderController extends GetxController {
  final OrderService service = OrderService();

  RxBool isLoading = false.obs;

  /// =========================
  /// ACTIVE ORDERS
  /// =========================
  RxList<dynamic> activeOrders = <dynamic>[].obs;
  RxString selectedOrderId = "".obs;
  RxBool hasActiveOrder = false.obs;
  RxBool trackingEnabled = false.obs;
  RxBool showTrackingBar = false.obs;
  RxDouble trackingProgress = 0.0.obs;

  String? activeOrderStatus;
  RxBool isTrackingMinimized = true.obs;

  /// =========================
  /// REWARD & WALLET
  /// =========================
  RxBool useReward = false.obs;
  RxDouble rewardAmount = 0.0.obs;
  RxDouble walletBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // অ্যাপ ওপেন হওয়ার সময় যদি AuthController ইতিমধ্যেই লগইন স্টেট কনফার্ম করে ফেলে, তবে ডাটা লোড হবে।
    if (Get.find<AuthController>().isLoggedIn.value) {
      loadActiveOrders();
      loadRewardWallet();
    }
  }

  // =========================================================
  // PLACE ORDER
  // =========================================================
  Future<bool> placeOrder(
    String addressId, {
    required String paymentMethod,
  }) async {
    final cart = Get.find<CartController>();

    try {
      isLoading.value = true;

      if (Get.find<AuthController>().isLoggedIn.value) {
        await cart.loadServerCart();
      }

      // ব্যাকএন্ডে অর্ডার ইনিশিলাইজেশন
      final response = await service.createOrder(
        addressId,
        useReward: useReward.value,
        rewardAmount: rewardAmount.value,
        deliveryCharge: Get.find<LocationController>().deliveryCharge.value.toDouble(),
        paymentMethod: paymentMethod,
      );

      // ==========================================
      // 1. SSLCOMMERZ FLOW
      // ==========================================
      if (response["paymentMethod"] == "SSLCOMMERZ" && response["paymentUrl"] != null) {

        final result = await Get.dialog<bool>(
          PaymentDialog(paymentUrl: response["paymentUrl"]),
          barrierDismissible: false,
        );

        // ❌ পেমেন্ট ক্যানসেল বা ফেইল হলে
        if (result != true) {
          Get.snackbar(
            "Payment Incomplete",
            "পেমেন্ট সম্পন্ন হয়নি। আপনার কার্টের আইটেমগুলো সুরক্ষিত আছে।",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
          return false; // ইউজার Order Summary পেজেই থাকবে
        }
        
        // ✅ পেমেন্ট সফল হলে সাকসেস হ্যান্ডলার ফায়ার হবে
        await _handleSuccessResponse();
        return true;
      } 
      
      // ==========================================
      // 2. COD FLOW
      // ==========================================
      else {
        await _handleSuccessResponse();
        return true;
      }

    } catch (e) {
      Get.snackbar(
        "Order Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // HANDLE SUCCESS RESPONSE & NAVIGATION (FIXED)
  // ==========================================
Future<void> _handleSuccessResponse() async {
    await Future.delayed(const Duration(milliseconds: 100));

    // 🎯 নেমড রুটে অতিরিক্ত পারামিটার বাদ দিয়ে
    Get.offAllNamed(AppRoutes.ordersuccess);

    Future.microtask(() async {
      final cart = Get.find<CartController>();
      await cart.clearCart();
      await loadActiveOrders();
      await loadRewardWallet();

      useReward.value = false;
      rewardAmount.value = 0.0;
    });
  }

  // =========================
  // LOAD REWARD WALLET
  // =========================
  Future<void> loadRewardWallet() async {
    try {
      final auth = Get.find<AuthController>();

      final userId = auth.user["_id"]?.toString();
      if (userId == null || userId.isEmpty) return;

      final wallet = await service.getRewardWallet(userId);
      walletBalance.value = (wallet["balance"] ?? 0).toDouble();
    } catch (e) {
      print("Error loading wallet: $e");
    }
  }

  // =========================
  // LOAD ACTIVE ORDERS
  // =========================
  Future<void> loadActiveOrders() async {
    try {
      if (!Get.find<AuthController>().isLoggedIn.value) return;

      final orders = await service.getMyOrders();

      final active = orders.where((o) {
        final status = o["orderStatus"]?.toString() ?? "";
        return status != "Delivered" && status != "Cancelled";
      }).toList();

      activeOrders.value = active;

      if (active.isEmpty) {
        clearTracking();
        hasActiveOrder.value = false;
        selectedOrderId.value = "";
        return;
      }

      hasActiveOrder.value = true;

      if (selectedOrderId.value.isEmpty) {
        selectedOrderId.value = active.first["_id"];
      }

      final exists = active.any((e) => e["_id"] == selectedOrderId.value);

      if (!exists) {
        selectedOrderId.value = active.first["_id"];
      }

      final selected = active.firstWhereOrNull((e) => e["_id"] == selectedOrderId.value);
      if (selected == null) return;

      trackingEnabled.value = selected["trackingEnabled"] ?? false;
      activeOrderStatus = selected["orderStatus"];

      if (trackingEnabled.value) {
        Get.find<OrderTrackingController>().startTracking(selectedOrderId.value);
      }
    } catch (e) {
      clearTracking();
      hasActiveOrder.value = false;
      print("Error loading active orders: $e");
    }
  }

  // =========================
  // SELECT ORDER
  // =========================
  Future<void> selectOrder(String orderId) async {
    selectedOrderId.value = orderId;

    final selected = activeOrders.firstWhereOrNull((e) => e["_id"] == orderId);

    if (selected != null) {
      trackingEnabled.value = selected["trackingEnabled"] ?? false;
      activeOrderStatus = selected["orderStatus"];

      final tracking = Get.find<OrderTrackingController>();
      tracking.stopTracking();
      tracking.startTracking(orderId);
    }
  }

  // =========================
  // REMOVE DELIVERED ORDER
  // =========================
  void removeOrder(String orderId) {
    activeOrders.removeWhere((e) => e["_id"] == orderId);

    if (activeOrders.isEmpty) {
      clearTracking();
      return;
    }

    if (selectedOrderId.value == orderId) {
      selectedOrderId.value = activeOrders.first["_id"];
    }
  }

  // =========================
  // CLEAR TRACKING
  // =========================
  void clearTracking() {
    activeOrders.clear();
    selectedOrderId.value = "";
    hasActiveOrder.value = false;
    trackingEnabled.value = false;
    showTrackingBar.value = false;
    activeOrderStatus = null;
    trackingProgress.value = 0;
    isTrackingMinimized.value = true;
  }

  // =========================
  // OPEN TRACKING
  // =========================
  void openTracking() {
    if (selectedOrderId.value.isEmpty) return;

    Get.toNamed(
      AppRoutes.tracking,
      arguments: selectedOrderId.value,
    );
  }

  // =========================
  // CHECK ACTIVE ORDER
  // =========================
  Future<void> checkActiveOrder() async {
    try {
      if (!Get.find<AuthController>().isLoggedIn.value) return;

      final orders = await service.getMyOrders();

      final activeOrdersList = orders.where((o) {
        final status = o["orderStatus"];
        return status == "OutForDelivery";
      }).toList();

      if (activeOrdersList.isEmpty) {
        selectedOrderId.value = "";
        hasActiveOrder.value = false;
        return;
      }

      hasActiveOrder.value = true;

      if (selectedOrderId.value.isEmpty) {
        selectedOrderId.value = activeOrdersList.first["_id"];
      }
    } catch (e) {
      hasActiveOrder.value = false;
    }
  }
}