class AddressModel {
  final String id;

  final String fullName;
  final String phoneNumber;

  final String division;
  final String district;

  final String area;
  final String addressLine;

  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.division,
    required this.district,
    required this.area,
    required this.addressLine,
    required this.isDefault,
  });

  factory AddressModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AddressModel(
      id: json["_id"] ?? "",

      fullName: json["fullName"] ?? "",

      phoneNumber:
          json["phoneNumber"] ?? "",

      division:
          json["division"] ?? "",

      district:
          json["district"] ?? "",

      area:
          json["area"] ?? "",

      addressLine:
          json["addressLine"] ?? "",

      isDefault:
          json["isDefault"] ?? false,
    );
  }
}