import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';

import 'search_controller.dart';

class SearchScreen
    extends GetView<
        ProductSearchController> {

  const SearchScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          "Search Products",
        ),
      ),

      body: Column(

        children: [

          Padding(
            padding:
                const EdgeInsets.all(
              12,
            ),

            child: TextField(

              autofocus: true,

              decoration:
                  InputDecoration(

                hintText:
                    "Search in Bangla or English",

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              onChanged:
                  controller
                      .onSearchChanged,
            ),
          ),

          Expanded(
            child: Obx(
              () {

                if (controller
                    .isLoading
                    .value) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (controller
                    .products
                    .isEmpty) {

                  return const Center(
                    child: Text(
                      "Search products...",
                    ),
                  );
                }

                return GridView.builder(

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  itemCount:
                      controller
                          .products
                          .length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount:
                        2,

                    crossAxisSpacing:
                        10,

                    mainAxisSpacing:
                        10,

                    childAspectRatio:
                        .68,
                  ),

                  itemBuilder:
                      (
                    context,
                    index,
                  ) {

                    final p =
                        controller
                            .products[index];

                    return GestureDetector(

                      onTap: () {

                        Get.toNamed(
                          AppRoutes
                              .productDetails,
                          arguments:
                              p,
                        );
                      },

                      child: Card(

                        elevation: 2,

                        shape:
                            RoundedRectangleBorder(
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

                            Expanded(

                              child:
                                  ClipRRect(

                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(
                                    12,
                                  ),
                                ),

                                child:
                                    Image.network(

                                  p.images
                                          .isNotEmpty
                                      ? p.images
                                          .first
                                      : "",

                                  fit:
                                      BoxFit.cover,

                                  width:
                                      double.infinity,

                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return const Center(
                                      child:
                                          Icon(
                                        Icons
                                            .image,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            Padding(

                              padding:
                                  const EdgeInsets.all(
                                8,
                              ),

                              child:
                                  Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    p.titleEn
                                            .isNotEmpty
                                        ? p.titleEn
                                        : p.titleBn,

                                    maxLines:
                                        2,

                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(

                                    "৳${p.currentPrice}",

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}