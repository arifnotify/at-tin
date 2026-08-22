class TranslatedText {
  final String en;
  final String bn;

  TranslatedText({required this.en, required this.bn});

  factory TranslatedText.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TranslatedText(en: "", bn: "");
    return TranslatedText(
      en: json["en"] ?? "",
      bn: json["bn"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "en": en,
        "bn": bn,
      };
}

class LocationModel {
  final String id;
  final TranslatedText division;
  final TranslatedText district;
  final int deliveryCharge;
  final bool isActive;

  LocationModel({
    required this.id,
    required this.division,
    required this.district,
    required this.deliveryCharge,
    required this.isActive,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json["_id"] ?? "",
      division: TranslatedText.fromJson(json["division"]),
      district: TranslatedText.fromJson(json["district"]),
      deliveryCharge: json["deliveryCharge"] ?? 0,
      isActive: json["isActive"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "division": division.toJson(),
        "district": district.toJson(),
        "deliveryCharge": deliveryCharge,
        "isActive": isActive,
      };
}