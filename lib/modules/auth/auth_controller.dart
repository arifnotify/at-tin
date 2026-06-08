import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/data/services/auth_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class AuthController
    extends GetxController {

  final service =
      AuthService();

  final box =
      GetStorage();

  RxBool isLoading =
      false.obs;

  RxBool isLoggedIn =
      false.obs;

  @override
  void onInit() {

    super.onInit();

    checkLogin();
  }

  void checkLogin() {

    final token =
        box.read("token");

    isLoggedIn.value =
        token != null;
  }

  Future sendOtp(
    String phone,
  ) async {

    try {

      isLoading.value =
          true;

      await service.sendOtp(
        phone,
      );

      Get.toNamed(
        "/otp",
        arguments: phone,
      );

    } finally {

      isLoading.value =
          false;
    }
  }


Future verifyOtp({required String phone, required String otp}) async {
  try {
    isLoading.value = true;

    final data = await service.verifyOtp(phone: phone, otp: otp);

    box.write("token", data["token"] ?? data["access_token"]);
    isLoggedIn.value = true;

    /// 🔹 Sync Guest Cart to Server
    final cartController = Get.find<CartController>();
    await cartController.syncCartAfterLogin();
    await Get.find<CartController>().loadServerCart();

    /// 🔹 Go to Address Page
    Get.toNamed( "/address",);
  } finally {
    isLoading.value = false;
  }
}

  void logout() {

    box.remove("token");

    isLoggedIn.value =
        false;
  }
}