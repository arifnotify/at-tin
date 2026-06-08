import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

class LoginPage
    extends StatelessWidget {

  LoginPage({super.key});

  final phoneController =
      TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {

    final controller =
        Get.find<AuthController>();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Login",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(
              height: 40,
            ),

            TextField(

              controller:
                  phoneController,

              keyboardType:
                  TextInputType.phone,

              decoration:
                  const InputDecoration(
                labelText:
                    "Phone Number",
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Obx(
              () => SizedBox(

                width:
                    double.infinity,

                height: 55,

                child:
                    ElevatedButton(

                  onPressed:
                      controller
                              .isLoading
                              .value
                          ? null
                          : () {

                              controller
                                  .sendOtp(
                                phoneController
                                    .text,
                              );
                            },

                  child: controller
                          .isLoading
                          .value
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Send OTP",
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