import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final box = GetStorage();

  final RxString currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();

    currentLanguage.value =
        box.read('language') ?? 'en';
  }

  bool get isBangla =>
      currentLanguage.value == 'bn';

  void changeLanguage(String langCode) {
    currentLanguage.value = langCode;

    box.write(
      'language',
      langCode,
    );
  }
}