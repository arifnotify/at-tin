import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'address_controller.dart';
import 'add_address_page.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
    appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Get.offAllNamed("/home");
    },
  ),
  title: const Text("Select Address"),
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddAddressPage());
        },
        child: const Icon(Icons.add),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.addresses.isEmpty) {
          return const Center(
            child: Text("No Address Found"),
          );
        }

        return Column(
          children: [
            /// ADDRESS LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final address = controller.addresses[index];

                  return Obx(() {
                    return Card(
                      child: RadioListTile<String>(
                        value: address.id,

                        groupValue: controller
                            .selectedAddress.value?.id,

                        onChanged: (value) {
                          controller.selectAddress(address);
                        },

                        title: Text(address.fullName),

                        subtitle: Text(
                          "${address.phoneNumber}\n${address.addressLine}",
                        ),

                        secondary: controller
                                    .selectedAddress.value?.id ==
                                address.id
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.location_on),
                      ),
                    );
                  });
                },
              ),
            ),

            /// CONTINUE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),

                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (controller
                                    .selectedAddress.value ==
                                null) {
                              Get.snackbar(
                                "Error",
                                "Please select an address",
                              );
                              return;
                            }

                            Get.toNamed("/order-summary");
                          },

                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}