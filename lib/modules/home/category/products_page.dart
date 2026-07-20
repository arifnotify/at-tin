import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'package:tin/modules/home/widgets/product_card.dart';

class ProductsPage extends StatelessWidget {
  ProductsPage({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<ProductModel> products;

  // হোম কন্ট্রোলার ব্যবহার করা হচ্ছে কারণ এখানেই মেইন ডাটা সোর্সটি রয়েছে
  final HomeController homeController = Get.find<HomeController>();
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    // arguments-এর ডাটা টাইপ নিরাপদে চেক করা হচ্ছে যেন ক্র্যাশ না করে
    String categoryName = title;
    String targetCategoryId = "";

    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        // যদি arguments একটি Map হয় (সাব-ক্যাটাগরি থেকে আসলে)
        final Map subCategory = Get.arguments;
        categoryName = subCategory["name"] ?? title;
        targetCategoryId = subCategory["_id"] ?? "";
      } else if (Get.arguments is ProductModel) {
        // যদি arguments সরাসরি একটি ProductModel অবজেক্ট হয় (ক্র্যাশ প্রতিরোধের মূল সমাধান)
        final ProductModel passedProduct = Get.arguments;
        if (passedProduct.category != null) {
          categoryName = passedProduct.category!["name"]?.toString() ?? title;
          targetCategoryId = passedProduct.category!["_id"]?.toString() ?? "";
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        // ১. নির্দিষ্ট ক্যাটাগরির প্রোডাক্ট ফিল্টার করা হচ্ছে
        final categoryProducts = homeController.products.where((p) {
          if (p.category == null) return false;
          final pCategoryId = p.category!["_id"]?.toString() ?? "";
          return pCategoryId == targetCategoryId;
        }).toList();

        // ২. ফিল্টার করা ক্যাটাগরি প্রোডাক্ট থেকে 'fresh' প্রোডাক্ট আলাদা করা হচ্ছে
        final freshProducts = categoryProducts
            .where((p) => (p.productType ?? "").toString().toLowerCase().trim() == "fresh")
            .toList();

        // ৩. ফিল্টার করা ক্যাটাগরি প্রোডাক্ট থেকে 'regular' প্রোডাক্ট আলাদা করা হচ্ছে
        final regularProducts = categoryProducts
            .where((p) => (p.productType ?? "").toString().toLowerCase().trim() == "regular")
            .toList();

        return Stack(
          children: [
            // ==========================================
            // PRODUCT LIST LAYER
            // ==========================================
            if (categoryProducts.isEmpty && !homeController.isLoading.value)
              const Center(
                child: Text(
                  "No Product Available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              RefreshIndicator(
                onRefresh: () => homeController.loadHomeData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      /// --- ১. FRESH PRODUCTS SECTION ---
                      if (freshProducts.isNotEmpty) ...[
                        const Text(
                          "Fresh Product",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        _buildProductGrid(freshProducts),
                        const SizedBox(height: 25),
                      ],

                      /// --- ২. REGULAR PRODUCTS SECTION ---
                      if (regularProducts.isNotEmpty) ...[
                        const Text(
                          "Regular Product",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        _buildProductGrid(regularProducts),
                        const SizedBox(height: 25),
                      ],

                      /// --- ব্যাকআপ: যদি প্রোডাক্ট থাকে কিন্তু টাইপ কোনোটার সাথেই না মেলে ---
                      if (freshProducts.isEmpty && regularProducts.isEmpty && categoryProducts.isNotEmpty) ...[
                        const Text(
                          "All Products",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        _buildProductGrid(categoryProducts),
                      ],
                    ],
                  ),
                ),
              ),

            // ==========================================
            // LOADER LAYER
            // ==========================================
            if (homeController.isLoading.value)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withOpacity(0.45),
                    child: const Center(
                      child: AppLoader(),
                    ),
                  ),
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

  /// প্রোডাক্টদের জন্য ৩-কলামের সুন্দর গ্রিড উইজেট
  Widget _buildProductGrid(List<ProductModel> productList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 0.50,
      ),
      itemBuilder: (context, index) {
        return ProductCard(
          product: productList[index],
        );
      },
    );
  }
}