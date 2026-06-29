import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tin/core/constants/app_constants.dart';

class RewardService {

  Future<double> getWalletBalance(
    String userId,
    String token,
  ) async {

    final url =
        "${AppConstants.baseUrl}/rewards/wallet/$userId";

    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(res.body);

    return (data['balance'] ?? 0).toDouble();
  }
}