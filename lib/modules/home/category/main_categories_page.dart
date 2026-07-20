import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/category/category_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';

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
    // হোম পেজের মতো ৬টি সুন্দর হালকা কালার প্যালেট (লুপ হবে)
    final List<Color> bgColors = [
      const Color(0xFFE8F5E9), // হালকা সবুজ
      const Color(0xFFE3F2FD), // হালকা নীল
      const Color(0xFFFFF3E0), // হালকা কমলা
      const Color(0xFFF3E5F5), // হালকা বেগুনি
      const Color(0xFFE0F2F1), // হালকা টিল
      const Color(0xFFFCE4EC), // হালকা গোলাপি
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
        if (controller.isLoading.value) {
          return const Center(
            child: AppLoader(),
          );
        }

        if (controller.categories.isEmpty) {
          return const Center(
            child: Text(
              "No Categories Found",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: controller.categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5, // অন্য পেজগুলোর সাথে সামঞ্জস্যপূর্ণ রেসপনসিভ রেশিও
          ),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final backgroundColor = bgColors[index % bgColors.length];

            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.subCategory,
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
                        // 🟢 ১. নাম সেকশন (বামের অর্ধেক জায়গা জুড়ে ৪৬% উইডথ)
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          width: constraints.maxWidth * 0.46,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              category.name,
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

                        // 🟢 ২. ইমেজ সেকশন (ডানের অর্ধেক জায়গা জুড়ে - BoxFit.contain)
                        Positioned(
                          right: 4, // হালকা সেফ প্যাডিং যেন কোণায় লেগে না যায়
                          top: 4,
                          bottom: 4,
                          width: constraints.maxWidth * 0.48, // ডানের পুরো অর্ধেক স্পেস
                          child: Container(
                            alignment: Alignment.centerRight, // ডান পাশে এলাইন করে রাখবে
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                category.image,
                                fit: BoxFit.contain, // 🟢 এর ফলে ইমেজের কোনো অংশ কাটবে না, পুরোপুরি আসবে
                                errorBuilder: (_, __, ___) => Container(
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