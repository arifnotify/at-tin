import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final lang = Get.find<LanguageController>();

    final currentPrice = product.currentPrice;
    final hasDiscount = product.hasDiscount;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.productDetails,
          arguments: product,
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                /// IMAGE + CART
                SizedBox(
                  height: 140,
                  child: Stack(
                    children: [
                      Center(
                        child: Image.network(
                          product.images.isNotEmpty
                              ? product.images.first
                              : "",
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),

                      /// FLASH SALE BADGE
                      if (product.isFlashSale)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "FLASH SALE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      /// CART BUTTON
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Obx(() {
                          final item =
                              cartController.getItem(
                            product.id,
                          );
                          /// ADD BUTTON
                          if (item == null) {
                            return GestureDetector(
                              onTap: () {
                                cartController
                                    .addToCart(product);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        const Color(
                                      0xff7B3FE4,
                                    ),
                                    width: 2,
                                  ),
                                  color:
                                      Colors.white,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 22,
                                  color:
                                      Color(
                                    0xff7B3FE4,
                                  ),
                                ),
                              ),
                            );
                          }

                          /// QTY BADGE
                          if (!item.isEditing) {
                            return GestureDetector(
                              onTap: () {
                                cartController
                                    .showControls(
                                  product.id,
                                );
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration:
                                    const BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  color:
                                      Color(
                                    0xff7B3FE4,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    item.quantity
                                        .toString(),
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          /// FULL CONTROL
                          return Container(
                            width: 120,
                            height: 36,
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 5,
                                  color:
                                      Colors.black12,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                /// MINUS
                                Expanded(
                                  child: InkWell(
                                    borderRadius:
                                        const BorderRadius.only(
                                      topLeft:
                                          Radius.circular(
                                        20,
                                      ),
                                      bottomLeft:
                                          Radius.circular(
                                        20,
                                      ),
                                    ),
                                    onTap: () {
                                      cartController
                                          .decrement(
                                        product.id,
                                      );
                                    },
                                    child:
                                        const Center(
                                      child: Icon(
                                        Icons.remove,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),

                                Text(
                                  item.quantity
                                      .toString(),
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                /// PLUS
                                Expanded(
                                  child: InkWell(
                                    borderRadius:
                                        const BorderRadius.only(
                                      topRight:
                                          Radius.circular(
                                        20,
                                      ),
                                      bottomRight:
                                          Radius.circular(
                                        20,
                                      ),
                                    ),
                                    onTap: () {
                                      cartController
                                          .increment(
                                        product.id,
                                      );
                                    },
                                    child:
                                        const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 20,
                                        color:
                                            Color(
                                          0xff7B3FE4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                /// PRICE
                Row(
                  children: [
                    Text(
                      "৳${currentPrice.toInt()}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xffFF6B6B),
                      ),
                    ),

                    const SizedBox(width: 5),

                    if (hasDiscount)
                      Text(
                        "৳${product.price.toInt()}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          decoration:
                              TextDecoration
                                  .lineThrough,
                        ),
                      ),

                    const Spacer(),

                    if (product.discountPercent >
                        0)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.green,
                          borderRadius:
                              BorderRadius.circular(
                            4,
                          ),
                        ),
                        child: Text(
                          "-${product.discountPercent}%",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                /// TITLE
                Obx(() {
                return Text(
                  lang.isBangla
                      ? product.titleBn
                      : product.titleEn,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),

                const Spacer(),

                /// BOTTOM
                              /// BOTTOM
                Row(
                  children: [
                    /// UNIT (LEFT SIDE)
                    Text(
                      product.unit?.isNotEmpty == true
                          ? product.unit!
                          : "1 pcs",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    /// ICON + TEXT (RIGHT SIDE)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.productType == "fresh"
                              ? Icons.access_time
                              : Icons.event,
                          size: 14,
                          color: product.productType == "fresh"
                              ? Colors.green
                              : Colors.orange,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          product.productType == "fresh"
                              ? (product.freshText ?? "Fresh")
                              : (product.expiryText ?? ""),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:  TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}