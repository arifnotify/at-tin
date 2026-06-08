class BannerModel {
  final String id;

  final String title;

  final String image;

  final String link;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.link,
  });

  factory BannerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BannerModel(
      id: json["_id"] ?? "",

      title: json["title"] ?? "",

      image: json["image"] ?? "",

      link: json["link"] ?? "",
    );
  }
}