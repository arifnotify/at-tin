import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    await Future.wait([
      _minimumDelay(),
      _loadAppData(),
    ]);

    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> _minimumDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _loadAppData() async {
    // এখানে future এ token check / api init দিতে পারো
    return;
  }
}