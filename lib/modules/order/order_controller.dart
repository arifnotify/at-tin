import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/services/order_service.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart';

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
    
    // অ্যাপ ওপেন হওয়ার সময় যদি AuthController ইতিমধ্যেই লগইন স্টেট কনফার্ম করে ফেলে, তবে ডাটা লোড হবে।
    // নিরাপদ থাকার জন্য আমরা মূল ডাটা লোডিং কলটি AuthController-এর checkLogin থেকেও ট্রিগার করে দিয়েছি।
    if (Get.find<AuthController>().isLoggedIn.value) {
      loadActiveOrders();
      loadRewardWallet();
    }
  }

  // =========================
  // PLACE ORDER
  // =========================
  Future<void> placeOrder(String addressId) async {
    final cart = Get.find<CartController>();

    try {
      isLoading.value = true;

      if (Get.find<AuthController>().isLoggedIn.value) {
        await cart.loadServerCart();
      }

      final order = await service.createOrder(
        addressId,
        useReward: useReward.value,
        rewardAmount: rewardAmount.value,
        deliveryCharge: Get.find<LocationController>().deliveryCharge.value.toDouble(),
      );

      if (order == null || order["_id"] == null) {
        throw "Order creation failed";
      }

      await cart.clearCart();
      await loadActiveOrders();
      await loadRewardWallet();

      useReward.value = false;
      rewardAmount.value = 0;

      Get.offAllNamed(AppRoutes.ordersuccess);
    } catch (e) {
      Get.snackbar(
        "Order Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOAD REWARD WALLET (UPDATED)
  // =========================
  Future<void> loadRewardWallet() async {
    try {
      final auth = Get.find<AuthController>();

      // টোকেন বা ইউজার আইডি না থাকলে রিকোয়েস্ট স্কিপ করবে
      final userId = auth.user["_id"]?.toString();
      if (userId == null || userId.isEmpty) return;

      final wallet = await service.getRewardWallet(userId);
      walletBalance.value = (wallet["balance"] ?? 0).toDouble();
    } catch (e) {
      print("Error loading wallet: $e");
    }
  }

  // =========================
  // LOAD ACTIVE ORDERS (UPDATED)
  // =========================
  Future<void> loadActiveOrders() async {
    try {
      // ইউজার লগইন না থাকলে অহেতুক API কল করা বন্ধ করবে
      if (!Get.find<AuthController>().isLoggedIn.value) return;

      final orders = await service.getMyOrders();

      final active = orders.where((o) {
        final status = o["orderStatus"]?.toString() ?? "";
        return status != "Delivered" && status != "Cancelled";
      }).toList();

      activeOrders.value = active;

      /// ❌ NO ACTIVE ORDER
      if (active.isEmpty) {
        clearTracking();
        hasActiveOrder.value = false;
        selectedOrderId.value = "";
        return;
      }

      hasActiveOrder.value = true;

      /// 🔥 DEFAULT SELECT
      if (selectedOrderId.value.isEmpty) {
        selectedOrderId.value = active.first["_id"];
      }

      /// 🔥 CHECK IF SELECTED STILL EXISTS
      final exists = active.any((e) => e["_id"] == selectedOrderId.value);

      if (!exists) {
        selectedOrderId.value = active.first["_id"];
      }

      /// 🔥 GET SELECTED ORDER
      final selected = active.firstWhereOrNull((e) => e["_id"] == selectedOrderId.value);
      if (selected == null) return;

      trackingEnabled.value = selected["trackingEnabled"] ?? false;
      activeOrderStatus = selected["orderStatus"];

      /// 🔥 IMPORTANT: auto restart tracking
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

      /// Stop Previous Tracking
      tracking.stopTracking();

      /// Start Selected Order Tracking
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

      /// DEFAULT ORDER
      if (selectedOrderId.value.isEmpty) {
        selectedOrderId.value = activeOrdersList.first["_id"];
      }
    } catch (e) {
      hasActiveOrder.value = false;
    }
  }
}