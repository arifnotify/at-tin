import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart'; // লোকেশন কন্ট্রোলার ইমপোর্ট নিশ্চিত করুন
import 'package:tin/modules/location/location_bottom_sheet.dart'; // লোকেশন বটম শিট ইমপোর্ট নিশ্চিত করুন

class AppBottomNavBar extends StatelessWidget {
  final CartController cartController;

  const AppBottomNavBar({
    super.key,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    // ভাষা কন্ট্রোলার
    final lang = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>()
        : Get.put(LanguageController());

    // ব্র্যান্ড থিম কালারসমূহ
    const Color primaryTheme = Color(0xFF1D4D33);
    const Color darkTheme = Color(0xFF143724);

    return Obx(
      () => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 70, // ফিক্সড ন্যানো স্ট্যান্ডার্ড হাইট
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                /// Checkout Button (যদি কার্টে আইটেম থাকে)
                if (cartController.totalItems > 0)
                  Expanded(
                    flex: 6,
                    child: InkWell(
                      onTap: () {
                        // 👉 লোকেশন চেক লজিক এখানে যুক্ত করা হলো
                        final locationController = Get.isRegistered<LocationController>()
                            ? Get.find<LocationController>()
                            : Get.put(LocationController());

                        final String locationId = locationController.currentLocationId;

                        // যদি লোকেশন সিলেক্ট করা না থাকে
                        if (locationId.isEmpty) {
                          // মেসেজ বা স্ন্যাকবার দেখানো
                          Get.snackbar(
                            lang.isBangla ? "লোকেশন প্রয়োজন" : "Location Required",
                            lang.isBangla
                                ? "দয়া করে চেকআউট করার আগে আপনার ডেলিভারি লোকেশন সিলেক্ট করুন।"
                                : "Please select your delivery location before checkout.",
                            backgroundColor: Colors.red.shade600,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 10,
                            duration: const Duration(seconds: 3),
                          );

                          // লোকেশন সিলেক্ট করার বটম শিট ওপেন করে দেওয়া
                          Get.bottomSheet(
                            const LocationBottomSheet(),
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                          );
                          return; // চেকআউট পেজে যাওয়া থামায়ে দিবে
                        }

                        // লোকেশন সিলেক্ট করা থাকলে সরাসরি কার্ট/চেকআউট পেজে যাবে
                        Get.toNamed(AppRoutes.cart);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryTheme,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            /// ১. মোট আইটেম সংখ্যা বাটন (কাউন্টার)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${cartController.totalItems}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 6),

                            /// ২. Checkout/চেকআউট টেক্সট
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  lang.isBangla ? "চেকআউট" : "Checkout",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            /// ৩. প্রাইসের ইনসাইড ডার্ক বক্স
                            Container(
                              decoration: BoxDecoration(
                                color: darkTheme,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Text(
                                "৳${cartController.totalPrice.toInt()}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // যদি কার্ট খালি থাকে, তবে স্পেস ধরে রাখার জন্য
                if (cartController.totalItems == 0) const Spacer(),

                const SizedBox(width: 4),

                /// Home Icon
/// Home Icon
Expanded(
  flex: 2,
  child: IconButton(
    onPressed: () {
      Get.offAllNamed(AppRoutes.home);
    },
    padding: EdgeInsets.zero,
    icon: const Icon(
      Icons.home_rounded,
      color: primaryTheme,
      size: 28,
    ),
  ),
),

                /// Category Icon
                Expanded(
                  flex: 2,
                  child: IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.allCategories),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),

                /// Search Icon
                Expanded(
                  flex: 2,
                  child: IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.search),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}