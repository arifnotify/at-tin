import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/core/constants/network_controller.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'auth_controller.dart';

class OtpPage extends StatelessWidget {
  OtpPage({super.key});

  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final phone = Get.arguments ?? "";
    final authController = Get.find<AuthController>();
    final langController = Get.find<LanguageController>();
    final networkController = Get.find<NetworkController>();

    // ব্র্যান্ড প্রাইমারি থিম কালার
    const Color primaryColor = Color(0xFF1D4D33);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            langController.isBangla ? "ওটিপি যাচাইকরণ" : "OTP Verification",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  Text(
                    langController.isBangla
                        ? "কোডটি প্রবেশ করান"
                        : "Enter verification code",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    langController.isBangla
                        ? "$phone নম্বরে একটি ওটিপি পাঠানো হয়েছে"
                        : "We have sent a code to $phone",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        hintText: "----",
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 18,
                          letterSpacing: 2.0,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () async {
                              if (!networkController.isConnected.value) {
                                networkController.showProfessionalSnackbar(
                                  isOffline: true,
                                  bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
                                  enMessage: "No internet connection detected",
                                );
                                return;
                              }

                              await authController.verifyOtp(
                                phone: phone,
                                otp: otpController.text.trim(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: AppLoader(),
                            )
                          : Text(
                              langController.isBangla
                                  ? "ওটিপি যাচাই করুন"
                                  : "Verify OTP",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}