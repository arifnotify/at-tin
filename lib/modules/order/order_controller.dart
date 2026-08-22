import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/core/socket/socket_service.dart';
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

    SocketService().connect();

    SocketService().listenOrderStatusChanged((data) async {
      print("🔥 ORDER STATUS CHANGED");
      await loadActiveOrders();
    });

    SocketService().listenOrderUpdated((data) async {
      print("🔥 ORDER UPDATED");
      await loadActiveOrders();
    });

    if (Get.find<AuthController>().isLoggedIn.value) {
      loadActiveOrders();
      loadRewardWallet();
    }
  }

  @override
  void onClose() {
    // 🛡️ মেমরি লিক রোধে কন্ট্রোলার অফ হলে সকেট ডিসকানেক্ট বা অফ করা
    SocketService().offOrderStatusChanged();
    SocketService().offOrderUpdated();
    super.onClose();
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

      // 1. SSLCOMMERZ FLOW
      if (response["paymentMethod"] == "SSLCOMMERZ" && response["paymentUrl"] != null) {
        final result = await Get.dialog<bool>(
          PaymentDialog(paymentUrl: response["paymentUrl"]),
          barrierDismissible: false,
        );

        if (result != true) {
          Get.snackbar(
            "Payment Incomplete",
            "পেমেন্ট সম্পন্ন হয়নি। আপনার কার্টের আইটেমগুলো সুরক্ষিত আছে।",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
          return false;
        }

        await _handleSuccessResponse();
        return true;
      } 
      // 2. COD FLOW
      else {
        await _handleSuccessResponse();
        return true;
      }
    } catch (e) {
      print("Order error details: $e");
      
      Get.snackbar(
        "Order Failed",
        "ইন্টারনেট সংযোগ নেই বা সমস্যা দেখা দিয়েছে। আবার চেষ্টা করুন।",
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
  // HANDLE SUCCESS RESPONSE & NAVIGATION
  // ==========================================
  Future<void> _handleSuccessResponse() async {
    await Future.delayed(const Duration(milliseconds: 100));

    Get.offAllNamed(AppRoutes.ordersuccess);

    Future.microtask(() async {
      try {
        final cart = Get.find<CartController>();
        await cart.clearCart();
        await loadActiveOrders();
        await loadRewardWallet();

        useReward.value = false;
        rewardAmount.value = 0.0;
      } catch (e) {
        print("Error in success handler: $e");
      }
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

      // 🔄 RxList-এর মান সঠিকভাবে আপডেট করতে assignAll ব্যবহার
      activeOrders.assignAll(active);

      if (active.isEmpty) {
        clearTracking();
        hasActiveOrder.value = false;
        selectedOrderId.value = "";
        return;
      }

      hasActiveOrder.value = true;

      if (selectedOrderId.value.isEmpty || !active.any((e) => e["_id"] == selectedOrderId.value)) {
        selectedOrderId.value = active.first["_id"];
      }

      final selected = active.firstWhereOrNull((e) => e["_id"] == selectedOrderId.value);
      if (selected == null) return;

      trackingEnabled.value = selected["trackingEnabled"] ?? false;
      activeOrderStatus = selected["orderStatus"];

      if (trackingEnabled.value) {
        if (Get.isRegistered<OrderTrackingController>()) {
          Get.find<OrderTrackingController>().startTracking(selectedOrderId.value);
        }
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

      if (Get.isRegistered<OrderTrackingController>()) {
        final tracking = Get.find<OrderTrackingController>();
        tracking.stopTracking();
        tracking.startTracking(orderId);
      }
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
}