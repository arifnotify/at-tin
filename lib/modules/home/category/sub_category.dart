import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/services/category_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/category/products_page.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';

class SubCategoryPage extends StatelessWidget {
  SubCategoryPage({super.key});

  final CategoryService service = CategoryService();
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    final CategoryModel category =
        Get.arguments as CategoryModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: FutureBuilder(
        future: service.getSubCategories(category.id),
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
                "Error: ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No Data Found"),
            );
          }

          final List subCategories =
              snapshot.data as List;

          if (subCategories.isEmpty) {
            return const Center(
              child: Text("No Sub Categories Found"),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: subCategories.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final sub = subCategories[index];

                return GestureDetector(
                  onTap: () {
                      print("SUB => $sub");

                      Get.to(
                        () => ProductsPage(title: '', products: [],),
                        arguments: sub,
                      );
                    },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              sub["image"] ?? "",
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                );
                              },
                            ),
                          ),

                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin:
                                      Alignment.topCenter,
                                  end:
                                      Alignment.bottomCenter,
                                  colors: [
                                    Colors.black
                                        .withOpacity(0.1),
                                    Colors.black
                                        .withOpacity(0.5),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 12,
                            bottom: 12,
                            right: 12,
                            child: Text(
                              sub["name"] ?? "",
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
      cartController: cartController,
        ),
    );
  }
}