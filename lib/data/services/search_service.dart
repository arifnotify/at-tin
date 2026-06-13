import 'package:tin/core/network/dio_client.dart';

class SearchService {
  Future<Map<String, dynamic>> searchProducts({
    required String keyword,
  }) async {
    final response = await DioClient.dio.get(
      "/products/search",
      queryParameters: {
        "keyword": keyword,
        "page": 1,
        "limit": 20,
      },
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }
}