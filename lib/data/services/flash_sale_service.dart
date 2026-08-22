import 'package:tin/core/network/dio_client.dart';

class FlashSaleService {

  Future<dynamic> getFlashSaleById(
    String id,
  ) async {

    final response =
        await DioClient.dio.get(
      "/flash-sale/$id",
    );

    return response.data;
  }
}