import 'package:tin/core/network/dio_client.dart';


class CartService {

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

  Future<List<dynamic>> getCart() async {

    final response =
        await DioClient.dio.get(
      "/cart",
    );

    return response.data;
  }

  Future updateQuantity(
    String cartId,
    int quantity,
  ) async {

    return DioClient.dio.patch(
      "/cart/$cartId",
      data: {
        "quantity": quantity,
      },
    );
  }

  Future removeItem(
    String cartId,
  ) async {

    return DioClient.dio.delete(
      "/cart/$cartId",
    );
  }
}