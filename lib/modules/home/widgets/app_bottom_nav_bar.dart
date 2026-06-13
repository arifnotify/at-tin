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
    return Obx(
      () => Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            /// Checkout Button
            if (cartController.totalItems > 0)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.cart);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Checkout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "৳${cartController.totalPrice} (${cartController.totalItems})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            /// Home
            Expanded(
              child: IconButton(
                onPressed: () => Get.toNamed("/"),
                icon: const Icon(Icons.home),
              ),
            ),

            /// Category
            Expanded(
              child: IconButton(
                onPressed: () => Get.toNamed(AppRoutes.allCategories),
                icon: const Icon(Icons.grid_view),
              ),
            ),

            /// Search
                        /// Search
            Expanded(
              child: IconButton(
                tooltip: "Search",
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.search,
                  );
                },
                icon: const Icon(
                  Icons.search,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}