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
      id: json["_id"] ?? json["id"] ?? "",
      fullName: json["fullName"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",

      areaOrVillage: json["areaOrVillage"] ?? "",
      landmark: json["landmark"] ?? "",
      directionNote: json["directionNote"],

      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),

      isDefault: json["isDefault"] ?? false,
    );
  }

  // 🔹 toJson Method (API Request বা Local Storage-এর জন্য)
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "areaOrVillage": areaOrVillage,
      "landmark": landmark,
      "directionNote": directionNote,
      "latitude": latitude,
      "longitude": longitude,
      "isDefault": isDefault,
    };
  }

  // 🔹 copyWith Method (Local Controller State Update-এর জন্য)
  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? areaOrVillage,
    String? landmark,
    String? directionNote,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      areaOrVillage: areaOrVillage ?? this.areaOrVillage,
      landmark: landmark ?? this.landmark,
      directionNote: directionNote ?? this.directionNote,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}