class AddressModel {
  final String id;
  final String fullName;
  final String phoneNumber;

  final String areaOrVillage;
  final String landmark;
  final String? directionNote;

  final double latitude;
  final double longitude;

  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.areaOrVillage,
    required this.landmark,
    this.directionNote,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory AddressModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AddressModel(
      id: json["_id"],
      fullName: json["fullName"],
      phoneNumber: json["phoneNumber"],

      areaOrVillage: json["areaOrVillage"],
      landmark: json["landmark"],
      directionNote: json["directionNote"],

      latitude:
          (json["latitude"] ?? 0)
              .toDouble(),

      longitude:
          (json["longitude"] ?? 0)
              .toDouble(),

      isDefault:
          json["isDefault"] ?? false,
    );
  }
}