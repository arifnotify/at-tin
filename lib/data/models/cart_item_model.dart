import 'dart:async';

class CartItemModel {
  final String id;

  final String title;

  final String image;

  final num price;

  final num originalPrice;

  int quantity;

  bool isEditing;

  Timer? timer;

  CartItemModel({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.originalPrice,
    this.quantity = 1,
    this.isEditing = true,
    this.timer,
  });

  factory CartItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final product = json["product"];

    return CartItemModel(
      id: json["_id"],

      title: product["title"],

      image: product["images"] != null &&
              product["images"].isNotEmpty
          ? product["images"][0]
          : "",

      price: json["price"],

      originalPrice: product["price"],

      quantity: json["quantity"],
    );
  }
}