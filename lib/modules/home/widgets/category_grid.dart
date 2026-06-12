import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

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
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
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
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        TextButton(
          onPressed: onAllCategoriesPressed,
          child: const Text("All Categories"),
        ),
      ],
    );
  }
}