import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/constants/network_controller.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/banner_model.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/home_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final HomeService service = HomeService();
  final SocketService socketService = SocketService();
  final GetStorage box = GetStorage();

  late LocationController locationController;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  // ক্যাশে সর্বোচ্চ কতটি প্রোডাক্ট সেভ রাখা হবে
  static const int _maxCachedProducts = 20;

  @override
  void onInit() {
    super.onInit();
    print("🏠 HOME CONTROLLER INIT");

    // 1. App Lifecycle Observer অ্যাড করা (ব্যাকগ্রাউন্ড ট্র্যাকিংয়ের জন্য)
    WidgetsBinding.instance.addObserver(this);

    // 2. LOCATION CONTROLLER
    if (Get.isRegistered<LocationController>()) {
      locationController = Get.find<LocationController>();
    }

    // 3. CART LOAD
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().loadServerCart();
    }

    // 4. INSTANT CACHE LOAD (Fast UI)
    loadHomeFromCache();

    // 5. FIRST HOME LOAD
    loadHomeData(showLoader: categories.isEmpty && products.isEmpty);

    // 6. LISTEN TO NETWORK RESTORE
    _listenToNetworkChanges();

    // 7. SOCKET INIT & LISTENERS
    _initSocketListeners();
  }

  // ==========================================
  // 🔄 APP LIFECYCLE LISTENER (২-৫ ঘণ্টা পর ব্যাকগ্রাউন্ড থেকে ফিরলে)
  // ==========================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("⚡ APP RESUMED FROM BACKGROUND! Refreshing Socket & Data...");
      _handleAppResume();
    }
  }

  Future<void> _handleAppResume() async {
    try {
      // সকেট রি-কানেক্ট নিশ্চিত করা
      socketService.connect();

      // সাইলেন্টলি হোমের সব ডাটা আবার লোড করা
      await loadHomeData(showLoader: false);

      // কার্ট ডাটা সিঙ্ক
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().loadServerCart();
      }
    } catch (e) {
      print("RESUME REFRESH ERROR: $e");
    }
  }

  // ==========================================
  // 🔌 SOCKET LISTENERS
  // ==========================================
  void _initSocketListeners() {
    socketService.connect();

    socketService.listenHomeUpdated((_) async {
      print("🔥 HOME UPDATE RECEIVED");
      await loadHomeData(showLoader: false);
    });

    socketService.listenBannerUpdated((_) async {
      print("🔥 BANNER UPDATED");
      await loadHomeData(showLoader: false);
    });

    socketService.listenFlashSaleUpdated((_) async {
      print("🔥 FLASH SALE UPDATED");
      await loadHomeData(showLoader: false);
    });
  }

  // ==========================================
  // 📡 LISTEN TO NETWORK CHANGES
  // ==========================================
  void _listenToNetworkChanges() {
    if (Get.isRegistered<NetworkController>()) {
      final networkController = Get.find<NetworkController>();

      ever(networkController.isConnected, (bool isOnline) {
        if (isOnline) {
          print("⚡ INTERNET IS BACK! Auto refreshing Home Data & Socket...");
          _handleAppResume();
        }
      });
    }
  }

  // ==========================================
  // READ FROM LOCAL STORAGE (Offline First)
  // ==========================================
  void loadHomeFromCache() {
    try {
      final cachedBanners = box.read<List>('cached_banners');
      final cachedCategories = box.read<List>('cached_categories');
      final cachedProducts = box.read<List>('cached_products');

      if (cachedBanners != null) {
        banners.assignAll(
          cachedBanners
              .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }

      if (cachedCategories != null) {
        categories.assignAll(
          cachedCategories
              .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }

      if (cachedProducts != null) {
        products.assignAll(
          cachedProducts
              .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
      print("⚡ HOME DATA RESTORED FROM LOCAL CACHE");
    } catch (e) {
      print("CACHE RESTORE ERROR: $e");
    }
  }

  // ==========================
  // LOAD HOME DATA
  // ==========================
  Future<void> loadHomeData({
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      String? locationId;
      if (Get.isRegistered<LocationController>()) {
        locationId = Get.find<LocationController>().box.read("locationId");
      }

      // Parallel Network Call
      final results = await Future.wait([
        service.getBanners(),
        service.getHomeCategories(),
        service.getProducts(locationId: locationId),
      ]);

      final bannerData = results[0];
      final categoryData = results[1];
      final productData = results[2];

      // BANNER
      if (bannerData is List) {
        banners.assignAll(
          bannerData.map((e) => BannerModel.fromJson(e)).toList(),
        );
        box.write('cached_banners', bannerData);
      }

      // CATEGORY
      if (categoryData is List) {
        categories.assignAll(
          categoryData.map((e) => CategoryModel.fromJson(e)).toList(),
        );
        box.write('cached_categories', categoryData);
      }

      // PRODUCTS
      if (productData is List) {
        products.assignAll(
          productData.map((e) => ProductModel.fromJson(e)).toList(),
        );
        final limitedProductsForCache =
            productData.take(_maxCachedProducts).toList();
        box.write('cached_products', limitedProductsForCache);
      }

      banners.refresh();
      categories.refresh();
      products.refresh();

    } catch (e) {
      print("HOME LOAD ERROR: $e");
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  // ==========================
  // LOCATION CHANGE
  // ==========================
  Future<void> changeLocationReload() async {
    isRefreshing.value = true;
    await loadHomeData();
    await Future.delayed(const Duration(milliseconds: 300));
    isRefreshing.value = false;
  }

  // ==========================
  // MANUAL REFRESH
  // ==========================
  Future<void> refreshHome() async {
    isRefreshing.value = true;
    await loadHomeData(showLoader: false);
    await Future.delayed(const Duration(milliseconds: 300));
    isRefreshing.value = false;
  }

  @override
  void onClose() {
    // Observer রিমুভ করা
    WidgetsBinding.instance.removeObserver(this);
    socketService.disconnect();
    super.onClose();
  }
}