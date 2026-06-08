import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/address/address_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';

import 'order_controller.dart';

class OrderSummaryPage
    extends StatelessWidget {

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
        Get.find<
            AddressController>();

    final location =
        Get.find<
            LocationController>();

    final order =
        Get.put(
      OrderController(),
    );

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          "Order Summary",
        ),
      ),

      body: Column(

        children: [

          /// ADDRESS
          Container(

            width:
                double.infinity,

            margin:
                const EdgeInsets.all(
              12,
            ),

            padding:
                const EdgeInsets.all(
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
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  address
                          .selectedAddress
                          .value
                          ?.fullName ??
                      "",
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                Text(
                  address
                          .selectedAddress
                          .value
                          ?.phoneNumber ??
                      "",
                ),

                Text(
                  address
                          .selectedAddress
                          .value
                          ?.addressLine ??
                      "",
                ),
              ],
            ),
          ),

          /// PRODUCTS
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

                return ListTile(

                  leading:
                      Image.network(
                    item.image,
                    width: 50,
                  ),

                  title:
                      Text(
                    item.title,
                  ),

                  subtitle:
                      Text(
                    "Qty ${item.quantity}",
                  ),

                  trailing:
                      Text(
                    "৳${item.price * item.quantity}",
                  ),
                );
              },
            ),
          ),

          /// TOTAL
          Container(

            padding:
                const EdgeInsets.all(
              16,
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
                      "Delivery",
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
                      ),
                    ),

                    Text(
                      "৳${cart.grandTotal.toStringAsFixed(0)}",
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
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

                    height:
                        55,

                    child:
                        ElevatedButton(

                      onPressed:
                          order
                                  .isLoading
                                  .value
                              ? null
                              : () {

                                  order
                                      .placeOrder(
                                    address
                                        .selectedAddress
                                        .value!
                                        .id,
                                  );
                                },

                      child:
                          order
                                  .isLoading
                                  .value
                              ? const CircularProgressIndicator()
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