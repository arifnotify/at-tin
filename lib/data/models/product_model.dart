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

  /// 👉 Product Locations
  final List<Map<String, dynamic>> locations;

  /// 👉 Product Country
  final Map<String, dynamic>? country;

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
    this.locations = const [],
    this.country,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    // =========================
    // TITLE & DESCRIPTION PARSING (String or Map safely)
    // =========================
    Map<String, dynamic> parseLocalMap(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      } else if (value is String && value.isNotEmpty) {
        return {'en': value, 'bn': value};
      }
      return {};
    }

    // =========================
    // LOCATIONS PARSING
    // =========================
    List<Map<String, dynamic>> parsedLocations = [];
    if (json['locations'] is List) {
      for (var loc in json['locations']) {
        if (loc is Map) {
          parsedLocations.add(Map<String, dynamic>.from(loc));
        } else if (loc != null) {
          parsedLocations.add({'_id': loc.toString()});
        }
      }
    }

    return ProductModel(
      // =========================
      // BASIC
      // =========================
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',

      title: parseLocalMap(json['title']),

      description: parseLocalMap(json['description']),

      // =========================
      // PRICE
      // =========================
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,

      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,

      flashSalePrice: (json['flashSalePrice'] ?? json['salePrice']) != null
          ? ((json['flashSalePrice'] ?? json['salePrice']) as num).toDouble()
          : null,

      // =========================
      // IMAGES
      // =========================
      images: json['images'] != null
          ? List<String>.from(
              (json['images'] as List).map((e) => e.toString()),
            )
          : [],

      // =========================
      // PRODUCT INFO
      // =========================
      unit: json['unit']?.toString() ?? '',

      productType: json['productType']?.toString() ?? 'regular',

      freshText: json['freshText']?.toString() ?? '',

      expiryText: json['expiryText']?.toString() ?? '',

      // =========================
      // YOUTUBE
      // =========================
      youtubeVideoUrl: json['youtubeVideoUrl']?.toString(),

      // =========================
      // CATEGORY
      // =========================
      category: json['category'] is Map
          ? Map<String, dynamic>.from(json['category'])
          : (json['category'] != null
              ? {'_id': json['category'].toString()}
              : null),

      // =========================
      // COUNTRY
      // =========================
      country: json['country'] is Map
          ? Map<String, dynamic>.from(json['country'])
          : (json['country'] != null
              ? {'_id': json['country'].toString()}
              : null),

      // =========================
      // LOCATIONS
      // =========================
      locations: parsedLocations,
    );
  }

  // =========================================================
  // TITLE HELPERS
  // =========================================================

  String get titleEn => title['en']?.toString() ?? '';

  String get titleBn => title['bn']?.toString() ?? '';

  // =========================================================
  // DESCRIPTION HELPERS
  // =========================================================

  String get descriptionEn => description['en']?.toString() ?? '';

  String get descriptionBn => description['bn']?.toString() ?? '';

  // =========================================================
  // CATEGORY HELPERS
  // =========================================================

  String get categoryName {
    final name = category?['name'];

    if (name is Map) {
      return name['en']?.toString() ?? '';
    }

    return name?.toString() ?? '';
  }

  String get categoryNameEn {
    final name = category?['name'];

    if (name is Map) {
      return name['en']?.toString() ?? '';
    }

    return name?.toString() ?? '';
  }

  String get categoryNameBn {
    final name = category?['name'];

    if (name is Map) {
      return name['bn']?.toString() ?? '';
    }

    return name?.toString() ?? '';
  }

  String get parentCategoryId =>
      category?['parentCategory']?.toString() ?? '';

  // =========================================================
  // COUNTRY HELPERS
  // =========================================================

  /// Country ID
  String get countryId => country?['_id']?.toString() ?? '';

  /// Country Name
  String get countryName => country?['name']?.toString() ?? '';

  /// Country Code
  String get countryCode => country?['code']?.toString() ?? '';

  /// Country Flag Image URL
  String get countryFlag => country?['flag']?.toString() ?? '';

  /// Product has country or not
  bool get hasCountry => country != null && countryName.isNotEmpty;

  /// Product has flag or not
  bool get hasCountryFlag => countryFlag.isNotEmpty;

  // =========================================================
  // LOCATION HELPERS
  // =========================================================

  /// জেলার নাম (English)
  List<String> get locationNamesEn {
    return locations.map<String>((location) {
      final district = location['district'];

      if (district is Map) {
        return district['en']?.toString() ?? '';
      }

      return district?.toString() ?? '';
    }).toList();
  }

  /// জেলার নাম (Bangla)
  List<String> get locationNamesBn {
    return locations.map<String>((location) {
      final district = location['district'];

      if (district is Map) {
        return district['bn']?.toString() ?? '';
      }

      return district?.toString() ?? '';
    }).toList();
  }

  /// ভাষা অনুযায়ী জেলার নাম
  List<String> locationNames(
    bool isBangla,
  ) {
    return locations.map<String>((location) {
      final district = location['district'];

      if (district is Map) {
        return isBangla
            ? (district['bn']?.toString() ?? '')
            : (district['en']?.toString() ?? '');
      }

      return district?.toString() ?? '';
    }).toList();
  }

  /// Location আছে কিনা
  bool hasLocation(
    String locationId,
  ) {
    return locations.any(
      (location) => location['_id']?.toString() == locationId,
    );
  }

  // =========================================================
  // PRICE HELPERS
  // =========================================================

  double get currentPrice {
    if (flashSalePrice != null && flashSalePrice! > 0) {
      return flashSalePrice!;
    }

    if (discountPrice != null && discountPrice! > 0) {
      return discountPrice!;
    }

    return price;
  }

  bool get hasDiscount => currentPrice < price;

  bool get isFlashSale => flashSalePrice != null && flashSalePrice! > 0;

  int get discountPercent {
    if (!hasDiscount || price <= 0) {
      return 0;
    }

    return (((price - currentPrice) / price) * 100).round();
  }

  // =========================================================
  // YOUTUBE HELPER
  // =========================================================

  bool get hasYoutubeVideo =>
      youtubeVideoUrl != null && youtubeVideoUrl!.isNotEmpty;
}