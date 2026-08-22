import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';

class CategoryModel {
  final String id;
  final dynamic name; // ব্যাকএন্ড থেকে আসা অবজেক্ট {en: "...", bn: "..."}
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  // 🟢 সরাসরি মডেলের ভেতর থেকে LanguageController ব্যবহার করে নাম রিটার্ন করা
  String get localizedName {
    if (name is Map) {
      final langController = Get.isRegistered<LanguageController>()
          ? Get.find<LanguageController>()
          : Get.put(LanguageController());
      
      final currentLang = langController.currentLanguage.value; // 'en' বা 'bn'
      return name[currentLang]?.toString() ?? name['en']?.toString() ?? '';
    }
    return name.toString();
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      image: json["image"] ?? "",
    );
  }
}