import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/services/category_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/category/products_page.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';

class SubCategoryPage extends StatelessWidget {
  SubCategoryPage({super.key});

  final CategoryService service = CategoryService();
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    CategoryModel? category;
    String appBarTitle = "Sub Category";
    String categoryId = "";

    if (args != null) {
      if (args is CategoryModel) {
        category = args;
        appBarTitle = category.name;
        categoryId = category.id;
      } else if (args is Map) {
        appBarTitle = args["name"] ?? "Sub Category";
        categoryId = args["id"]?.toString() ?? "";
      }
    }

    // ৬টি লাইট ব্যাকগ্রাউন্ড কালার লুপ
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
        title: Text(
          appBarTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: categoryId.isEmpty
          ? const Center(child: Text("Invalid Category"))
          : FutureBuilder(
              future: service.getSubCategories(categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: AppLoader(),
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

                final List subCategories = snapshot.data as List;

                if (subCategories.isEmpty) {
                  return const Center(
                    child: Text("No Sub Categories Found"),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: subCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5, // রেসপনসিভ রেশিও
                  ),
                  itemBuilder: (context, index) {
                    final sub = subCategories[index];
                    final backgroundColor = bgColors[index % bgColors.length];

                    return GestureDetector(
                      onTap: () {
                        debugPrint("SUB => $sub");
                        Get.to(
                          () => ProductsPage(title: sub["name"] ?? '', products: const []),
                          arguments: sub,
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
                                      sub["name"] ?? "",
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
                                        sub["image"] ?? "",
                                        fit: BoxFit.contain, // 🟢 এর ফলে ইমেজের কোনো অংশ কাটবে না, পুরোপুরি আসবে
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
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
              },
            ),
      bottomNavigationBar: AppBottomNavBar(
        cartController: cartController,
      ),
    );
  }
}