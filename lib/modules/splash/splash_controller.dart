import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';

class SplashController
    extends GetxController {

  @override
  void onInit() {

    super.onInit();

    checkApp();
  }

  void checkApp() {

    Future.delayed(
      const Duration(
        seconds: 2,
      ),
      () {

        Get.offAllNamed(
          AppRoutes.home,
        );
      },
    );
  }
}