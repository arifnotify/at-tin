import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/core/routes/app_routes.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState
    extends State<ProductDetailsPage> {
  late ProductModel product;
  late CartController cartController;
  final lang = Get.find<LanguageController>();

  int quantity = 0;
  int currentImage = 0;

  @override
  void initState() {
    super.initState();

    product = Get.arguments;
    cartController = Get.find<CartController>();

    final item =
        cartController.getItem(product.id);

    if (item != null) {
      quantity = item.quantity;
    }
  }

  void syncCart() {
    final item =
        cartController.getItem(product.id);

    if (item == null) {
      cartController.addToCart(product);
      final newItem =
          cartController.getItem(product.id);

      if (newItem != null) {
        newItem.quantity = quantity;
        cartController.cartItems.refresh();
      }
    } else {
      item.quantity = quantity;
      cartController.cartItems.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.black),
        title: Obx(
          () => Text(
            lang.isBangla
                ? product.titleBn
                : product.titleEn,

            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// IMAGE SLIDER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      itemCount:
                          product.images.isNotEmpty
                              ? product.images.length
                              : 1,
                      onPageChanged: (i) {
                        setState(() {
                          currentImage = i;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          product.images.isNotEmpty
                              ? product
                                  .images[index]
                              : "",
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DOT INDICATOR
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      product.images.isNotEmpty
                          ? product.images.length
                          : 1,
                      (index) => Container(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentImage ==
                                  index
                              ? Colors.purple
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// DETAILS
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Obx(
                      () => Text(
                        lang.isBangla
                            ? product.titleBn
                            : product.titleEn,

                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        "৳${product.currentPrice.toInt()}",
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.red,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      if (product.hasDiscount)
                        Text(
                          "৳${product.price.toInt()}",
                          style: const TextStyle(
                            decoration:
                                TextDecoration
                                    .lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.unit ?? "1 pcs",
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// FRESH / EXPIRY
                  Row(
                    children: [
                      Icon(
                        product.productType ==
                                "fresh"
                            ? Icons.access_time
                            : Icons.event,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.productType ==
                                "fresh"
                            ? (product.freshText ??
                                "Fresh")
                            : (product.expiryText ??
                                ""),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// BUY + QTY
                  Row(
                    children: [

                      /// BUY NOW
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.offAllNamed(
                                  AppRoutes.home);
                            },
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green,
                            ),
                            child: const Text(
                              "Buy Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// QTY CONTROL
                      Container(
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Row(
                          children: [

                            IconButton(
                              onPressed: () {
                                if (quantity > 0) {
                                  setState(() {
                                    quantity--;
                                  });
                                  syncCart();
                                }
                              },
                              icon: const Icon(
                                Icons.remove,
                              ),
                            ),

                            Text(
                              quantity.toString(),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                                syncCart();
                              },
                              icon: const Icon(
                                Icons.add,
                                color:
                                    Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => Text(
                      lang.isBangla
                          ? product.descriptionBn
                          : product.descriptionEn,

                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}