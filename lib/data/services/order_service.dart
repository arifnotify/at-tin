import 'package:tin/core/network/dio_client.dart';

class OrderService {
  // ==========================
  // CREATE ORDER
  // ==========================
  Future<dynamic> createOrder(
    String addressId,
  ) async {
    final response =
        await DioClient.dio.post(
      "/orders",
      data: {
        "shippingAddress": addressId,
      },
    );

    return response.data;
  }

  // ==========================
  // TRACK ORDER
  // ==========================
  Future<dynamic> getTracking(
    String orderId,
  ) async {
    final response =
        await DioClient.dio.get(
      "/orders/$orderId/tracking",
    );

    return response.data;
  }

  // ==========================
  // GET SINGLE ORDER
  // ==========================
  Future<dynamic> getOrderById(
    String id,
  ) async {
    final response =
        await DioClient.dio.get(
      "/orders/$id",
    );

    return response.data;
  }

  // ==========================
  // GET MY ORDERS
  // ==========================
  Future<List<dynamic>> getMyOrders() async {
    final response =
        await DioClient.dio.get(
      "/orders/my-orders",
    );

    return response.data;
  }

  // ==========================
  // GET ACTIVE ORDER
  // ==========================
  Future<dynamic> getActiveOrder() async {
    final response =
        await DioClient.dio.get(
      "/orders/active",
    );

    return response.data;
  }
}