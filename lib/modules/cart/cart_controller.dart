import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/core/constants/network_controller.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/cart_item_model.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/cart_service.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController with WidgetsBindingObserver {
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  final CartService cartService = CartService();
  final SocketService socketService = SocketService();
  final RxBool isLoading = false.obs;

  final box = GetStorage();
  static const String guestCartKey = "guest_cart";

  bool _isSocketListening = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // 🔄 লাইফসাইকেল ট্র্যাকিং
    loadGuestCart();
    _initCartSocket();
  }

  // ==========================================================
  // 🔄 APP RESUME SYNC (অ্যাপ ব্যাকগ্রাউন্ড থেকে ফিরলে)
  // ==========================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        if (auth.isLoggedIn.value) {
          socketService.connect();
          loadServerCart();
        }
      }
    }
  }

  // =========================
  // SOCKET INIT
  // =========================
  void _initCartSocket() {
    socketService.connect();

    if (_isSocketListening) return;
    _isSocketListening = true;

    socketService.listenCartUpdated((_) async {
      print("🔥 CART UPDATED VIA SOCKET");
      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        if (auth.isLoggedIn.value) {
          await loadServerCart();
        }
      }
    });
  }

  // =========================
  // HELPER: NETWORK CHECK & SNACKBAR
  // =========================
  bool _checkInternetConnection() {
    if (Get.isRegistered<NetworkController>()) {
      final network = Get.find<NetworkController>();
      if (!network.isConnected.value) {
        network.showProfessionalSnackbar(
          isOffline: true,
          bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
          enMessage: "No internet connection detected",
        );
        return false;
      }
    }
    return true;
  }

  // =========================
  // GUEST CART LOCAL STORAGE
  // =========================
  Future<void> saveGuestCart() async {
    final data = cartItems.map((e) => e.toJson()).toList();
    await box.write(guestCartKey, data);
  }

  Future<void> loadGuestCart() async {
    final data = box.read(guestCartKey);
    if (data == null) return;

    cartItems.value = List<Map<String, dynamic>>.from(data)
        .map((e) => CartItemModel.fromLocalJson(e))
        .toList();

    cartItems.refresh();
  }

  // =========================
  // SERVER SYNC & LOAD
  // =========================

  /// SYNC GUEST CART TO SERVER AFTER LOGIN
  Future<void> syncCartAfterLogin() async {
    if (!_checkInternetConnection()) return;

    print("SYNC PROCESS STARTED");

    try {
      final guestItems = List<CartItemModel>.from(cartItems);

      await loadServerCart();

      if (cartItems.isNotEmpty) {
        await box.remove(guestCartKey);
        print("USER ALREADY HAS CART ITEMS. GUEST CART DISCARDED.");
        return;
      }

      if (guestItems.isNotEmpty) {
        final itemsToSync = guestItems
            .map((e) => {
                  "productId": e.id,
                  "quantity": e.quantity,
                  "price": e.price,
                })
            .toList();

        await cartService.syncCart(itemsToSync);
        await box.remove(guestCartKey);
        await loadServerCart();
        print("GUEST CART SYNCED SUCCESSFULLY TO EMPTY USER CART.");
      }
    } catch (e) {
      print("SYNC FAILED => $e");
    }
  }

  /// LOAD SERVER CART
  Future<void> loadServerCart() async {
    try {
      final data = await cartService.getCart();

      final oldEditing = {
        for (final item in cartItems) item.id: item.isEditing,
      };

      final oldSyncing = {
        for (final item in cartItems) item.id: item.isSyncing,
      };

      final List<CartItemModel> items = data.map<CartItemModel>((e) {
        final item = CartItemModel.fromJson(e);
        item.isEditing = oldEditing[item.id] ?? false;
        item.isSyncing = oldSyncing[item.id] ?? false;
        return item;
      }).toList();

      // Inactive products remove
      items.removeWhere((item) {
        final json = data.firstWhereOrNull(
          (e) => e["product"]?["_id"] == item.id,
        );
        if (json == null) return true;
        return json["product"] == null || json["product"]["isActive"] == false;
      });

      cartItems.assignAll(items);
      cartItems.refresh();
    } catch (e) {
      print("LOAD SERVER CART ERROR => $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // CART ACTIONS & CONTROLS
  // =========================

  /// GET ITEM
  CartItemModel? getItem(String id) {
    return cartItems.firstWhereOrNull((e) => e.id == id);
  }

  /// ADD TO CART
  Future<void> addToCart(ProductModel product) async {
    final auth = Get.find<AuthController>();

    /// LOGIN USER
    if (auth.isLoggedIn.value) {
      if (!_checkInternetConnection()) return;

      final newItem = CartItemModel(
        id: product.id,
        cartId: null,
        titleBn: product.titleBn,
        titleEn: product.titleEn,
        image: product.images.isNotEmpty ? product.images.first : "",
        price: product.currentPrice,
        originalPrice: product.price,
        quantity: 1,
        isEditing: true,
        isSyncing: true,
      );

      cartItems.add(newItem);
      cartItems.refresh();
      _autoHide(newItem);

      _addToServer(product);
      return;
    }

    /// GUEST USER
    final item = getItem(product.id);
    if (item != null) {
      increment(product.id);
      return;
    }

    final newItem = CartItemModel(
      id: product.id,
      cartId: null,
      titleBn: product.titleBn,
      titleEn: product.titleEn,
      image: product.images.isNotEmpty ? product.images.first : "",
      price: product.currentPrice,
      originalPrice: product.price,
      quantity: 1,
    );

    cartItems.add(newItem);
    cartItems.refresh();

    await saveGuestCart();
    _autoHide(newItem);
  }

  /// INCREMENT
  void increment(String id) async {
    final auth = Get.find<AuthController>();

    if (auth.isLoggedIn.value && !_checkInternetConnection()) return;

    final item = getItem(id);
    if (item == null || item.isSyncing) return;

    final oldQty = item.quantity;
    item.quantity++;
    item.isEditing = true;
    cartItems.refresh();

    if (auth.isLoggedIn.value) {
      _updateServerQuantity(item, oldQty);
    } else {
      await saveGuestCart();
    }

    _autoHide(item);
  }

  /// DECREMENT
  void decrement(String id) async {
    final auth = Get.find<AuthController>();

    if (auth.isLoggedIn.value && !_checkInternetConnection()) return;

    final item = getItem(id);
    if (item == null || item.isSyncing) return;

    if (item.quantity <= 1) {
      await removeItem(id);
      return;
    }

    final oldQty = item.quantity;
    item.quantity--;
    item.isEditing = true;
    cartItems.refresh();

    if (auth.isLoggedIn.value) {
      _updateServerQuantity(item, oldQty);
    } else {
      await saveGuestCart();
    }

    _autoHide(item);
  }

  /// SHOW CONTROL
  void showControls(String id) {
    final item = getItem(id);
    if (item == null) return;

    item.isEditing = true;
    cartItems.refresh();
    _autoHide(item);
  }

  /// AUTO HIDE EDIT CONTROLS
  void _autoHide(CartItemModel item) {
    item.timer?.cancel();
    item.timer = Timer(
      const Duration(seconds: 6),
      () {
        final current = getItem(item.id);
        if (current != null) {
          current.isEditing = false;
          cartItems.refresh();
        }
      },
    );
  }

  /// REMOVE ITEM
  Future<void> removeItem(String id) async {
    final auth = Get.find<AuthController>();

    if (auth.isLoggedIn.value && !_checkInternetConnection()) return;

    final item = getItem(id);
    if (item == null) return;

    item.timer?.cancel(); // টাইমার ক্যানসেল করা
    final cartId = item.cartId;
    cartItems.removeWhere((e) => e.id == id);
    cartItems.refresh();

    if (auth.isLoggedIn.value) {
      if (cartId != null) {
        try {
          await cartService.removeItem(cartId);
        } catch (e) {
          print("REMOVE SERVER ITEM ERROR => $e");
        }
      }
    } else {
      await saveGuestCart();
    }
  }

  // =========================
  // SERVER HELPERS & DIRECT CALLS
  // =========================

  Future<void> increaseServerQty(String cartId, int qty) async {
    if (!_checkInternetConnection()) return;

    try {
      await cartService.updateQuantity(cartId, qty + 1);
      await loadServerCart();
    } catch (e) {
      print("INCREASE SERVER QTY ERROR => $e");
    }
  }

  Future<void> decreaseServerQty(String cartId, int qty) async {
    if (!_checkInternetConnection()) return;

    try {
      if (qty <= 1) {
        await cartService.removeItem(cartId);
      } else {
        await cartService.updateQuantity(cartId, qty - 1);
      }
      await loadServerCart();
    } catch (e) {
      print("DECREASE SERVER QTY ERROR => $e");
    }
  }

  Future<void> _updateServerQuantity(
    CartItemModel item,
    int previousQuantity,
  ) async {
    if (item.cartId == null) return;

    try {
      await cartService.updateQuantity(
        item.cartId!,
        item.quantity,
      );
    } catch (e) {
      item.quantity = previousQuantity;
      cartItems.refresh();
      print("SERVER QTY UPDATE FAILED => $e");
    }
  }

  Future<void> _addToServer(ProductModel product) async {
    try {
      await cartService.addToCart(product.id, 1);
      await loadServerCart();

      final item = getItem(product.id);
      if (item != null) {
        item.isSyncing = false;
        cartItems.refresh();
      }

      showControls(product.id);
    } catch (e) {
      cartItems.removeWhere((item) => item.id == product.id);
      cartItems.refresh();
      print("ADD TO SERVER ERROR => $e");
    }
  }

  // =========================
  // GETTERS & COMPUTED PROPERTIES
  // =========================

  int get totalItems => cartItems.fold(0, (a, b) => a + b.quantity);

  double get totalPrice =>
      cartItems.fold(0, (a, b) => a + (b.price * b.quantity));

  double get totalSaved => cartItems.fold(
      0, (a, b) => a + ((b.originalPrice - b.price) * b.quantity));

  double get grandTotal {
    if (!Get.isRegistered<LocationController>()) {
      return totalPrice;
    }
    final location = Get.find<LocationController>();
    return totalPrice + location.deliveryCharge.value;
  }

  // =========================
  // CLEAR LOCAL & SERVER CART
  // =========================
  Future<void> clearCart() async {
    for (var item in cartItems) {
      item.timer?.cancel();
    }
    cartItems.clear();
    cartItems.refresh();
    await box.remove(guestCartKey);

    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn.value) {
        try {
          await cartService.clearCart();
          print("✅ DB & REDIS CLEARED");
        } catch (e) {
          print("❌ CLEAR CART API ERROR => $e");
        }
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var item in cartItems) {
      item.timer?.cancel();
    }
    _isSocketListening = false;
    super.onClose();
  }
}