import 'package:dio/dio.dart';
import 'package:tin/core/constants/app_constants.dart';

class SupportService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
    ),
  );

  Future<Map<String, dynamic>>
      getSupportLinks() async {
    final response = await dio.get(
      "/support-links",
    );

    return response.data;
  }
}