import 'package:tin/core/network/dio_client.dart';

import '../models/payment_settings_model.dart';

class PaymentSettingsService {

  Future<PaymentSettingsModel>
      getPaymentSettings() async {

    final response =
        await DioClient.dio.get(
      "/payment-settings",
    );

    return PaymentSettingsModel.fromJson(
      response.data,
    );
  }
}