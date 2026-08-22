class BannerModel {
  final String id;
  final String title;
  final String image;

  // Banner click করলে কোথায় যাবে
  final String linkType;

  // Product / Flash Sale / Category ID
  final String? linkId;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.linkType,
    this.linkId,
  });

  factory BannerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BannerModel(
      id: json["_id"] ?? "",
      title: json["title"] ?? "",
      image: json["image"] ?? "",
      linkType: json["linkType"] ?? "none",
      linkId: json["linkId"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "image": image,
      "linkType": linkType,
      "linkId": linkId,
    };
  }
}