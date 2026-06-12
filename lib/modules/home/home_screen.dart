import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';

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
                    title:
                        "Popular Products",
                    products:
                        homeController
                            .products,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// Flash Sale
                  ProductSection(
                    title:
                        "Flash Sale",
                    products:
                        homeController
                            .products,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// Fresh Products
                  ProductSection(
                    title:
                        "Fresh Vegetables",
                    products:
                        homeController
                            .products,
                  ),

                  const SizedBox(
                    height: 20,
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