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

Future<void> checkLogin() async {
  final token = box.read("token");

  isLoggedIn.value = token != null;

  if (isLoggedIn.value) {
    await Get.find<CartController>()
        .loadServerCart();
  }
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


Future<void> verifyOtp({
  required String phone,
  required String otp,
}) async {
  print("VERIFY OTP CALLED");

  try {
    isLoading.value = true;

    final data = await service.verifyOtp(
      phone: phone,
      otp: otp,
    );

    // Token সেভ
    box.write("token", data["token"] ?? data["access_token"]);
    isLoggedIn.value = true;

    final cartController = Get.find<CartController>();

    // Guest Cart → Server Cart sync
    await cartController.syncCartAfterLogin();

    isLoading.value = false;

    // ================== সরল লজিক ==================
    Get.offAllNamed('/home');
    // ===============================================

  } catch (e) {
    isLoading.value = false;
    Get.snackbar(
      "Error",
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

 void logout() {

  box.remove("token");

  Get.find<CartController>()
      .clearCart();

  isLoggedIn.value = false;
}
}