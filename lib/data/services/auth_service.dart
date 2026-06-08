import 'package:tin/core/network/dio_client.dart';

class AuthService {

  Future sendOtp(
    String phone,
  ) async {

    final response =
        await DioClient.dio.post(
      "/auth/send-otp",
      data: {
        "phone": phone,
      },
    );

    return response.data;
  }

  Future verifyOtp({
    required String phone,
    required String otp,
  }) async {

    final response =
        await DioClient.dio.post(
      "/auth/verify-otp",
      data: {
        "phone": phone,
        "otp": otp,
      },
    );

    return response.data;
  }
}