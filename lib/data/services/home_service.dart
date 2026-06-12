import 'package:tin/core/network/dio_client.dart';

class HomeService {

  Future<dynamic> getBanners() async {
    final response = await DioClient.dio.get(
      "/banners",
    );

    return response.data;
  }

  /// =========================
  /// 🔥 ADD THIS METHOD
  /// MAIN CATEGORIES ONLY
  /// =========================
  Future<dynamic> getMainCategories() async {
    final response = await DioClient.dio.get(
      "/categories/main",
    );

    return response.data;
  }

  Future<dynamic> getCategories() async {
    final response = await DioClient.dio.get(
      "/categories",
    );

    return response.data;
  }

  Future<dynamic> getProducts() async {
    final response = await DioClient.dio.get(
      "/products",
    );

    return response.data;
  }
  

}