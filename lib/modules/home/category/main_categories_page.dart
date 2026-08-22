import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/category/category_controller.dart';
import 'package:tin/modules/home/category/sub_category.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';

class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  final CategoryController controller = Get.isRegistered<CategoryController>()
      ? Get.find<CategoryController>()
      : Get.put(CategoryController());

  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    controller.fetchAllCategoriesAndSubCategories();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> bgColors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFFFF3E0),
      const Color(0xFFF3E5F5),
      const Color(0xFFE0F2F1),
      const Color(0xFFFCE4EC),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "All Categories",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(
            child: Text(
              "No Categories Found",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: controller.categories.length,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final backgroundColor = bgColors[index % bgColors.length];

            return GestureDetector(
              onTap: () {
                // মেইন ক্যাটাগরিতে ক্লিক করলে SubCategoryPage-এ যাবে এবং ডাটা পাস করবে
                Get.to(
                  () => const SubCategoryPage(),
                  arguments: category,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          width: constraints.maxWidth * 0.46,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              category.localizedName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2D2D2D),
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          bottom: 4,
                          width: constraints.maxWidth * 0.48,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: category.image,
                                fit: BoxFit.contain,
                                memCacheWidth: 200,
                                memCacheHeight: 200,
                                fadeInDuration: const Duration(milliseconds: 300),
                                placeholder: (context, url) => Container(
                                  color: Colors.transparent,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: AppBottomNavBar(
        cartController: cartController,
      ),
    );
  }
}