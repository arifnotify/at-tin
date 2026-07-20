class ProductModel {
  final String id;

  final Map<String, dynamic> title;

  final Map<String, dynamic> description;

  final double price;

  final double? discountPrice;

  final double? flashSalePrice;

  final List<String> images;

  final String? unit;

  final String? productType;

  final String? freshText;

  final String? expiryText;

  /// 👉 YouTube Video URL
  final String? youtubeVideoUrl;

  /// 👉 Category
  final Map<String, dynamic>? category;

  /// 👉 NEW : Product Locations
  final List<Map<String, dynamic>> locations;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.discountPrice,
    this.flashSalePrice,
    required this.images,
    this.unit,
    this.productType,
    this.freshText,
    this.expiryText,
    this.youtubeVideoUrl,
    this.category,

    /// NEW
    this.locations = const [],
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductModel(
      id: json['_id'] ?? '',

      title: json['title'] != null
          ? Map<String, dynamic>.from(
              json['title'],
            )
          : {},

      description:
          json['description'] != null
              ? Map<String, dynamic>.from(
                  json['description'],
                )
              : {},

      price:
          (json['price'] ?? 0).toDouble(),

      discountPrice:
          json['discountPrice'] != null
              ? (json['discountPrice'])
                  .toDouble()
              : null,

      flashSalePrice:
          json['flashSalePrice'] != null
              ? (json['flashSalePrice'])
                  .toDouble()
              : null,

      images: json['images'] != null
          ? List<String>.from(
              json['images'],
            )
          : [],

      unit: json['unit'] ?? '',

      productType:
          json['productType'] ??
              'regular',

      freshText:
          json['freshText'] ?? '',

      expiryText:
          json['expiryText'] ?? '',

      youtubeVideoUrl:
          json['youtubeVideoUrl'],

      category:
          json['category'] != null
              ? Map<String, dynamic>.from(
                  json['category'],
                )
              : null,

      /// NEW
      locations:
          json['locations'] != null
              ? List<Map<String, dynamic>>.from(
                  json['locations'].map(
                    (e) =>
                        Map<String, dynamic>.from(
                            e),
                  ),
                )
              : [],
    );
  }
  // =========================
  // Helper Getters
  // =========================


  String get titleEn =>
      title['en'] ?? '';


  String get titleBn =>
      title['bn'] ?? '';



  String get descriptionEn =>
      description['en'] ?? '';



  String get descriptionBn =>
      description['bn'] ?? '';



  String get categoryName =>
      category?['name'] ?? '';



  // =========================
  // LOCATION HELPERS (NEW)
  // =========================


  /// সব Location Name
 List<String> get locationNames {
  return locations
      .map<String>(
        (location) =>
            location['district']?.toString() ?? '',
      )
      .toList();
}



  /// Location আছে কিনা চেক
  bool hasLocation(
    String locationId,
  ) {

    return locations.any(
      (location) =>
          location['_id'] == locationId,
    );

  }



  // =========================
  // PRICE HELPERS
  // =========================


  double get currentPrice {

    if (flashSalePrice != null &&
        flashSalePrice! > 0) {

      return flashSalePrice!;

    }


    if (discountPrice != null &&
        discountPrice! > 0) {

      return discountPrice!;

    }


    return price;

  }



  bool get hasDiscount =>
      currentPrice < price;



  bool get isFlashSale =>
      flashSalePrice != null &&
      flashSalePrice! > 0;



  int get discountPercent {

    if (!hasDiscount) {
      return 0;
    }


    return (
      (
        (price - currentPrice)
        /
        price
      ) *
      100
    ).round();

  }



  // =========================
  // YouTube Helper
  // =========================


  bool get hasYoutubeVideo =>
      youtubeVideoUrl != null &&
      youtubeVideoUrl!.isNotEmpty;


}