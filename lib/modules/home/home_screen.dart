import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';

import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/appdrawer/app_drawer.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/location/location_bottom_sheet.dart';
import 'package:tin/modules/location/location_controller.dart';

import 'widgets/banner_slider.dart';
import 'widgets/category_grid.dart';
import 'widgets/product_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final locationController =
        Get.put(
      LocationController(),
    );

    final homeController =
        Get.put(
      HomeController(),
    );

   final cartController =
    Get.find<CartController>();
    
   final lang = Get.find<LanguageController>();

    return Scaffold(
  endDrawer: AppDrawer(),

  appBar: AppBar(
    elevation: 0,

    title: Obx(
      () => InkWell(
        onTap: () {
          Get.bottomSheet(
            const LocationBottomSheet(),
            backgroundColor: Colors.white,
            isScrollControlled: true,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.deepPurple,
              size: 20,
            ),
            const SizedBox(width: 5),
            Text(
              locationController.currentLocation,
            ),
            const Icon(
              Icons.keyboard_arrow_down,
            ),
          ],
        ),
      ),
    ),

    actions: [
      Builder(
        builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context)
                  .openEndDrawer();
            },
            icon: const Icon(
              Icons.menu,
            ),
          );
        },
      ),
    ],
  ),


      body: Obx(
        () {
          if (homeController
              .isLoading
              .value) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await homeController
                  .loadHomeData();
            },
            child:
                SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.all(
                12,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  /// Banner
                  if (homeController
                      .banners
                      .isNotEmpty)
                    BannerSlider(
                      banners:
                          homeController
                              .banners,
                    ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// Categories
                  
                    Obx(() {
                      if (homeController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return CategoryGrid(
                        categories: homeController.categories,
                      );
                    }),

                  const SizedBox(
                    height: 20,
                  ),

                  /// Popular Products
                  ProductSection(
                    title: lang.currentLanguage.value == "bn"
                            ? "জনপ্রয় পণ্য"
                            : "Popular Products",
                    products:
                        homeController
                            .products,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ProductSection(
                    title: lang.currentLanguage.value == "bn"
                            ? "সল্প মূল্যে"
                            : "flash sale",
                    products: homeController.products
                        .where((p) => p.isFlashSale)
                        .toList(),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// Fresh Products
                  ProductSection(
                    title: lang.currentLanguage.value == "bn"
                            ? "তাজা পণ্য"
                            : "fresh product",
                    products: homeController.products
                        .where((p) => p.productType == "fresh")
                        .toList(),
                  ),
                  
                  const SizedBox(
                    height: 20,
                  ),

                  /// regular Products
                  ProductSection(
                    title: lang.currentLanguage.value == "bn"
                            ? "সবসময় এ পণ্য "
                            : "regular product",
                    products: homeController.products
                        .where((p) => p.productType == "regular")
                        .toList(),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  
                  ProductSection(
                      title: lang.currentLanguage.value == "bn"
                            ? "ফল"
                            : "Fruits",
                    products: homeController.products
                        .where(
                          (p) =>
                              p.categoryName
                                  .toLowerCase() ==
                              "fruits",
                        )
                        .toList(),
                        
                  ),
                ],
              ),
            ),
          );
        },
      ),

bottomNavigationBar: AppBottomNavBar(
  cartController: cartController,
),
    );
  }
}