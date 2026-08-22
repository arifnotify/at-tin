import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/core/constants/network_controller.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'auth_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            langController.isBangla ? "মোবাইল লগইন" : "Mobile Login",
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

                  // হেডিং টেক্সট
                  Text(
                    langController.isBangla
                        ? "আপনার মোবাইল নম্বর দিন"
                        : "Enter your mobile number",
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
                        ? "এসএমএস-এর মাধ্যমে একটি ওটিপি (OTP) পাবেন"
                        : "You will receive a one time pin as an SMS",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ফোন নম্বর ইনপুট ফিল্ড
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        hintText: "01XXXXXXXXX",
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
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

                  // "Login with OTP" বাটন এবং কাস্টম AppLoader
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              // ইন্টারনেট কানেকশন চেক করা হচ্ছে
                              if (!networkController.isConnected.value) {
                                networkController.showProfessionalSnackbar(
                                  isOffline: true,
                                  bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
                                  enMessage: "No internet connection detected",
                                );
                                return;
                              }

                              authController.sendOtp(phoneController.text.trim());
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
                                  ? "ওটিপি দিয়ে লগইন করুন"
                                  : "Login with OTP",
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