class SupportLinkModel {
  final String whatsapp;
  final String phone;
  final String facebook;
  final String instagram;
  final String messenger;

  SupportLinkModel({
    required this.whatsapp,
    required this.phone,
    required this.facebook,
    required this.instagram,
    required this.messenger,
  });

  factory SupportLinkModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SupportLinkModel(
      whatsapp: json["whatsapp"] ?? "",
      phone: json["phone"] ?? "",
      facebook: json["facebook"] ?? "",
      instagram: json["instagram"] ?? "",
      messenger: json["messenger"] ?? "",
    );
  }
}