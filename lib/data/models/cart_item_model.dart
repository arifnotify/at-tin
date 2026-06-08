import 'dart:async';

class CartItemModel {
  /// PRODUCT ID
  final String id;

  /// SERVER CART DOCUMENT ID
  final String? cartId;

  final String title;

  final String image;

  final num price;

  final num originalPrice;

  int quantity;

  bool isEditing;

  Timer? timer;

  CartItemModel({
    required this.id,
    this.cartId,
    required this.title,
    required this.image,
    required this.price,
    required this.originalPrice,
    this.quantity = 1,
    this.isEditing = true,
    this.timer,
  });

  /// SERVER CART JSON
  factory CartItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final product = json["product"];

    return CartItemModel(
      /// Cart Document ID
      cartId: json["_id"],

      /// Product ID
      id: product["_id"] ?? "",

      title: product["title"] ?? "",

      image: product["images"] != null &&
              product["images"] is List &&
              product["images"].isNotEmpty
          ? product["images"][0]
          : "",

      price: json["price"] ?? 0,

      originalPrice: product["price"] ?? 0,

      quantity: json["quantity"] ?? 1,

      isEditing: false,
    );
  }

  /// LOCAL STORAGE JSON
  factory CartItemModel.fromLocalJson(
    Map<String, dynamic> json,
  ) {
    return CartItemModel(
      id: json["id"] ?? "",

      cartId: json["cartId"],

      title: json["title"] ?? "",

      image: json["image"] ?? "",

      price: json["price"] ?? 0,

      originalPrice:
          json["originalPrice"] ?? 0,

      quantity: json["quantity"] ?? 1,

      isEditing: false,
    );
  }

  /// SAVE TO LOCAL STORAGE
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cartId": cartId,
      "title": title,
      "image": image,
      "price": price,
      "originalPrice": originalPrice,
      "quantity": quantity,
    };
  }

  /// COPY WITH
  CartItemModel copyWith({
    String? id,
    String? cartId,
    String? title,
    String? image,
    num? price,
    num? originalPrice,
    int? quantity,
    bool? isEditing,
    Timer? timer,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      title: title ?? this.title,
      image: image ?? this.image,
      price: price ?? this.price,
      originalPrice:
          originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      isEditing: isEditing ?? this.isEditing,
      timer: timer ?? this.timer,
    );
  }
}