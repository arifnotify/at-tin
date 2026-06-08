class ProductModel {
  final String id;
  final String title;
  final String description;

  final double price;
  final double? discountPrice;
  final double? flashSalePrice;

  final List<String> images;
  final String? unit;

  // NEW
  final String? productType;
  final String? freshText;
  final String? expiryText;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.discountPrice,
    this.flashSalePrice,
    required this.images,
    this.unit,

    // NEW
    this.productType,
    this.freshText,
    this.expiryText,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',

      price: (json['price'] ?? 0).toDouble(),

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
              json['productType'] ?? 'regular',

          freshText:
              json['freshText'] ?? '',

          expiryText:
              json['expiryText'] ?? '',
    );
  }

  /// Current Selling Price

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

  bool get hasDiscount {
    return currentPrice < price;
  }

  bool get isFlashSale {
    return flashSalePrice != null &&
        flashSalePrice! > 0;
  }

  int get discountPercent {
    if (!hasDiscount) return 0;

    return (((price - currentPrice) /
                price) *
            100)
        .round();
  }
}