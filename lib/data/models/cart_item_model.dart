import 'dart:async';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';

class CartItemModel {
  final String id;
  final String? cartId;

  /// 🔥 MULTI LANGUAGE SUPPORT (IMPORTANT FIX)
  final String titleBn;
  final String titleEn;

  final String image;

  final num price;
  final num originalPrice;

  int quantity;
  bool isEditing;
  Timer? timer;
  bool isSyncing;
  final bool isActive;

  CartItemModel({
    required this.id,
    this.cartId,
    required this.titleBn,
    required this.titleEn,
    required this.image,
    required this.price,
    required this.originalPrice,
    this.quantity = 1,
    this.isEditing = true,
    this.timer,
    this.isSyncing = false,
    this.isActive = true,
  });

  /// 🟢 GET LOCALIZED TITLE (BEST PRACTICE)
  String get localizedTitle {
    final lang = Get.find<LanguageController>();
    return lang.isBangla ? titleBn : titleEn;
  }

  /// ================= SERVER CART JSON =================
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json["product"] is Map
        ? Map<String, dynamic>.from(json["product"])
        : <String, dynamic>{};

    final titleMap = product["title"] is Map
        ? Map<String, dynamic>.from(product["title"])
        : <String, dynamic>{};

    // ================= PRICE FIX =================
    final basePrice = product["price"] ?? 0;
    final discountPrice = product["discountPrice"];
    final flashPrice = product["flashSalePrice"];

    num finalPrice = basePrice;

    if (flashPrice != null && flashPrice > 0) {
      finalPrice = flashPrice;
    } else if (discountPrice != null && discountPrice > 0) {
      finalPrice = discountPrice;
    }
    // ============================================

    String imageUrl = "";

    if (product["images"] is List &&
        product["images"].isNotEmpty) {
      imageUrl = product["images"][0].toString();
    }

    return CartItemModel(
      cartId: json["_id"]?.toString(),
      id: product["_id"]?.toString() ?? "",

      /// 🔥 FIXED: KEEP BOTH LANGUAGES
      titleBn: titleMap["bn"] ?? "",
      titleEn: titleMap["en"] ?? "",

      image: imageUrl,

      price: finalPrice,
      originalPrice: basePrice,

      quantity: json["quantity"] ?? 1,
      isEditing: false,
    );
  }

  /// ================= LOCAL STORAGE JSON =================
  factory CartItemModel.fromLocalJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json["id"] ?? "",
      cartId: json["cartId"],

      /// 🔥 FIXED
      titleBn: json["titleBn"] ?? "",
      titleEn: json["titleEn"] ?? "",

      image: json["image"] ?? "",
      price: json["price"] ?? 0,
      originalPrice: json["originalPrice"] ?? 0,
      quantity: json["quantity"] ?? 1,
      isEditing: false,
      isActive: json["product"]?["isActive"] ?? true,
    );
  }

  /// ================= SAVE TO LOCAL STORAGE =================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cartId": cartId,

      /// 🔥 FIXED
      "titleBn": titleBn,
      "titleEn": titleEn,

      "image": image,
      "price": price,
      "originalPrice": originalPrice,
      "quantity": quantity,
    };
  }

  /// ================= COPY WITH =================
  CartItemModel copyWith({
    String? id,
    String? cartId,
    String? titleBn,
    String? titleEn,
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
      titleBn: titleBn ?? this.titleBn,
      titleEn: titleEn ?? this.titleEn,
      image: image ?? this.image,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      isEditing: isEditing ?? this.isEditing,
      timer: timer ?? this.timer,
    );
  }
}