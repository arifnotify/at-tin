import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/address/address_page.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/auth/login_page.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {

    final locationController =  Get.find<LocationController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Checkout",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return const Center(
            child: Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return Column(
          children: [
            /// STEP BAR
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Row(
                children: [
                  _step(
                    title: "Review",
                    active: true,
                    number: "1",
                  ),

                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),

                  _step(
                    title: "Address",
                    active: false,
                    number: "2",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// CART ITEMS
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                itemCount:
                    cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item =
                      cartController.cartItems[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.04),
                          blurRadius: 8,
                          offset:
                              const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// IMAGE
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          child: Image.network(
                            item.image,
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                "৳${item.price}",
                                style:
                                    const TextStyle(
                                  color: Color(
                                    0xff7B3FE4,
                                  ),
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              /// QUANTITY
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                decoration:
                                    BoxDecoration(
                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                      0xff7B3FE4,
                                    ),
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    25,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                      final auth =
                                          Get.find<AuthController>();

                                      if (auth.isLoggedIn.value) {

                                        await cartController
                                            .decreaseServerQty(
                                          item.cartId!,
                                          item.quantity,
                                        );

                                      } else {

                                        cartController.decrement(
                                          item.id,
                                        );
                                      }
                                    },
                                      child:
                                          const Icon(
                                        Icons.remove,
                                        size: 18,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 24,
                                    ),

                                    Text(
                                      item.quantity
                                          .toString(),
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            16,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 24,
                                    ),

                                    GestureDetector(
                                      onTap: () async {

                                          final auth =
                                              Get.find<AuthController>();

                                          if (auth.isLoggedIn.value) {

                                            await cartController
                                                .increaseServerQty(
                                              item.cartId!,
                                              item.quantity,
                                            );

                                          } else {

                                            cartController.increment(
                                              item.id,
                                            );
                                          }
                                        },
                                      child:
                                          const Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Color(
                                          0xff7B3FE4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// TOTAL
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final auth =
                                    Get.find<AuthController>();

                                if (auth.isLoggedIn.value) {

                                  await cartController
                                      .cartService
                                      .removeItem(
                                    item.cartId!,
                                  );

                                  await cartController
                                      .loadServerCart();

                                } else {

                                  cartController.removeItem(
                                    item.id,
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),

                            const SizedBox(
                              height: 25,
                            ),

                            Text(
                              "৳${item.price * item.quantity}",
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// SUMMARY
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    "Items",
                    cartController.totalItems
                        .toString(),
                  ),

                  const SizedBox(height: 8),

                  _summaryRow(
                    "Subtotal",
                    "৳${cartController.totalPrice.toStringAsFixed(0)}",
                  ),

                  const SizedBox(height: 8),

                  _summaryRow(
                              "Delivery",
                              "৳${locationController.deliveryCharge.value}",
                            ),

                  const Divider(),

                  _summaryRow(
                          "Total",
                          "৳${cartController.grandTotal.toStringAsFixed(0)}",
                          bold: true,
                        ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xff7B3FE4,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                    onPressed: () {

                              final auth =
                                  Get.find<AuthController>();

                              if(auth.isLoggedIn.value){

                                Get.to(
                                  ()=> const AddressPage(),
                                );

                              }else{

                                Get.to(
                                  ()=> LoginPage(),
                                );

                              }
                            },
                      child: const Text(
                        "Continue to Address",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  static Widget _step({
    required String title,
    required bool active,
    required String number,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: active
              ? const Color(0xff7B3FE4)
              : Colors.grey.shade300,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active
                ? const Color(0xff7B3FE4)
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  static Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}