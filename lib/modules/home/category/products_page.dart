import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/category_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/product_card.dart';

class ProductsPage extends StatelessWidget {
  ProductsPage({
    super.key,
    required this.title,
    required this.products,
  });

  final String title;
  final List<ProductModel> products;

  final CategoryService service = CategoryService();
  final CartController cartController =
      Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    final subCategory = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          subCategory["name"] ?? title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      /// BODY
      body: FutureBuilder(
        future: service.getProductsByCategory(
          subCategory["_id"],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData ||
              (snapshot.data as List).isEmpty) {
            return const Center(
              child: Text("No Products Found"),
            );
          }

          final products =
              snapshot.data as List;

          /// GRID VIEW (FIXED 3 COLUMN SAFE)
          return GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
            itemCount: products.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.50,
            ),
            itemBuilder: (context, index) {
              final product =
                  ProductModel.fromJson(
                products[index],
              );

              return ProductCard(
                product: product,
              );
            },
          );
        },
      ),

      /// BOTTOM NAV
      bottomNavigationBar: AppBottomNavBar(
        cartController: cartController,
      ),
    );
  }
}