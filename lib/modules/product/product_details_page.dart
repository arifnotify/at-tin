import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
  });

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState
    extends State<ProductDetailsPage> {
  late ProductModel product;

  final lang = Get.find<LanguageController>();

  final cartController =
      Get.find<CartController>();

  int currentImage = 0;

  @override
  void initState() {
    super.initState();

    product = Get.arguments;
  }

  // =========================================================
  // YOUTUBE
  // =========================================================

  Future<void> openYoutube(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF6F6F6),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // TITLE
                  // =================================================

                  Padding(
                    padding:
                        const EdgeInsets.all(
                      10,
                    ),
                    child: Obx(
                      () => Text(
                        lang.isBangla
                            ? product.titleBn
                            : product.titleEn,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const Divider(
                    height: 1,
                  ),

                  // =================================================
                  // IMAGE
                  // =================================================

                  SizedBox(
                    height: 250,
                    child:
                        PageView.builder(
                      itemCount:
                          product.images
                                  .isEmpty
                              ? 1
                              : product
                                  .images
                                  .length,
                      onPageChanged:
                          (index) {
                        setState(() {
                          currentImage =
                              index;
                        });
                      },
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        return Padding(
                          padding:
                              const EdgeInsets
                                  .all(
                            20,
                          ),
                          child:
                              Image.network(
                            product
                                    .images
                                    .isNotEmpty
                                ? product
                                    .images[index]
                                : "",
                            fit: BoxFit
                                .contain,
                            errorBuilder:
                                (
                              _,
                              __,
                              ___,
                            ) {
                              return Icon(
                                Icons
                                    .image_not_supported,
                                size: 50,
                                color: Colors
                                    .grey
                                    .shade300,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // =================================================
                  // IMAGE DOTS
                  // =================================================

                  if (product.images
                          .length >
                      1)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children:
                            List.generate(
                          product.images
                              .length,
                          (index) =>
                              Container(
                            margin:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  3,
                            ),
                            width: 8,
                            height: 8,
                            decoration:
                                BoxDecoration(
                              shape: BoxShape
                                  .circle,
                              color: currentImage ==
                                      index
                                  ? Colors
                                      .purple
                                  : Colors
                                      .grey
                                      .shade300,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // =================================================
                  // PRICE + UNIT + FRESH/EXPIRY + YOUTUBE
                  // =================================================

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                    ),
                    child: Wrap(
                      crossAxisAlignment:
                          WrapCrossAlignment
                              .center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // PRICE
                        Text(
                          "৳${product.currentPrice.toInt()}",
                          style:
                              const TextStyle(
                            color: Colors.red,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        // OLD PRICE
                        if (product.hasDiscount)
                          Text(
                            "৳${product.price.toInt()}",
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                              decoration:
                                  TextDecoration
                                      .lineThrough,
                              fontSize: 18,
                            ),
                          ),

                        // UNIT
                        Text(
                          product.unit ?? "",
                          style:
                              const TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        // FRESH
                        if (product.productType ==
                                "fresh" &&
                            product.freshText !=
                                null &&
                            product.freshText!
                                .isNotEmpty)
                          Text(
                            product.freshText!,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                        // EXPIRY
                        if (product.productType !=
                                "fresh" &&
                            product.expiryText !=
                                null &&
                            product.expiryText!
                                .isNotEmpty)
                          Text(
                            product.expiryText!,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                        // YOUTUBE
                        if (product
                            .hasYoutubeVideo)
                          SizedBox(
                            height: 35,
                            child:
                                ElevatedButton
                                    .icon(
                              onPressed: () {
                                openYoutube(
                                  product
                                      .youtubeVideoUrl!,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .play_circle_fill,
                                size: 18,
                              ),
                              label:
                                  const Text(
                                "Video",
                                style:
                                    TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.red,
                                foregroundColor:
                                    Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =================================================
                  // BUY + CART
                  // =================================================

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                      children: [
                        // BUY NOW
                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed: () {
                              cartController
                                  .addToCart(
                                product,
                              );
                            },
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors
                                      .deepPurple,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  8,
                                ),
                              ),
                            ),
                            child:
                                const Text(
                              "Buy Now",
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        // CART CONTROL
                        Obx(
                          () {
                            final item =
                                cartController
                                    .getItem(
                              product.id,
                            );

                            final qty =
                                item?.quantity ??
                                    0;

                            // ADD
                            if (qty == 0) {
                              return IconButton(
                                onPressed: () {
                                  cartController
                                      .addToCart(
                                    product,
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons.add,
                                  color: Colors
                                      .deepPurple,
                                ),
                              );
                            }

                            // QUANTITY
                            return Container(
                              decoration:
                                  BoxDecoration(
                                border:
                                    Border.all(
                                  color: Colors
                                      .grey
                                      .shade300,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  6,
                                ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize
                                        .min,
                                children: [
                                  // MINUS
                                  IconButton(
                                    onPressed: () {
                                      cartController
                                          .decrement(
                                        product.id,
                                      );
                                    },
                                    icon:
                                        const Icon(
                                      Icons.remove,
                                    ),
                                  ),

                                  // QTY
                                  Text(
                                    qty.toString(),
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  // PLUS
                                  IconButton(
                                    onPressed: () {
                                      cartController
                                          .increment(
                                        product.id,
                                      );
                                    },
                                    icon:
                                        const Icon(
                                      Icons.add,
                                      color: Colors
                                          .purple,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =================================================
                  // COUNTRY
                  // DESCRIPTION এর ঠিক উপরে
                  // =================================================

// =========================================================
// COUNTRY
// DESCRIPTION এর ঠিক উপরে
// =========================================================

if (product.country != null &&
    product.countryName.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(
      left: 10,
      right: 10,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // COUNTRY FLAG
        Container(
          width: 22,
          height: 22,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              product.countryFlag,
              width: 18,
              height: 18,
              fit: BoxFit.cover,
              errorBuilder: (
                _,
                __,
                ___,
              ) {
                return const Icon(
                  Icons.flag,
                  size: 13,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 5),

        // COUNTRY NAME
        Text(
          product.countryName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xff444444),
          ),
        ),
      ],
    ),
  ),

const SizedBox(height: 8),

                  // =================================================
                  // GAP
                  // =================================================

                  if (product.country != null &&
                      product.countryName
                          .isNotEmpty)
                    const SizedBox(
                      height: 12,
                    ),

                  // =================================================
                  // DESCRIPTION
                  // =================================================

                  Padding(
                    padding:
                        const EdgeInsets
                            .all(
                      10,
                    ),
                    child: Obx(
                      () => Text(
                        lang.isBangla
                            ? product
                                .descriptionBn
                            : product
                                .descriptionEn,
                        style:
                            const TextStyle(
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
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