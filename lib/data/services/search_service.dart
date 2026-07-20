import 'package:get_storage/get_storage.dart';
import 'package:tin/core/network/dio_client.dart';

class SearchService {
  final GetStorage box = GetStorage();

  Future<Map<String, dynamic>> searchProducts({
    required String keyword,
  }) async {
    final String? locationId = box.read("locationId");

    final response = await DioClient.dio.get(
      "/products/search",
      queryParameters: {
        "keyword": keyword,
        "page": 1,
        "limit": 20,

        // ✅ Selected Location
        if (locationId != null && locationId.isNotEmpty)
          "location": locationId,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }
}