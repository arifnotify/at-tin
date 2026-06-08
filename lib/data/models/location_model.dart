class LocationModel {
  final String id;

  final String division;

  final String district;

  final int deliveryCharge;

  final bool isActive;

  LocationModel({
    required this.id,
    required this.division,
    required this.district,
    required this.deliveryCharge,
    required this.isActive,
  });

  factory LocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LocationModel(
      id: json["_id"] ?? "",

      division:
          json["division"] ?? "",

      district:
          json["district"] ?? "",

      deliveryCharge:
          json["deliveryCharge"] ?? 0,

      isActive:
          json["isActive"] ?? false,
    );
  }
}