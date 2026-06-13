import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/category/category_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';

class AllCategoriesPage extends StatefulWidget {
   const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final controller = Get.put(CategoryController());
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    controller.loadMainCategories(); // শুধু main categories
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Categories")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final category = controller.categories[index];

            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.subCategory,
                  arguments: category,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      category.image,
                      fit: BoxFit.cover,
                    ),

                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          

        );
      }
      
      ),
      bottomNavigationBar: AppBottomNavBar(
      cartController: cartController,
        ),
      
    );
  }
}