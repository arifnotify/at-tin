import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tin/modules/address/address_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';

import 'order_controller.dart';

class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final cart =
        Get.find<CartController>();

    final address =
        Get.find<AddressController>();

    final location =
        Get.find<LocationController>();

    final order =
        Get.put(
      OrderController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Summary",
        ),
      ),

      body: Column(
        children: [

          /// ADDRESS
          Obx(
            () {
              final selected =
                  address
                      .selectedAddress
                      .value;

              if (selected ==
                  null) {
                return Container(
                  width:
                      double.infinity,
                  margin:
                      const EdgeInsets
                          .all(
                    12,
                  ),
                  padding:
                      const EdgeInsets
                          .all(
                    12,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .white,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    "No address selected",
                  ),
                );
              }

              return Container(
                width:
                    double.infinity,
                margin:
                    const EdgeInsets
                        .all(
                  12,
                ),
                padding:
                    const EdgeInsets
                        .all(
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors
                          .black12,
                      blurRadius:
                          5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    const Text(
                      "Delivery Address",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            16,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      selected
                          .fullName,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    Text(
                      selected
                          .phoneNumber,
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      selected
                          .areaOrVillage,
                    ),

                    Text(
                      "📍 ${selected.landmark}",
                    ),

                    if ((selected
                                .directionNote ??
                            "")
                        .isNotEmpty)
                      Text(
                        selected
                            .directionNote!,
                      ),
                  ],
                ),
              );
            },
          ),

          /// PRODUCT LIST
          Expanded(
            child:
                ListView.builder(
              itemCount:
                  cart.cartItems
                      .length,
              itemBuilder:
                  (
                context,
                index,
              ) {

                final item =
                    cart.cartItems[
                        index];

                return Card(
                  margin:
                      const EdgeInsets
                          .symmetric(
                    horizontal:
                        12,
                    vertical: 4,
                  ),
                  child:
                      ListTile(
                    leading:
                        Image.network(
                      item.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit
                          .cover,
                    ),

                    title: Text(
                      item.title,
                    ),

                    subtitle:
                        Text(
                      "Qty: ${item.quantity}",
                    ),

                    trailing:
                        Text(
                      "৳${(item.price * item.quantity).toStringAsFixed(0)}",
                    ),
                  ),
                );
              },
            ),
          ),

          /// TOTAL SECTION
          Container(
            padding:
                const EdgeInsets
                    .all(
              16,
            ),
            decoration:
                const BoxDecoration(
              color:
                  Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors
                      .black12,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [

                    const Text(
                      "Subtotal",
                    ),

                    Text(
                      "৳${cart.totalPrice.toStringAsFixed(0)}",
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [

                    const Text(
                      "Delivery Charge",
                    ),

                    Text(
                      "৳${location.deliveryCharge.value}",
                    ),
                  ],
                ),

                const Divider(),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [

                    const Text(
                      "Total",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            16,
                      ),
                    ),

                    Text(
                      "৳${cart.grandTotal.toStringAsFixed(0)}",
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                Obx(
                  () =>
                      SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        ElevatedButton(
                      onPressed: order
                              .isLoading
                              .value
                          ? null
                          : () {

                              if (address
                                      .selectedAddress
                                      .value ==
                                  null) {

                                Get.snackbar(
                                  "Error",
                                  "Please select an address",
                                );

                                return;
                              }

                              order
                                  .placeOrder(
                                address
                                    .selectedAddress
                                    .value!
                                    .id,
                              );
                            },

                      child: order
                              .isLoading
                              .value
                          ? const SizedBox(
                              height:
                                  20,
                              width:
                                  20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Text(
                              "Cash On Delivery",
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}