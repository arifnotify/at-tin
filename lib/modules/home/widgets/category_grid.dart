import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart'; // 👈 আপনার LanguageController ইমপোর্ট নিশ্চিত করুন
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/models/category_model.dart';

class CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final VoidCallback? onAllCategoriesPressed;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.onAllCategoriesPressed,
  });

  @override
  Widget build(BuildContext context) {
    // LanguageController ইনস্ট্যান্স নেওয়া
    final LanguageController langController = Get.find<LanguageController>();

    // ৬টি ভিন্ন কালার প্যালেট
    final List<Color> bgColors = [
      const Color(0xFFE8F5E9), // হালকা সবুজ (Grocery)
      const Color(0xFFE3F2FD), // হালকা নীল (Pharmacy)
      const Color(0xFFFFF3E0), // হালকা কমলা (Food)
      const Color(0xFFF3E5F5), // হালকা বেগুনি (Cleaning)
      const Color(0xFFE0F2F1), // হালকা টিল (Home & Kitchen)
      const Color(0xFFFCE4EC), // হালকা গোলাপি (Fashion)
    ];

    if (categories.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length > 6 ? 6 : categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5, // রেসপনসিভ রেশিও
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
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
                        // 🟢 ১. নাম সেকশন (বাংলা/ইংরেজি ভাষা পরিবর্তনের জন্য localizedName)
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
                        
                        // 🟢 ২. ইমেজ সেকশন
                        Positioned(
                          right: 4,
                          top: 4,
                          bottom: 4,
                          width: constraints.maxWidth * 0.48,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                category.image,
                                fit: BoxFit.contain,
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
        ),
        
        const SizedBox(height: 16),
        
        // 🟢 ৩. All Categories বাটন (Obx দিয়ে র‍্যাপ করা হয়েছে যাতে ভাষা পরিবর্তন করলে এটিও সাথে সাথে বদলায়)
        Center(
          child: Obx(() => TextButton(
                onPressed: onAllCategoriesPressed ?? () => Get.toNamed(AppRoutes.allCategories),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                ),
                child: Text(
                  langController.isBangla ? "সব ক্যাটাগরি" : "All Categories",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        ),
      ],
    );
  }
}