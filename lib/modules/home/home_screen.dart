import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/appdrawer/app_drawer.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'package:tin/modules/location/location_bottom_sheet.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/order/order_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart';
import 'package:tin/modules/order/rider_progres_bar.dart';

import 'widgets/banner_slider.dart';
import 'widgets/category_grid.dart';
import 'widgets/product_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  final locationController =
      Get.put(LocationController());

  final homeController =
      Get.put(HomeController());

  final cartController =
      Get.find<CartController>();

  final auth =
      Get.find<AuthController>();

  final lang =
      Get.find<LanguageController>();

  final orderController =
      Get.find<OrderController>();

  final trackingController =
      Get.find<OrderTrackingController>(); 
  
  List<ProductModel> get flashProducts => homeController.products
    .where((p) => p.isFlashSale)
    .toList();
      
  @override
  void initState() {
    super.initState();

    initTracking();
  }

  Future<void> initTracking() async {
    if (!auth.isLoggedIn.value) {
      return;
    }

    await orderController.loadActiveOrders();

    if (orderController
        .selectedOrderId
        .value
        .isNotEmpty) {
      trackingController.startTracking(
        orderController.selectedOrderId.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AppDrawer(),

      appBar: AppBar(
        elevation: 0,
        title: Obx(
          () => InkWell(
            onTap: () {
              Get.bottomSheet(
                const LocationBottomSheet(),
                backgroundColor:
                    Colors.white,
                isScrollControlled: true,
              );
            },
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color:
                      Colors.deepPurple,
                  size: 20,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  locationController
                      .currentLocation,
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
            builder: (context) =>
                IconButton(
              onPressed: () {
                Scaffold.of(context)
                    .openEndDrawer();
              },
              icon: const Icon(
                Icons.menu,
              ),
            ),
          ),
        ],
      ),

      body: Obx(() {

        return Stack(
          children: [

            /// ================= MAIN CONTENT =================

            RefreshIndicator(
              onRefresh: () async {
                await homeController
                    .loadHomeData();

                await orderController
                    .loadActiveOrders();
              },
              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(
                        12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    if (homeController
                        .banners
                        .isNotEmpty)
                      BannerSlider(
                        banners:
                            homeController
                                .banners,
                      ),

                    const SizedBox(
                        height: 20),

                    CategoryGrid(
                      categories:
                          homeController
                              .categories,
                    ),

                    const SizedBox(
                        height: 20),

                    ProductSection(
                      title: lang
                                  .currentLanguage
                                  .value ==
                              "bn"
                          ? "জনপ্রিয় পণ্য"
                          : "Popular Products",
                      products:
                          homeController
                              .products,
                    ),

                    const SizedBox(
                        height: 20),


                      if (flashProducts.isNotEmpty) ...[
                        ProductSection(
                          title: "Flash Sale",
                          products: flashProducts,
                        ),

                        const SizedBox(height: 20),
                      ],

                    const SizedBox(
                        height: 20),

                    ProductSection(
                      title:
                          "Fresh Product",
                      products:
                          homeController
                              .products
                              .where(
                                (p) =>
                                    p.productType ==
                                    "fresh",
                              )
                              .toList(),
                    ),

                    const SizedBox(
                        height: 20),

                    ProductSection(
                      title:
                          "Regular Product",
                      products:
                          homeController
                              .products
                              .where(
                                (p) =>
                                    p.productType ==
                                    "regular",
                              )
                              .toList(),
                    ),

                    const SizedBox(
                      height: 120,
                    ),
                  ],
                ),
              ),
            ),

Obx(() {
  final showLoader =
      homeController.isLoading.value ||
      homeController.isRefreshing.value;

  if (!showLoader) {
    return const SizedBox();
  }

  return Positioned.fill(
    child: IgnorePointer(
      child: Container(
        color: Colors.black.withOpacity(0.05),
        child: const Center(
          child: AppLoader(),
        ),
      ),
    ),
  );
}),

            /// ================= TRACKING BAR =================

            Obx(() {

              if (!auth.isLoggedIn.value) {
                return const SizedBox();
              }

              if (!orderController
                  .hasActiveOrder
                  .value) {
                return const SizedBox();
              }

              if (!trackingController
                  .trackingEnabled
                  .value) {
                return const SizedBox();
              }

              return Positioned(
                left: 15,
                right: 15,
                bottom: 20,
                child: orderController
                        .isTrackingMinimized
                        .value

                    /// MINIMIZED
                    ? Align(
                        alignment:
                            Alignment
                                .bottomRight,
                        child:
                            GestureDetector(
                          onTap: () {
                            orderController
                                .isTrackingMinimized
                                .value = false;
                          },
                          child:
                              Container(
                            width: 55,
                            height: 55,
                            decoration:
                                const BoxDecoration(
                              color: Colors
                                  .green,
                              shape: BoxShape
                                  .circle,
                            ),
                            child:
                                const Icon(
                              Icons
                                  .delivery_dining,
                              color: Colors
                                  .white,
                            ),
                          ),
                        ),
                      )

                    /// EXPANDED
                    : Stack(
                        children: [

                          const RiderProgressLine(),

                          Positioned(
                            top: 5,
                            right: 5,
                            child:
                                GestureDetector(
                              onTap: () {
                                orderController
                                    .isTrackingMinimized
                                    .value = true;
                              },
                              child:
                                  Container(
                                width:
                                    28,
                                height:
                                    28,
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Colors.grey,
                                  shape:
                                      BoxShape.circle,
                                ),
                                child:
                                    const Icon(
                                  Icons.close,
                                  size: 16,
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ],
        );
      }),

      bottomNavigationBar:
          AppBottomNavBar(
        cartController:
            cartController,
      ),
    );
  }
}