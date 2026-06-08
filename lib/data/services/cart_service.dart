import 'package:tin/core/network/dio_client.dart';

class CartService {

  /// ADD PRODUCT TO SERVER CART
  Future<void> addToCart(
    String productId,
    int quantity,
  ) async {

    await DioClient.dio.post(
      "/cart",
      data: {
        "productId": productId,
        "quantity": quantity,
      },
    );
  }

  /// SYNC GUEST CART TO SERVER
  Future<void> syncCart(
    List<Map<String, dynamic>> items,
  ) async {

    await DioClient.dio.post(
      "/cart/sync",
      data: {
        "items": items,
      },
    );
  }

  /// GET SERVER CART
  Future<List<dynamic>> getCart() async {

    final response =
        await DioClient.dio.get(
      "/cart",
    );

    return response.data;
  }

  /// UPDATE CART QUANTITY
  Future<void> updateQuantity(
    String cartId,
    int quantity,
  ) async {

    await DioClient.dio.patch(
      "/cart/$cartId",
      data: {
        "quantity": quantity,
      },
    );
  }

  /// REMOVE CART ITEM
  Future<void> removeItem(
    String cartId,
  ) async {

    await DioClient.dio.delete(
      "/cart/$cartId",
    );
  }

  /// CLEAR ALL CART ITEMS
  Future<void> clearCart() async {

    await DioClient.dio.delete(
      "/cart/clear",
    );
  }
}