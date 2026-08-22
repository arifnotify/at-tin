class PaymentSettingsModel {
  final bool codEnabled;
  final bool sslcommerzEnabled;

  PaymentSettingsModel({
    required this.codEnabled,
    required this.sslcommerzEnabled,
  });

  factory PaymentSettingsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentSettingsModel(
      codEnabled: json["codEnabled"] ?? false,
      sslcommerzEnabled:
          json["sslcommerzEnabled"] ?? false,
    );
  }
}