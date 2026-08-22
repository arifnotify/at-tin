import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/category_model.dart';
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

  final HomeController homeController = Get.find<HomeController>();
  final CartController cartController = Get.find<CartController>();
  final LanguageController langController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    String targetCategoryId = "";
    dynamic categoryNameSource = title;

    // ১. আর্গুমেন্ট হ্যান্ডলিং
    final dynamic args = Get.arguments;

    if (args != null) {
      if (args is CategoryModel) {
        categoryNameSource = args.name;
        targetCategoryId = args.id;
      } else if (args is Map) {
        categoryNameSource = args["name"] ?? title;
        targetCategoryId = (args["_id"] ?? args["id"])?.toString() ?? "";
      } else if (args is ProductModel) {
        if (args.category != null) {
          categoryNameSource = args.category!["name"] ?? title;
          targetCategoryId = (args.category!["_id"] ?? args.category!["id"])?.toString() ?? "";
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        // 🟢 সঠিক নিয়মে Obx এর ভেতর .value কল করা হয়েছে
        title: Obx(() {
          final currentLang = langController.currentLanguage.value; // 👈 এখানে সরাসরি .value কল করা বাধ্যতামূলক
          String displayName = title;

          if (categoryNameSource is Map) {
            displayName = categoryNameSource[currentLang]?.toString() ?? categoryNameSource['en']?.toString() ?? title;
          } else {
            displayName = categoryNameSource.toString();
          }

          return Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ),
      body: Obx(() {
        // 🟢 ২. ডাটা ফেচিং অবস্থা
        if (homeController.isLoading.value) {
          return const Center(
            child: AppLoader(),
          );
        }

        List<ProductModel> displayProducts = products;

        if (targetCategoryId.isNotEmpty) {
          displayProducts = homeController.products.where((p) {
            if (p.category == null) return false;
            final pCategoryId = (p.category!["_id"] ?? p.category!["id"])?.toString() ?? "";
            return pCategoryId == targetCategoryId;
          }).toList();
        }

        // 🟢 ৩. প্রোডাক্ট না থাকলে মেসেজ (এখানেও ভাষা চেক করার জন্য .value ব্যবহার করা হয়েছে)
        if (displayProducts.isEmpty) {
          final bool isBn = langController.currentLanguage.value == 'bn';
          return Center(
            child: Text(
              isBn ? "কোনো প্রোডাক্ট উপলব্ধ নেই" : "No Product Available",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          );
        }

        // 🟢 ৪. প্রোডাক্ট গ্রিড রেন্ডার
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: _buildProductGrid(displayProducts),
        );
      }),
      bottomNavigationBar: AppBottomNavBar(
        cartController: cartController,
      ),
    );
  }

  /// ৩-কলামের প্রোডাক্ট গ্রিড উইজেট
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