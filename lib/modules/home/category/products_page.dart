import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/category_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/product_card.dart';

class ProductsPage extends StatelessWidget {
  //ProductsPage({super.key});

  final CategoryService service = CategoryService();
  final CartController cartController = Get.find<CartController>();
    final String title;

  final List<ProductModel>
      products;
 ProductsPage({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final subCategory = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          subCategory["name"] ?? "",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No Products Found"),
            );
          }

          final products = snapshot.data as List;

          if (products.isEmpty) {
            return const Center(
              child: Text("No Products Found"),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            itemCount: products.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 18,
              childAspectRatio: 0.52,
            ),
            itemBuilder: (context, index) {
              final json = products[index];
              print("🔍 Product $index: $json"); // এখানে productType আছে কিনা দেখুন

              final product = ProductModel.fromJson(json);
              print("Product Type: ${product.productType}");
              print("freshText = ${product.freshText}");
              print("expiryText = ${product.expiryText}");

              return ProductCard(product: product);
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
      cartController: cartController,
        ),
    );
  }
}