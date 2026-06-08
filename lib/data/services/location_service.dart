import 'package:dio/dio.dart';
import 'package:tin/core/network/dio_client.dart';


class LocationService {
  Future<List<dynamic>> getLocations() async {
    try {
      final response =
          await DioClient.dio.get(
        "/locations",
      );

      print(response.data);

      return response.data;
    } on DioException catch (e) {
      print("ERROR:");
      print(e.message);
      print(e.response?.data);

      rethrow;
    }
  }
}