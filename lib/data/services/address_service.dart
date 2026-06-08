import 'package:tin/core/network/dio_client.dart';

class AddressService {

  Future<List<dynamic>>
      getAddresses() async {

    final response =
        await DioClient.dio.get(
      "/address",
    );

    return response.data;
  }

  Future<dynamic> createAddress(
    Map<String, dynamic> body,
  ) async {

    final response =
        await DioClient.dio.post(
      "/address",
      data: body,
    );

    return response.data;
  }

  Future<dynamic> updateAddress(
    String id,
    Map<String, dynamic> body,
  ) async {

    final response =
        await DioClient.dio.patch(
      "/address/$id",
      data: body,
    );

    return response.data;
  }

  Future<void> deleteAddress(
    String id,
  ) async {

    await DioClient.dio.delete(
      "/address/$id",
    );
  }
}