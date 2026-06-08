import 'dart:async';
import 'package:get/get.dart';
import 'package:tin/data/models/cart_item_model.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/cart_service.dart';
import 'package:tin/modules/location/location_controller.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  final CartService cartService = CartService();

  /// CLEAR LOCAL CART
  void clearCart() {
    cartItems.clear();
    cartItems.refresh();
  }

  /// SYNC GUEST CART TO SERVER AFTER LOGIN
  Future<void> syncCartAfterLogin() async {
    if (cartItems.isEmpty) return;

    final items = cartItems.map((e) => {
          "productId": e.id,
          "quantity": e.quantity,
          "price": e.price,
        }).toList();

    try {
      await cartService.syncCart(items); // Backend API call
      await loadServerCart();            // Reload server cart to local state
      print("CART SYNC SUCCESS");
    } catch (e) {
      print("SYNC ERROR: $e");
    }
  }

  /// LOAD SERVER CART
Future<void> loadServerCart() async {

  try {

    final data =
        await cartService.getCart();

    cartItems.value =
        data.map<CartItemModel>(
      (e) =>
          CartItemModel.fromJson(
        e,
      ),
    ).toList();

  } catch (e) {

    print(e);
  }
}

  /// GET ITEM
  CartItemModel? getItem(String id) {
    try {
      return cartItems.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ADD TO CART
  void addToCart(ProductModel product) {
    final item = getItem(product.id);
    if (item != null) {
      increment(product.id);
      return;
    }

    final newItem = CartItemModel(
      id: product.id,
      title: product.title,
      image: product.images.isNotEmpty ? product.images.first : "",
      price: product.currentPrice,
      originalPrice: product.price,
      quantity: 1,
    );

    cartItems.add(newItem);
    cartItems.refresh();
    _autoHide(newItem);
  }

  /// INCREMENT
  void increment(String id) {
    final item = getItem(id);
    if (item == null) return;

    item.quantity++;
    item.isEditing = true;
    cartItems.refresh();
    _autoHide(item);
  }

  /// DECREMENT
  void decrement(String id) {
    final item = getItem(id);
    if (item == null) return;

    if (item.quantity <= 1) {
      item.timer?.cancel();
      cartItems.remove(item);
      cartItems.refresh();
      return;
    }

    item.quantity--;
    item.isEditing = true;
    cartItems.refresh();
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
      const Duration(seconds: 4),
      () {
        item.isEditing = false;
        cartItems.refresh();
      },
    );
  }

  /// REMOVE ITEM
  void removeItem(String id) {
    cartItems.removeWhere((e) => e.id == id);
    cartItems.refresh();
  }

  /// TOTAL ITEMS
  int get totalItems =>
      cartItems.fold(0, (a, b) => a + b.quantity);

  /// TOTAL PRICE
  double get totalPrice =>
      cartItems.fold(0, (a, b) => a + (b.price * b.quantity));

  /// TOTAL SAVED
  double get totalSaved =>
      cartItems.fold(0, (a, b) => a + ((b.originalPrice - b.price) * b.quantity));

  /// GRAND TOTAL WITH DELIVERY
  double get grandTotal {
    final location = Get.find<LocationController>();
    return totalPrice + location.deliveryCharge.value;
  }

// server increase
  Future<void> increaseServerQty(
  String cartId,
  int qty,
) async {

  await cartService.updateQuantity(
    cartId,
    qty + 1,
  );

  await loadServerCart();
}

// server decrease
Future<void> decreaseServerQty(
  String cartId,
  int qty,
) async {

  if (qty <= 1) {

    await cartService.removeItem(
      cartId,
    );

  } else {

    await cartService.updateQuantity(
      cartId,
      qty - 1,
    );
  }

  await loadServerCart();
}
}