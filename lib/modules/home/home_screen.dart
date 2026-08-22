import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/appdrawer/app_drawer.dart';
import 'package:tin/modules/home/category/products_page.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'package:tin/modules/location/location_bottom_sheet.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/order/order_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart';
import 'package:tin/modules/order/rider_progres_bar.dart';
import 'package:tin/modules/reward/reward_controller.dart';
import 'package:tin/modules/support/user_help_section.dart';

import 'widgets/banner_slider.dart';
import 'widgets/category_grid.dart';
import 'widgets/product_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // AppBinding এ যেহেতু সব Register করা আছে, তাই সহজে Get.find() দিয়ে ধরা হলো
  final rewardController = Get.find<RewardController>();
  final locationController = Get.find<LocationController>();
  final homeController = Get.find<HomeController>();
  final cartController = Get.find<CartController>();
  final auth = Get.find<AuthController>();
  final lang = Get.find<LanguageController>();
  final orderController = Get.find<OrderController>();
  final trackingController = Get.find<OrderTrackingController>();

  final RxBool _isDrawerOpen = false.obs;

  List<ProductModel> get flashProducts => homeController.products
      .where((p) => p.isFlashSale)
      .toList();

  @override
  void initState() {
    super.initState();
    
    // ফ্রেম রেন্ডার হওয়ার পর সেফলি ব্যাকগ্রাউন্ড ডাটা ফেচিং ট্রিগার
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initTracking();
      loadRewardBalance();
      loadRewardTransactions();
    });

    // সাইলেন্ট ব্যাকগ্রাউন্ড রিওয়ার্ড সিঙ্ক
    ever(auth.isLoggedIn, (isLogged) {
      if (isLogged) {
        loadRewardBalance();
        loadRewardTransactions();
      }
    });
  }

  Future<void> initTracking() async {
    if (!auth.isLoggedIn.value) return;

    await orderController.loadActiveOrders();

    if (orderController.selectedOrderId.value.isNotEmpty) {
      trackingController.startTracking(
        orderController.selectedOrderId.value,
      );
    }
  }

  // ================= SILENT REWARD FETCHING =================
  Future<void> loadRewardBalance() async {
    if (!auth.isLoggedIn.value) return;

    final userId = auth.user['_id'] ?? auth.user['id'] ?? '';
    final token = auth.box.read("token") ?? '';

    if (userId.toString().isNotEmpty && token.toString().isNotEmpty) {
      await rewardController.loadBalance(userId.toString(), token.toString());
    }
  }

  Future<void> loadRewardTransactions() async {
    if (!auth.isLoggedIn.value) return;

    final userId = auth.user['_id'] ?? auth.user['id'] ?? '';
    final token = auth.box.read("token") ?? '';

    if (userId.toString().isNotEmpty && token.toString().isNotEmpty) {
      await rewardController.loadTransactions(userId.toString(), token.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: null,

      // সিঙ্গেল Root Obx
      body: Obx(() {
        return Stack(
          children: [
            /// ================= MAIN CONTENT =================
            Column(
              children: [
                /// --- CUSTOM APPBAR ---
AppBar(
  elevation: 0,
  backgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: Colors.black),
  title: Row(
    children: [
      /// LOCATION (ডাইরেক্ট ডাটাবেজ থেকে ডাটা আসবে)
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Get.bottomSheet(
                const LocationBottomSheet(),
                backgroundColor: Colors.white,
                isScrollControlled: true,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 4),

                  Flexible(
                    child: Obx(() {
                      final languageController = Get.find<LanguageController>();
                      final locationController = Get.find<LocationController>();
                      final isBangla = languageController.isBangla;

                      // কোনো ডিফল্ট ফিক্সড স্ট্রিম বা 'লোকেশন নির্বাচন করুন' থাকবে না
                      // ইউজারের পছন্দ করা ডিস্ট্রিক্ট অথবা ডাটাবেজের প্রথম ডিস্ট্রিক্ট বসবে
                      String displayLocation = "";

                      if (isBangla) {
                        if (locationController.selectedDistrictBn.value.isNotEmpty) {
                          displayLocation = locationController.selectedDistrictBn.value;
                        } else if (locationController.locations.isNotEmpty) {
                          displayLocation = locationController.locations.first.district.bn;
                        }
                      } else {
                        if (locationController.selectedDistrictEn.value.isNotEmpty) {
                          displayLocation = locationController.selectedDistrictEn.value;
                        } else if (locationController.locations.isNotEmpty) {
                          displayLocation = locationController.locations.first.district.en;
                        }
                      }

                      return Text(
                        displayLocation,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                  const SizedBox(width: 2),

                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      /// REWARD BADGE
      const SizedBox(width: 6),
      Obx(() {
        if (!auth.isLoggedIn.value) return const SizedBox.shrink();

        return Material(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => showRewardTransactions(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${rewardController.balance.value.toStringAsFixed(0)} ৳",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ],
  ),
  actions: [
    Obx(() => IconButton(
      onPressed: () {
        _isDrawerOpen.value = !_isDrawerOpen.value;
      },
      icon: Icon(
        _isDrawerOpen.value ? Icons.close_rounded : Icons.menu_rounded,
        color: Colors.black,
      ),
    )),
  ],
),
                /// --- BODY SCROLLABLE CONTENT ---
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    strokeWidth: 0,
                    onRefresh: () async {
                      // ম্যানুয়ালি লোডার ট্রিগার করা হচ্ছে
                      homeController.isRefreshing.value = true;
                      try {
                        await homeController.refreshHome();
                        await orderController.loadActiveOrders();
                        await loadRewardBalance();
                        await loadRewardTransactions();
                      } finally {
                        // রিফ্রেশ শেষ হলে লোডার বন্ধ করা হচ্ছে
                        homeController.isRefreshing.value = false;
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (homeController.banners.isNotEmpty)
                            BannerSlider(banners: homeController.banners),

                          const SizedBox(height: 10),
                          CategoryGrid(categories: homeController.categories),
                          
                          /// 🟢 POPULAR PRODUCTS SECTION
                          const SizedBox(height: 15),
                          ProductSection(
                            title: lang.currentLanguage.value == "bn" ? "জনপ্রিয় পণ্য" : "Popular Products",
                            products: homeController.products,
                            onMoreTap: () {
                              Get.to(() => ProductsPage(
                                title: lang.currentLanguage.value == "bn" ? "জনপ্রিয় পণ্য" : "Popular Products",
                                products: homeController.products,
                              ));
                            },
                          ),

                          /// 🟢 FLASH SALE SECTION
                          const SizedBox(height: 15),
                          if (flashProducts.isNotEmpty) ...[
                            ProductSection(
                              title: lang.currentLanguage.value == "bn" ? "স্বল্প মূল্যে" : "Flash Sale", 
                              products: flashProducts,
                              onMoreTap: () {
                                Get.to(() => ProductsPage(
                                  title: lang.currentLanguage.value == "bn" ? "স্বল্প মূল্যে" : "Flash Sale",
                                  products: flashProducts,
                                ));
                              },
                            ),
                            const SizedBox(height: 15),
                          ],

                          /// 🟢 FRESH PRODUCT SECTION
                          const SizedBox(height: 15),
                          ProductSection(
                            title: lang.currentLanguage.value == "bn" ? "তাজা পণ্য" : "Fresh Product",
                            products: homeController.products.where((p) => p.productType == "fresh").toList(),
                            onMoreTap: () {
                              final freshProducts = homeController.products.where((p) => p.productType == "fresh").toList();
                              Get.to(() => ProductsPage(
                                title: lang.currentLanguage.value == "bn" ? "তাজা পণ্য" : "Fresh Product",
                                products: freshProducts,
                              ));
                            },
                          ),
                          const SizedBox(height: 15),
                          ...homeController.categories.map((mainCategory) {
                            final categoryProducts = homeController.products.where((product) {
                              final parentCategoryId =
                                  product.category?["parentCategory"]?.toString() ?? "";
                              return parentCategoryId == mainCategory.id;
                            }).toList();
                            
                            if (categoryProducts.isEmpty) {
                              return const SizedBox();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProductSection(
                                  title: mainCategory.localizedName,
                                  products: categoryProducts,
                                  onMoreTap: () {
                                    Get.to(
                                      () => ProductsPage(
                                        title: mainCategory.localizedName,
                                        products: categoryProducts,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 15),
                              ],
                            );
                          }).toList(),

                          /// 🟢 REGULAR PRODUCT SECTION
                          const SizedBox(height: 15),
                          ProductSection(
                            title: lang.currentLanguage.value == "bn" ? "দৈনন্দিন পণ্য " : "Regular Product",
                            products: homeController.products.where((p) => p.productType == "regular").toList(),
                            onMoreTap: () {
                              final regularProducts = homeController.products.where((p) => p.productType == "regular").toList();
                              Get.to(() => ProductsPage(
                                title: lang.currentLanguage.value == "bn" ? "দৈনন্দিন পণ্য " : "Regular Product",
                                products: regularProducts,
                              ));
                            },
                          ),
                          const UserHelpSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// ================= LOADER LAYER =================
            if (homeController.isLoading.value || homeController.isRefreshing.value)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(child: AppLoader()),
                  ),
                ),
              ),

            /// ================= TRACKING BAR LAYER =================
            if (auth.isLoggedIn.value && orderController.hasActiveOrder.value && trackingController.trackingEnabled.value)
              Positioned(
                left: 15,
                right: 15,
                bottom: 20,
                child: orderController.isTrackingMinimized.value
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            orderController.isTrackingMinimized.value = false;
                          },
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delivery_dining, color: Colors.white),
                          ),
                        ),
                      )
                    : Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 12, right: 15),
                            child: RiderProgressLine(),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                orderController.isTrackingMinimized.value = true;
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

            /// ================= CUSTOM DRAWERS =================
            if (_isDrawerOpen.value)
              Positioned(
                top: statusBarHeight,
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _isDrawerOpen.value = false,
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),
              ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: statusBarHeight,
              bottom: 0,
              right: _isDrawerOpen.value ? 0 : -MediaQuery.of(context).size.width * 0.75,
              width: MediaQuery.of(context).size.width * 0.75,
              child: Material(
                elevation: 16,
                child: AppDrawer(),
              ),
            ),
          ],
        );
      }),

      bottomNavigationBar: AppBottomNavBar(
        cartController: cartController,
      ),
    );
  }

  /// ================= REWARD TRANSACTIONS BOTTOM SHEET =================
  void showRewardTransactions(BuildContext context) {
    loadRewardTransactions();
    final bool isBn = lang.currentLanguage.value == "bn";

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? "রিওয়ার্ড লেনদেন" : "Reward Transactions",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                            "৳${rewardController.balance.value.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              Expanded(
                child: Obx(() {
                  if (rewardController.txLoading.value && rewardController.transactions.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.green));
                  }

                  if (rewardController.transactions.isEmpty) {
                    return Center(
                      child: Text(
                        isBn ? "কোনো লেনদেনের ইতিহাস পাওয়া যায়নি" : "No transactions found",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: rewardController.transactions.length,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, index) {
                      final tx = rewardController.transactions[index];

                      final String rawType = (tx["type"] ?? tx["transactionType"] ?? "EARN").toString().toUpperCase();
                      final bool earn = rawType == "EARN" || rawType == "CREDIT";

                      final num rawAmount = tx["amount"] ?? tx["points"] ?? 0;
                      final String formattedAmount = rawAmount.toDouble().toStringAsFixed(2);

                      final String description = tx["description"] ?? tx["title"] ?? tx["note"] ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade200, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: earn ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              child: Icon(
                                earn ? Icons.add : Icons.remove,
                                color: earn ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "৳$formattedAmount",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    description,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: earn ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                earn
                                    ? (isBn ? "অর্জিত" : "EARN")
                                    : (isBn ? "ব্যবহৃত" : "REDEEM"),
                                style: TextStyle(
                                  color: earn ? Colors.green.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}