import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/constants/app_constants.dart';

class DioClient {

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  static void init() {

    dio.interceptors.add(
      InterceptorsWrapper(

        onRequest: (options, handler) {

          final token = GetStorage().read("token");

          print("SENDING TOKEN: $token");

          if (token != null) {

            options.headers["Authorization"] =
                "Bearer $token";
          }

          return handler.next(options);
        },

        onError: (error, handler) {

          print("API ERROR: ${error.response?.statusCode}");
          print("ERROR DATA: ${error.response?.data}");

          return handler.next(error);
        },
      ),
    );
  }
}