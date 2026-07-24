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
  final rewardController = Get.put(RewardController());
  final locationController = Get.put(LocationController());
  final homeController = Get.put(HomeController());
  final cartController = Get.find<CartController>();
  final auth = Get.find<AuthController>();
  final lang = Get.find<LanguageController>();
  final orderController = Get.find<OrderController>();
  final trackingController = Get.find<OrderTrackingController>(); 
  
  // ড্রয়ার ওপেন/ক্লোজ স্টেট ট্র্যাকিং ভেরিয়েবল
  final RxBool _isDrawerOpen = false.obs;

  List<ProductModel> get flashProducts => homeController.products
      .where((p) => p.isFlashSale)
      .toList();
      
  @override
  void initState() {
    super.initState();
    initTracking();
    loadRewardBalance(); 
    loadRewardTransactions(); 
  }

  Future<void> initTracking() async {
    if (!auth.isLoggedIn.value) {
      return;
    }

    await orderController.loadActiveOrders();

    if (orderController.selectedOrderId.value.isNotEmpty) {
      trackingController.startTracking(
        orderController.selectedOrderId.value,
      );
    }
  }

  Future<void> loadRewardBalance() async {
    if (!auth.isLoggedIn.value) return;

    final userId = auth.user['_id'] ?? '';
    final token = auth.box.read("token"); 

    await rewardController.loadBalance(
      userId,
      token,
    );
  }

  Future<void> loadRewardTransactions() async {
    if (!auth.isLoggedIn.value) return;

    final userId = auth.user['_id'] ?? '';
    final token = auth.box.read("token");

    await rewardController.loadTransactions(userId, token);
  }

  @override
  Widget build(BuildContext context) {
    // উপরের স্ট্যাটাস বারের (ঘড়ি, ব্যাটারি আইকন) উচ্চতা বের করা হলো
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      // ব্যাকগ্রাউন্ড কালার সাদা করা হলো
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      // ১. ড্রয়ার দিয়ে অ্যাপবারকে ঢেকে ফেলার জন্য AppBar-কে Scaffold থেকে সরিয়ে বডির Stack-এর ভেতর নিয়ে যাওয়া হলো
      appBar: null, 

      body: Obx(() {
        return Stack(
          children: [
            /// ================= ২. MAIN CONTENT (APPBAR + SCROLLABLE BODY) =================
            Column(
              children: [
                /// --- CUSTOM APPBAR ---
                AppBar(
                  elevation: 0,
                  // অ্যাপবারের ব্যাকগ্রাউন্ড কালার সাদা করা হলো
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.black),
                  title: Obx(
                    () => Row(
                      children: [
                        /// LOCATION
                        Expanded(
                          child: InkWell(
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
                                Flexible(
                                  child: Text(
                                    locationController.currentLocation,
                                    style: const TextStyle(color: Colors.black), // সাদা ব্যাকগ্রাউন্ডের জন্য কালো টেক্সট
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                              ],
                            ),
                          ),
                        ),

                        /// REWARD BADGE
                        const SizedBox(width: 10),
                        Obx(() {
                          if (!auth.isLoggedIn.value) return const SizedBox();
                          final reward = rewardController.balance.value;

                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => showRewardTransactions(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.card_giftcard, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${reward.toStringAsFixed(0)} ৳",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        _isDrawerOpen.value = !_isDrawerOpen.value;
                      },
                      icon: Icon(
                        _isDrawerOpen.value ? Icons.close : Icons.menu,
                        color: Colors.black, // সাদা ব্যাকগ্রাউন্ডের জন্য আইকন কালো করা হলো
                      ),
                    ),
                  ],
                ),

                /// --- BODY SCROLLABLE CONTENT ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await homeController.loadHomeData();
                      await orderController.loadActiveOrders();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (homeController.banners.isNotEmpty)
                            BannerSlider(banners: homeController.banners),

                          const SizedBox(height: 20),
                          CategoryGrid(categories: homeController.categories),

                          const SizedBox(height: 20),
                          ProductSection(
                            title: lang.currentLanguage.value == "bn" ? "জনপ্রিয় পণ্য" : "Popular Products",
                            products: homeController.products,
                          ),

                          const SizedBox(height: 20),
                          if (flashProducts.isNotEmpty) ...[
                            ProductSection(
                              title: "Flash Sale",
                              products: flashProducts,
                            ),
                            const SizedBox(height: 20),
                          ],

                          const SizedBox(height: 20),
                          ProductSection(
                            title: "Fresh Product",
                            products: homeController.products.where((p) => p.productType == "fresh").toList(),
                          ),

                          const SizedBox(height: 20),
                          ProductSection(
                            title: "Regular Product",
                            products: homeController.products.where((p) => p.productType == "regular").toList(),
                          ),
                          const SizedBox(height: 20),
                          const UserHelpSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// ================= ৩. LOADER LAYER =================
            Obx(() {
              final showLoader = homeController.isLoading.value;
              if (!showLoader) return const SizedBox();

              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.05),
                    child: const Center(child: AppLoader()),
                  ),
                ),
              );
            }),

            /// ================= ৪. TRACKING BAR LAYER =================
Obx(() {
  if (!auth.isLoggedIn.value) return const SizedBox();
  if (!orderController.hasActiveOrder.value) return const SizedBox();
  if (!trackingController.trackingEnabled.value) return const SizedBox();

  return Positioned(
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
            clipBehavior: Clip.none, // ক্রস আইকন যেন বাইরে সুন্দর দেখায়
            children: [
              // প্রোগ্রেস লাইনের ডানপাশে প্যাডিং দেওয়া হয়েছে যেন ক্রসের নিচে না পড়ে
              const Padding(
                padding: EdgeInsets.only(top: 12, right: 15),
                child: RiderProgressLine(),
              ),

              /// ================= CLOSE BUTTON =================
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
  );
}),

            /// ================= ৫. CUSTOM DRAWERS WITH EXACT BOUNDS =================
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

      // ৬. বটম নেভিগেশন বারটি Scaffold-এর নিজস্ব জায়গায় থাকায় ড্রয়ার কোনোভাবেই এর ওপরে ওভারল্যাপ করবে না
      bottomNavigationBar: AppBottomNavBar(
        cartController: cartController,
      ),
    );
  }

  /// ================= REWARD TRANSACTIONS SHEET =================
  void showRewardTransactions(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * .65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 15),
            const Text(
              "Reward Transactions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (rewardController.txLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (rewardController.transactions.isEmpty) {
                  return const Center(child: Text("No transactions found"));
                }

                return ListView.builder(
                  itemCount: rewardController.transactions.length,
                  itemBuilder: (_, index) {
                    final tx = rewardController.transactions[index];
                    final earn = tx["type"] == "EARN";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: earn ? Colors.green : Colors.red,
                        child: Icon(earn ? Icons.add : Icons.remove, color: Colors.white),
                      ),
                      title: Text("৳${tx["amount"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tx["description"] ?? ""),
                      trailing: Text(
                        tx["type"],
                        style: TextStyle(color: earn ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}