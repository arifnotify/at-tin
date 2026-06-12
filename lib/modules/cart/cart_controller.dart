import 'dart:async';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/cart_item_model.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/cart_service.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final lang = Get.find<LanguageController>();

  final CartService cartService = CartService();

  final box = GetStorage();

  static const String guestCartKey =
    "guest_cart";

@override
void onInit() {

  super.onInit();

  loadGuestCart();
}

// ...........SaveGuest cart 

Future<void> saveGuestCart() async {

  final data = cartItems
      .map(
        (e) => e.toJson(),
      )
      .toList();

  await box.write(
    guestCartKey,
    data,
  );
}

// ..... loadguest cart 
Future<void> loadGuestCart() async {

  final data =
      box.read(
        guestCartKey,
      );

  if (data == null) return;

  cartItems.value =
      List<Map<String, dynamic>>
          .from(data)
          .map(
            (e) =>
                CartItemModel
                    .fromLocalJson(
              e,
            ),
          )
          .toList();

  cartItems.refresh();
}


  /// SYNC GUEST CART TO SERVER AFTER LOGIN
Future<void> syncCartAfterLogin() async {

  print("SYNC STARTED");

  if (cartItems.isEmpty) {
    await loadServerCart();
    return;
  }

  final items = cartItems.map((e) => {
    "productId": e.id,
    "quantity": e.quantity,
    "price": e.price,
  }).toList();

  await cartService.syncCart(items);

  await clearCart();

  await loadServerCart();

  print("CART SYNC SUCCESS");
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
Future<void> addToCart(
  ProductModel product,
) async {

  final auth =
      Get.find<AuthController>();

  /// LOGIN USER
  if (auth.isLoggedIn.value) {

    try {

      await cartService.addToCart(
        product.id,
        1,
      );

      await loadServerCart();


    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );
    }

    return;
  }

  /// GUEST USER

  final item =
      getItem(product.id);

  if (item != null) {

    increment(product.id);

    return;
  }

final newItem = CartItemModel(
  id: product.id,
  cartId: null,

  titleBn: product.titleBn,
  titleEn: product.titleEn,

  image: product.images.isNotEmpty
      ? product.images.first
      : "",

  price: product.currentPrice,
  originalPrice: product.price,
  quantity: 1,
);

cartItems.add(newItem);
  cartItems.refresh();

  await saveGuestCart();

  _autoHide(
    newItem,
  );
}

  /// INCREMENT
void increment(String id) async {
  final auth = Get.find<AuthController>();
  final item = getItem(id);
  if (item == null) return;

  item.quantity++;
  item.isEditing = true;
  cartItems.refresh();

  if (auth.isLoggedIn.value) {
    await cartService.updateQuantity(
      item.cartId!,
      item.quantity,
    );
    await loadServerCart();
  } else {
    await saveGuestCart();
  }

  _autoHide(item);
}

  /// DECREMENT
void decrement(String id) async {
  final auth = Get.find<AuthController>();
  final item = getItem(id);
  if (item == null) return;

  if (item.quantity <= 1) {
    await removeItem(id);
    return;
  }

  item.quantity--;
  item.isEditing = true;
  cartItems.refresh();

  if (auth.isLoggedIn.value) {
    await cartService.updateQuantity(
      item.cartId!,
      item.quantity,
    );
    await loadServerCart();
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
      const Duration(seconds: 4),
      () {
        item.isEditing = false;
        cartItems.refresh();
      },
    );
  }

  /// REMOVE ITEM
Future<void> removeItem(String id) async {
  final auth = Get.find<AuthController>();

  final item = getItem(id);
  if (item == null) return;

  if (auth.isLoggedIn.value && item.cartId != null) {
    await cartService.removeItem(item.cartId!);
    await loadServerCart();
  } else {
    cartItems.removeWhere((e) => e.id == id);
    await saveGuestCart();
  }

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


/// CLEAR LOCAL CART
Future<void> clearCart() async {

  print(
    "Before Clear: ${cartItems.length}",
  );

  cartItems.clear();

  cartItems.refresh();

  await box.remove(
    guestCartKey,
  );

  print(
    "After Clear: ${cartItems.length}",
  );
}
}