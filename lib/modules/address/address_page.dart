import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/address/address_controller.dart';

import 'add_address_page.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AddressController(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Get.offAllNamed(
              "/home",
            );
          },
        ),
        title: const Text(
          "Select Address",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Get.to(
            () => const AddAddressPage(),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (controller.addresses.isEmpty) {
          return const Center(
            child: Text(
              "No Address Found",
            ),
          );
        }

        return Column(
          children: [

            /// ADDRESS LIST
            Expanded(
              child:
                  ListView.builder(
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                itemCount: controller
                    .addresses.length,
                itemBuilder:
                    (context, index) {

                  final address =
                      controller
                          .addresses[index];

                  return Obx(() {
                    return Card(
                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),

                      child:
                          RadioListTile<
                              String>(
                        value:
                            address.id,

                        groupValue:
                            controller
                                .selectedAddress
                                .value
                                ?.id,

                        onChanged:
                            (_) {
                          controller
                              .selectAddress(
                            address,
                          );
                        },

                        title: Row(
                          children: [

                            Expanded(
                              child: Text(
                                address
                                    .fullName,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            if (address
                                .isDefault)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      8,
                                  vertical:
                                      4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .green,
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child:
                                    const Text(
                                  "Default",
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        12,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        subtitle:
                            Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 8,
                          ),
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                address
                                    .phoneNumber,
                              ),

                              const SizedBox(
                                height:
                                    4,
                              ),

                              Text(
                                address
                                    .areaOrVillage,
                              ),

                              const SizedBox(
                                height:
                                    4,
                              ),

                              Text(
                                "📍 ${address.landmark}",
                              ),

                              if (address
                                      .directionNote !=
                                  null &&
                                  address
                                      .directionNote!
                                      .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    top:
                                        4,
                                  ),
                                  child:
                                      Text(
                                    address
                                        .directionNote!,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        secondary:
                            controller
                                        .selectedAddress
                                        .value
                                        ?.id ==
                                    address.id
                                ? const Icon(
                                    Icons
                                        .check_circle,
                                    color: Colors
                                        .green,
                                  )
                                : const Icon(
                                    Icons
                                        .location_on,
                                    color: Colors
                                        .red,
                                  ),
                      ),
                    );
                  });
                },
              ),
            ),

            /// CONTINUE BUTTON
            Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: SizedBox(
                width:
                    double.infinity,
                height: 55,
                child: ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors
                            .deepPurple,
                  ),

                  onPressed: () {

                    if (controller
                            .selectedAddress
                            .value ==
                        null) {

                      Get.snackbar(
                        "Error",
                        "Please select an address",
                      );

                      return;
                    }

                    Get.toNamed(
                      "/order-summary",
                    );
                  },

                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}