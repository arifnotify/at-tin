import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/category_service.dart';
import 'package:tin/modules/location/location_controller.dart';

class ProductsController extends GetxController with WidgetsBindingObserver {
  final CategoryService service = CategoryService();
  final SocketService socketService = SocketService();

  // ==========================
  // PRODUCTS & STATES
  // ==========================
  RxList<ProductModel> products = <ProductModel>[].obs;

  // First loading
  RxBool isLoading = false.obs;

  // Background socket update
  RxBool isRefreshing = false.obs;

  String categoryId = "";
  String locationId = "";

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // 🔄 ব্যাকগ্রাউন্ড লাইফসাইকেল ট্র্যাকিং

    // ১. আর্গুমেন্ট সেফটি চেক (_id, categoryId, বা id যেকোনো কি গ্রহণ করবে)
    final dynamic args = Get.arguments;
    if (args is Map) {
      categoryId = args["_id"] ?? args["categoryId"] ?? args["id"] ?? "";
    } else if (args is String) {
      categoryId = args;
    }

    // ২. সেফলি Location ID পড়া
    _syncLocationId();

    // ৩. প্রাথমিক লোড ও সকেট ইনিট
    loadProducts();
    initSocket();
  }

  // ==========================================================
  // 🔄 APP RESUME SYNC (অ্যাপ ব্যাকগ্রাউন্ড থেকে ফিরলে)
  // ==========================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("⚡ PRODUCTS: App resumed! Refreshing product list...");
      socketService.connect();
      refreshFromSocket();
    }
  }

  // ==========================
  // LOCATION HELPER
  // ==========================
  void _syncLocationId() {
    if (Get.isRegistered<LocationController>()) {
      final locationController = Get.find<LocationController>();
      locationId = locationController.box.read("locationId") ?? "";
    } else {
      locationId = "";
    }
  }

  // ==========================
  // FIRST LOAD
  // ==========================
  Future<void> loadProducts() async {
    if (categoryId.isEmpty) return;

    try {
      isLoading.value = true;

      final data = await service.getProductsByCategory(
        categoryId,
        locationId,
      );

      updateProducts(data);
    } catch (e) {
      print("PRODUCT LOAD ERROR => $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // SOCKET BACKGROUND UPDATE
  // ==========================
  Future<void> refreshFromSocket() async {
    if (categoryId.isEmpty) return;

    try {
      isRefreshing.value = true;

      final data = await service.getProductsByCategory(
        categoryId,
        locationId,
      );

      updateProducts(data);
    } catch (e) {
      print("SOCKET PRODUCT ERROR => $e");
    } finally {
      isRefreshing.value = false;
    }
  }

  // ==========================
  // UPDATE LIST
  // ==========================
  void updateProducts(dynamic data) {
    if (data != null && data is List) {
      products.assignAll(
        data.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
  }

  // ==========================
  // SOCKET INIT
  // ==========================
  void initSocket() {
    socketService.connect();

    socketService.listenProductUpdated((_) {
      print("🔥 PRODUCT PAGE SOCKET UPDATE");
      refreshFromSocket();
    });
  }

  // ==========================
  // LOCATION CHANGE
  // ==========================
  Future<void> changeLocation(String newLocationId) async {
    locationId = newLocationId;
    await loadProducts();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // socketService.offProductUpdated(); // সকেট লিসেন ডিসকানেক্ট করতে পারেন
    super.onClose();
  }
}