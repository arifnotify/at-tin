import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class AppBottomNavBar extends StatelessWidget {
  final CartController cartController;

  const AppBottomNavBar({
    super.key,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    // চালডাল থিমের বেগুনি কালার কোডসমূহ
    const Color primaryPurple = Color(0xFF9354ED); 
    const Color darkPurple = Color(0xFF6E28D9);

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
            height: 70, // বাটন এবং আইকনগুলোর জন্য ফিক্সড স্ট্যান্ডার্ড হাইট
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                /// Checkout Button (যদি কার্টে আইটেম থাকে)
                if (cartController.totalItems > 0)
                  Expanded(
                    flex: 5, // চেকআউট বাটনের রেসপন্সিভ স্পেস
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.cart);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// "Checkout" টেক্সটকে Flexible করা হয়েছে যেন ওভারফ্লো না হয়
                            const Flexible(
                              child: Text(
                                "Checkout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, // ছোট স্ক্রিনের জন্য সামঞ্জস্যপূর্ণ সাইজ
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // খুব ছোট স্ক্রিন হলে টেক্সট কেটে ৩টি ডট (...) আসবে
                              ),
                            ),
                            
                            const SizedBox(width: 4), // দুই উইজেটের মাঝের সেফ গ্যাপ

                            /// প্রাইসের জন্য ভেতরের ডার্ক বেগুনি বক্স
                            Container(
                              decoration: BoxDecoration(
                                color: darkPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, // প্যাডিং কিছুটা কমানো হয়েছে ওভারফ্লো এড়াতে
                                vertical: 6,
                              ),
                              child: Text(
                                "৳${cartController.totalPrice.toInt()}", 
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                Expanded(
                  flex: 2,
                  child: IconButton(
                    onPressed: () => Get.toNamed("/"),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.home_rounded,
                      color: primaryPurple,
                      size: 30,
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
                      size: 26,
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
                      size: 26,
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