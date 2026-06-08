

import 'package:tin/core/network/dio_client.dart';

class OrderService {

  Future<dynamic> createOrder(
    String addressId,
  ) async {

    final response =
        await DioClient.dio.post(
      "/orders",
      data: {
        "shippingAddress":
            addressId,
      },
    );

    return response.data;
  }
}