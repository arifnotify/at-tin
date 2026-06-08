import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

class OtpPage
    extends StatelessWidget {

  OtpPage({super.key});

  final otpController =
      TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {

    final phone =
        Get.arguments;

    final controller =
        Get.find<AuthController>();

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("OTP"),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            Text(
              "OTP sent to $phone",
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  otpController,
              keyboardType:
                  TextInputType.number,
            ),

            const SizedBox(
              height: 20,
            ),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {

                            await controller.verifyOtp(
                              phone: phone,
                              otp: otpController.text,
                            );
                          },

                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Verify OTP",
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}