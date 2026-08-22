import 'package:tin/core/network/dio_client.dart';

class AuthService {
  // =========================
  // SEND OTP
  // =========================
  Future sendOtp(
    String phone,
  ) async {
    final response = await DioClient.dio.post(
      "/auth/send-otp",
      data: {
        "phone": phone,
      },
    );

    return response.data;
  }

  // =========================
  // VERIFY OTP
  // =========================
  Future verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await DioClient.dio.post(
      "/auth/verify-otp",
      data: {
        "phone": phone,
        "otp": otp,
      },
    );

    return response.data;
  }

  // ==========================================
  // GET PROFILE (Fresh User Data & Block Check)
  // ==========================================
  Future getProfile() async {
    final response = await DioClient.dio.get("/auth/profile");
    return response.data;
  }
}