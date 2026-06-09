import 'package:tin/core/network/dio_client.dart';

class AddressService {

  /// GET ALL ADDRESSES
  Future<List<dynamic>> getAddresses() async {
    try {
      final response = await DioClient.dio.get(
        "/addresses",
      );

      return response.data;
    } catch (e) {
      throw Exception("Failed to load addresses: $e");
    }
  }

  /// CREATE ADDRESS (PIN DROP SUPPORT)
  Future<dynamic> createAddress(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await DioClient.dio.post(
        "/addresses",
        data: body,
      );

      return response.data;
    } catch (e) {
      throw Exception("Failed to create address: $e");
    }
  }

  /// DELETE ADDRESS
  Future<void> deleteAddress(String id) async {
    try {
      await DioClient.dio.delete(
        "/addresses/$id",
      );
    } catch (e) {
      throw Exception("Failed to delete address: $e");
    }
  }

  /// UPDATE ADDRESS (OPTIONAL but useful)
  Future<dynamic> updateAddress(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await DioClient.dio.patch(
        "/addresses/$id",
        data: body,
      );

      return response.data;
    } catch (e) {
      throw Exception("Failed to update address: $e");
    }
  }
}