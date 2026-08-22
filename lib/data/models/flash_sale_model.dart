class FlashSaleModel {
  final String id;
  final String title;
  final String? bannerImage; // ব্যানার ছবির URL
  final List<dynamic> products; // প্রোডাক্ট মডেল বা প্রোডাক্ট ID-এর লিস্ট

  FlashSaleModel({
    required this.id,
    required this.title,
    this.bannerImage,
    required this.products,
  });

  factory FlashSaleModel.fromJson(Map<String, dynamic> json) {
    return FlashSaleModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      bannerImage: json['bannerImage']?.toString() ?? json['image']?.toString(),
      products: json['products'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'bannerImage': bannerImage,
      'products': products,
    };
  }
}