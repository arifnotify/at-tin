import 'dart:async';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';

class CartItemModel {
  final String id;
  final String? cartId;

  /// 🔥 MULTI LANGUAGE SUPPORT
  final String titleBn;
  final String titleEn;

  final String image;

  final num price;
  final num originalPrice;

  /// 🟢 UNIT SUPPORT (NEW)
  final dynamic unit; 

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
    this.unit, // এখানে যুক্ত করা হয়েছে
    this.quantity = 1,
    this.isEditing = true,
    this.timer,
    this.isSyncing = false,
    this.isActive = true,
  });

  /// 🟢 GET LOCALIZED TITLE
  String get localizedTitle {
    final lang = Get.find<LanguageController>();
    return lang.isBangla ? titleBn : titleEn;
  }

  /// 🟢 GET LOCALIZED UNIT (NEW)
  String get localizedUnit {
    final lang = Get.find<LanguageController>();
    final isBn = lang.isBangla;

    if (unit is Map) {
      return isBn ? (unit["bn"] ?? unit["en"] ?? "") : (unit["en"] ?? "");
    }
    return unit?.toString() ?? "";
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

      titleBn: titleMap["bn"] ?? "",
      titleEn: titleMap["en"] ?? "",

      image: imageUrl,

      price: finalPrice,
      originalPrice: basePrice,
      
      // 🟢 সার্ভার থেকে ইউনিট রিসিভ করা (product বা সরাসরি json থেকে)
      unit: product["unit"] ?? json["unit"], 

      quantity: json["quantity"] ?? 1,
      isEditing: false,
    );
  }

  /// ================= LOCAL STORAGE JSON =================
  factory CartItemModel.fromLocalJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json["id"] ?? "",
      cartId: json["cartId"],

      titleBn: json["titleBn"] ?? "",
      titleEn: json["titleEn"] ?? "",

      image: json["image"] ?? "",
      price: json["price"] ?? 0,
      originalPrice: json["originalPrice"] ?? 0,
      unit: json["unit"], // লোকাল স্টোরেজ থেকে ইউনিট
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

      "titleBn": titleBn,
      "titleEn": titleEn,

      "image": image,
      "price": price,
      "originalPrice": originalPrice,
      "unit": unit, // লোকাল স্টোরেজে ইউনিট সেভ করা
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
    dynamic unit,
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
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      isEditing: isEditing ?? this.isEditing,
      timer: timer ?? this.timer,
    );
  }
}